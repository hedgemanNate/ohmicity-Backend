//
//  BusinessBannerAd.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 8/26/21.
//

import Foundation
import FirebaseFirestore

class BusinessBannerAd: Codable, Equatable {
    static func == (lhs: BusinessBannerAd, rhs: BusinessBannerAd) -> Bool {
        lhs.adID == rhs.adID
    }
    
    let adID: String
    var businessID: String?
    let businessName: String
    var image: Data
    var adLink: String
    var startDate: Date
    var endDate: Date
    var promotionalText: String
    var isPublished: Bool = true
    var lastModified = Timestamp()
    
    init(name: String, image: Data, link: String, start: Date, finish: Date, text: String) {
        self.adID = UUID().uuidString
        self.businessName = name
        self.image = image
        self.adLink = link
        self.startDate = start
        self.endDate = finish
        self.promotionalText = text
    }
}
