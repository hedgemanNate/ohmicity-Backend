//
//  OpeningViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/7/22.
//

import Cocoa

class OpeningViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        localDataController.loadBandData()
        localDataController.loadJsonData()
        localDataController.loadShowData()
        localDataController.loadBusinessData()
        localDataController.loadBandTagData()
        localDataController.loadVenueTagData()
    }
    
}
