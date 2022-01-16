//
//  ProductionShows.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/16/22.
//

import Foundation

struct AllProductionShows: Codable {
    var allProductionShowsID : String = "EB7BD27C-15EA-43A5-866A-BF6883D0DD67"
    var shows: [SingleProductionShow]
}

struct SingleProductionShow: Codable{
    let showID: String
    let venue: String
    let band: String
    let collaboration: [String]
    let bandDisplayName: String
    let date: Date
    let ohmPick: Bool
}


struct ShowsData2: Codable {
    let shows: [ShowData]
}

struct ShowData2: Codable, Hashable {
    let venue: String
    let band: String
    let dateString: String
}


