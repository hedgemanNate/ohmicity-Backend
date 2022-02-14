//
//  ProductionData.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/16/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

//MARK: Shows
class AllProductionShows: Codable {
    var allProductionShowsID : String = "EB7BD27C-15EA-43A5-866A-BF6883D0DD67"
    var shows: [SingleProductionShow]
    
    init(shows:[SingleProductionShow]) {
        self.shows = shows
    }
}

struct SingleProductionShow: Codable, Equatable {
    let showID: String
    let venue: String
    let band: String
    var collaboration: [String]?
    let bandDisplayName: String
    let date: Date
    let ohmPick: Bool
    
    init(showID: String, venue: String, band: String, collaboration: [String]?, bandDisplayName: String, date: Date, ohmPick: Bool) {
        
        self.showID = showID
        self.venue = venue
        self.band = band
        self.collaboration = collaboration
        self.bandDisplayName = bandDisplayName
        self.date = date
        self.ohmPick = ohmPick
    }
}


//MARK: Bands
struct GroupOfProductionBands: Codable, Equatable {
    var groupOfProductionBandsID : String = UUID().uuidString
    var bands: [SingleProductionBand]
    
    init(bands:[SingleProductionBand]) {
        self.bands = bands
    }
}

struct SingleProductionBand: Codable, Equatable {
    let bandID: String
    let name: String
    let photo: Data?
    let genre: [Genre]
    var mediaLink: String?
    let ohmPick: Bool
    let special: Bool
    
    init(bandID: String, name: String, photo: Data?, genre: [Genre], mediaLink: String?, ohmPick: Bool) {
        
        self.bandID = bandID
        self.name = name
        self.photo = photo
        self.genre = genre
        self.mediaLink = mediaLink
        self.ohmPick = ohmPick
        self.special = false
    }
}


//MARK: Venues
class AllProductionVenues: Codable {
    var allProductionVenuesID : String = "VP39XJ2L-90W5K-JG70-A3MC-0DI4P94ZWW3R"
    var venues: [SingleProductionVenue]
    
    init(venues:[SingleProductionVenue]) {
        self.venues = venues
    }
}

struct SingleProductionVenue: Codable, Equatable {
    let venueID: String
    var name: String
    var address: String = ""
    var city: [City] = []
    var phoneNumber: Int = 0
    var hours: Hours?
    var logo: Data?
    var pics: [Data] = []
    var customer: Bool = false
    var ohmPick: Bool = false
    var website: String = ""
    var businessType: [BusinessType] = []
    
    init(venueID: String, name: String, address: String, city: [City], phoneNumber: Int, hours: Hours, logo: Data, pics: [Data], customer: Bool, website: String, ohmPick: Bool, businessType: [BusinessType]) {
        
        self.venueID = venueID
        self.name = name
        self.address = address
        self.city = city
        self.phoneNumber = phoneNumber
        self.hours = hours
        self.logo = logo
        self.pics = pics
        self.customer = customer
        self.ohmPick = ohmPick
        self.website = website
        self.businessType = businessType
    }
}


