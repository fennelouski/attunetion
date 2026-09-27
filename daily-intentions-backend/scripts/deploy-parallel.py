#!/usr/bin/env python3
"""Build on this computer and deploy one committed revision to both hosts."""
import argparse
from datetime import datetime, timezone
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile

BACKEND = Path(__file__).resolve().parent.parent
REPO = BACKEND.parent
PROJECT = 'prj_tHzqeLxYTZ1n2y1HFbPzIpCn5Kfy'
TEAM = 'team_4XxwBQjEz3krxaqWiyyw7O0d'
ACCOUNT = '074861507225'
CUTOFF = datetime(2026, 10, 22, 7, tzinfo=timezone.utc)


def output(command, **kwargs):
    return subprocess.check_output(command, text=True, **kwargs).strip()


def check_release():
    if datetime.now(timezone.utc) >= CUTOFF:
        raise RuntimeError('Parallel-deployment cutoff reached. Check actual cutover state; do not use this command after cutover.')
    if output(['git', 'diff', 'HEAD', '--name-only'], cwd=REPO):
        raise RuntimeError('Commit integrated source changes before deployment.')
    if output(['git', 'ls-files', '--others', '--exclude-standard', 'daily-intentions-backend'], cwd=REPO):
        raise RuntimeError('Uncommitted backend files must be reviewed before deployment.')
    remote = output(['git', 'remote', 'get-url', 'origin'], cwd=REPO)
    if remote not in ('https://github.com/fennelouski/attunetion.git', 'git@github.com:fennelouski/attunetion.git'):
        raise RuntimeError('Unexpected repository.')
    return output(['git', 'rev-parse', 'HEAD'], cwd=REPO)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--profile', default='fishbowl-head')
    parser.add_argument('--vercel-cli', default=shutil.which('vercel'))
    args = parser.parse_args()
    revision = check_release()
    if not args.vercel_cli:
        raise RuntimeError('Install the supported Vercel CLI first.')
    credentials = json.loads(output(['aws', 'configure', 'export-credentials', '--profile', args.profile, '--format', 'process']))
    env = dict(os.environ)
    env.pop('AWS_PROFILE', None)
    env.update(AWS_ACCESS_KEY_ID=credentials['AccessKeyId'], AWS_SECRET_ACCESS_KEY=credentials['SecretAccessKey'],
               AWS_REGION='us-west-2', AWS_DEFAULT_REGION='us-west-2', SOURCE_COMMIT=revision,
               VERCEL_PROJECT_ID=PROJECT, VERCEL_ORG_ID=TEAM)
    if credentials.get('SessionToken'):
        env['AWS_SESSION_TOKEN'] = credentials['SessionToken']
    else:
        env.pop('AWS_SESSION_TOKEN', None)
    identity = json.loads(output(['aws', 'sts', 'get-caller-identity', '--output', 'json'], env=env))
    if identity['Account'] != ACCOUNT:
        raise RuntimeError('Unexpected AWS account.')
    subprocess.run(['npm', 'test'], cwd=BACKEND, env=env, check=True)
    # A private, ignored staging tree excludes all local edits and Xcode user state.
    staging = BACKEND / '.deploy' / revision
    if staging.exists():
        shutil.rmtree(staging)
    staging.mkdir(parents=True, mode=0o700)
    archive = subprocess.check_output(['git', 'archive', revision], cwd=REPO)
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        tar.extractall(staging)
    secret_file = staging / '.vercel' / '.env.production.local'
    try:
        subprocess.run([args.vercel_cli, 'pull', '--yes', '--environment', 'production', '--project', PROJECT, '--scope', TEAM], cwd=staging, env=env, check=True)
        secret_file.chmod(0o600)
        # Parse inside a child process; credential values never appear in tool output.
        secret_env = json.loads(output(['node', '--input-type=module', '-e', 'import {parseEnv} from "node:util";import {readFileSync} from "node:fs";process.stdout.write(JSON.stringify(parseEnv(readFileSync(process.argv[1],"utf8"))));', str(secret_file)]))
        key = secret_env.get('OPENAI_API_KEY')
        if not key:
            raise RuntimeError('Existing production provider key is absent; refusing to invent a credential.')
        if secret_env.get('API_SECRET_KEY'):
            raise RuntimeError('Production API authentication changed. Reconcile AWS parity before release.')
        # SST stores this as encrypted deployment state; pass via stdin, never argv.
        subprocess.run(['npx', '--no-install', 'sst', 'secret', 'set', 'OpenAIAPIKey', '--stage', 'parallel'], input=key, text=True, cwd=BACKEND, env=env, check=True, stdout=subprocess.DEVNULL)
        secret_env.clear()
        key = None
        subprocess.run([args.vercel_cli, 'build', '--prod', '--yes'], cwd=staging, env=env, check=True)
        # Deploy the protected parity service first. No native app points at it.
        subprocess.run(['npm', 'run', 'deploy:aws'], cwd=BACKEND, env=env, check=True)
        result = output([args.vercel_cli, 'deploy', '--prebuilt', '--prod', '--yes', '--meta', f'sourceCommit={revision}', '--env', f'SOURCE_COMMIT={revision}'], cwd=staging, env=env)
        record = {'revision': revision, 'deployedAt': datetime.now(timezone.utc).isoformat(), 'mode': 'parallel',
                  'vercelDeployment': result.splitlines()[-1], 'aws': json.loads((BACKEND / '.sst/outputs.json').read_text()),
                  'verification': 'Required: signed AWS and production Vercel live smoke checks. Deployment alone is not verified parity.'}
        (BACKEND / '.deploy/deployed.json').write_text(json.dumps(record, indent=2) + '\n')
        print(json.dumps(record, indent=2))
    finally:
        # Vercel pull prints variable names only. Always remove pulled values and build caches, even on failure.
        secret_file.unlink(missing_ok=True)
        shutil.rmtree(staging, ignore_errors=True)



if __name__ == '__main__':
    main()
