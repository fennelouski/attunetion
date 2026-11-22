#!/bin/bash
set -euo pipefail
test "$(aws sts get-caller-identity --query Account --output text)" = 074861507225
root="$(git rev-parse --show-toplevel)"
rev="$(git rev-parse HEAD)"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
git -C "$root" archive "$rev" daily-intentions-backend | tar -x -C "$stage"
cd "$stage/daily-intentions-backend"
npm ci --no-audit --no-fund >/dev/null
npm test
node_modules/.bin/esbuild aws/production.mjs --bundle --platform=node --target=node24 --format=cjs --external:@aws-sdk/client-dynamodb --outfile="$stage/index.js"
(cd "$stage" && touch -t 202601010000 index.js && zip -Xq code.zip index.js)
hash="$(shasum -a 256 "$stage/code.zip" | cut -d' ' -f1)"
key="attunetion/releases/$rev/$hash.zip"
aws s3 cp "$stage/code.zip" "s3://nfbucketforstuff/$key" --region us-west-2 --only-show-errors
version="$(aws secretsmanager list-secret-version-ids --secret-id attunetion/website-openai --region us-west-2 --query 'Versions[?contains(VersionStages, `AWSCURRENT`)].VersionId | [0]' --output text)"
aws cloudformation deploy --stack-name attunetion-production-api --region us-west-2 --template-file aws/production.yaml --capabilities CAPABILITY_IAM --parameter-overrides "CodeKey=$key" "Revision=$rev" "SecretVersion=$version" --no-fail-on-empty-changeset
url="$(aws cloudformation describe-stacks --stack-name attunetion-production-api --region us-west-2 --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue | [0]" --output text)"
curl -fsS "$url/api/health" | python3 -c 'import json,sys;assert json.load(sys.stdin)["revision"] == sys.argv[1]' "$rev"
echo "Verified $rev at $url"
