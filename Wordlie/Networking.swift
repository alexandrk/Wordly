//
//  Networking.swift
//  Wordlie
//
//  API Related Methods
//
//  Created by Alexander on 10/1/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit
import Alamofire

enum WordAPIResult {
    case success([String: AnyObject])
    case failure(Error)
}

enum NetworkingErrors: Error {
    case ParsingJson(message: String)
}

class Networking: NSObject {

    /**
     Sends an API request and prepares the response for the completion handler
     - Parameter word: Word to search for the definition
     - Parameter completion: Completion handler for when the response comes back
     */
    static func sendWordDefinitionAPIRequest(word:String, completion: @escaping (WordAPIResult) -> Void) {
        let requestURL:String = "\(Constants.WordsAPIEndPoint)\(word)"
        
        // API Call
        Alamofire
            .request(requestURL, headers: [Constants.MashapeKeyKey: OutOfSourceControl.WordsAPIMashapeKey])
            .validate(statusCode: 200..<300)
            .responseJSON { response  in
        
                // If error
                if response.error != nil || response.result.error != nil {
                    completion(.failure((response.error == nil) ? response.error! : response.result.error!))
                }
                
                // If success
                if let json = response.result.value as? [String: AnyObject] {
                    completion(.success(json))
                }
        }
        
    }
    
    /**
     Parses the response and saves data into the CoreData
     - Parameter json: response object
     */
    static func parseWordsAPIResponse(json: [String: AnyObject]) throws -> Word {
        
        // Minimal required data checks
        guard let results = json[Constants.Response.Keys.Results] as? [[String: AnyObject]] else {
            throw NetworkingErrors.ParsingJson(message: "Definition Missing")
        }
        
        // Get the value from results
        guard let word = json[Constants.Response.Keys.Word] as? String, word.characters.count > 0 else {
            throw NetworkingErrors.ParsingJson(message: "Error parsing '.word' key")
        }
        
        // Create Word Managed Object and start filling it out
        let wordMO = CoreData.createWordObj()
        
        wordMO.name = word
        
        let createdAt = NSDate()
        wordMO.createdAt = createdAt
        wordMO.updatedAt = createdAt
        
        // TODO: Save syllabuls as well
        
        // Frequency
        if let frequency = json[Constants.Response.Keys.Frequency] as? Double {
            wordMO.frequency = frequency
        }
        
        // Pronounciation
        if  let prono = json[Constants.Response.Keys.PronunciationWrapper] as? [String: String],
            let pronounciation = prono[Constants.Response.Keys.PronunciationAll],
            pronounciation.characters.count > 0
        {
                wordMO.pronounciation = pronounciation
        }
        
        for result in results {

            // Definition
            if let definition = result[Constants.Response.Keys.Definition] as? String {
                let definitionMO = CoreData.createDefinitionObj()
                definitionMO.definition = definition
            
                // Examples
                if let examples = result[Constants.Response.Keys.Examples] as? [String] {
                    for example in examples {
                        let exampleMO = CoreData.createExampleObj()
                        exampleMO.example = example
                        exampleMO.definition = definitionMO
                    }
                }
        
                // Part Of Speech
                if let partOfSpeech = result[Constants.Response.Keys.PartOfSpeech] as? String {
                    definitionMO.partOfSpeech = partOfSpeech
                }
                
                // Synonyms
                if let synonyms = result[Constants.Response.Keys.Synonyms] as? [String] {
                    var allSynonyms = [String]()
                    for synonym in synonyms {
                        allSynonyms.append(synonym)
                    }
                    definitionMO.synonyms = allSynonyms as [NSString]
                }
        
                wordMO.addToDefinitions(definitionMO)
            } // definition
            
        } // for in loop on the results
    
        // Save data to CoreData
        CoreData.saveContext()
        
        return wordMO
    }
}
