#!/usr/bin/env python3
"""Verify native routes without sending personal data; four bounded AI calls total."""
import argparse
from datetime import datetime, timezone, timedelta
import hashlib
import hmac
import json
from pathlib import Path
import re
import subprocess
from urllib.error import HTTPError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


def signed_headers(url, method, body, credentials):
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    day = stamp[:8]
    parsed = urlsplit(url)
    headers = {'host': parsed.netloc, 'x-amz-date': stamp, 'content-type': 'application/json'}
    if credentials.get('SessionToken'):
        headers['x-amz-security-token'] = credentials['SessionToken']
    names = ';'.join(sorted(headers))
    canonical_headers = ''.join(f'{key}:{headers[key]}\n' for key in sorted(headers))
    canonical = '\n'.join([method, parsed.path or '/', parsed.query, canonical_headers, names, hashlib.sha256(body).hexdigest()])
    scope = f'{day}/us-west-2/lambda/aws4_request'
    to_sign = '\n'.join(['AWS4-HMAC-SHA256', stamp, scope, hashlib.sha256(canonical.encode()).hexdigest()])
    def digest(key, value): return hmac.new(key, value.encode(), hashlib.sha256).digest()
    key = digest(('AWS4' + credentials['SecretAccessKey']).encode(), day)
    for value in ['us-west-2', 'lambda', 'aws4_request']:
        key = digest(key, value)
    signature = hmac.new(key, to_sign.encode(), hashlib.sha256).hexdigest()
    headers['Authorization'] = f"AWS4-HMAC-SHA256 Credential={credentials['AccessKeyId']}/{scope}, SignedHeaders={names}, Signature={signature}"
    return headers


def request(url, method='GET', body=None, credentials=None):
    payload = body.encode() if body is not None else b''
    headers = signed_headers(url, method, payload, credentials) if credentials else {'Content-Type': 'application/json'}
    req = Request(url, method=method, data=payload if method != 'GET' else None, headers=headers)
    try:
        response = urlopen(req, timeout=65)
    except HTTPError as error:
        response = error
    data = response.read().decode()
    return {'status': response.status, 'body': data, 'finalUrl': response.url}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--aws-url', required=True)
    parser.add_argument('--vercel-url', default='https://attunetion.vercel.app')
    parser.add_argument('--revision', required=True)
    parser.add_argument('--profile', default='fishbowl-head')
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    credentials = json.loads(subprocess.check_output(['aws', 'configure', 'export-credentials', '--profile', args.profile, '--format', 'process'], text=True))
    record = {'revision': args.revision, 'checkedAt': datetime.now(timezone.utc).isoformat(), 'hosts': {}, 'syntheticAIRequests': 0}
    anonymous = request(args.aws_url.rstrip('/') + '/api/health')
    assert anonymous['status'] == 403, 'AWS parity endpoint must reject anonymous callers'
    record['awsUnsignedStatus'] = anonymous['status']
    for name, base, auth in [('aws', args.aws_url, credentials), ('vercel', args.vercel_url, None)]:
        base = base.rstrip('/')
        health = request(base + '/api/health', credentials=auth)
        assert health['status'] == 200, (name, 'health', health['status'])
        assert json.loads(health['body'])['revision'] == args.revision, (name, 'revision mismatch')
        invalid = request(base + '/api/ai/generate-theme', 'POST', 'null', auth)
        assert invalid['status'] == 400, (name, 'validation', invalid['status'])
        overlong = request(base + '/api/ai/generate-theme', 'POST', json.dumps({'intentionText': 'x' * 2001}), auth)
        assert overlong['status'] == 400, (name, 'input bound', overlong['status'])
        theme = request(base + '/api/ai/generate-theme', 'POST', json.dumps({'intentionText': 'Approach today with patient attention'}), auth)
        record['syntheticAIRequests'] += 1
        assert theme['status'] == 200, (name, 'AI', theme['status'])
        value = json.loads(theme['body'])['theme']
        assert all(re.fullmatch(r'#[0-9a-fA-F]{6}', value[key]) for key in ['backgroundColor', 'textColor', 'accentColor'])
        assert all(isinstance(value[key], str) and value[key] for key in ['name', 'reasoning'])
        week_start = datetime(2026, 9, 28, tzinfo=timezone.utc)
        weekly = request(base + '/api/ai/generate-weekly-intentions', 'POST', json.dumps({'userInfo': 'Synthetic test profile: enjoys walking, reading, and patient attention.', 'weekStartDate': '2026-09-28', 'previousIntentions': []}), auth)
        record['syntheticAIRequests'] += 1
        assert weekly['status'] == 200, (name, 'weekly AI', weekly['status'])
        schedule = json.loads(weekly['body'])
        intentions = schedule['intentions']
        assert len(intentions) == 9
        assert {scope: sum(item['scope'] == scope for item in intentions) for scope in ['day', 'week', 'month']} == {'day': 7, 'week': 1, 'month': 1}
        assert all(isinstance(item['text'], str) and item['text'].strip() for item in intentions)
        for item in intentions:
            assert datetime.strptime(item['date'], '%Y-%m-%d').strftime('%Y-%m-%d') == item['date']
        assert {item['date'] for item in intentions if item['scope'] == 'day'} == {(week_start + timedelta(days=i)).strftime('%Y-%m-%d') for i in range(7)}
        assert schedule['weekStartDate'] == '2026-09-28' and schedule['weekEndDate'] == '2026-10-04'
        record['hosts'][name] = {'url': base, 'health': health, 'invalidBodyStatus': invalid['status'], 'overlongInputStatus': overlong['status'], 'syntheticTheme': theme, 'syntheticWeekly': weekly}
        Path(args.output).write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'checks': 'passed', 'output': args.output, 'syntheticAIRequests': record['syntheticAIRequests']}))


if __name__ == '__main__':
    main()
