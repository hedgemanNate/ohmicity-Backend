//
//  TagController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Foundation

class TagController {
    
    //Properties
    static var bandTags = [BandTag]()
    static var venueTags = [VenueTag]()
    
    
    static func scanBandTags(bandName: String) -> Band {
        let newBand = Band(name: bandName)
        
        for bandTag in bandTags {
            
            if bandTag.variations.contains(bandName) {
                guard let foundBand = LocalDataStorageController.bandArray.first(where: {$0.bandID == bandTag.bandID}) else { continue }
                
                print(foundBand.name)
                return foundBand
            }
        }
        
        return newBand
    }
    
    static func scanVenueTags(venue: String) -> BusinessFullData {
        let newVenue = BusinessFullData(name: venue, address: "Blank", phoneNumber: 0, website: "Blank")
        
        for venueTag in venueTags {
            
            if venueTag.variations.contains(venue) {
                guard let foundVenue = LocalDataStorageController.venueArray.first(where: {$0.venueID == venueTag.venueID}) else { return newVenue }
                
                return foundVenue
            }
        }
        
        return newVenue
    }
}
