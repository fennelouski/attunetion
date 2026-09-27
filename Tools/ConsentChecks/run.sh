#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-consent.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
xcrun swiftc -parse-as-library -swift-version 5 \
  Attunetion/Models/UserProfile.swift \
  Attunetion/Services/UserProfileRepository.swift \
  Attunetion/Services/ConsentManager.swift \
  Attunetion/Services/APIClient.swift \
  Tools/ConsentChecks/main.swift -o "$check_dir/check"
"$check_dir/check"
