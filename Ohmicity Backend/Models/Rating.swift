//
//  Reviews.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 7/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Rating: Codable {
    var ratingID: String
    var lastModified: Timestamp?
    let userID: String
    var stars: Int
    var review: String?
    
    init(ratingID: String, userID: String, stars: Int, review: String) {
        
        let ratingID = Firestore.firestore().collection("ratingData").document().documentID
        
        self.ratingID = ratingID
        self.userID = userID
        self.stars = stars
        self.review = review
    }
    
    private init?(ratingID: String, dictionary: [String : Any]) {
        guard let userID = dictionary["userID"] as? String,
              let stars = dictionary["stars"] as?  Int,
              let review = dictionary["review"] as? String else {return nil}
        
        self.ratingID = ratingID
        self.userID = userID
        self.stars = stars
        self.review = review
    }
}
