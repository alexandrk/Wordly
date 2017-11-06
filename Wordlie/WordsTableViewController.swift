//
//  WordsTableViewController.swift
//  Wordlie
//
//  Created by Alexander on 10/2/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit
import CoreData

class WordsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    
  @objc // Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let wordFetchRequest = NSFetchRequest<Word>(entityName: "Word")
        let primarySortDescriptor = NSSortDescriptor(key: #keyPath(Word.updatedAt), ascending: false)
        wordFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: wordFetchRequest,
            managedObjectContext: CoreData.moc,
            sectionNameKeyPath: #keyPath(Word.daySectionIdentifier),
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    // Called to reload data, if Fetched Results Controller data changed
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Using a simple color, since having a background gradient
        // on UITableView turned out to be overly complicated
        tableView.backgroundColor = UIColor(red: 175/255, green: 250/255, blue: 140/255, alpha: 1)
        tableView.register(WordTableViewCell.self, forCellReuseIdentifier: WordTableViewCell.reuseIdentifier)
        
        // Perform Fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }
    
    // MARK: - TableViewController Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }

        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    // Sets up Custom Section Header Title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle: String?
        if let sectionIdentifier = fetchedResultsController.sections?[section].name {
            if let numericSection = Int(sectionIdentifier) {
                // Parse the numericSection into its year/month/day components.
                let year = numericSection / 10000
                let month = (numericSection / 100) % 100
                let day = numericSection % 100
                
                // Reconstruct the date from these components.
                var components = DateComponents()
                components.calendar = Calendar.current
                components.day = day
                components.month = month
                components.year = year
                
                // Set the section title with this date
                if let date = components.date {
                    sectionTitle = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                }
            }
        }
        
        return sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.reuseIdentifier, for: indexPath) as! WordTableViewCell
        let word = fetchedResultsController.object(at: indexPath)
        
        // Configures Cell
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = word.name
        cell.detailTextLabel?.text = word.pronounciation
        
        return cell
    }
    
    // Shows details of the word that was tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = fetchedResultsController.object(at: indexPath)
        
        let viewCotroller = WordViewController()
        viewCotroller.wordMO = word
        viewCotroller.hideSearch = true
        navigationController?.pushViewController(viewCotroller, animated: true)
    }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          let word = fetchedResultsController.object(at: indexPath) as Word
          CoreData.moc.delete(word)
          CoreData.saveContext()
      }
  }
    
}
