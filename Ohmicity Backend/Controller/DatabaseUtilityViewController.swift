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
    
    
    @IBAction func pushBandsToDBButtonTapped(_ sender: Any) {
        
        for band in LocalDataStorageController.bandArray {
            do {
                try workRef.bandDataPath.document(band.bandID).setData(from: band, completion: { err in
                    if let err = err {
                        NSLog(err.localizedDescription)
                        self.messageTextField.stringValue = err.localizedDescription
                    }
                    self.messageTextField.stringValue = "Database Upload Completed"
                })
            } catch let error {
                self.messageTextField.stringValue = error.localizedDescription
            }
            
        }
    }
    
}
