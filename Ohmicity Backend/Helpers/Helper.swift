//
//  Helper.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/6/21.
//

import Foundation
import FirebaseFirestore


//MARK: Singletons
let notificationCenter = NotificationCenter.default

//let dateFormat1 = "E, MMMM d, yyyy ha"
//let dateFormat2 = "MMMM d, yyyy ha"
//let dateFormat3 = "MMMM d, yyyy"
let dateFormat4 = "MMM d, yyyy h:mma"
let dateFormatDay = "E"
let dateFormatShowInfo = "E, MMMM d, h:mma"

let dateFormatter = DateFormatter()

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
