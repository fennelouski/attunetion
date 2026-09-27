#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-flow.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
python3 - "$check_dir/IntentionLink.swift" <<'PY'
from pathlib import Path
import sys
source = Path('Attunetion/Views/Main/IntentionsListView.swift').read_text()
Path(sys.argv[1]).write_text('import Foundation\n' + source[source.index('enum IntentionLink: Equatable {'):])
PY
xcrun swiftc -parse-as-library -swift-version 5 \
    Attunetion/Models/Intention.swift Attunetion/Services/IntentionRepository.swift \
    "$check_dir/IntentionLink.swift" Tools/FlowChecks/main.swift -o "$check_dir/check"
"$check_dir/check" "$check_dir"
