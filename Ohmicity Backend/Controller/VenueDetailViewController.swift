//
//  VenueDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/3/21.
//

import Foundation
import Cocoa

class VenueDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //MARK: Properties
    var currentVenue: RawJSON?
    var currentBusiness: BusinessFullData?
    
    @IBOutlet weak var tableView: NSTableView!
    var currentBusinessShows: [Show]?
    
    //Text Fields
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var phoneTextField: NSTextField!
    @IBOutlet weak var starsTextField: NSTextField!
    @IBOutlet weak var websiteTextField: NSTextField!
    
    //Buttons
    
    @IBOutlet weak var updateBusinessButton: NSButton!
    @IBOutlet weak var deleteShowButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPick: NSButton!
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var resetSaveButton: NSButton!
    @IBOutlet weak var logoImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
        
        if currentBusiness != nil {
            activateDelete()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    //MARK: Buttons Tapped
    @IBAction func resetSaveButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = true
            self.resetSaveButton.isEnabled = false
        }
    }
    
    @IBAction func updateBusinessButtonTapped(_ sender: Any) {
        var updated = currentBusiness
        
        localDataController.businessArray.map { $0.venueID == currentBusiness?.venueID ? $0 : updated}
    }
    
    @IBAction func saveBusinessButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = false
            self.resetSaveButton.isEnabled = true
        }
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        let newBusiness = BusinessFullData(name: name, address: address, phoneNumber: phoneNumber, website: website)
        print("Business Created")
        
        if currentVenue?.shows != [] {
            for show in (currentVenue?.shows)! {
                let newShow: Show = Show(
                    band:show.bandName!,
                    venue:(currentVenue?.venueName)!,
                    showTime: show.showTime!)
                
                localDataController.showArray.append(newShow)
                print("Show added to Business")
            }
        }
        
        localDataController.businessArray.append(newBusiness)
        localDataController.saveBusinessData()
        localDataController.saveShowData()
        activateDelete()
        notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        print("Save Button Tapped")
    }
    
    @IBAction func deleteShowButtonTapped(_ sender: Any) {
        if tableView.selectedRow < 0 {
            return print("No show selected")
        } else {
            let index = tableView.selectedRow
            let selectedShow = currentBusinessShows?[index]
            currentBusinessShows?.remove(at: index)
            
            guard let removeIndex = localDataController.showArray.firstIndex(where: {$0.showID == selectedShow?.showID}) else {return print("No show found")}
            localDataController.showArray.remove(at: removeIndex)
            
            localDataController.saveShowData()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            print("Show Deleted")
        }
    }
    
    
    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
        guard let index = localDataController.businessArray.firstIndex(where: {$0.venueID == currentBusiness?.venueID}) else {return}
        localDataController.businessArray.remove(at: index)
        localDataController.saveBusinessData()
        
        removeShows {
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("businessDeleted"), object: nil)
            notificationCenter.post(name: NSNotification.Name("showsDeleted"), object: nil)
        }
        
    }
    
    private func activateDelete() {
        DispatchQueue.main.async {
            self.deleteButton.isEnabled = true
        }
    }
    
    //MARK: UpdateViews
    func updateViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        if currentVenue != nil {
            nameTextField.stringValue = currentVenue!.venueName!
        } else if currentBusiness != nil {
            nameTextField.stringValue = currentBusiness!.name
            addressTextField.stringValue = currentBusiness!.address
            phoneTextField.stringValue = String(currentBusiness!.phoneNumber)
            starsTextField.stringValue = String(currentBusiness?.stars ?? 0)
            websiteTextField.stringValue = currentBusiness!.website!
            
            //Initializing currentBusinessArray
            currentBusinessShows = localDataController.showArray.filter({$0.venue == currentBusiness?.name})
        }
        deleteButton.isEnabled = false
        resetSaveButton.isEnabled = false
    }
    
}

//MARK: Tablview
extension VenueDetailViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if currentVenue != nil {
            return (currentVenue?.shows?.count) ?? 0
        } else if currentBusiness != nil {
            return currentBusinessShows?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var currentShow: Show? {
            if currentVenue != nil {
                
                let jsonShow = currentVenue?.shows![row]
                let convertedShow = Show(band: (jsonShow?.bandName)!, venue: (currentVenue?.venueName!)!, showTime: (jsonShow?.showTime!)!)
                return convertedShow
            } else if currentBusiness != nil {
                let currentBusinessShows = localDataController.showArray.filter({$0.venue == currentBusiness?.name})
                return currentBusinessShows[row]
            }
            return currentShow
        }
        
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Band") {
            let bandIdentifier = NSUserInterfaceItemIdentifier("BandCell")
            
            guard let cellView = tableView.makeView(withIdentifier: bandIdentifier, owner: self) as? NSTableCellView else {return nil}
            
            cellView.textField?.stringValue = currentShow?.band ?? "No Data"
            
            return cellView
            
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Time") {
            let showTimeIdentifier = NSUserInterfaceItemIdentifier("TimeCell")
            
            guard let cellView = tableView.makeView(withIdentifier: showTimeIdentifier, owner: self) as? NSTableCellView else {return nil}
            
            let showTime = currentShow?.showTime.replacingOccurrences(of: "\n", with: " ")
            
            cellView.textField?.stringValue = showTime ?? "No Data"
            
            return cellView
            
        }
        return nil
    }
}

//MARK: Helper Functions
extension VenueDetailViewController {
    
    private func removeShows(completion: @escaping () -> Void) {
        var number = 0
        for show in localDataController.showArray {
            if show.venue == currentBusiness?.name {
                let index = localDataController.showArray.firstIndex(where: {$0.showID == show.showID})
                localDataController.showArray.remove(at: index!)
                number += 1
            }
        }
        print("\(number) shows deleted")
        completion()
    }
}
