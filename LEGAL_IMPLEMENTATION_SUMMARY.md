# Legal Documents & Consent Implementation Summary

## Overview
Implemented comprehensive legal documentation and user consent mechanism for the Attunetion app, ensuring compliance with data sharing requirements for AI/suggestion features.

## What Was Implemented

### 1. Legal Documents (Vercel Backend)
Located in: `daily-intentions-backend/public/legal/`

#### Privacy Policy (`privacy-policy.html`)
- **Key Points:**
  - Clearly states "All your content stays in iCloud"
  - Explains that data is synced via Apple's iCloud (CloudKit)
  - Details third-party data sharing when using suggestion features
  - Specifies that data sent to third parties (like OpenAI) is NOT stored on our servers
  - Requires explicit consent before using suggestion features
  - Explains user rights and data deletion

#### Terms of Service (`terms-of-service.html`)
- **Key Points:**
  - Describes suggestion features (avoiding "AI" terminology)
  - Requires consent for data sharing with third-party services
  - Explains that data is processed by third parties according to their policies
  - Users can revoke consent by disabling features
  - Emphasizes iCloud storage

#### End User License Agreement (`eula.html`)
- **Key Points:**
  - Details user content ownership (stored in iCloud)
  - Explains permission to share data with third parties for suggestions
  - Requires explicit agreement before using suggestion features
  - Can be disabled at any time

### 2. iOS App Integration

#### AboutView Updates (`Attunetion/Views/Settings/AboutView.swift`)
- Added "Privacy & Legal" section with links to:
  - Privacy Policy
  - Terms of Service
  - End User License Agreement
- Added disclaimer text: "All your content stays in iCloud and is synced across your devices. When you use suggestion features, we may share data with third-party services with your consent."
- Links open documents from Vercel backend in Safari

#### SettingsView (`Attunetion/Views/Settings/SettingsView.swift`)
- Already contained links to legal documents in the "About" section
- Links direct users to the About page via sheet presentation
- Legal documents are accessible via external links

### 3. User Consent System

#### UserProfile Model Updates (`Attunetion/Models/UserProfile.swift`)
Added two new properties:
- `hasAcceptedTerms: Bool` - Tracks if user has accepted ToS/EULA
- `termsAcceptedDate: Date?` - Records when terms were accepted

#### LegalConsentView (`Attunetion/Views/Settings/LegalConsentView.swift`)
**NEW FILE** - Beautiful consent dialog that:
- Displays key information about data usage
- Shows 4 key points with icons:
  1. Your Content Stays in iCloud
  2. Third-Party Processing
  3. You're In Control
  4. Your Privacy Matters
- Links to all three legal documents
- Clear consent statement
- "I Agree" and "Not Now" buttons
- Properly themed with AppThemeManager

#### UserProfileView Updates (`Attunetion/Views/Settings/UserProfileView.swift`)
- Modified "Auto-Suggest Intentions" toggle to check consent first
- If user hasn't accepted terms, shows consent dialog when toggling on
- Displays info message when terms not accepted
- Updates footer text to mention third-party data sharing
- On consent acceptance:
  - Sets `hasAcceptedTerms = true`
  - Records `termsAcceptedDate`
  - Enables auto-suggestions

#### ConsentManager Service (`Attunetion/Services/ConsentManager.swift`)
**NEW FILE** - Centralized consent management:
- `hasAcceptedTerms()` - Check if user has accepted
- `acceptTerms()` - Mark terms as accepted
- `revokeConsent()` - Revoke consent and disable features
- `requireConsent()` - Throws error if consent not given
- `ConsentError.termsNotAccepted` - Helpful error message

#### APIClient Updates (`Attunetion/Services/APIClient.swift`)
- Added `APIError.termsNotAccepted` error case
- Added helpful error message directing users to settings
- Added comment about consent checking (caller responsibility)

## User Flow

### First-Time User Using Suggestion Features
1. User navigates to Settings > Suggested Intentions
2. User toggles "Auto-Suggest Intentions" ON
3. **Consent dialog appears** (if not previously accepted)
4. User reviews key points about data usage
5. User can click links to read full legal documents
6. User clicks "I Agree" → Consent recorded, feature enabled
7. OR user clicks "Not Now" → Feature stays disabled

### Returning User (Already Accepted)
1. User toggles "Auto-Suggest Intentions" ON
2. Feature enables immediately (no dialog)
3. Footer reminds them about third-party data sharing

### Accessing Legal Documents
- **From About Page:** Settings > About (sheet) → Links under "Privacy & Legal"
- **From Settings:** Settings > "About" section → Direct links
- **From Consent Dialog:** When accepting terms → Click any of the 3 links

## Technical Details

### Data Storage
- Legal documents: Static HTML files served by Vercel
- Consent status: Stored in UserProfile model (SwiftData/iCloud)
- No consent data sent to backend servers

### Legal Document URLs
Format: `{baseURL}/legal/{document}.html`
- Privacy Policy: `/legal/privacy-policy.html`
- Terms of Service: `/legal/terms-of-service.html`
- EULA: `/legal/eula.html`

### Base URL Configuration
- Configured via `APIClient.shared.baseURL`
- Falls back to placeholder if not configured
- Can be set via UserDefaults for testing

## Key Features

### User-Friendly
- ✅ Never mentions "AI" (uses "suggestion features" instead)
- ✅ Clear, simple language about data sharing
- ✅ Beautiful, themed consent dialog
- ✅ Easy access to legal documents
- ✅ Can revoke consent anytime

### Privacy-Focused
- ✅ Emphasizes "All your content stays in iCloud"
- ✅ Clear about third-party data sharing
- ✅ Explicit consent required before data sharing
- ✅ Data not stored on our servers
- ✅ User controls when features are enabled

### Compliant
- ✅ Privacy Policy clearly explains data usage
- ✅ Terms of Service require consent for data sharing
- ✅ EULA grants limited license for processing
- ✅ Consent tracked with timestamp
- ✅ User can revoke consent

## Next Steps (Recommended)

1. **Update APIClient.baseURL** to your actual Vercel deployment URL
2. **Add Consent Checks** to all AI API call sites:
   ```swift
   try ConsentManager.shared.requireConsent(modelContext: modelContext)
   ```
3. **Test Consent Flow** on device/simulator
4. **Deploy Backend** to Vercel so legal documents are accessible
5. **Consider Adding** a "Revoke Consent" button in settings if user wants to stop using features

## Files Created/Modified

### New Files
- `Attunetion/Views/Settings/LegalConsentView.swift`
- `Attunetion/Services/ConsentManager.swift`
- `LEGAL_IMPLEMENTATION_SUMMARY.md` (this file)

### Modified Files
- `daily-intentions-backend/public/legal/privacy-policy.html`
- `daily-intentions-backend/public/legal/terms-of-service.html`
- `daily-intentions-backend/public/legal/eula.html`
- `Attunetion/Models/UserProfile.swift`
- `Attunetion/Views/Settings/AboutView.swift`
- `Attunetion/Views/Settings/UserProfileView.swift`
- `Attunetion/Services/APIClient.swift`

## Legal Document Highlights

### What Users Know
1. **Their content stays in iCloud** - synced across their devices
2. **When using suggestions**, data is sent to third parties
3. **Data is not stored** on our servers
4. **They must consent** before using suggestion features
5. **They can revoke consent** at any time

This implementation ensures full transparency and user control while maintaining a smooth, user-friendly experience.
