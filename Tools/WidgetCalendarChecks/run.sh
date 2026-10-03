#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-widget-calendar.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
xcrun swiftc IntentionWidget/WidgetRefreshSchedule.swift Tools/WidgetCalendarChecks/main.swift -o "$check_dir/checks"
"$check_dir/checks"
