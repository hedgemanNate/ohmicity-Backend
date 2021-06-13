//
//  Band.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/4/21.
//

import Foundation
import Cocoa

enum Genre: String, Codable {
    case rock
    case blues
    case jazz
    case dance
    case reggae
    case country
    case funkSoul
    case edm
    case hiphop
    case dj
}

class Band: Codable, Equatable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.bandID == rhs.bandID
    }
    
    var bandID: String = UUID().uuidString
    var name: String
    var photo: String?
    var genre: [Genre] = []
    //var shows: [Show] = []
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
    
    func addAndRemoveGenreType(button: NSButton, genreNumber: Int) {
    //NOTES: Used with a loop function and number counter to check the state (on/off) of all buttons in the array. The loop adds the next button into this function along with the genre current number on the counter. Which decides which Genre is added/removed to/from the Bands Genre Array.
        
        switch genreNumber {
        case 1:
            if button.state == .on {
                genre.append(Genre.rock)
            } else {
                genre.removeAll(where: {$0 == Genre.rock})
            }
        case 2:
            if button.state == .on {
                genre.append(Genre.blues)
            } else {
                genre.removeAll(where: {$0 == Genre.blues})
            }
        case 3:
            if button.state == .on {
                genre.append(Genre.jazz)
            } else {
                genre.removeAll(where: {$0 == Genre.jazz})
            }
        case 4:
            if button.state == .on {
                genre.append(Genre.dance)
            } else {
                genre.removeAll(where: {$0 == Genre.dance})
            }
        case 5:
            if button.state == .on {
                genre.append(Genre.reggae)
            } else {
                genre.removeAll(where: {$0 == Genre.reggae})
            }
        case 6:
            if button.state == .on {
                genre.append(Genre.country)
            } else {
                genre.removeAll(where: {$0 == Genre.country})
            }
        case 7:
            if button.state == .on {
                genre.append(Genre.funkSoul)
            } else {
                genre.removeAll(where: {$0 == Genre.funkSoul})
            }
        case 8:
            if button.state == .on {
                genre.append(Genre.edm)
            } else {
                genre.removeAll(where: {$0 == Genre.edm})
            }
        case 9:
            if button.state == .on {
                genre.append(Genre.hiphop)
            } else {
                genre.removeAll(where: {$0 == Genre.hiphop})
            }
        case 10:
            if button.state == .on {
                genre.append(Genre.dj)
            } else {
                genre.removeAll(where: {$0 == Genre.dj})
            }
        default:
            break
        }
    }
}
