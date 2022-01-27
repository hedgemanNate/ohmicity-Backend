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
    //Properties
    var bandsDone = false { didSet{bandLight.fillColor = .green}}
    var showsDone = false { didSet{showLight.fillColor = .green}}
    var venuesDone = false { didSet{venueLight.fillColor = .green}}
    
    //Views
    @IBOutlet weak var bandLight: NSBox!
    @IBOutlet weak var showLight: NSBox!
    @IBOutlet weak var venueLight: NSBox!
    
    //Labels
    @IBOutlet weak var showLabel: NSTextField!
    @IBOutlet weak var bandLabel: NSTextField!
    @IBOutlet weak var venueLabel: NSTextField!
    
    
    @IBOutlet weak var utilityButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(showDataReady), name: NSNotification.Name("GotShowData"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(bandDataReady), name: NSNotification.Name("GotBandData"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(venueDataReady), name: NSNotification.Name("GotVenueData"), object: nil)
        
        updateViews()
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        RemoteDataController.getRemoteBandData()
        RemoteDataController.getRemoteShowData()
        RemoteDataController.getRemoteVenueData()
        
        
    }
    
    func updateViews() {
        bandLight.fillColor = .red
        showLight.fillColor = .red
        venueLight.fillColor = .red
        
        
        LocalBackupDataStorageController.loadJsonData()
        LocalBackupDataStorageController.loadShowData()
        LocalBackupDataStorageController.loadBusinessData()
        LocalBackupDataStorageController.loadBandTagData()
        LocalBackupDataStorageController.loadVenueTagData()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @objc private func checkIfDataIsReady() {
        
        if bandsDone == true && venuesDone == true && showsDone == true {
            utilityButton.isEnabled = true
            editButton.isEnabled = true
        }
    }
    
    @objc private func showDataReady() {
        showsDone = true
        showLabel.stringValue = "Show Data Ready"
        checkIfDataIsReady()
    }
    
    @objc private func bandDataReady() {
        bandsDone = true
        bandLabel.stringValue = "Band Data Ready"
        checkIfDataIsReady()
    }
    
    @objc private func venueDataReady() {
        venuesDone = true
        venueLabel.stringValue = "Venue Data Ready"
        checkIfDataIsReady()
    }
}
