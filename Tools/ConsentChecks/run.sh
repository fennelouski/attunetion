#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-consent.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
history_source=${1:-Attunetion/Services/AutoIntentionService.swift}
python3 - "$history_source" "$check_dir/WeeklyHistory.swift" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1]).read_text()
start = '        let previousIntentions = '
end = '\n        // Call API to generate intentions'
assert source.count(start) == 1 and source.count(end) == 1, 'History projection must be unique'
body = source[source.index(start):source.index(end)].rstrip()
Path(sys.argv[2]).write_text('import Foundation\n\n@MainActor\nfunc weeklyHistoryForConsentCheck(from allIntentions: [Intention]) -> [PreviousIntentionForGeneration] {\n' + body + '\n    return previousIntentions\n}\n')
PY
xcrun swiftc -parse-as-library -swift-version 5 \
  Attunetion/Services/IntentionPeriod.swift \
  Attunetion/Models/Intention.swift \
  Attunetion/Models/UserProfile.swift \
  Attunetion/Services/UserProfileRepository.swift \
  Attunetion/Services/ConsentManager.swift \
  Attunetion/Services/APIClient.swift \
  "$check_dir/WeeklyHistory.swift" \
  Tools/ConsentChecks/main.swift -o "$check_dir/check"
"$check_dir/check"
