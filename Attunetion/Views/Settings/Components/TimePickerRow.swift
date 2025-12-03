//
//  TimePickerRow.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI

/// A row component for selecting time
struct TimePickerRow: View {
    let title: String
    @Binding var time: Date
    
    var body: some View {
        DatePicker(
            title,
            selection: $time,
            displayedComponents: .hourAndMinute
        )
        #if !os(watchOS)
        .datePickerStyle(.compact)
        #endif
    }
}

