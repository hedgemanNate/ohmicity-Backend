//
//  Shows.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation

struct Venue: Codable {
    var venue: [RawJSON]
}

struct RawJSON: Codable, Equatable, Hashable {
    static func == (lhs: RawJSON, rhs: RawJSON) -> Bool {
        return lhs.venueName == rhs.venueName
    }
    
    let venueName: String?
    let shows: [ShowJSON]?
    var delete: Bool?
}

struct ShowJSON: Codable, Hashable {
    let band: String?
    let dateString: String?
}

struct ShowData: Codable, Hashable {
    let venue: String
    let band: String
    let dateString: String
}
