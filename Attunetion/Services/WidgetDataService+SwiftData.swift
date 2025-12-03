//
//  WidgetDataService+SwiftData.swift
//  Attunetion
//
//  Extension for updating widget data from SwiftData models
//

import Foundation
import SwiftData

extension WidgetDataService {
    /// Update widget data from current intention and theme using SwiftData (main app only)
    @MainActor
    func updateWidgetDataFromSwiftData(modelContext: ModelContext) {
        let repository = IntentionRepository(modelContext: modelContext)
        let themeRepository = ThemeRepository(modelContext: modelContext)
        
        // Get current intention
        if let intention = repository.getCurrentDisplayIntention() {
            let intentionData = IntentionData(
                id: intention.id,
                text: intention.text,
                scope: intention.scope.rawValue,
                scopeDate: intention.date,
                quote: intention.quote,
                aiGenerated: intention.aiGenerated
            )
            
            // Get theme for intention
            var themeData: ThemeData? = nil
            if let themeId = intention.themeId,
               let theme = themeRepository.getTheme(byId: themeId) {
                themeData = ThemeData(
                    backgroundColor: theme.backgroundColor,
                    textColor: theme.textColor,
                    accentColor: theme.accentColor,
                    fontName: theme.fontName
                )
            }
            
            updateWidgetData(intentionData: intentionData, themeData: themeData)
        } else {
            // No current intention
            updateWidgetData(intentionData: nil, themeData: nil)
        }
    }
}



