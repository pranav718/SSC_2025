//
//  SentimentAnalyzer.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 16/02/25.
//

import NaturalLanguage

class SentimentAnalyzer {
    static func analyzeSentiment(text: String) -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let(sentiment,_) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let score = Double(sentiment?.rawValue ?? "0") ?? 0
        
        if score > 0 {
            return "positive"
        }else if score < 0 {
            return "negative"
        }else {
            return "neutral"
        }
        
    }
}
