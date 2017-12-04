//
//  WordEntityExtension.swift
//  Wordlie
//
//  Created by Alexander on 10/3/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import CoreData

extension Word {
    
    /**
     Transient property for grouping a table into sections based on **updateAt** date
     */
    @objc public var daySectionIdentifier: String? {
        let currentCalendar = Calendar.current
        self.willAccessValue(forKey: "daySectionIdentifier")
        var sectionIdentifier = ""
        if let date = self.updatedAt as Date? {
            let day = currentCalendar.component(.day, from: date)
            let month = currentCalendar.component(.month, from: date)
            let year = currentCalendar.component(.year, from: date)
            
            // Construct integer from year, month, day. Convert to string.
            sectionIdentifier = "\(year * 10000 + month * 100 + day)"
        }
        self.didAccessValue(forKey: "daySectionIdentifier")
        
        return sectionIdentifier
    }
    
}
