# Build Status & Known Issues

## ✅ Widget Target Membership - FIXED

**Issue**: Widget couldn't access `WidgetDataService` from main app target

**Solution**: Created `WidgetDataService.swift` in `IntentionWidget/` folder

**Status**: ✅ Fixed - Widget now has its own copy that reads from App Group UserDefaults

---

## 🔨 Build Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ SDK
- macOS 14.0+ (for development)

### Build Steps

1. **Open Project**
   ```bash
   open "Attunetion.xcodeproj"
   ```

2. **Select Scheme**
   - Choose "Attunetion" scheme
   - Select iPhone simulator or device

3. **Build**
   - Press ⌘B to build
   - Or ⌘R to build and run

4. **Build Widget Extension**
   - Select "IntentionWidget" scheme
   - Build to verify widget compiles

### Expected Build Results

- ✅ Main app target builds successfully
- ✅ Widget extension builds successfully
- ✅ No compilation errors
- ⚠️ May have warnings (check and fix if critical)

---

## ⚠️ Known Build Issues

### None Currently Known

If you encounter build errors:

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Delete Derived Data**: 
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data path
   - Delete "Attunetion" folder
3. **Rebuild**: ⌘B

---

## 🔍 Common Build Errors & Fixes

### Error: "Cannot find 'WidgetDataService' in scope"

**Fix**: Ensure `WidgetDataService.swift` exists in `IntentionWidget/` folder

### Error: "No such module 'WidgetKit'"

**Fix**: WidgetKit is available in iOS 14+. Check deployment target.

### Error: "App Group entitlement missing"

**Fix**: Verify both `Attunetion.entitlements` and `IntentionWidget.entitlements` have:
```
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.nathanfennel.Attunetion</string>
</array>
```

### Error: SwiftData schema issues

**Fix**: Ensure all models are in Schema:
- Intention
- IntentionTheme
- UserPreferences

---

## 📱 Testing Requirements

### Simulator Testing
- ✅ Basic functionality
- ✅ UI/UX testing
- ✅ Data persistence
- ⚠️ Widgets (limited - can add but may not update properly)
- ❌ Notifications (may not work reliably)

### Device Testing (Recommended)
- ✅ All features work properly
- ✅ Widgets update correctly
- ✅ Notifications work
- ✅ Performance testing
- ✅ Real-world usage

---

## 🎯 Build Targets

### Main App Target: "Attunetion"
- **Bundle ID**: `com.nathanfennel.Attunetion`
- **Deployment Target**: iOS 17.0+
- **Capabilities**: 
  - App Groups
  - CloudKit
  - Push Notifications

### Widget Extension: "IntentionWidget"
- **Bundle ID**: `com.nathanfennel.Attunetion.IntentionWidget`
- **Deployment Target**: iOS 17.0+
- **Capabilities**:
  - App Groups
  - WidgetKit

---

## 📊 Build Configuration

### Debug Configuration
- Optimization: None
- Debug symbols: Full
- Swift optimizations: None

### Release Configuration
- Optimization: Optimize for Speed
- Debug symbols: Hidden
- Swift optimizations: Optimize for Speed

---

## 🚀 Deployment Checklist

Before releasing:

- [ ] Build succeeds in Release configuration
- [ ] All tests pass
- [ ] No critical warnings
- [ ] App Group ID matches in all entitlements
- [ ] Bundle IDs are correct
- [ ] Version number updated
- [ ] Build number incremented

---

**Last Updated**: After widget target fix



