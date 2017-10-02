//
//  ViewController.swift
//  Wordlie
//
//  Created by Alexander on 9/11/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements Definitions
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "Background Gradient (Green)")
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let wordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter the word in question"
        field.font = UIFont(name: "PingFangHK-Semibold", size: 20)
        field.textAlignment = .center
        field.autocapitalizationType = .allCharacters
        field.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        field.layer.cornerRadius = 10
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Lookup", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangHK-Semibold", size: 20)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(red: 33/255, green: 145/255, blue: 33/255, alpha: 0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonClick), for: .touchUpInside)
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangHK-Semibold", size: 16)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.isEditable = false
        view.font = UIFont(name: "PingFangHK-Regular", size: 18)
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangHK-Semibold", size: 20)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(red: 33/255, green: 145/255, blue: 33/255, alpha: 0.6)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonClick), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Animated Field Constraints
    
    var wordFieldWidthConstraint: NSLayoutConstraint?
    var wordFieldYConstraint: NSLayoutConstraint?
    var searchButtonYConstraint: NSLayoutConstraint?
    var constraintsAnimationHappened: Bool = false
    
    // MARK: - Button Click Event Handlers
    func searchButtonClick() {
        
        var wordMO: Word?
        
        // Return if the wordField is empty
        guard let word = wordField.text, word.characters.count > 0 else {
            infoLabel.text = "Please enter a word you want the definion for into the text field above"
            return
        }
        
        // Clear out the info label
        infoLabel.text = ""
        
        // Check if the word is already in the Database (previously searched)
        if let wordExists = CoreData.checkIfWordExists(word: word), wordExists.count > 0{
            animateConstraints()
            prepareToDisplay(wordExists.first!)
        }
        else {
            
            // Lookup the word definition from the API
            Networking.sendWordDefinitionAPIRequest(word: word){results in
                self.activityIndicator.stopAnimating()
                
                switch results {
                    case let .failure(error):
                        self.infoLabel.text = "No results found.\nPlease try another word."
                        print(error)
                    
                    case let .success(resultsJson):
                        do {
                            wordMO = try Networking.parseWordsAPIResponse(json: resultsJson)
                        }
                        catch {
                            self.infoLabel.text = "No results found.\nPlease try another word."
                            return
                        }
                        self.prepareToDisplay(wordMO!)
                }
            }
            self.textView.text = ""
            self.textView.isHidden = true
            self.saveButton.isHidden = true
            animateConstraints()
            activityIndicator.startAnimating()
        }
    }
    
    func prepareToDisplay(_ wordMO: Word) {
        self.textView.isHidden = false
        self.saveButton.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        displayWordInfo(wordMO)
    }
    
    fileprivate func displayWordInfo(_ word: Word) {
        let highlight = [NSFontAttributeName: Constants.App.LargeFont]
        let regular = [NSFontAttributeName: Constants.App.SmallFont]
        let finalOutput = NSMutableAttributedString()
        
        if word.frequency > 0 {
            let highlightedAS = NSAttributedString(string: "Usage Frequency: ", attributes: highlight)
            let regularAS = NSAttributedString(string: "\(word.frequency) out of 7", attributes: regular)
            finalOutput.append(highlightedAS)
            finalOutput.append(regularAS)
        }
        
        if let pronunciation = word.pronounciation, pronunciation.characters.count > 0 {
            let highlightedAS = NSAttributedString(string: "\n\nPronunciation: ", attributes: highlight)
            let regularAS = NSAttributedString(string: "[\(pronunciation)]", attributes: regular)
            finalOutput.append(highlightedAS)
            finalOutput.append(regularAS)
        }
        
        if let definitions = word.definitions?.allObjects as? [Definition] {
            for (index, result) in definitions.enumerated() {
                
                if let definition = result.definition {
                    let highlightedAS = NSAttributedString(string: "\n\nDefinition #\(index+1): ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(definition)\n", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
                
                if let examples = result.examples?.allObjects as? [Example], examples.count > 0 {
                    var allExamples = String()
                    for example in examples {
                        if let exampleValue = example.example {
                            allExamples += "\(exampleValue)\n"
                        }
                    }
                    let highlightedAS = NSAttributedString(string: "\nExamples: ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(allExamples)", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
                
                if let type = result.partOfSpeech {
                    let highlightedAS = NSAttributedString(string: "\nPart of Speech (Type): ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(type)", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
                
                if let synonyms = result.synonyms as [String]? {
                    var allSynonyms = String()
                    for synonym in synonyms {
                        allSynonyms += "\n\t\(synonym)"
                    }
                    let highlightedAS = NSAttributedString(string: "\nSynonums: ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(allSynonyms)", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
            }
        }
        self.textView.attributedText = finalOutput
    }
    
    func saveButtonClick() {
        print("Save button clicked")
        // Add word to Vocabulary
    }
    
    func animateConstraints() {
        
        if constraintsAnimationHappened {
            return
        }
        // Text Field
        wordFieldWidthConstraint?.isActive = false
        wordFieldWidthConstraint = wordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 16/25)
        wordFieldWidthConstraint?.isActive = true
        wordFieldYConstraint?.isActive = false
        wordFieldYConstraint = wordField.topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
        wordFieldYConstraint?.isActive = true
        
        // Search Button
        searchButtonYConstraint?.isActive = false
        searchButtonYConstraint = searchButton.topAnchor.constraint(equalTo: wordField.topAnchor)
        searchButtonYConstraint?.isActive = true
        
        // Animate
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.constraintsAnimationHappened = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(wordField)
        backgroundImageView.addSubview(searchButton)
        backgroundImageView.addSubview(infoLabel)
        backgroundImageView.addSubview(activityIndicator)
        backgroundImageView.addSubview(textView)
        backgroundImageView.addSubview(saveButton)
        
        setupLayout()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        print(paths)
    }

    func setupLayout() {
        
        // Background Image View
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // Text Field
        wordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -10).isActive = true
        wordFieldYConstraint = wordField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        wordFieldYConstraint?.isActive = true
        wordFieldWidthConstraint = wordField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 10)
        wordFieldWidthConstraint?.isActive = true
        wordField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Search Button
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        searchButtonYConstraint = searchButton.topAnchor.constraint(equalTo: wordField.bottomAnchor, constant: 30)
        searchButtonYConstraint?.isActive = true
        searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        searchButton.heightAnchor.constraint(equalTo: wordField.heightAnchor).isActive = true
        
        // Info Label
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 30).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        infoLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Activity Indicator
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Results Text View
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: wordField.bottomAnchor, constant: 30).isActive = true
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -30).isActive = true
        
        // Save Button
        saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 15).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        saveButton.heightAnchor.constraint(equalTo: wordField.heightAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        
    }
    
}

