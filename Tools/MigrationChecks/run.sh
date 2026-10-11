#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-migration.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
xcrun swiftc -parse-as-library -swift-version 5 -module-name AttunetionModelChecks -D LEGACY \
  Tools/MigrationChecks/LegacyModels.swift Attunetion/Services/IntentionPeriod.swift \
  Tools/MigrationChecks/main.swift -o "$check_dir/legacy"
"$check_dir/legacy" "$check_dir"
xcrun swiftc -parse-as-library -swift-version 5 -module-name AttunetionModelChecks \
  Attunetion/AttunetionSchema.swift Attunetion/Services/IntentionPeriod.swift \
  Attunetion/Models/Intention.swift Attunetion/Models/IntentionTheme.swift \
  Attunetion/Models/UserPreferences.swift Attunetion/Models/UserProfile.swift \
  Attunetion/Models/IntentionFeedback.swift Tools/MigrationChecks/main.swift -o "$check_dir/current"
"$check_dir/current" "$check_dir"
"$check_dir/current" "$check_dir" verify-new-fields
