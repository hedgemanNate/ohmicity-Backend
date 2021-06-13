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
    
    var scheduleTextFieldsArray: [NSTextField] = []
    var businessTypeButtonsArray: [NSButton] = []
    
    @IBOutlet weak var tableView: NSTableView!
    var currentBusinessShows: [Show]?
    
    //Text Fields
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var phoneTextField: NSTextField!
    @IBOutlet weak var starsTextField: NSTextField!
    @IBOutlet weak var websiteTextField: NSTextField!
    
    //Schedule:
    @IBOutlet weak var mondayOpenTextField: NSTextField!
    @IBOutlet weak var tuesdayOpenTextField: NSTextField!
    @IBOutlet weak var wednesdayOpenTextField: NSTextField!
    @IBOutlet weak var thursdayOpenTextField: NSTextField!
    @IBOutlet weak var fridayOpenTextField: NSTextField!
    @IBOutlet weak var saturdayOpenTextField: NSTextField!
    @IBOutlet weak var sundayOpenTextField: NSTextField!
    
    //Buttons
    @IBOutlet weak var updateBusinessButton: NSButton!
    @IBOutlet weak var makeBusinessButton: NSButton!
    @IBOutlet weak var deleteShowButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPick: NSButton!
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var resetSaveButton: NSButton!
    @IBOutlet weak var logoImageView: NSImageView!
    //Genre
    @IBOutlet weak var resturantGenreButton: NSButton!
    @IBOutlet weak var barGenreButton: NSButton!
    @IBOutlet weak var clubGenreButton: NSButton!
    @IBOutlet weak var outdoorsGenreButton: NSButton!
    @IBOutlet weak var liveMusicGenreButton: NSButton!
    @IBOutlet weak var familyGenreButton: NSButton!
    
    
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
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        let stars = Double(starsTextField.stringValue) ?? 0
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        currentBusiness?.name = name
        currentBusiness?.address = address
        currentBusiness?.website = website
        currentBusiness?.phoneNumber = phoneNumber
        currentBusiness?.stars = stars
        if ohmPick.state == .on {
            currentBusiness?.ohmPick = true
        } else if ohmPick.state == .off {
            currentBusiness?.ohmPick = false
        }
        
        addScheduleAndBusinessType(business: currentBusiness!)
        guard let index = localDataController.businessArray.firstIndex(where: {$0.venueID == currentBusiness?.venueID}) else {return}
        localDataController.businessBasicArray[index].name = name
        localDataController.businessBasicArray[index].stars = stars
        //localDataController.businessBasicArray[index].logo = logo /*Preparing for logo*/
        
        localDataController.saveBusinessData()
        localDataController.saveBusinessBasicData()
        
    }
    
    @IBAction func makeBusinessButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = false
            self.resetSaveButton.isEnabled = true
        }
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        let stars = starsTextField.stringValue
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        let newBusiness = BusinessFullData(name: name, address: address, phoneNumber: phoneNumber, website: website)
        print("Business Created")
        
        newBusiness.stars = Double(stars)!
        addScheduleAndBusinessType(business: newBusiness)
        
        let newBusinessBasic = BusinessBasicData(venueID: newBusiness.venueID, name: newBusiness.name, logo: newBusiness.logo, stars: newBusiness.stars)
        
        localDataController.businessArray.append(newBusiness)
        localDataController.businessBasicArray.append(newBusinessBasic)
        localDataController.saveBusinessData()
        localDataController.saveBusinessBasicData()
        localDataController.saveShowData()
        activateDelete()
        notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        print("Save Button Tapped")
    }
    
    @IBAction func deleteShowButtonTapped(_ sender: Any) {
        //Will handle indivuals show deletes later. Once all businesses are entered into the data//
        
//        if tableView.selectedRow < 0 {
//            return print("No show selected")
//        } else {
//            let index = tableView.selectedRow
//            let selectedShow = currentBusinessShows?[index]
//            currentBusinessShows?.remove(at: index)
//
//            guard let removeIndex = localDataController.showArray.firstIndex(where: {$0.showID == selectedShow?.showID}) else {return print("No show found")}
//            localDataController.showArray.remove(at: removeIndex)
//
//            localDataController.saveShowData()
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
//            print("Show Deleted")
//        }
    }
    
    
    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
        localDataController.businessArray.removeAll(where: {$0 == currentBusiness})
        localDataController.businessBasicArray.removeAll(where: {$0.venueID == currentBusiness?.venueID})
        
        removeShows {
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("businessUpdated"), object: nil)
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        }
        
        localDataController.saveBusinessData()
        localDataController.saveBusinessBasicData()
        
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
            updateBusinessButton.isEnabled = false
            nameTextField.stringValue = currentVenue!.venueName!
            makeBusinessButton.isEnabled = true
            deleteButton.isEnabled = false
        } else if currentBusiness != nil {
            addBusinessHours()
            addBusinessType()
            updateBusinessButton.isEnabled = true
            makeBusinessButton.isEnabled = false
            nameTextField.stringValue = currentBusiness!.name
            addressTextField.stringValue = currentBusiness!.address
            phoneTextField.stringValue = String(currentBusiness!.phoneNumber)
            starsTextField.stringValue = String(currentBusiness?.stars ?? 0)
            websiteTextField.stringValue = currentBusiness!.website!
            
            mondayOpenTextField.stringValue = currentBusiness?.hours.Monday ?? "No Hours"
            tuesdayOpenTextField.stringValue = currentBusiness?.hours.Tuesday ?? "No Hours"
            wednesdayOpenTextField.stringValue = currentBusiness?.hours.Wednesday ?? "No Hours"
            thursdayOpenTextField.stringValue = currentBusiness?.hours.Thursday  ?? "No Hours"
            fridayOpenTextField.stringValue = currentBusiness?.hours.Friday ?? "No Hours"
            saturdayOpenTextField.stringValue = currentBusiness?.hours.Saturday ?? "No Hours"
            sundayOpenTextField.stringValue = currentBusiness?.hours.Sunday ?? "No Hours"
            //Initializing currentBusinessShows Array
            currentBusinessShows = localDataController.showArray.filter({$0.venue == currentBusiness?.name})
            
            if currentBusiness?.ohmPick == true {
                ohmPick.state = .on
            } else {
                ohmPick.state = .off
            }
        }
        
        //Text and Button Arrays
        scheduleTextFieldsArray = [
            mondayOpenTextField,
            tuesdayOpenTextField,
            wednesdayOpenTextField,
            thursdayOpenTextField,
            fridayOpenTextField,
            saturdayOpenTextField,
            sundayOpenTextField
        ]
        
        businessTypeButtonsArray = [
            resturantGenreButton,
            barGenreButton,
            clubGenreButton,
            outdoorsGenreButton,
            liveMusicGenreButton,
            familyGenreButton
        ]
        
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
                let convertedShow = Show(band: (jsonShow?.bandName)!, venue: (currentVenue?.venueName!)!, dateString: (jsonShow?.showTime!)!)
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
            //let showTime = currentShow?.dateString.replacingOccurrences(of: "\n", with: " ")
            cellView.textField?.stringValue = "\(currentShow?.dateString ?? "No Data") \(currentShow?.time ?? "")"
            return cellView
            
        }
        return nil
    }
}

//MARK: Helper Functions
extension VenueDetailViewController {
    
    private func removeShows(completion: @escaping () -> Void) {
        localDataController.showArray.removeAll(where: {$0.venue == currentBusiness?.name})
        completion()
    }
    
    private func addScheduleAndBusinessType(business: BusinessFullData) {
        var day = 1
        var type = 1
        
        for dateHours in self.scheduleTextFieldsArray {
            business.addBusinessHours(textField: dateHours, textFieldNumber: day)
            print("\(dateHours.stringValue)")
            print("day added")
            day += 1
        }
        
        for businessTypeButton in self.businessTypeButtonsArray {
            business.addAndRemoveBusinessType(button: businessTypeButton, typeNumber: type)
            type += 1
            print("genre added")
        }
    }
    
    private func addBusinessHours() {
        if currentBusiness != nil {
            mondayOpenTextField.stringValue = (currentBusiness?.hours.Monday)!
            tuesdayOpenTextField.stringValue = (currentBusiness?.hours.Tuesday)!
            wednesdayOpenTextField.stringValue = (currentBusiness?.hours.Wednesday)!
            thursdayOpenTextField.stringValue = (currentBusiness?.hours.Thursday)!
            fridayOpenTextField.stringValue = (currentBusiness?.hours.Friday)!
            saturdayOpenTextField.stringValue = (currentBusiness?.hours.Saturday)!
            sundayOpenTextField.stringValue = (currentBusiness?.hours.Sunday)!
        } else {
            mondayOpenTextField.stringValue = " "
            tuesdayOpenTextField.stringValue = " "
            wednesdayOpenTextField.stringValue = " "
            thursdayOpenTextField.stringValue = " "
            fridayOpenTextField.stringValue = " "
            saturdayOpenTextField.stringValue = " "
            sundayOpenTextField.stringValue = " "
        }
    }
    
    private func addBusinessType() {
        if currentBusiness != nil {
            for genre in currentBusiness!.businessType {
                switch genre {
                case .Resturant:
                    resturantGenreButton.state = .on
                case .Bar:
                    barGenreButton.state = .on
                case .Club:
                    clubGenreButton.state = .on
                case .Outdoors:
                    outdoorsGenreButton.state = .on
                case .LiveMusic:
                    liveMusicGenreButton.state = .on
                case .Family:
                    familyGenreButton.state = .on
                }
            }
            
        }
    }
}
