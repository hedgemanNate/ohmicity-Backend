//
//  Band.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/4/21.
//

import Foundation
import FirebaseFirestore
import Cocoa

enum Genre: String, Codable {
    case Rock
    case Blues
    case Jazz
    case Dance
    case Reggae
    case Country
    case FunkSoul
    case EDM
    case HipHop
    case DJ
    case Pop
    case Metal
    case Experimental
    case JamBand
    case Gospel
    case EasyListening
    case NA
    case SynthPop = "Synth Pop"
    case RnB = "R&B"
    case Latin
    case Folk
    case Soul
    case Americana
    case ClassicRock = "Classic Rock"
    case World
    case Alternative = "Alternative Rock"
    case BlueGrass = "Bluegrass"
}

class Band: Codable, Equatable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.bandID == rhs.bandID
    }
    
    var bandID: String = UUID().uuidString
    var lastModified = Timestamp()
    var name: String
    var photo: Data?
    var genre: [Genre] = []
    var mediaLink: String?
    var ohmPick: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
    init(newBand: Band) {
        bandID = newBand.bandID
        name = newBand.name
        photo = newBand.photo
        genre = newBand.genre
        mediaLink = newBand.mediaLink
        ohmPick = newBand.ohmPick
    }
    
    init(name: String, mediaLink: String, ohmPick: NSButton.StateValue) {
        self.name = name
        self.mediaLink = mediaLink
        if ohmPick == .on {
            self.ohmPick = true
        } else {
            self.ohmPick = false
        }
    }
}
