//
//  NotificationToggleRow.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

/// A row component for toggling notification settings
struct NotificationToggleRow: View {
    let title: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        Toggle(title, isOn: $isEnabled)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    }
}

