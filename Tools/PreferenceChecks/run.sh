#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/attunetion-preferences.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
# Exercise the actual Settings save and new-draft load/creation bodies without
# starting SwiftUI, notifications, widgets, CloudKit, or the real app store.
python3 - "$check_dir/PreferenceConsumers.swift" <<'PY'
from pathlib import Path
import sys

def method(source, name):
    start = source.index('    private func ' + name)
    opening = source.index('{', start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return source[start:end].replace('private func ', 'func ', 1)

settings = Path('Attunetion/Views/Settings/SettingsView.swift').read_text()
new = Path('Attunetion/Views/Main/NewIntentionView.swift').read_text()
start = new.index('        let newIntention = Intention(')
end = new.index('\n        \n        do {', start)
creation = new[start:end] + '\n        return newIntention\n'
start = settings.index('@MainActor\nenum LocalUserDataDeletion {')
end = settings.index('\n\nstruct DefaultThemePickerView:', start)
deletion = settings[start:end]
Path(sys.argv[1]).write_text('''import Foundation
import SwiftData

@MainActor final class PreferenceSelection {
    let modelContext: ModelContext
    var preferences: UserPreferences? {
        UserPreferencesRepository(modelContext: modelContext).getPreferences()
    }
    var preferenceSaveError: String?
    init(_ context: ModelContext) { modelContext = context }
''' + method(settings, 'saveDefaultTheme') + '\n' + method(settings, 'saveDefaultFont') + '''
}

@MainActor final class NewDraft {
    let modelContext: ModelContext
    var hasLoadedAppearanceDefaults = false
    var selectedTheme: IntentionTheme?
    var selectedFont: String?
    init(_ context: ModelContext) { modelContext = context }
''' + method(new, 'loadAppearanceDefaults') + '''
    func makeIntention() -> Intention {
        let trimmedText = "Synthetic next intention"
        let selectedScope = IntentionScope.day
        let selectedDate = Date()
''' + creation + '''
    }
}
''' + deletion)
PY
xcrun swiftc -parse-as-library -swift-version 5 -default-isolation MainActor \
  Attunetion/Models/Intention.swift \
  Attunetion/Models/IntentionTheme.swift \
  Attunetion/Models/PresetThemes.swift \
  Attunetion/Models/UserPreferences.swift \
  Attunetion/Models/UserProfile.swift \
  Attunetion/Models/IntentionFeedback.swift \
  Attunetion/Services/ThemeRepository.swift \
  Attunetion/Services/UserPreferencesRepository.swift \
  Attunetion/Services/WidgetDataService.swift \
  "$check_dir/PreferenceConsumers.swift" \
  Tools/PreferenceChecks/main.swift -o "$check_dir/check"
for stage in write read clear verify-clear post-delete-theme verify-theme-and-delete-font verify-font-and-delete-nil verify-nil-and-fail verify-no-row; do
  "$check_dir/check" "$check_dir" "$stage"
done
