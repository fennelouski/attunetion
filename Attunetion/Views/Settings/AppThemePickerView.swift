//
import SwiftUI

struct AppThemePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)

                FadedScrollView(themeManager: themeManager) {
                    VStack(spacing: 24) {
                        // Title
                        Text("Choose App Theme")
                            .font(.system(size: 28, weight: .ultraLight, design: .default))
                            .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                            .padding(.top, 20)

                        // Theme options
                        VStack(spacing: 16) {
                            ForEach(AppTheme.presetThemes, id: \.id) { theme in
                                Button {
                                    themeManager.setTheme(theme)
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    ThemeOptionCard(
                                        theme: theme,
                                        isSelected: theme.id == themeManager.currentTheme.id,
                                        themeManager: themeManager
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(theme.name)
                                .accessibilityValue(theme.id == themeManager.currentTheme.id ? "Selected" : "")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }
}

struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    @ObservedObject var themeManager: AppThemeManager

    var body: some View {
        ZStack {
            // Background with theme colors
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.lightBackground.toSwiftUIColor())
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.lightAccent.toSwiftUIColor(), lineWidth: isSelected ? 3 : 1)
                )
                .shadow(color: theme.lightAccent.toSwiftUIColor().opacity(0.3), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                // Theme name
                Text(theme.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(theme.lightPrimaryText.toSwiftUIColor())

                // Color preview circles
                HStack(spacing: 8) {
                    Circle()
                        .fill(theme.lightBackground.toSwiftUIColor())
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    Circle()
                        .fill(theme.lightAccent.toSwiftUIColor())
                        .frame(width: 20, height: 20)

                    Circle()
                        .fill(theme.lightPrimaryText.toSwiftUIColor())
                        .frame(width: 20, height: 20)
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(theme.lightAccent.toSwiftUIColor())
                }
            }
            .padding(20)
        }
        .frame(minHeight: 120)
    }
}

#Preview {
    AppThemePickerView(themeManager: AppThemeManager())
}
