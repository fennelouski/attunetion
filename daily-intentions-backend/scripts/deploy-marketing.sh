#!/bin/bash
set -euo pipefail
: "${CERTIFICATE_ARN:?Set CERTIFICATE_ARN to the issued us-east-1 ACM certificate for the site}"
root="$(git rev-parse --show-toplevel)"
revision="$(git rev-parse HEAD)"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
cd "$root"
git archive "$revision" daily-intentions-backend/public daily-intentions-backend/aws/marketing.yaml | tar -x -C "$stage"
site="$stage/daily-intentions-backend/public"
# Reveal the download control once the product exists in the release storefront.
python3 - "$site/index.html" "${STORE_COUNTRY:-us}" <<'PYTHON'
import json, pathlib, sys, urllib.parse, urllib.request
page = pathlib.Path(sys.argv[1])
query = urllib.parse.urlencode({"id": "6757886472", "country": sys.argv[2]})
with urllib.request.urlopen("https://itunes.apple.com/lookup?" + query, timeout=20) as response:
    listed = any(item.get("trackId") == 6757886472 for item in json.load(response)["results"])
if listed:
    page.write_text(page.read_text().replace('class="cta-button" hidden', 'class="cta-button"'))
PYTHON
stack=attunetion-public-site
aws cloudformation deploy --region us-east-1 --stack-name "$stack" \
  --template-file "$stage/daily-intentions-backend/aws/marketing.yaml" \
  --parameter-overrides "CertificateArn=$CERTIFICATE_ARN" --no-fail-on-empty-changeset
output() {
  aws cloudformation describe-stacks --region us-east-1 --stack-name "$stack" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue | [0]" --output text
}
aws s3 sync "$site/" "s3://$(output BucketName)/" --region us-east-1 --cache-control 'public,max-age=300'
distribution="$(output DistributionId)"
invalidation="$(aws cloudfront create-invalidation --distribution-id "$distribution" --paths '/*' --query Invalidation.Id --output text)"
aws cloudfront wait invalidation-completed --distribution-id "$distribution" --id "$invalidation"
domain="$(output DomainName)"
for page in index.html support.html legal/privacy-policy.html legal/eula.html legal/terms-of-service.html; do
  curl -fsS "https://$domain/$page" | cmp - "$site/$page"
done
echo "Verified $revision at https://$domain/"
