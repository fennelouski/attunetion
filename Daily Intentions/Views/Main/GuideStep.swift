//
//  GuideStep.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import Foundation

struct GuideStep {
    let title: String
    let description: String
    let icon: String
    var scope: IntentionScope? = nil
    var placeholder: String? = nil
    var showExamples: Bool = false
    var isComplete: Bool = false
}
