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
    
    //Views
    @IBOutlet weak var bandLight: NSBox!
    @IBOutlet weak var showLight: NSBox!
    
    @IBOutlet weak var utilityButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(checkIfBandDataIsReady), name: NSNotification.Name("GotShowData"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(checkIfShowDataIsReady), name: NSNotification.Name("GotBandData"), object: nil)
        updateViews()
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        RemoteDataController.getRemoteBandData()
        RemoteDataController.getRemoteShowData()
        
        
    }
    
    func updateViews() {
        bandLight.fillColor = .red
        showLight.fillColor = .red
        
        
        LocalBackupDataStorageController.loadJsonData()
        LocalBackupDataStorageController.loadShowData()
        LocalBackupDataStorageController.loadBusinessData()
        LocalBackupDataStorageController.loadBandTagData()
        LocalBackupDataStorageController.loadVenueTagData()
    }
    
    @objc private func checkIfBandDataIsReady() {
        showsDone = true
        if bandsDone == true {
            utilityButton.isEnabled = true
            editButton.isEnabled = true
        }
    }
    
    @objc private func checkIfShowDataIsReady() {
        bandsDone = true
        if showsDone == true {
            utilityButton.isEnabled = true
            editButton.isEnabled = true
        }
    }
}
