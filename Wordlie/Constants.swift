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
        static let WordFieldPlaceholderText = "ENTER WORD"
        static let SearchButtonTitle = "Lookup"
        static let TextFieldsBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        static let ButtonsBackgroundColor = UIColor(red: 33/255, green: 145/255, blue: 33/255, alpha: 0.6)
        
        static let WordControllerNavigationItemTitle = "WORDIE"
        static let WordControllerTabBarItemTitle = "Search"
        
        static let WordsControllerNavigationItemTitle = "All Words"
        static let WordsControllerTabBarItemTitle = "Words"
        
        static let EmptyWordFieldErrorMessage = "Please enter a word you want the definion for into the text field above."
        static let NoWordFoundErrorMessage = "No results found.\nPlease try another word."
        static let ParsingJsonErrorMessage = "Error parsing the response.\nPlease contact the developer.\nSorry for the inconvenience."
        
        static let ExtraLargeBoldFont = UIFont(name: "PingFangHK-Semibold", size: 20.0)!
        static let ExtraLargeFont = UIFont(name: "PingFangHK-Regular", size: 20.0)!
        static let LargeBoldFont = UIFont(name: "PingFangHK-Semibold", size: 18.0)!
        static let LargeFont = UIFont(name: "PingFangHK-Regular", size: 18.0)!
        static let MediumBoldFont = UIFont(name: "PingFangHK-Semibold", size: 16.0)!
        static let MediumFont = UIFont(name: "PingFangHK-Regular", size: 16.0)!
        static let SmallBoldFont = UIFont(name: "PingFangHK-Semibold", size: 14)!
        static let SmallFont = UIFont(name: "PingFangHK-Regular", size: 14)!
        
        
        
        struct Spacing {
            static let Small: CGFloat = 10
            static let Medium: CGFloat = 30
            static let Large: CGFloat = 60
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
        static let DefaultVocabularyName = "General"
        
        struct Entities {
            static let Word = "Word"
            static let Vocabulary = "Vocabulary"
            static let Example = "Example"
            static let Definition = "Definition"
        }
    }
    
}
