//
//  LegalConsentView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

struct LegalConsentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: AppThemeManager

    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(themeManager: themeManager)

                FadedScrollView(themeManager: themeManager) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48, weight: .ultraLight))
                                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())

                            Text("Terms & Privacy")
                                .font(.system(size: 28, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())

                            Text("AI features send text to OpenAI through the Attunetion service. Review what is shared before choosing to continue.")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        Divider()
                            .background(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            .padding(.horizontal, 20)

                        // Key Points
                        VStack(alignment: .leading, spacing: 20) {
                            Text("What you need to know:")
                                .font(.system(size: 18, weight: .medium, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())

                            infoRow(
                                icon: "icloud.fill",
                                title: "Writing Without AI",
                                description: "You can write and style intentions on your device without using AI or sending the text to our service."
                            )

                            infoRow(
                                icon: "network",
                                title: "What Is Shared",
                                description: "AI themes send the intention text you are editing. The generator sends the description you enter. Automatic suggestions send your saved profile and up to ten previous intentions, including their dates and scopes. These requests go to OpenAI through our service."
                            )

                            infoRow(
                                icon: "hand.raised.fill",
                                title: "You're In Control",
                                description: "Choose Stop Sharing with AI in Settings > Suggested Intentions to block future AI requests and turn off automatic suggestions. This does not recall data already sent."
                            )

                            infoRow(
                                icon: "shield.fill",
                                title: "Your Privacy Matters",
                                description: "Our service providers may retain requests and technical logs under their policies. Read the Privacy Policy for provider details before sharing personal or sensitive information."
                            )
                        }
                        .padding(.horizontal, 20)

                        Divider()
                            .background(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            .padding(.horizontal, 20)

                        // Legal Links
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Please review:")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())

                            legalLink(title: "Privacy Policy", document: "privacy-policy")
                            legalLink(title: "Terms of Service", document: "terms-of-service")
                            legalLink(title: "End User License Agreement", document: "eula")
                        }
                        .padding(.horizontal, 20)

                        // Consent Statement
                        VStack(alignment: .leading, spacing: 12) {
                            Text("By tapping \"I Agree\", you acknowledge that you have read and agree to our Terms of Service, End User License Agreement, and Privacy Policy. You consent to sending the text described above to OpenAI through the Attunetion service for AI features.")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.1))
                        )
                        .padding(.horizontal, 20)

                        // Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                #if os(iOS)
                                HapticFeedback.medium()
                                #endif
                                onAccept()
                                dismiss()
                            }) {
                                Text("I Agree")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                #if os(iOS)
                                HapticFeedback.light()
                                #endif
                                onDecline()
                                dismiss()
                            }) {
                                Text("Not Now")
                                    .font(.system(size: 17, weight: .medium, design: .default))
                                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Legal Agreement")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDecline()
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
            }
        }
    }

    @ViewBuilder
    private func infoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())

                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    .lineSpacing(4)
            }
        }
    }

    @ViewBuilder
    private func legalLink(title: String, document: String) -> some View {
        let baseURL = APIClient.shared.baseURL
        let address = document == "privacy-policy"
            ? "https://nathanfennel.com/attunetion/privacy.html"
            : "\(baseURL)/legal/\(document).html"
        if let url = URL(string: address) {
            Link(destination: url) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.05))
                )
            }
        }
    }
}

#Preview {
    LegalConsentView(
        onAccept: {},
        onDecline: {}
    )
}
