//
//  Venue.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import Cocoa

enum BusinessType: String, Codable {
    case Resturant
    case Bar
    case Club
    case Outdoors
    case LiveMusic = "Live Music"
    case Family = "Family Friendly"
}


struct BusinessFullData: Codable, Equatable {
    static func == (lhs: BusinessFullData, rhs: BusinessFullData) -> Bool {
        return lhs.venueID == rhs.venueID
    }
    
    var venueID: String = UUID().uuidString
    let name: String
    var address: String
    var phoneNumber: Int
    var hours: Hours?
    var logo: String?
    //var shows: [Show] = []
    var ratings: [Rating] = []
    var stars: Double = 0
    var customer: Bool = false
    var ohmPick: Bool = false
    var website: String?
    var businessType: BusinessType?
    
    init(name: String, address: String, phoneNumber: Int, website: String) {
        
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
    }
}

struct BusinessBasicData: Codable {
    var venueID: String
    var name: String
    var logo: String
    var stars: Double
    var shows: [Show] //To Query which places has shows today
}

struct Rating: Codable {
    let userID: String
    var stars: Int
    var review: String?
}

struct Hours: Codable {
    var Monday: String?
    var Tuesday: String?
    var Wednesday: String?
    var Thursday: String?
    var Friday: String?
    var Saturday: String?
    var Sunday: String?
}
