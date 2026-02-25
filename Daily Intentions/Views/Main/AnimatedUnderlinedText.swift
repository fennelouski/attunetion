//
//  AnimatedUnderlinedText.swift
//  Daily Intentions
//
//  Created by Nathan Fennel on 12/21/25.
//

import SwiftUI
import NaturalLanguage

// MARK: - Animated Underlined Text

struct AnimatedUnderlinedText: View {
    let text: String
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    
    @State private var words: [String] = []
    @State private var underlinedWordIndex: Int? = nil
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
            .overlay(
                WordUnderlineOverlay(
                    words: words,
                    underlinedIndex: underlinedWordIndex,
                    color: color
                )
            )
            .onAppear {
                parseWords()
                startUnderlineAnimation()
            }
    }
    
    private func parseWords() {
        let tagger = NLTokenizer(unit: .word)
        tagger.string = text
        
        var wordList: [String] = []
        tagger.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let word = String(text[range])
            wordList.append(word)
            return true
        }
        
        words = wordList
    }
    
    private func startUnderlineAnimation() {
        guard !words.isEmpty else { return }
        
        var currentIndex = 0
        
        func animateNextWord() {
            guard currentIndex < words.count else {
                // Restart from beginning after a brief pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    currentIndex = 0
                    animateNextWord()
                }
                return
            }
            
            let word = words[currentIndex]
            let characterCount = word.count
            let duration = Double(characterCount) * 0.2 // 200ms per character
            
            // Show underline
            withAnimation(.easeInOut(duration: duration)) {
                underlinedWordIndex = currentIndex
            }
            
            // Wait for underline to complete, then fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: 0.2)) {
                    underlinedWordIndex = nil
                }
                
                // Move to next word after fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentIndex += 1
                    animateNextWord()
                }
            }
        }
        
        animateNextWord()
    }
}
