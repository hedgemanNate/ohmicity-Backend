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
    @IBOutlet weak var startDateTextField: NSTextField!
    @IBOutlet weak var startTimeTextField: NSTextField!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPickButton: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if currentShow != nil {
            let editedShow = localDataController.showArray.first(where: {$0 == currentShow})
            editedShow?.dateString = startDateTextField.stringValue
            editedShow?.time = startTimeTextField.stringValue
            
            if ohmPickButton.state == .on {
                currentShow?.ohmPick = true
            } else {
                currentShow?.ohmPick = false
            }
            
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            localDataController.saveShowData()
        } else {
            let newShow = Show(band: bandNameTextField.stringValue, venue: venueNameTextField.stringValue, dateString: startDateTextField.stringValue)
            newShow.time = startTimeTextField.stringValue
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
            startDateTextField.stringValue = "\(currentShow!.dateString)"
            startTimeTextField.stringValue = "\(currentShow?.time ?? "No Time")"
            deleteButton.isEnabled = true
            
            switch currentShow?.ohmPick {
            
            case false:
                ohmPickButton.state = .off
            case true:
                ohmPickButton.state = .on
            case .none:
                return
            case .some(_):
                return
            }
        } else {
            deleteButton.isEnabled = false
        }
    }
    
}
