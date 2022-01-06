//
//  Show.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/4/21.
//
import Cocoa
import Foundation
import FirebaseFirestore

struct Show: Codable, Equatable, Hashable {
    var showID: String
    var lastModified = Timestamp()
    var band: String
    var venue: String
    var city: [City]?
    var dateString: String
    var date = Date()
    var time = ""
    var onHold: Bool = false
    var ohmPick: Bool = false
    
    //Equatable Conformity
    static func == (lhs: Show, rhs: Show) -> Bool {
        return lhs.venue == rhs.venue && lhs.dateString == rhs.dateString && lhs.time == rhs.time
    }

    //Hashable Conformity
    func hash(into hasher: inout Hasher) {
        hasher.combine(showID)
    }
    
    
}
 
extension Show {
    
    init?(band: String, venue: String, dateString: String) {
        
        dateFormatter.dateFormat = dateFormat4
        guard let newDate = dateFormatter.date(from: dateString) else {return nil}
        
        let showID = Firestore.firestore().collection("showData").document().documentID
        self.showID = showID
        self.band = band
        self.venue = venue
        self.dateString = dateString
        self.date = newDate
    }
    
    init(band: String, venue: String, dateString: String, date: Date) {
        
        let showID = Firestore.firestore().collection("showData").document().documentID
        self.showID = showID
        self.band = band
        self.venue = venue
        self.dateString = dateString
        self.date = date
    }
    
}
