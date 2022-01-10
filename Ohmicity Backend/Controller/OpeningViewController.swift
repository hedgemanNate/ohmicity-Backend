//
//  OpeningViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/7/22.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase

class OpeningViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        localDataController.loadBandData()
        localDataController.loadJsonData()
        localDataController.loadShowData()
        localDataController.loadBusinessData()
        localDataController.loadBandTagData()
        localDataController.loadVenueTagData()
    }
    
}
