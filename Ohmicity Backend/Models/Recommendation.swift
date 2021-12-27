//
//  Recommendation.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 7/9/21.
//

import Foundation

struct Recommendation: Codable, Equatable {
    static func == (lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.recommendationID == rhs.recommendationID
    }
    
    let businessName: String
    let explanation: String
    let recommendationID: String
    let user: String
    var save: Bool?
    
}
