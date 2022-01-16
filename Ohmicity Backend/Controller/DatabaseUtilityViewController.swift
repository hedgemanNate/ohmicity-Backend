//
//  DatabaseUtilityViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/10/22.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseUtilityViewController: NSViewController {
    
    //Properties
    @IBOutlet weak var messageTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 780)
    }
    
    
    @IBAction func pushBandsToDevelopingDBButtonTapped(_ sender: Any) {
    outer: for band in RemoteDataController.bandArray {
            workRef.bandDataPath.document(band.bandID).delete { err in
                if let err = err {
                    self.messageTextField.stringValue = err.localizedDescription
                }
            }
        messageTextField.stringValue = "Bands Deleted From Database"
        }
        
        
        for band in LocalBackupDataStorageController.bandArray {
            do {
                try workRef.bandDataPath.document(band.bandID).setData(from: band, completion: { err in
                    if let err = err {
                        NSLog(err.localizedDescription)
                        self.messageTextField.stringValue = err.localizedDescription
                    }
                    self.messageTextField.stringValue = "Bands Upload to Database Completed"
                })
            } catch let error {
                self.messageTextField.stringValue = error.localizedDescription
            }
            
        }
    }
    
    @IBAction func pushVenuesToDevelopingDBButtonTapped(_ sender: Any) {
    }
    
    @IBAction func pushShowsToDevelopingDBButtonTapped(_ sender: Any) {
        for show in LocalBackupDataStorageController.showArray {
            do {
                try workRef.showDataPath.document(show.showID).setData(from: show, completion: { err in
                    if let err = err {
                        NSLog(err.localizedDescription)
                        self.messageTextField.stringValue = err.localizedDescription
                    }
                    self.messageTextField.stringValue = "Show Upload Completed"
                })
            } catch let error {
                self.messageTextField.stringValue = error.localizedDescription
            }
        }
    }
    
    @IBAction func pushAllShowsToDevelopingDBButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            let singleShow = SingleProductionShow(showID: show.showID, venue: show.venue, band: show.band, collaboration: [], bandDisplayName: show.bandDisplayName, date: show.date, ohmPick: show.ohmPick)
            ProductionShowController.allShows.shows.append(singleShow)
        }
        
        do {
            try workRef.allShowDataPath.document(ProductionShowController.allShows.allProductionShowsID).setData(from: ProductionShowController.allShows) { err in
                if let err = err {
                    self.messageTextField.stringValue = err.localizedDescription
                } else {
                    self.messageTextField.stringValue = "All Production Shows Pushed"
                }
            }
        } catch let error {
            self.messageTextField.stringValue = error.localizedDescription
        }
        
    }
    
    
    
    
}
