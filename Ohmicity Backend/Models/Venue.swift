//
//  Venue.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import Cocoa

struct Business {
    let venueID: String
    var name: String
    var address: String
    var phoneNumber: Int
    var logo: NSImage
    var shows: [Show]?
    var ratings: [Rating]?
    var stars: Double?
    var customer: Bool
    var pick: Bool
}

struct Rating {
    let userID: String
    var stars: Int
    var review: String?
}
