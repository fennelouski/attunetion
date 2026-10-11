//
//  IntentionRowView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct IntentionRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let intention: Intention
    @ObservedObject var themeManager: AppThemeManager
    let style: IntentionListStyle
    let intentionTheme: IntentionTheme?

    init(intention: Intention, themeManager: AppThemeManager, style: IntentionListStyle = .cards, intentionTheme: IntentionTheme? = nil) {
        self.intention = intention
        self.themeManager = themeManager
        self.style = style
        self.intentionTheme = intentionTheme
    }

    private var scopeColor: Color {
        if let theme = intentionTheme {
            return theme.accentColorValue
        }
        return themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }

    private var primaryTextColor: Color {
        intentionTheme?.textColorValue ?? themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor()
    }

    private var secondaryTextColor: Color {
        intentionTheme?.textColorValue.opacity(0.8) ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()
    }

    private var rowBackgroundColor: Color {
        if let theme = intentionTheme {
            return theme.backgroundColorValue.opacity(0.3)
        }
        return colorScheme == .dark
            ? themeManager.currentTheme.darkSecondaryButtonBackground.toSwiftUIColor().opacity(0.3)
            : Color.white.opacity(0.5)
    }

    private var strokeColor: Color {
        (intentionTheme?.textColorValue ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()).opacity(0.1)
    }

    private var accentColor: Color {
        intentionTheme?.accentColorValue ?? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: intention.date)
    }

    /// Determines if this intention is currently active (today, this week, or this month)
    private var isActiveIntention: Bool {
        intention.scope.isCurrent(intention.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Scope badge with optional orbital animation overlay
            ZStack {
                Text(intention.scope.rawValue.capitalized)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(scopeColor.opacity(0.8))
                    )

                // Show orbital animation for active intentions
                if isActiveIntention {
                    let orbitSize: CGFloat = 44
                    let animation: AnyView = {
                        switch intention.scope {
                        case .day:
                            return AnyView(FastOrbitalBeadAnimation(size: orbitSize, color: scopeColor))
                        case .week:
                            return AnyView(WeeklyOrbitalBeadAnimation(size: orbitSize, color: scopeColor))
                        case .month, .season, .year:
                            return AnyView(SlowOrbitalBeadAnimation(size: orbitSize, color: scopeColor))
                        }
                    }()

                    animation
                }
            }
            .frame(width: 70, height: 44)

            // Intention text
            VStack(alignment: .leading, spacing: 6) {
                Text(intention.text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineLimit(nil)
                    .foregroundColor(primaryTextColor)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(dateString)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(secondaryTextColor)
            }

            Spacer()

            // AI badge if applicable
            if intention.aiGenerated {
                Image(systemName: "target")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(accentColor)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor((intentionTheme?.textColorValue ?? themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor()).opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Group {
                if style == .cards {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            rowBackgroundColor
                        )
                }
            }
        )
        .overlay(
            Group {
                if style == .cards {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            strokeColor,
                            lineWidth: 1
                        )
                }
            }
        )
    }
}

#Preview {
    let container = try! ModelContainer(for: Intention.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let _ = container.mainContext
    
    // Create sample intentions for preview
    let intention1 = Intention(text: "Be present with family", scope: .day, date: Date())
    let intention2 = Intention(text: "Focus on health and wellness", scope: .week, date: Date())
    let intention3 = Intention(text: "Build meaningful connections", scope: .month, date: Date())
    
    VStack(spacing: 12) {
        IntentionRowView(intention: intention1, themeManager: AppThemeManager())
        IntentionRowView(intention: intention2, themeManager: AppThemeManager())
        IntentionRowView(intention: intention3, themeManager: AppThemeManager())
    }
    .padding()
    .background(AppBackground(themeManager: AppThemeManager()))
    .modelContainer(container)
}
