//
//  ViewController.swift
//  Wordlie
//
//  Created by Alexander on 9/11/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

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
    
    var wordFieldWidthConstraint: NSLayoutConstraint?
    var wordFieldYConstraint: NSLayoutConstraint?
    var searchButtonYConstraint: NSLayoutConstraint?
    
    func searchButtonClick() {
        
        // Check if the field is not empty
        guard let word = wordField.text, word.characters.count > 0 else {
            infoLabel.text = "Please enter a word you want the definion for into the text field above"
            return
        }
        
        infoLabel.text = ""
        
        // Lookup the word definition from the API
        let requestURL = "\(Constants.WordsAPIEndPoint)\(word)"
        Alamofire
            .request(requestURL, headers: [Constants.MashapeKeyKey: OutOfSourceControl.wordsAPIMashapeKey])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            
                self.activityIndicator.stopAnimating()
                self.textView.isHidden = false
                self.saveButton.isHidden = false
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
                //debugPrint(response)
                
                print(response.value)
                
                if let json = response.result.value as? [String: AnyObject] {
                    
                    let largeFont = UIFont(name: "PingFangHK-Semibold", size: 20.0)!
                    let smallFont = UIFont(name: "PingFangHK-Regular", size: 18)!
                    let highlightAttributes = [NSFontAttributeName: largeFont]
                    let regularAttributes = [NSFontAttributeName: smallFont]
                    let finalOutput = NSMutableAttributedString()
                    
                    //let word = Word()
                    
                    if let frequency = json["frequency"] {
                        let highlightedAS = NSAttributedString(string: "Usage Frequency: ", attributes: highlightAttributes)
                        let regularAS = NSAttributedString(string: "\(frequency) out of 7", attributes: regularAttributes)
                        finalOutput.append(highlightedAS)
                        finalOutput.append(regularAS)
                    }
                    
                    if let pronunciation = json["pronunciation"] as? [String: String],
                        let allPronunce = pronunciation["all"] {
                        
                        let highlightedAS = NSAttributedString(string: "\n\nPronunciation: ", attributes: highlightAttributes)
                        let regularAS = NSAttributedString(string: "[\(allPronunce)]", attributes: regularAttributes)
                        finalOutput.append(highlightedAS)
                        finalOutput.append(regularAS)
                    }
                    
                    if let results = json["results"] as? [[String: AnyObject]] {
                        for (index, result) in results.enumerated() {
                            
                            if let definition = result["definition"] as? String {
                                
                                let highlightedAS = NSAttributedString(string: "\n\nDefinition #\(index+1): ", attributes: highlightAttributes)
                                let regularAS = NSAttributedString(string: "\(definition)\n", attributes: regularAttributes)
                                finalOutput.append(highlightedAS)
                                finalOutput.append(regularAS)
                            }
                            
                            if let examples = result["examples"] as? [String] {
                                var allExamples = String()
                                for example in examples {
                                    allExamples += "\(example)"
                                }
                                let highlightedAS = NSAttributedString(string: "\nExamples: ", attributes: highlightAttributes)
                                let regularAS = NSAttributedString(string: "\(allExamples)", attributes: regularAttributes)
                                finalOutput.append(highlightedAS)
                                finalOutput.append(regularAS)
                            }

                            if let type = result["partOfSpeech"] as? String {
                                let highlightedAS = NSAttributedString(string: "\nPart of Speech (Type): ", attributes: highlightAttributes)
                                let regularAS = NSAttributedString(string: "\(type)", attributes: regularAttributes)
                                finalOutput.append(highlightedAS)
                                finalOutput.append(regularAS)
                            }

                            if let synonyms = result["synonyms"] as? [String] {
                                var allSynonyms = String()
                                for synonym in synonyms {
                                    allSynonyms += "\n\t\(synonym)"
                                }
                                let highlightedAS = NSAttributedString(string: "\nSynonums: ", attributes: highlightAttributes)
                                let regularAS = NSAttributedString(string: "\(allSynonyms)", attributes: regularAttributes)
                                finalOutput.append(highlightedAS)
                                finalOutput.append(regularAS)
                            }
                        }
                    }
                    self.textView.attributedText = finalOutput
                    
                }
        }
        animateConstraints()
        activityIndicator.startAnimating()
    }
    
    func saveButtonClick() {
        print("Save button clicked")
        
        // Save data to CoreData
        
    }
    
    func animateConstraints() {
        
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
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
    }
    
}

