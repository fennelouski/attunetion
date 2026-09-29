#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-reminders.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
xcrun swiftc -parse-as-library -swift-version 5 \
  Attunetion/Models/UserPreferences.swift \
  Attunetion/Services/NotificationManager.swift \
  Tools/ReminderChecks/main.swift -o "$check_dir/check"
"$check_dir/check"
