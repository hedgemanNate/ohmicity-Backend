//
//  ProductionShowController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/16/22.
//

import Foundation

class ProductionShowController {
    static var allShows = AllProductionShows(shows: [SingleProductionShow]())
}

class ProductionBandController {
    static var allBands = [GroupOfProductionBands]()
}

class ProductionVenueController {
    static var allVenues = AllProductionVenues(venues: [SingleProductionVenue]())
}
