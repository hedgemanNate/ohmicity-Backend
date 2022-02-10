//
//  User.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/2/21.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Equatable {
    
    let userID: String
    var accountType: AccountType = .Consumer
    var subscription: SubscriptionType = .None
    var lastModified: Timestamp?
    var email: String
    var savedShows: [String] = []
    var favoriteBusinesses: [String] = []
    var favoriteBands: [String] = []
    var bandRatings: [UsersRatings]?
    var usedPromotions: [String] = []
    var paidServices: [String] = []
    var features: [Features]?
    var preferredCity: City?
    var recommendationBlackOutDate: Date?
    var recommendationCount: Int?
    var supportBlackOutDate: Date?
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.userID == rhs.userID
    }
}

enum AccountType: String, Codable, Equatable {
    case Consumer
    case Artist
    case Business
}

enum SubscriptionType: String, Codable, Equatable {
    case err
    case None
    case FrontRowPass = "Front Row Pass"
    case BackStagePass = "Backstage Pass"
    case FullAccessPass = "Full Access Pass"
}

enum Features: String, Codable {
    case Favorites
    case NoPopupAds
    case SeeAllData
    case XityDeals
    case ShowReminders
    case TodayShowFilter
    case Search
}

struct UsersRatings: Codable {
    var businessName: String?
    var bandName: String?
    var rating: Int
}
