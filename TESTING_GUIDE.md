# Testing Guide - Attunetion App

## ✅ Widget Target Membership - FIXED

**Status**: ✅ Fixed by creating `WidgetDataService.swift` in `IntentionWidget/` folder

The widget now has its own copy of `WidgetDataService` that can read from App Group UserDefaults. This avoids target membership issues since the widget target uses file system synchronization.

---

## 🧪 Testing Checklist

### TEST CATEGORY 1: Basic App Launch & Navigation

**Status**: ⏳ Pending manual testing

- [ ] App launches without crashing
- [ ] Onboarding shows on first launch (if no prior data)
- [ ] Can skip onboarding
- [ ] Can complete onboarding
- [ ] Main list view loads
- [ ] Can navigate to new intention screen
- [ ] Can navigate to settings
- [ ] Back navigation works

**How to Test**:
1. Build and run app in simulator
2. If onboarding shows, test both skip and complete flows
3. Navigate through all screens
4. Test back button/swipe gestures

---

### TEST CATEGORY 2: Intention CRUD Operations

**Status**: ⏳ Pending manual testing

- [ ] Create day intention with text "Test Day" → saves successfully
- [ ] Verify it appears in list
- [ ] Tap it → detail view opens
- [ ] Edit the intention text → changes save
- [ ] Create week intention → saves successfully
- [ ] Create month intention → saves successfully
- [ ] Delete an intention → removes from list
- [ ] Close and reopen app → intentions persist

**How to Test**:
1. Create intentions with different scopes
2. Verify they appear in the list
3. Test edit functionality
4. Test delete functionality
5. Force quit app (swipe up in simulator) and reopen
6. Verify data persists

---

### TEST CATEGORY 3: Intention Hierarchy (Critical Business Logic)

**Status**: ⏳ Pending manual testing

- [ ] Create only month intention → verify it shows as "current"
- [ ] Add week intention → verify week overrides month as "current"
- [ ] Add day intention → verify day overrides both
- [ ] Delete day → verify week becomes current
- [ ] Delete week → verify month becomes current
- [ ] Test with dates: future day intention doesn't show as current

**How to Test**:
1. Create month intention for current month
2. Verify it shows in "Current" card at top
3. Create week intention for current week
4. Verify week now shows as current (month should be in list below)
5. Create day intention for today
6. Verify day shows as current
7. Delete day → verify week becomes current
8. Delete week → verify month becomes current

**Expected Behavior**:
- Hierarchy: Day > Week > Month
- Only intentions for current period show as "current"
- Future intentions don't show as current

---

### TEST CATEGORY 4: Search & Filter

**Status**: ⏳ Pending manual testing

- [ ] Create 5+ intentions with different text
- [ ] Search for specific word → correct results show
- [ ] Clear search → all results return
- [ ] Filter by Day scope → only day intentions show
- [ ] Filter by Week scope → only week intentions show
- [ ] Filter by Month scope → only month intentions show
- [ ] Test "All" filter → all intentions show

**How to Test**:
1. Create multiple intentions with varied text (e.g., "Exercise", "Read", "Meditate", "Work", "Family")
2. Use search bar to search for "Exercise" → should show only matching intentions
3. Clear search → all intentions return
4. Use scope filter buttons → verify filtering works
5. Test combinations (search + filter)

---

### TEST CATEGORY 5: Themes & Styling

**Status**: ⏳ Pending manual testing

- [ ] Test Ocean theme → colors apply correctly
- [ ] Test Sunset theme → colors apply correctly
- [ ] Test Forest theme → colors apply correctly
- [ ] Test Minimal theme → colors apply correctly
- [ ] Test Midnight theme → colors apply correctly
- [ ] Change font → font applies correctly
- [ ] Theme persists after app restart

**How to Test**:
1. Create new intention
2. Select different themes from theme picker
3. Verify colors apply in preview and saved intention
4. Test font picker
5. Restart app → verify theme persists

---

### TEST CATEGORY 6: Widget Functionality

**Status**: ⏳ Pending manual testing

- [ ] Widget extension compiles (check build log)
- [ ] Can add widget to home screen (test in simulator)
- [ ] Widget shows correct current intention
- [ ] Create new day intention → close app → check if widget updates
- [ ] Force widget refresh: open app, create intention, check widget
- [ ] Test small widget size
- [ ] Test medium widget size
- [ ] Test large widget size
- [ ] Tap widget → app opens
- [ ] Test lock screen widget (if iOS 16+)

**How to Test**:
1. Build app (widget extension should compile)
2. Run app in simulator
3. Create an intention
4. Go to home screen (⌘⇧H)
5. Long press → Add Widget → Search "Daily Intention"
6. Add widget to home screen
7. Verify widget shows current intention
8. Create new intention in app
9. Check widget (may take a few seconds to update)
10. Tap widget → verify app opens

**Widget Debug Tips**:
- Widgets update on timeline, not immediately
- Check Console.app for widget extension logs
- Use: `xcrun simctl spawn booted log stream --predicate 'subsystem contains "widget"'`
- Widget timeline refreshes at calculated intervals (midnight for day, start of week for week, etc.)

---

### TEST CATEGORY 7: Notifications

**Status**: ⏳ Pending manual testing

- [ ] Open Settings → Notification Settings
- [ ] Enable daily notifications at current time + 2 minutes
- [ ] Wait for notification to arrive
- [ ] Pull down on notification → see inline text input
- [ ] Type "Test from notification" → tap Send
- [ ] Open app → verify intention was created
- [ ] Verify widget updated with new intention
- [ ] Test "Skip" action on notification
- [ ] Tap notification body → app opens
- [ ] Disable notifications → verify they stop

**How to Test**:
1. Go to Settings → Notification Settings
2. Enable daily notifications
3. Set time to 2 minutes from now
4. Wait for notification
5. Pull down on notification → should show text input
6. Type intention text → tap Send
7. Open app → verify intention created
8. Check widget → should update

**Note**: Notifications require real device or simulator with proper permissions

---

### TEST CATEGORY 8: Edge Cases & Error Handling

**Status**: ⏳ Pending manual testing

- [ ] Try to create intention with empty text → validation prevents it
- [ ] Create intention with 500+ character text → handles gracefully
- [ ] Test with no internet (airplane mode) → app doesn't crash
- [ ] Try to generate AI theme with no backend URL → shows helpful error
- [ ] Create 50+ intentions → list performance is acceptable
- [ ] Test with very long intention text → truncates in list view
- [ ] Test deleting while search is active → doesn't crash

**How to Test**:
1. Try various edge cases
2. Enable airplane mode → test app functionality
3. Try AI theme generation without backend → verify error message
4. Create many intentions → test scrolling performance
5. Test validation on empty text

---

### TEST CATEGORY 9: UI/UX Polish

**Status**: ⏳ Pending manual testing

- [ ] Test in dark mode → all screens readable
- [ ] Test in light mode → all screens readable
- [ ] Test with large text size (Settings → Accessibility → Larger Text)
- [ ] All buttons have appropriate tap areas
- [ ] Loading states show when appropriate
- [ ] Empty states show helpful messages
- [ ] Confirmation dialogs for destructive actions (delete)

**How to Test**:
1. Switch between light/dark mode
2. Change text size in Settings
3. Test all interactive elements
4. Verify loading indicators appear
5. Test empty states (delete all intentions)

---

## 🐛 Bug Tracking

### Found Bugs

**None yet** - Testing pending

### Fixed Issues

1. ✅ **Widget Target Membership** - Fixed by creating WidgetDataService.swift in widget folder

---

## 📊 Testing Progress

- **Total Test Categories**: 9
- **Completed**: 0
- **In Progress**: 0
- **Pending**: 9

---

## 🚀 Next Steps

1. **Build the app** in Xcode
2. **Run in simulator**
3. **Work through each test category** systematically
4. **Document any bugs** found
5. **Fix bugs** as discovered
6. **Re-test** after fixes

---

## 📝 Notes

- Widget updates are timeline-based, not immediate
- Some features require real device (notifications, widgets on home screen)
- Backend is optional - app works without it
- All data persists via SwiftData

---

**Last Updated**: Integration complete, ready for testing



