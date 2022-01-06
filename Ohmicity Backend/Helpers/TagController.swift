//
//  TagController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Foundation

class TagController {
    
    //Properties
    var bandTags = [BandTags]()
    var venueTags = [VenueTags]()
    
    
    func scanBandTags(band: String) -> Band {
        let blankBand = Band(name: band)
        
        for bandTag in bandTags {
            
            if bandTag.variations.contains(band) {
                guard let foundBand = localDataController.bandArray.first(where: {$0.bandID == bandTag.bandID}) else { return blankBand }
                
                return foundBand
            }
        }
        
        return blankBand
    }
    
    func scanVenueTags(venue: String) -> BusinessFullData {
        let blankVenue = BusinessFullData(name: "Blank", address: "Blank", phoneNumber: 0, website: "Blank")
        
        for venueTag in venueTags {
            
            if venueTag.variations.contains(venue) {
                guard let foundVenue = localDataController.businessArray.first(where: {$0.venueID == venueTag.venueID}) else { return blankVenue }
                
                return foundVenue
            }
        }
        
        return blankVenue
    }
}

let tagController = TagController()
