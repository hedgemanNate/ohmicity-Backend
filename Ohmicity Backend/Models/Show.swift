//
//  Show.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/4/21.
//

import Foundation

struct Show: Codable, Equatable {
    var showID: String = UUID().uuidString
    let band: String
    let venue: String
    let showTime: String
    var ohmPick: Bool = false
}
