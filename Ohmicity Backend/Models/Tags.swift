//
//  Tags.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Foundation

class BandTag: Codable {
    let bandID: String
    var variations: [String]
    
    init(band: Band) {
        self.bandID = band.bandID
        self.variations = [band.name]
    }
}

class VenueTag: Codable {
    let venueID: String
    var variations: [String]
    
    init(venueID: String, variations: [String]) {
        self.venueID = venueID
        self.variations = variations
    }
}
