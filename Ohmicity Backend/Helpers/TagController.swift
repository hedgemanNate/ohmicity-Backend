//
//  TagController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Foundation

class TagController {
    
    //Properties
    var bandTags = [BandTag]()
    var venueTags = [VenueTag]()
    
    
    func scanBandTags(band: String) -> Band {
        let newBand = Band(name: band)
        
        for bandTag in bandTags {
            
            if bandTag.variations.contains(band) {
                guard let foundBand = localDataController.bandArray.first(where: {$0.bandID == bandTag.bandID}) else { return newBand }
                
                return foundBand
            }
        }
        
        return newBand
    }
    
    func scanVenueTags(venue: String) -> BusinessFullData {
        let newVenue = BusinessFullData(name: venue, address: "Blank", phoneNumber: 0, website: "Blank")
        
        for venueTag in venueTags {
            
            if venueTag.variations.contains(venue) {
                guard let foundVenue = localDataController.businessArray.first(where: {$0.venueID == venueTag.venueID}) else { return newVenue }
                
                return foundVenue
            }
        }
        
        return newVenue
    }
}

let tagController = TagController()
