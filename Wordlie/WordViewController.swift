//
//  WordViewController.swift
//  Wordlie
//
//  View Controler for Word Search and Display
//
//  Created by Alexander on 9/11/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {

    // MARK: - Properties
    
    var wordMO: Word?
    var hideSearch = false
    
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
        field.placeholder = Constants.App.WordFieldPlaceholderText
        field.font = Constants.App.MediumFont
        field.textAlignment = .center
        field.clearButtonMode = .whileEditing
        field.backgroundColor = Constants.App.TextFieldsBackgroundColor
        field.returnKeyType = .search
        field.layer.cornerRadius = 10
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.App.SearchButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.App.LargeFont
        button.layer.cornerRadius = 10
        button.backgroundColor = Constants.App.ButtonsBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonClick), for: .touchUpInside)
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.App.SmallFont
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
        view.font = Constants.App.SmallFont
        view.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        view.backgroundColor = Constants.App.TextFieldsBackgroundColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Animated Field Constraints
    
    var wordFieldWidthConstraint: NSLayoutConstraint?
    var wordFieldYConstraint: NSLayoutConstraint?
    var searchButtonYConstraint: NSLayoutConstraint?
    var constraintsAnimationHappened: Bool = false
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to keyboard events (keyboardWill[Show|Hide]), used to shift view
        // to display the bottom text field, while entering text into it
        subscribeToKeyboardNotifications()
        
        // Set textfield delegate
        wordField.delegate = self
        
        // Adding all the UI elements to the view
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(wordField)
        backgroundImageView.addSubview(searchButton)
        backgroundImageView.addSubview(infoLabel)
        backgroundImageView.addSubview(activityIndicator)
        backgroundImageView.addSubview(textView)
        
        setupLayout()
        
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
//        print(paths)
    }
    
    /**
     Used when controller is loaded from the WordsTableView
     */
    override func viewWillAppear(_ animated: Bool) {
        if wordMO != nil && hideSearch == true {
            
            navigationItem.title = wordMO?.name?.capitalized
            
            // Hide word search elements
            wordField.isHidden = true
            searchButton.isHidden = true
            
            wordField.alpha = 0
            
            wordFieldYConstraint?.isActive = false
            wordFieldYConstraint = wordField.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.App.Spacing.Small)
            wordFieldYConstraint?.isActive = true
            
            prepareToDisplay(wordMO!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard events
        unsubscribeFromKeyboardNotifications()
        
        // Makes sure hideSearch is set to default
        hideSearch = false
    }
    
    // MARK: - Button Click Event Handlers
    
    public func searchButtonClick() {
        
        // dispatches Notification to Hide keyboard
        if wordField.isFirstResponder {
            wordField.resignFirstResponder()
        }
        
        // Return if the wordField is empty
        guard let word = wordField.text?.trimmingCharacters(in: .whitespacesAndNewlines), word.characters.count > 0 else {
            infoLabel.text = Constants.App.EmptyWordFieldErrorMessage
            return
        }
        wordField.text = word // Assigns trimmed value back to the field
        
        // Clear out the info label
        infoLabel.text = ""
        
        // If the word is already in the Database (previously searched), return it
        if let wordExists = CoreData.checkIfWordExists(word: word), wordExists.count > 0{
            animateConstraints()
            prepareToDisplay(wordExists.first!)
        }
        else {
            // Lookup the word definition from the API
            Networking.sendWordDefinitionAPIRequest(word: word){results in
                
                // Stop the activity indicator
                self.activityIndicator.stopAnimating()
                
                // Check results of the response of an API call
                switch results {
                    case .failure:
                        self.infoLabel.text = Constants.App.NetworkErrorErrorMessage
                    
                    case let .success(resultsJson):
                        do {
                            // Parse the response
                            self.wordMO = try Networking.parseWordsAPIResponse(json: resultsJson)
                        }
                        catch {
                            var labelText = String()
                            switch error as! NetworkingErrors {
                            case .ParsingJsonDefinitionMissing:
                              labelText = Constants.App.NoWordFoundErrorMessage
                            case .ParsingJsonWordKeyMissing:
                              labelText = Constants.App.ParsingJsonErrorMessage
                            }
                            self.infoLabel.text = labelText
                            return
                        }
                        self.prepareToDisplay(self.wordMO!)
                }
            }
            
            // Done after an API call is dispatched
            self.textView.text = ""
            self.textView.isHidden = true
            animateConstraints()
            activityIndicator.startAnimating()
        }
    }
    
    
    // MARK: - Helper Functions
    private func prepareToDisplay(_ wordMO: Word) {
        self.textView.isHidden = false
        displayWordInfo(wordMO)
    }
    
    /**
     Formats the Core Data Word Managed Object data, before displaying it in the textView
     - Parameter word: Word Managed Object
     */
    private func displayWordInfo(_ word: Word) {
        let highlight = [NSFontAttributeName: Constants.App.SmallBoldFont]
        let regular = [NSFontAttributeName: Constants.App.SmallFont]
        let finalOutput = NSMutableAttributedString()
        
        // Word Frequency
        if word.frequency > 0 {
            let highlightedAS = NSAttributedString(string: "Usage Frequency: ", attributes: highlight)
            let regularAS = NSAttributedString(string: "\(word.frequency) out of 7", attributes: regular)
            finalOutput.append(highlightedAS)
            finalOutput.append(regularAS)
        }
        
        // Word Pronunciation
        if let pronunciation = word.pronounciation, pronunciation.characters.count > 0 {
            let highlightedAS = NSAttributedString(string: "\n\nPronunciation: ", attributes: highlight)
            let regularAS = NSAttributedString(string: "[\(pronunciation)]", attributes: regular)
            finalOutput.append(highlightedAS)
            finalOutput.append(regularAS)
        }
        
        // Word Definitions
        if let definitions = word.definitions?.allObjects as? [Definition] {
            for (index, result) in definitions.enumerated() {
                
                if let definition = result.definition {
                    let highlightedAS = NSAttributedString(string: "\n\nDefinition #\(index+1): ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(definition)\n", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
                
                // Examples of definition usage
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
                
                // Words 'Part Of Speech' under current definition
                if let type = result.partOfSpeech {
                    let highlightedAS = NSAttributedString(string: "\nPart of Speech (Type): ", attributes: highlight)
                    let regularAS = NSAttributedString(string: "\(type)", attributes: regular)
                    finalOutput.append(highlightedAS)
                    finalOutput.append(regularAS)
                }
                
                // Words Synonyms
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
    
    /**
     Animates UI elements constrans, when the initial word search is performed
     */
    func animateConstraints() {
        
        if constraintsAnimationHappened {
            return
        }
        
        // Text Field
        wordFieldWidthConstraint?.isActive = false
        wordFieldWidthConstraint = wordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 16/25)
        wordFieldWidthConstraint?.isActive = true
        wordFieldYConstraint?.isActive = false
        wordFieldYConstraint = wordField.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.App.Spacing.Large + 10)
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
    
    // MARK: - Lauout
    
    func setupLayout() {
        
        // Background Image View
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // Text Field
        wordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -Constants.App.Spacing.Small).isActive = true
        wordFieldYConstraint = wordField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        wordFieldYConstraint?.isActive = true
        wordFieldWidthConstraint = wordField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: Constants.App.Spacing.Small)
        wordFieldWidthConstraint?.isActive = true
        wordField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Search Button
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.App.Spacing.Small).isActive = true
        searchButtonYConstraint = searchButton.topAnchor.constraint(equalTo: wordField.bottomAnchor, constant: Constants.App.Spacing.Medium)
        searchButtonYConstraint?.isActive = true
        searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        searchButton.heightAnchor.constraint(equalTo: wordField.heightAnchor).isActive = true
        
        // Info Label
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: Constants.App.Spacing.Medium).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        infoLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Activity Indicator
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Results Text View
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let topConstraint = textView.topAnchor.constraint(equalTo: wordField.bottomAnchor, constant: Constants.App.Spacing.Small)
        topConstraint.priority = 1000
        topConstraint.isActive = true
        
        let topConstraintToView = textView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.App.Spacing.Large)
        topConstraintToView.priority = 999
        topConstraintToView.isActive = true
    
        textView.topAnchor.constraint(equalTo: wordField.bottomAnchor, constant: Constants.App.Spacing.Small).isActive = true
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.App.Spacing.Medium).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.App.Spacing.Large).isActive = true
        
    }
    
}

