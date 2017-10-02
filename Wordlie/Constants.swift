//
//  Constants.swift
//  Wordlie
//
//  Created by Alexander on 9/30/17.
//  Copyright © 2017 Dictality. All rights reserved.
//
import UIKit

struct Constants {

    static let WordsAPIEndPoint = "https://wordsapiv1.p.mashape.com/words/"
    static let MashapeKeyKey = "x-mashape-key"
    
    struct App {
        static let EmptyWordFieldErrorMessage = "Please enter a word you want the definion for into the text field above."
        static let LargeFont = UIFont(name: "PingFangHK-Semibold", size: 18.0)!
        static let SmallFont = UIFont(name: "PingFangHK-Regular", size: 16)!
        
        struct Spacing {
            static let Small: CGFloat = 10
            static let Medium: CGFloat = 30
        }
    }
    
    struct Response {
        struct Keys {
            static let Word = "word"
            static let Frequency = "frequency"
            static let PronunciationWrapper = "pronunciation"
            static let PronunciationAll = "all"
            static let Results = "results"
            static let Definition = "definition"
            static let Examples = "examples"
            static let PartOfSpeech = "partOfSpeech"
            static let Synonyms = "synonyms"
        }
    }
    
    struct CoreData {
        static let ModelName = "Model"
        
        struct Entities {
            static let Word = "Word"
            static let Vocabulary = "Vocabulary"
            static let Example = "Example"
            static let Definition = "Definition"
        }
    }
    
}
