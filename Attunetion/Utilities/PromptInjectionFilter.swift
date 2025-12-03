//
//  PromptInjectionFilter.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation

/// Utility to filter prompt injection attempts in user feedback
struct PromptInjectionFilter {
    /// Patterns that indicate prompt injection attempts
    private static let suspiciousPatterns: [String] = [
        "ignore previous",
        "forget all",
        "system:",
        "assistant:",
        "user:",
        "you are now",
        "act as",
        "pretend to be",
        "roleplay",
        "jailbreak",
        "override",
        "bypass",
        "hack",
        "exploit",
        "vulnerability",
        "security",
        "admin",
        "root",
        "sudo",
        "execute",
        "run command",
        "system prompt",
        "instructions:",
        "new instructions",
        "follow these",
        "disregard",
        "disregard previous",
        "ignore the above",
        "new task",
        "new goal",
        "new objective",
        "###",
        "```",
        "<|",
        "|>",
        "{{",
        "}}",
        "prompt:",
        "prompt injection",
        "injection attack",
        "adversarial",
        "malicious",
    ]
    
    /// Check if text contains prompt injection patterns
    static func containsPromptInjection(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        
        // Check for suspicious patterns
        for pattern in suspiciousPatterns {
            if lowercased.contains(pattern) {
                return true
            }
        }
        
        // Check for excessive special characters (potential encoding attempts)
        let specialCharCount = text.filter { !$0.isLetter && !$0.isNumber && !$0.isWhitespace && !$0.isPunctuation }.count
        if specialCharCount > text.count / 4 {
            return true
        }
        
        // Check for repeated patterns (potential obfuscation)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let wordFrequency = Dictionary(grouping: words, by: { $0.lowercased() })
        for (_, occurrences) in wordFrequency {
            if occurrences.count > 5 && text.count > 50 {
                return true
            }
        }
        
        return false
    }
    
    /// Sanitize text by removing suspicious content
    static func sanitize(_ text: String) -> String {
        var sanitized = text
        
        // Remove suspicious patterns
        for pattern in suspiciousPatterns {
            sanitized = sanitized.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.caseInsensitive, .diacriticInsensitive]
            )
        }
        
        // Remove excessive whitespace
        sanitized = sanitized.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


