//
//  PageIndicator.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/19/25.
//

import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Theme.primary : Theme.primary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
