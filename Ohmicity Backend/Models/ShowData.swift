//
//  Shows.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation

struct Shows: Codable {
    let shows: [ShowData]
}

struct ShowData: Codable, Hashable {
    let venue: String
    let band: String
    let dateString: String
}
