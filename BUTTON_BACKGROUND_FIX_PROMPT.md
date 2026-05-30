# Fix Double Background Issue on SwiftUI Buttons

## Problem Description

SwiftUI buttons throughout the app are displaying a **double background effect** - there appears to be one background color layered on top of another, creating a visible double-layer appearance. This is particularly noticeable on:

1. **ScopeSelector buttons** (Day/Week/Month selector) - The selected button shows a white/colored background on top of a light gray container background
2. **PrimaryButton components** - Main action buttons show double backgrounds
3. **SecondaryButton components** - Secondary action buttons show double backgrounds
4. **Various other buttons** throughout the app that have custom backgrounds

## What Has Been Tried (All Failed)

1. **First attempt**: Added `.frame(maxWidth: .infinity)` to button content and moved `.background()` outside the Button closure but after `.buttonStyle(.plain)`
   - Result: No change

2. **Second attempt**: Moved `.background()` modifier to be applied directly to the Button after `.buttonStyle(.plain)`
   - Result: No change

3. **Third attempt**: Created custom `ButtonStyle` structs (`SolidBackgroundButtonStyle`, `PrimaryButtonStyle`, `OptionalBackgroundButtonStyle`, `CardButtonStyle`) that apply backgrounds in the `makeBody` method
   - Result: Still showing double backgrounds

## Current Code Structure

### PrimaryButton Component
**File**: `Attunetion/Views/Components/PrimaryButton.swift`

```swift
var body: some View {
    Button(action: {
        #if os(iOS)
        HapticFeedback.light()
        #endif
        action()
    }) {
        Text(title)
            .font(.system(size: fontSize, weight: .semibold, design: fontDesign))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: buttonHeight)
            .frame(maxWidth: .infinity)
    }
    .buttonStyle(
        PrimaryButtonStyle(
            backgroundColor: themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor(),
            foregroundColor: themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor(),
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowY: shadowY
        )
    )
}
```

### ScopeSelector Component
**File**: `Attunetion/Views/Components/ScopeSelector.swift`

```swift
Button(action: {
    selectedScope = nil
}) {
    Text("All")
        .font(.system(size: buttonFontSize, weight: selectedScope == nil ? .semibold : .regular, design: fontDesign))
        .padding(.horizontal, buttonHorizontalPadding)
        .padding(.vertical, buttonVerticalPadding)
        .frame(maxWidth: .infinity)
}
.buttonStyle(
    OptionalBackgroundButtonStyle(
        backgroundColor: selectedScope == nil
            ? themeManager.buttonBackgroundColor(for: colorScheme).toSwiftUIColor()
            : (colorScheme == .dark
                ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.4)
                : Color.white.opacity(0.5)),
        foregroundColor: selectedScope == nil
            ? themeManager.buttonTextColor(for: colorScheme).toSwiftUIColor()
            : themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor(),
        cornerRadius: buttonCornerRadius
    )
)
```

### Custom ButtonStyles
**File**: `Attunetion/Views/Components/CustomButtonStyles.swift`

```swift
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowY: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .shadow(
                color: shadowRadius > 0 ? backgroundColor.opacity(0.3) : .clear,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OptionalBackgroundButtonStyle: ButtonStyle {
    let backgroundColor: Color?
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .background(
                Group {
                    if let bgColor = backgroundColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(bgColor)
                    } else {
                        Color.clear
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
```

## Visual Description of the Problem

From the user's description and screenshots:
- **ScopeSelector**: The selected button (e.g., "Month") shows a white/colored rounded rectangle background that appears to be layered on top of a light gray container background, creating a visible double-layer effect
- **Primary buttons**: Similar double background effect where the button's background color appears to have another background layer beneath it
- The effect is most pronounced in light mode but also visible in dark mode

## Expected Behavior

Each button should have **exactly one background color** that fills its entire area. There should be no visible layering or double background effect.

## Key Files to Check

1. `Attunetion/Views/Components/PrimaryButton.swift`
2. `Attunetion/Views/Components/ScopeSelector.swift`
3. `Attunetion/Views/Components/CustomButtonStyles.swift`
4. `Attunetion/Views/Main/IntentionGuideView.swift` (has buttons with backgrounds)
5. `Attunetion/Views/Onboarding/Components/ExampleIntentionCard.swift` (has card buttons)

## Additional Context

- The app uses SwiftUI
- Buttons need to work on iOS, macOS, and watchOS
- The app uses a custom `AppThemeManager` for theming
- Some buttons are in Forms/Sections which might affect rendering
- The issue persists across all platforms

## What Needs to Happen

1. **Investigate the root cause**: Why are buttons showing double backgrounds even with custom ButtonStyles?
2. **Find the correct solution**: Research SwiftUI button rendering and find the proper way to apply a single background
3. **Implement the fix**: Apply the solution to all affected button components
4. **Verify**: Ensure buttons show only one background color with no layering

## Possible Root Causes to Investigate

1. SwiftUI's default button rendering might be adding a background layer even with `.buttonStyle(.plain)`
2. The `ButtonStyle` implementation might not be fully overriding default behavior
3. There might be parent container backgrounds interfering (Forms, Sections, etc.)
4. The way backgrounds are applied in `makeBody` might need to be different
5. There could be an issue with how SwiftUI composites views with backgrounds

## Success Criteria

- All buttons display exactly one background color
- No visible double-layer or layering effects
- Buttons maintain their functionality and appearance (colors, corners, shadows)
- Solution works across all platforms (iOS, macOS, watchOS)
- Code is clean and maintainable

---

**Please investigate this thoroughly, test different approaches, and implement a working solution that eliminates the double background effect completely.**


