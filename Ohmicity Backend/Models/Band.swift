//
//  Band.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/4/21.
//

import Foundation

enum Genre: String, Codable {
    case rock
    case blues
    case jazz
    case dance
    case reggae
    case country
    case bluegrass
    case techno
    case hiphop
    case rap
}

struct Band: Codable, Equatable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.bandID == rhs.bandID
    }
    
    var bandID: String = UUID().uuidString
    let name: String
    var photo: String?
    var genre: [Genre] = []
    //var shows: [Show] = []
    var ohmPick: Bool = false
    
    init(name: String) {
        self.name = name
    }
}
