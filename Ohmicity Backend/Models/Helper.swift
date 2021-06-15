//
//  Helper.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/6/21.
//

import Foundation

let notificationCenter = NotificationCenter.default

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
