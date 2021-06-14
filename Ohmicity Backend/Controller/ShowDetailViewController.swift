//
//  ShowDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa

class ShowDetailViewController: NSViewController {
    //Properties
    var currentShow: Show?
    
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var venueNameTextField: NSTextField!
    @IBOutlet weak var startTimeTextField: NSTextField!
    @IBOutlet weak var deleteButton: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if currentShow != nil {
            var editedShow = localDataController.showArray.first(where: {$0 == currentShow})
            editedShow?.dateString = startTimeTextField.stringValue
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        } else {
            let newShow = Show(band: bandNameTextField.stringValue, venue: venueNameTextField.stringValue, dateString: startTimeTextField.stringValue)
            localDataController.showArray.append(newShow)
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        }
    }
        
    
    //MARK: UpdateViews
    private func updateViews() {
        if currentShow != nil {
            bandNameTextField.stringValue = currentShow!.band
            venueNameTextField.stringValue = currentShow!.venue
            startTimeTextField.stringValue = currentShow!.dateString
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
}
