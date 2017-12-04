//
//  CustomTabBarController.swift
//  Wordlie
//
//  Created by Alexander on 10/2/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Word (Search) controller
        let wordController = WordViewController()
        let wordNavigationController = UINavigationController(rootViewController: wordController)
        wordController.navigationItem.title = Constants.App.WordControllerNavigationItemTitle
        
        wordNavigationController.tabBarItem.title = Constants.App.WordControllerTabBarItemTitle
        wordNavigationController.tabBarItem.image = #imageLiteral(resourceName: "search-icon")
        
        // Words (List) controller
        let wordsController = WordsTableViewController()
        let wordsNavigationController = UINavigationController(rootViewController: wordsController)
        wordsController.navigationItem.title = Constants.App.WordsControllerNavigationItemTitle
        
        wordsNavigationController.tabBarItem.title = Constants.App.WordsControllerTabBarItemTitle
        wordsNavigationController.tabBarItem.image = #imageLiteral(resourceName: "list-icon")
        
        viewControllers = [wordNavigationController, wordsNavigationController]
    }

}
