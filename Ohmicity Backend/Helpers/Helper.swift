//
//  Helper.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/6/21.
//

import Foundation


//MARK: Singletons
let notificationCenter = NotificationCenter.default

let dateFormat1 = "E, MMMM d, yyyy ha"
let dateFormat2 = "MMMM d, yyyy ha"
let dateFormat3 = "MMMM d, yyyy"
let dateFormat4 = "MMM d, yyyy h:ma"
let dateFormatDay = "E"
let dateFormatShowInfo = "E, MMMM d, h:mma"

let dateFormatter = DateFormatter()

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

