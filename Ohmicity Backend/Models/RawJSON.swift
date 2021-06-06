//
//  Shows.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation

struct Venue: Codable {
    let venue: [RawJSON]
}

struct RawJSON: Codable, Equatable, Hashable {
    static func == (lhs: RawJSON, rhs: RawJSON) -> Bool {
        return lhs.venueName == rhs.venueName
    }
    
    let venueName: String?
    let shows: [ShowJSON]?
}

struct ShowJSON: Codable, Hashable {
    let bandName: String?
    let showTime: String?
}
