//
//  User.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import FirebaseFirestore

struct User {
    let userID: String
    var lastModified: Timestamp?
    var email: String
    var savedShows: [String] = []
    var favoriteBusinesses: [String] = []
    var favoriteBands: [String] = []
    var usedPromotions: [String] = []
    var paidServices: [String] = []
    var giftServices: [String] = []
    var adPoints: Int
}
