# Quick Start Guide - Attunetion App

## 🚀 Getting Started

### 1. Open Project in Xcode
```bash
cd "/Users/nathanfennel/Library/Mobile Documents/com~apple~CloudDocs/Xcode Projects/Attunetion"
open "Attunetion.xcodeproj"
```

### 2. Fix Widget Target Membership (REQUIRED)

**This is critical for widgets to work!**

1. In Xcode, select `WidgetDataService.swift` in Project Navigator
2. Open File Inspector (View → Inspectors → File)
3. Under "Target Membership", check BOTH:
   - ✅ **Attunetion** (main app)
   - ✅ **IntentionWidget** (widget extension)

4. Verify App Group is configured:
   - Main app: `Attunetion.entitlements` → Should have `group.com.nathanfennel.Attunetion`
   - Widget: `IntentionWidget.entitlements` → Should have same App Group ID

### 3. Build and Run

1. Select "Attunetion" scheme
2. Choose iPhone simulator or device
3. Press ⌘R to build and run

### 4. Test Widget

1. Run the app
2. Create an intention
3. Go to home screen
4. Long press → Add Widget → Search "Daily Intention"
5. Add widget to home screen
6. Verify it shows your current intention

---

## 🔧 Configuration

### Backend API (Optional - for AI features)

**If you want AI theme generation:**

1. Deploy backend (see `attunetion-backend/DEPLOYMENT.md`)
2. Update `APIClient.swift`:
   ```swift
   private var baseURL: String {
       return "https://your-project.vercel.app" // Your Vercel URL
   }
   ```

**Or set via UserDefaults for testing:**
```swift
UserDefaults.standard.set("https://your-project.vercel.app", forKey: "APIBaseURL")
```

**Note**: App works perfectly without backend - AI features are optional!

---

## ✅ Verification Checklist

After building, verify:

- [ ] App launches without crashes
- [ ] Can create intentions
- [ ] Intentions persist after app restart
- [ ] Widget can be added to home screen
- [ ] Widget shows current intention
- [ ] Notifications work (if enabled)
- [ ] Onboarding shows on first launch

---

## 🐛 Common Issues

### Widget Not Showing Data
- **Fix**: Ensure `WidgetDataService.swift` is in BOTH targets (see step 2 above)
- **Fix**: Verify App Group ID matches in both entitlements files

### App Crashes on Launch
- Check console for errors
- Verify all models are in Schema: `Intention`, `IntentionTheme`, `UserPreferences`

### Widget Not Updating
- Widget updates automatically when intentions change
- Can manually reload: `WidgetCenter.shared.reloadAllTimelines()`

### Backend API Errors
- Check `APIClient.swift` has correct baseURL
- Verify backend is deployed and accessible
- Check network connectivity

---

## 📱 Testing on Device

1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Build and run (may need to sign with your Apple ID)
4. Trust developer certificate on device (Settings → General → VPN & Device Management)

---

## 🎯 Next Steps

1. Complete widget target membership fix
2. Test all features (see `INTEGRATION_COMPLETE.md` for test suites)
3. Deploy backend (optional)
4. Test on real device
5. Submit to App Store (when ready)

---

## 📚 Documentation

- **Full Integration Report**: `INTEGRATION_COMPLETE.md`
- **Backend Deployment**: `attunetion-backend/DEPLOYMENT.md`
- **Data Model**: `DATA_MODEL.md`
- **Implementation Plan**: `IMPLEMENTATION_PLAN.md`

---

**Happy coding! 🎉**



