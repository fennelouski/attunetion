//
//  IntentionPack.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI

struct IntentionPack: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let monthly: String
    let weekly: String
    let daily: String
}

extension IntentionPack {
    static let packs: [IntentionPack] = [
        IntentionPack(
            name: "Wellness & Balance",
            description: "Focus on health, mindfulness, and self-care",
            monthly: "Prioritize my physical and mental well-being",
            weekly: "Make time for rest and recovery",
            daily: "Nourish my body and mind"
        ),
        IntentionPack(
            name: "Growth & Learning",
            description: "Embrace continuous learning and personal development",
            monthly: "Expand my knowledge and skills",
            weekly: "Dedicate time for learning",
            daily: "Stay curious and open"
        ),
        IntentionPack(
            name: "Relationships & Connection",
            description: "Strengthen bonds with loved ones and community",
            monthly: "Deepen meaningful relationships",
            weekly: "Reach out to family and friends",
            daily: "Show kindness and presence"
        ),
        IntentionPack(
            name: "Creativity & Expression",
            description: "Cultivate artistic expression and imagination",
            monthly: "Make space for creative exploration",
            weekly: "Engage with my creative side",
            daily: "Express myself authentically"
        ),
        IntentionPack(
            name: "Purpose & Contribution",
            description: "Make a positive impact in the world around you",
            monthly: "Align with my values and purpose",
            weekly: "Contribute to something bigger",
            daily: "Be of service to others"
        )
    ]
}
