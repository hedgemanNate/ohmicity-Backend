//
//  Shows.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation

struct Venue: Codable {
    let venue: [DoData]
}

struct DoData: Codable {
    let venueName: String
    let shows: [Show]?
}

struct Show: Codable {
    let bandName: String?
    let showTime: String?
}
