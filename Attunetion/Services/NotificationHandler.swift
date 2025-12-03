//
//  NotificationHandler.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import UserNotifications
import SwiftData

/// Handles notification responses and actions
@MainActor
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    private var modelContext: ModelContext?
    
    private override init() {
        super.init()
    }
    
    /// Set the model context for creating intentions
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }
    
    /// Handle user interaction with notification (tap or action)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        switch actionIdentifier {
        case "SET_INTENTION_ACTION":
            // Handle inline text input
            if let textResponse = response as? UNTextInputNotificationResponse {
                let intentionText = textResponse.userText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !intentionText.isEmpty else {
                    print("Empty intention text received")
                    return
                }
                
                // Determine scope from category
                let scope: IntentionScope = {
                    switch categoryIdentifier {
                    case "DAILY_INTENTION":
                        return .day
                    case "WEEKLY_INTENTION":
                        return .week
                    case "MONTHLY_INTENTION":
                        return .month
                    default:
                        return .day
                    }
                }()
                
                // Create intention
                await createIntention(text: intentionText, scope: scope)
            }
            
        case "SKIP_ACTION":
            // User skipped - just dismiss
            print("User skipped setting intention")
            break
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped notification - open app to new intention screen
            // Note: Deep linking will be handled by UI team, for now just log
            print("User tapped notification - should open app to new intention screen")
            await openApp(toScreen: .newIntention)
            
        default:
            break
        }
    }
    
    // MARK: - Private Helpers
    
    /// Create an intention from notification text input
    private func createIntention(text: String, scope: IntentionScope) async {
        guard let modelContext = modelContext else {
            print("ModelContext not set - using mock creation")
            await createMockIntention(text: text, scope: scope)
            return
        }
        
        let repository = IntentionRepository(modelContext: modelContext)
        
        // Determine the appropriate date for this scope
        let date: Date = {
            let calendar = Calendar.current
            switch scope {
            case .day:
                return Date()
            case .week:
                // Use start of current week
                return calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            case .month:
                // Use start of current month
                let components = calendar.dateComponents([.year, .month], from: Date())
                return calendar.date(from: components) ?? Date()
            }
        }()
        
        let intention = Intention(
            text: text,
            scope: scope,
            date: date
        )
        
        do {
            try repository.create(intention)
            print("Successfully created intention from notification: \(text)")
            
            // Sync widget data after creating intention
            WidgetDataService.shared.updateWidgetDataFromSwiftData(modelContext: modelContext)
            
            // Show confirmation notification
            await showConfirmationNotification(scope: scope)
        } catch {
            print("Failed to create intention from notification: \(error)")
            await showErrorNotification()
        }
    }
    
    /// Mock intention creation (for testing without full data layer)
    private func createMockIntention(text: String, scope: IntentionScope) async {
        print("📝 Mock: Created \(scope.rawValue) intention: \"\(text)\"")
        print("   In production, this would be saved via IntentionRepository")
        
        // Show confirmation notification
        await showConfirmationNotification(scope: scope)
    }
    
    /// Show confirmation notification after creating intention
    private func showConfirmationNotification(scope: IntentionScope) async {
        let content = UNMutableNotificationContent()
        content.title = "Intention Set!"
        content.body = "Your \(scope.rawValue) intention has been saved."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "confirmation-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    /// Show error notification if intention creation failed
    private func showErrorNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Error"
        content.body = "Failed to save your intention. Please try again in the app."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "error-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    /// Open app to specific screen (placeholder for deep linking)
    private func openApp(toScreen screen: AppScreen) async {
        // TODO: Coordinate with UI team for deep linking implementation
        print("Should navigate to: \(screen)")
    }
}

/// App screens for deep linking (to be coordinated with UI team)
enum AppScreen {
    case newIntention
    case settings
    case intentionsList
}

