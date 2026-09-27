#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-deletion.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
# Compile the actual helper without starting SwiftUI, the app, or its real store.
python3 - "$check_dir/LocalUserDataDeletion.swift" <<'PY'
from pathlib import Path
import sys
source = Path('Attunetion/Views/Settings/SettingsView.swift').read_text()
start = source.index('@MainActor\nenum LocalUserDataDeletion {')
end = source.index('\n\nstruct DefaultThemePickerView:', start)
Path(sys.argv[1]).write_text('import Foundation\nimport SwiftData\n' + source[start:end])
PY
xcrun swiftc -parse-as-library -swift-version 5 \
  Attunetion/Models/Intention.swift \
  Attunetion/Models/IntentionTheme.swift \
  Attunetion/Models/UserProfile.swift \
  Attunetion/Models/UserPreferences.swift \
  Attunetion/Models/IntentionFeedback.swift \
  "$check_dir/LocalUserDataDeletion.swift" \
  Tools/DeletionChecks/main.swift -o "$check_dir/check"
"$check_dir/check" "$check_dir"
