//
//  BannerAd.swift
//  Ohmicity
//
//  Created by Nathan Hedgeman on 7/27/21.
//

import Foundation
import Cocoa
import FirebaseFirestore
import FirebaseFirestoreSwift


//MARK: Front End Model has a UIImage property
class BannerAd: Equatable {
    static func == (lhs: BannerAd, rhs: BannerAd) -> Bool {
        lhs.bannerAdID == rhs.bannerAdID
    }
    
    //Properties
    let bannerAdID: String
    var imageData: Data?
    let businessID: String
    var lastModified: Timestamp?
    //var image: NSImage?
    
    
    init(_with data: Data, businessID: String) {
        self.bannerAdID = UUID().uuidString
        self.imageData = data
        self.businessID = businessID
    }
    
    init(_with image: NSImage, businessID: String) {
        self.bannerAdID = UUID().uuidString
        self.businessID = businessID
        //self.image = image
    }
}
