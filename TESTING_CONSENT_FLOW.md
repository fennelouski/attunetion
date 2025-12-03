# Testing the Consent Flow

## Prerequisites
1. Deploy the Vercel backend so legal documents are accessible
2. Update `APIClient.shared.baseURL` to your Vercel URL
3. Build and run the app on a simulator or device

## Test Scenarios

### Test 1: First-Time User Consent Flow
**Goal:** Verify that consent dialog appears for new users

1. Launch the app (fresh install or reset app data)
2. Navigate to **Settings**
3. Tap **Suggested Intentions** (under "Suggestions" section)
4. Attempt to toggle **"Auto-Suggest Intentions"** to ON

**Expected Result:**
- ✅ Consent dialog appears with title "Legal Agreement"
- ✅ Shows 4 key points with icons about data usage
- ✅ All 3 legal document links are present and functional
- ✅ "I Agree" button is prominent (blue/accent color)
- ✅ "Not Now" button is secondary (outline style)
- ✅ Cancel button in navigation bar

### Test 2: User Accepts Terms
**Goal:** Verify consent is properly recorded

1. Follow Test 1 steps to trigger consent dialog
2. Tap **"I Agree"**

**Expected Result:**
- ✅ Dialog dismisses
- ✅ "Auto-Suggest Intentions" toggle turns ON
- ✅ Footer text updates to mention third-party sharing
- ✅ Info message about "Requires accepting ToS" disappears
- ✅ Tap "Save" to save the profile
- ✅ Return to this screen - toggle should remain ON without showing dialog

### Test 3: User Declines Terms
**Goal:** Verify declining doesn't enable features

1. Follow Test 1 steps to trigger consent dialog
2. Tap **"Not Now"**

**Expected Result:**
- ✅ Dialog dismisses
- ✅ "Auto-Suggest Intentions" toggle stays OFF
- ✅ Info message still shows "Requires accepting Terms of Service"
- ✅ Toggling again shows consent dialog again

### Test 4: User Cancels Dialog
**Goal:** Verify cancel button works

1. Follow Test 1 steps to trigger consent dialog
2. Tap **"Cancel"** in navigation bar

**Expected Result:**
- ✅ Dialog dismisses
- ✅ "Auto-Suggest Intentions" toggle stays OFF
- ✅ Same behavior as declining

### Test 5: Legal Document Links
**Goal:** Verify all legal documents open correctly

1. Open consent dialog (follow Test 1)
2. Tap **"Privacy Policy"** link

**Expected Result:**
- ✅ Safari opens to: `{baseURL}/legal/privacy-policy.html`
- ✅ Document displays correctly (responsive, readable)
- ✅ Contains updated content about iCloud and third-party sharing

3. Return to app, tap **"Terms of Service"** link

**Expected Result:**
- ✅ Safari opens to: `{baseURL}/legal/terms-of-service.html`
- ✅ Document displays correctly

4. Return to app, tap **"End User License Agreement"** link

**Expected Result:**
- ✅ Safari opens to: `{baseURL}/legal/eula.html`
- ✅ Document displays correctly

### Test 6: About Page Legal Links
**Goal:** Verify legal documents accessible from About page

1. Navigate to **Settings**
2. Tap **"About"** (in the "About" section)
3. Scroll to **"Privacy & Legal"** section
4. Tap each of the three links

**Expected Result:**
- ✅ All links open correct documents in Safari
- ✅ Disclaimer text is visible and accurate

### Test 7: Settings Page Direct Links
**Goal:** Verify legal documents in Settings

1. Navigate to **Settings**
2. Scroll to **"About"** section
3. Find direct links to Privacy Policy, EULA, Terms of Service

**Expected Result:**
- ✅ All three links are present
- ✅ Links have external link icon (arrow.up.right.square)
- ✅ Clicking opens documents in Safari

### Test 8: Returning User (Already Accepted)
**Goal:** Verify consent persists across app launches

1. Accept terms (Test 2)
2. Close the app completely
3. Relaunch the app
4. Navigate to Settings > Suggested Intentions
5. Toggle "Auto-Suggest Intentions"

**Expected Result:**
- ✅ Toggle works immediately without showing dialog
- ✅ No info message about requiring consent
- ✅ Footer mentions third-party data sharing

### Test 9: Theme Consistency
**Goal:** Verify consent dialog respects app theme

1. Navigate to Settings
2. Change **App Theme** to different options (Serenity, Sunset, Ocean)
3. For each theme, trigger consent dialog

**Expected Result:**
- ✅ Dialog background matches app theme
- ✅ Text colors are readable (primary/secondary from theme)
- ✅ Accent color is consistent
- ✅ Icons use theme accent color

### Test 10: Dark Mode Support
**Goal:** Verify consent dialog works in dark mode

1. Enable Dark Mode on device
2. Launch app
3. Trigger consent dialog

**Expected Result:**
- ✅ Dialog is readable in dark mode
- ✅ Colors adapt appropriately
- ✅ No pure white backgrounds

## Data Verification

### Check UserProfile Storage
After accepting terms:

```swift
let repository = UserProfileRepository(modelContext: modelContext)
let profile = repository.getProfile()

print("Has Accepted Terms: \(profile.hasAcceptedTerms)")
print("Terms Accepted Date: \(profile.termsAcceptedDate)")
```

**Expected:**
- `hasAcceptedTerms` = `true`
- `termsAcceptedDate` = Date user clicked "I Agree"

## Edge Cases to Test

### Edge Case 1: No Internet Connection
1. Disable internet on device
2. Open consent dialog
3. Try to click legal document links

**Expected:**
- ✅ Links attempt to open but Safari shows no connection error
- ✅ App doesn't crash
- ✅ User can still accept/decline without viewing documents

### Edge Case 2: Invalid Base URL
1. Set `APIClient.shared.baseURL` to empty or invalid URL
2. Try to access legal documents

**Expected:**
- ✅ Links use fallback URL
- ✅ May not open if URL is invalid, but app doesn't crash

### Edge Case 3: Rapid Toggle
1. Rapidly toggle "Auto-Suggest Intentions" on/off/on

**Expected:**
- ✅ Dialog only shows once (not multiple times)
- ✅ Toggle state is consistent
- ✅ No crashes

## Automated Testing (Future)

Consider adding UI tests for:
```swift
func testConsentDialogAppearsForNewUser() {
    // Test that dialog shows when toggling without consent
}

func testConsentDialogDoesNotAppearForExistingUser() {
    // Test that dialog doesn't show if already accepted
}

func testAcceptingTermsEnablesFeature() {
    // Test that accepting enables auto-suggestions
}

func testDecliningTermsKeepsFeatureDisabled() {
    // Test that declining keeps toggle off
}
```

## Checklist Before Production

- [ ] Deploy Vercel backend
- [ ] Update `APIClient.baseURL` to production URL
- [ ] Test all scenarios on iOS simulator
- [ ] Test all scenarios on real iOS device
- [ ] Test in both light and dark mode
- [ ] Test with all app themes
- [ ] Verify legal documents are accessible online
- [ ] Verify documents are mobile-responsive
- [ ] Legal review of all three documents
- [ ] Add consent checks to all AI API call sites
- [ ] Test consent error handling
- [ ] Verify data persistence across app launches
- [ ] Test iCloud sync (multiple devices if possible)

## Known Issues to Watch For

1. **Build Errors:** There are some existing build errors unrelated to this implementation (WidgetDataService)
2. **Base URL:** Make sure to update the base URL before testing legal document links
3. **SwiftData Migration:** Adding new properties to UserProfile may require schema migration

## Success Criteria

✅ Users cannot use suggestion features without accepting terms
✅ Consent dialog is clear, user-friendly, and properly themed
✅ All legal documents are accessible and readable
✅ Consent is properly stored and persists
✅ Users can access legal documents from multiple places
✅ No crashes or errors in the consent flow
✅ Complies with data sharing disclosure requirements
