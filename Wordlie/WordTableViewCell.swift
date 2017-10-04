//
//  WordTableViewCell.swift
//  Wordlie
//
//  Created by Alexander on 10/2/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MyCustomWordCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
