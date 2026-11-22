#!/bin/bash
set -euo pipefail
# The website repository owns the branded subdomain release.
root="$(git rev-parse --show-toplevel)"
website="${ATTUNETION_WEBSITE_REPO:-$root/../nathanfennel.com}"
if [[ ! -f "$website/scripts/deploy-attunetion.sh" ]]; then
  echo "Set ATTUNETION_WEBSITE_REPO to the nathanfennel.com checkout containing scripts/deploy-attunetion.sh." >&2
  exit 1
fi
cd "$website"
exec npm run deploy:attunetion
