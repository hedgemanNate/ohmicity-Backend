//
//  VenueDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/3/21.
//

import Foundation
import Cocoa
import FirebaseFirestore
import FirebaseFirestoreSwift


class VenueDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    //MARK: Properties
    var cImage: NSImage?
    @IBOutlet weak var buttonBoxView: NSBox!
    @IBOutlet weak var remoteShowCheckLabel: NSTextField!
    
    
    var currentVenueShows: [Show]? {didSet{showsTableView.reloadData()}}
    var currentVenue: Venue? {didSet{updateViews()}}
    var venueFilterArray = [Venue]() {didSet{venueFilterArray.sort(by: {$0.name < $1.name}); venuesTableView.reloadData()}}
    var image: NSImage?
    var logoData: Data?
    var venuePicsData = [Data]() {didSet{collectionView.reloadData()}}
    
    var timer = Timer()
    
    var scheduleTextFieldsArray: [NSTextField] = []
    var venueTypeButtonsArray: [NSButton] = []
    var venueCityArray = [City]()
    var venueTypeArray = [BusinessType]()
    
    //TableViews
    @IBOutlet weak var showsTableView: NSTableView!
    @IBOutlet weak var venuesTableView: NSTableView!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    //Text Fields
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var phoneTextField: NSTextField!
    @IBOutlet weak var websiteTextField: NSTextField!
    @IBOutlet weak var messageCenter: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchFieldCell!
    
    
    //Schedule:
    @IBOutlet weak var mondayOpenTextField: NSTextField!
    @IBOutlet weak var tuesdayOpenTextField: NSTextField!
    @IBOutlet weak var wednesdayOpenTextField: NSTextField!
    @IBOutlet weak var thursdayOpenTextField: NSTextField!
    @IBOutlet weak var fridayOpenTextField: NSTextField!
    @IBOutlet weak var saturdayOpenTextField: NSTextField!
    @IBOutlet weak var sundayOpenTextField: NSTextField!
    
    //Buttons
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var ohmPick: NSButton!
    @IBOutlet weak var loadLogoButton: NSButton!
    @IBOutlet weak var loadPicturesButton: NSButton!
    @IBOutlet weak var deletePicsButton: NSButton!
    
    @IBOutlet weak var restaurantButton: NSButton!
    @IBOutlet weak var barButton: NSButton!
    @IBOutlet weak var clubButton: NSButton!
    @IBOutlet weak var outdoorsButton: NSButton!
    @IBOutlet weak var liveMusicButton: NSButton!
    @IBOutlet weak var familyButton: NSButton!
    var venueTypeButtonArray = [NSButton]()
    
    @IBOutlet weak var remoteRadioButton: NSButton!
    @IBOutlet weak var backupRadioButton: NSButton!
    
    @IBOutlet weak var backupSafetySwitch: NSButton!
    @IBOutlet weak var saveBackupButton: NSButton!
    @IBOutlet weak var loadBackupButton: NSButton!
    
    
    //Pictures
    @IBOutlet weak var logoImageView: NSImageView!
    
    //City
    @IBOutlet weak var veniceButton: NSButton!
    @IBOutlet weak var sarasotaButton: NSButton!
    @IBOutlet weak var bradentonButton: NSButton!
    @IBOutlet weak var stPeteButton: NSButton!
    @IBOutlet weak var tampaButton: NSButton!
    @IBOutlet weak var yborButton: NSButton!
    var cityArray = [NSButton]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 860)
        updateViews()
        venuesTableView.doubleAction = #selector(doubleClicked)
        
        cityArray = [veniceButton, sarasotaButton, bradentonButton, stPeteButton, tampaButton, yborButton]
        venueTypeButtonArray = [restaurantButton, barButton, clubButton, outdoorsButton, liveMusicButton, familyButton]
        
        showsTableView.delegate = self
        showsTableView.dataSource = self
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        venueFilterArray = RemoteDataController.venueArray
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        showsTableView.reloadData()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    //MARK: UpdateViews
    func updateViews() {
        collectionView.reloadData()
        showsTableView.reloadData()
        
        //Text Fields
        scheduleTextFieldsArray = [
            mondayOpenTextField,
            tuesdayOpenTextField,
            wednesdayOpenTextField,
            thursdayOpenTextField,
            fridayOpenTextField,
            saturdayOpenTextField,
            sundayOpenTextField
        ]
        
        if RemoteDataController.showArray != [] {
            remoteShowCheckLabel.stringValue = ""
        } else {
            remoteShowCheckLabel.stringValue = "Switch To Publisher Mode To See Shows"
        }
        
        logoImageView.imageAlignment = .alignCenter
        logoImageView.imageScaling = .scaleProportionallyDown
        
        if currentVenue != nil {
            self.title = "Edit \(currentVenue!.name)"
            getBusinessHours()
            getBusinessType()
            getCity()

            nameTextField.stringValue = currentVenue!.name
            addressTextField.stringValue = currentVenue!.address
            phoneTextField.stringValue = String(currentVenue!.phoneNumber)
            websiteTextField.stringValue = currentVenue!.website
            
            mondayOpenTextField.stringValue = currentVenue?.hours?.monday ?? "No Hours"
            tuesdayOpenTextField.stringValue = currentVenue?.hours?.tuesday ?? "No Hours"
            wednesdayOpenTextField.stringValue = currentVenue?.hours?.wednesday ?? "No Hours"
            thursdayOpenTextField.stringValue = currentVenue?.hours?.thursday  ?? "No Hours"
            fridayOpenTextField.stringValue = currentVenue?.hours?.friday ?? "No Hours"
            saturdayOpenTextField.stringValue = currentVenue?.hours?.saturday ?? "No Hours"
            sundayOpenTextField.stringValue = currentVenue?.hours?.sunday ?? "No Hours"
            
            
            //Initializing currentVenuesShows Array
            currentVenueShows = RemoteDataController.showArray.filter({$0.venue == currentVenue?.venueID})
            
            if currentVenue?.ohmPick == true {
                ohmPick.state = .on
            } else {
                ohmPick.state = .off
            }
            
            //Image Handling Should Happen Last
            guard let logo = currentVenue?.logo else {return}
            logoData = logo
            image = NSImage(data: logoData!)
            logoImageView.image = image
            
            guard let venuePics = currentVenue?.pics else {return}
            venuePicsData = venuePics
            
        } else {
            self.title = "Edit Blank Venue"
            nameTextField.stringValue = ""
            addressTextField.stringValue = ""
            phoneTextField.stringValue = ""
            websiteTextField.stringValue = ""
            getBusinessHours()
            getBusinessType()
            getCity()
            venuePicsData = []
            logoData = nil
            image = nil
            ohmPick.state = .off
            
            mondayOpenTextField.stringValue = currentVenue?.hours?.monday ?? "No Hours"
            tuesdayOpenTextField.stringValue = currentVenue?.hours?.tuesday ?? "No Hours"
            wednesdayOpenTextField.stringValue = currentVenue?.hours?.wednesday ?? "No Hours"
            thursdayOpenTextField.stringValue = currentVenue?.hours?.thursday  ?? "No Hours"
            fridayOpenTextField.stringValue = currentVenue?.hours?.friday ?? "No Hours"
            saturdayOpenTextField.stringValue = currentVenue?.hours?.saturday ?? "No Hours"
            sundayOpenTextField.stringValue = currentVenue?.hours?.sunday ?? "No Hours"
        }
    }
    
    //MARK: Radio Buttons
    @IBAction func venueTableViewDataSourceRadioButtons(_ sender: Any) {
        if remoteRadioButton.state == .on {
            venueFilterArray = RemoteDataController.venueArray
        } else if backupRadioButton.state == .on {
            venueFilterArray = LocalBackupDataStorageController.venueArray
        }
        venuesTableView.reloadData()
    }
    
    @IBAction func searchingTextField(_ sender: Any) {
        if backupRadioButton.state == .on {
            if searchTextField.stringValue == "" {
                venueFilterArray = LocalBackupDataStorageController.venueArray.sorted(by: {$0.name < $1.name})
            } else {
                venueFilterArray = LocalBackupDataStorageController.venueArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
        } else if remoteRadioButton.state == .on {
            if searchTextField.stringValue == "" {
                venueFilterArray = RemoteDataController.venueArray
            } else {
                venueFilterArray = RemoteDataController.venueArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
        }
        venuesTableView.reloadData()
    }
            
    
    //MARK: Load Buttons Tapped
    @IBAction func loadLogoButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["png", "jpeg", "jpg", "tiff"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            image = imageController.addImage(file: result!)
            logoImageView.image = image
            
            let imageData = NSData(contentsOf: result!)
            self.logoData = imageData as Data?
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func loadPicturesButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["png", "jpeg", "jpg", "tiff"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            guard let result = dialog.url else {return} // Pathname of the file
            let imageData = NSData(contentsOf: result)
            let data = imageData! as Data
            
            venuePicsData.append(data)
            self.collectionView.reloadData()
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    //MARK: Delete Button Tapped
    @IBAction func photoDeleteButtonTapped(_ sender: Any) {
        guard let index = collectionView.selectionIndexes.first else {return}
        
        venuePicsData.remove(at: index)
        self.collectionView.reloadData()
    }
    
    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
        guard let currentVenue = currentVenue else {return}
        
        if backupRadioButton.state == .on {
            messageCenter.stringValue = "You can't delete a single venue from backup! Switch to remote."
            return
        }
        
        if RemoteDataController.venueArray != [] {
            WorkingOffRemoteManager.allVenueDataPath.document(currentVenue.venueID).delete { err in
                if let err = err {
                    self.messageCenter.textColor = .red
                    self.messageCenter.stringValue = err.localizedDescription
                    self.messageCenter.textColor = .white
                    self.buttonIndication2(color: .red)
                } else {
                    self.clearVenue()
                    RemoteDataController.venueArray.removeAll(where: {$0 == currentVenue})
                    self.venuesTableView.reloadData()
                    self.removeShows {self.showsTableView.reloadData()}
                    self.messageCenter.stringValue = "Venue Deleted"
                    self.buttonIndication2(color: .green)
                }
            }
        }
    }
    
    //MARK: Save Button Tapped
    @IBAction func saveButtonTapped(_ sender: Any) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        
        if currentVenue == nil {
            alert.messageText = "Create New Venue"
            alert.informativeText = "Creating a new venue will use the information filled out on this page."
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Create New Venue")
        }
        
        if currentVenue != nil {
            alert.messageText = "Create New Venue Or Update Current Venue"
            alert.informativeText = "Creating a new venue will use the information filled out on this page."
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Create New Venue")
            alert.addButton(withTitle: "Update")
        }
        
        let res = alert.runModal()
        
        switch res {
        case .alertSecondButtonReturn:
            createNewVenue()
        case .alertThirdButtonReturn:
            updateVenue()
        default:
            break
        }
    }
    
    //MARK: Clear Button Tapped
    @IBAction func clearButtonTapped(_ sender: Any) {
        clearVenue()
    }
    
    private func clearVenue() {
        currentVenue = nil
        logoImageView.image = nil
        updateViews()
        collectionView.reloadData()
        messageCenter.stringValue = "Cleared"
    }

    //MARK: Backup Buttons
    
    
    @IBAction func backupSafetySwitchClicked(_ sender: Any) {
        
        switch backupSafetySwitch.state {
        case .off:
            saveBackupButton.isEnabled = false
            loadBackupButton.isEnabled = false
        case .on:
            saveBackupButton.isEnabled = true
            loadBackupButton.isEnabled = true
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [self] in
            backupSafetySwitch.state = .off
            saveBackupButton.isEnabled = false
            loadBackupButton.isEnabled = false
        }
    }
    
    
    @IBAction func saveBackupButtonTapped(_ sender: Any) {
        if RemoteDataController.bandArray == [] {
            messageCenter.stringValue = "There is no data from the remote database to backup. Make sure you are in Publisher Mode."
            return
        }
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
        LocalBackupDataStorageController.bandArray = RemoteDataController.bandArray
        LocalBackupDataStorageController.saveVenueData()
        messageCenter.stringValue = "Band Data Backup Saved"
    }
    
    @IBAction func loadBackupButtonTapped(_ sender: Any) {
        if backupSafetySwitch.state == .on {
            LocalBackupDataStorageController.loadVenueData()
            venueFilterArray = LocalBackupDataStorageController.venueArray
            messageCenter.stringValue = "Venue Data Backup Loaded"
        } else {
            messageCenter.stringValue = "Select Backup Radial before loading Backup"
        }
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
    }
    
    
//    //MARK: Business Type CheckBox Buttons
//    @IBAction func restaurantButtonTapped(_ sender: Any) {
//        if restaurantButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Restaurant})
//            venueTypeArray.append(BusinessType.Restaurant)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Restaurant})
//        }
//    }
//    @IBAction func barButtonTapped(_ sender: Any) {
//        if barButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Bar})
//            venueTypeArray.append(BusinessType.Bar)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Bar})
//        }
//    }
//    @IBAction func clubButtonTapped(_ sender: Any) {
//        if clubButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Club})
//            venueTypeArray.append(BusinessType.Club)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Club})
//        }
//    }
//    @IBAction func outdoorsButtonTapped(_ sender: Any) {
//        if outdoorsButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Outdoors})
//            venueTypeArray.append(BusinessType.Outdoors)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Outdoors})
//        }
//    }
//    @IBAction func liveMusicButtonTapped(_ sender: Any) {
//        if liveMusicButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.LiveMusic})
//            venueTypeArray.append(BusinessType.LiveMusic)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.LiveMusic})
//        }
//    }
//    @IBAction func familyButtonTapped(_ sender: Any) {
//        if familyButton.state == .on {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Family})
//            venueTypeArray.append(BusinessType.Family)
//        } else {
//            venueTypeArray.removeAll(where: {$0 == BusinessType.Family})
//        }
//    }
//
//    //MARK: City CheckBox Buttons
//    @IBAction func veniceButtonTapped(_ sender: Any) {
//        if veniceButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.Venice})
//            venueCityArray.append(City.Venice)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.Venice})
//        }
//    }
//    @IBAction func sarasotaButtonTapped(_ sender: Any) {
//        if sarasotaButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.Sarasota})
//            venueCityArray.append(City.Sarasota)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.Sarasota})
//        }
//    }
//
//    @IBAction func bradentonButtonTapped(_ sender: Any) {
//        if bradentonButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.Bradenton})
//            venueCityArray.append(City.Bradenton)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.Bradenton})
//        }
//    }
//
//    @IBAction func stPeteButtonTapped(_ sender: Any) {
//        if stPeteButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.StPete})
//            venueCityArray.append(City.StPete)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.StPete})
//        }
//    }
//
//    @IBAction func tampaButtonTapped(_ sender: Any) {
//        if tampaButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.Tampa})
//            venueCityArray.append(City.Tampa)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.Tampa})
//        }
//    }
//
//    @IBAction func yborButtonTapped(_ sender: Any) {
//        if yborButton.state == .on {
//            venueCityArray.removeAll(where: {$0 == City.Ybor})
//            venueCityArray.append(City.Ybor)
//        } else {
//            venueCityArray.removeAll(where: {$0 == City.Ybor})
//        }
//    }
    
    
}

//MARK: CollectionView
extension VenueDetailViewController {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return venuePicsData.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        var image = NSImage()
        
        
        if let pic = NSImage(data: venuePicsData[indexPath.item]) {
            image = pic
            
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("BusinessPhoto"), for: indexPath)
            guard let pictureItem = item as? BusinessPhoto else { return item }
            
            pictureItem.view.wantsLayer = true
            pictureItem.imageView?.imageScaling = .scaleProportionallyDown
            pictureItem.imageView?.image = image
            
            return pictureItem
            
        }
        return NSCollectionViewItem()
    }
}




//MARK: Tablview
extension VenueDetailViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        switch tableView {
        case showsTableView:
            if currentVenue != nil {
                return currentVenueShows?.count ?? 0
            }
            
        case venuesTableView:
            return venueFilterArray.count
            
        default:
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case showsTableView:
            var currentShow: Show? {
                if currentVenue != nil {
                    guard let currentVenueShows = currentVenueShows else {return nil}
                    return currentVenueShows[row]
                }
                return nil
            }
            
            guard let band = RemoteDataController.bandArray.first(where: {$0.bandID == currentShow?.band}) else {return nil}
            
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Band") {
                let bandIdentifier = NSUserInterfaceItemIdentifier("BandCell")
                guard let cellView = tableView.makeView(withIdentifier: bandIdentifier, owner: self) as? NSTableCellView else {return nil}
                cellView.textField?.stringValue = band.name
                return cellView
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Time") {
                let showTimeIdentifier = NSUserInterfaceItemIdentifier("TimeCell")
                guard let cellView = tableView.makeView(withIdentifier: showTimeIdentifier, owner: self) as? NSTableCellView else {return nil}
                //let showTime = currentShow?.dateString.replacingOccurrences(of: "\n", with: " ")
                cellView.textField?.stringValue = "\(currentShow?.dateString ?? "No Data")"
                return cellView
                
            }
            
        case venuesTableView:
            let venueIdentifier = NSUserInterfaceItemIdentifier("VenueCell")
            guard let cellView = tableView.makeView(withIdentifier: venueIdentifier, owner: self) as? NSTableCellView else {return nil}
            
            if remoteRadioButton.state == .on {
                cellView.textField?.stringValue = "Remote: \(row + 1): " + venueFilterArray[row].name
                return cellView
            } else {
                cellView.textField?.stringValue = "BackUp: " + venueFilterArray[row].name
                return cellView
            }
            
        default:
            return NSTableCellView()
        }
        return nil
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
    }
}



//MARK: Functions
extension VenueDetailViewController {
    
    @objc private func doubleClicked() {
        currentVenue = venueFilterArray[venuesTableView.selectedRow]
    }
    
    private func buttonIndication2(color: NSColor) {
        var counter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { time in
            if counter < 2 {
                DispatchQueue.main.async {
                    self.buttonBoxView.fillColor = color
                }
                counter += 1
            } else if counter == 2{
                DispatchQueue.main.async {
                    self.buttonBoxView.fillColor = .black
                }
                self.timer.invalidate()
                counter = 0
               
            }
        })
    }
    
    private func createNewVenue() {
        let newVenue = Venue(name: nameTextField.stringValue, address: addressTextField.stringValue, phoneNumber: Int(phoneTextField.stringValue) ?? 000, website: websiteTextField.stringValue)
        
        addTypeAndCityTo(newVenue)
        newVenue.hours = venueHoursFromFields()
        newVenue.logo = logoData
        newVenue.pics = venuePicsData
        newVenue.lastModified = Timestamp()
        
        do {
            try WorkingOffRemoteManager.allVenueDataPath.document(newVenue.venueID).setData(from: newVenue) { err in
                if let error = err {
                    self.messageCenter.stringValue = error.localizedDescription
                    self.buttonIndication2(color: .red)
                } else {
                    RemoteDataController.venueArray.append(newVenue)
                    DispatchQueue.main.async {
                        self.venuesTableView.reloadData()
                        self.messageCenter.stringValue = "\(newVenue.name) was added to database successfully!"
                        self.buttonIndication2(color: .green)
                    }
                }
            }
        } catch(let error) {
            NSLog(error.localizedDescription)
            self.messageCenter.stringValue = error.localizedDescription
        }
    }
    
    private func updateVenue() {
        guard let currentVenue = currentVenue else {
            messageCenter.stringValue = "No venue has been selected to be updated. First double click on a venue then update it."
            return
        }
        
        currentVenue.name = nameTextField.stringValue
        currentVenue.address = addressTextField.stringValue
        currentVenue.phoneNumber = Int(phoneTextField.stringValue) ?? 0000
        currentVenue.website = websiteTextField.stringValue
        currentVenue.logo = logoData
        currentVenue.pics = venuePicsData
        currentVenue.hours = venueHoursFromFields()
        addTypeAndCityTo(currentVenue)
        currentVenue.lastModified = Timestamp()
        
        do {
            try WorkingOffRemoteManager.allVenueDataPath.document(currentVenue.venueID).setData(from: currentVenue, completion: { err in
                if let err = err {
                    self.messageCenter.stringValue = err.localizedDescription
                    self.buttonIndication2(color: .red)
                } else {
                    RemoteDataController.venueArray.removeAll(where: {$0 == currentVenue})
                    RemoteDataController.venueArray.append(currentVenue)
                    RemoteDataController.venueArray.sort(by: {$0.name < $1.name})
                    self.venuesTableView.reloadData()
                    self.messageCenter.stringValue = "\(currentVenue.name) was updated successfully!"
                    self.buttonIndication2(color: .green)
                }
            })
        } catch(let error) {
            NSLog(error.localizedDescription)
            self.messageCenter.stringValue = error.localizedDescription
        }
    }
    
    private func removeShows(completion: @escaping () -> Void) {
        LocalBackupDataStorageController.showArray.removeAll(where: {$0.venue == currentVenue?.venueID})
        completion()
    }
    
    
    private func getBusinessHours() {
        if currentVenue != nil {
            guard let hours = currentVenue?.hours else {return}
            
            mondayOpenTextField.stringValue = hours.monday
            tuesdayOpenTextField.stringValue = hours.tuesday
            wednesdayOpenTextField.stringValue = hours.wednesday
            thursdayOpenTextField.stringValue = hours.thursday
            fridayOpenTextField.stringValue = hours.friday
            saturdayOpenTextField.stringValue = hours.saturday
            sundayOpenTextField.stringValue = hours.sunday
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
    
    private func venueHoursFromFields() -> Hours {
        let hours = Hours(mon: mondayOpenTextField.stringValue, tues: tuesdayOpenTextField.stringValue, wed: wednesdayOpenTextField.stringValue, thur: thursdayOpenTextField.stringValue, fri: fridayOpenTextField.stringValue, sat: saturdayOpenTextField.stringValue, sun: sundayOpenTextField.stringValue)
        
        return hours
    }
    
    private func getBusinessType() {
        familyButton.state = .off
        liveMusicButton.state = .off
        outdoorsButton.state = .off
        clubButton.state = .off
        barButton.state = .off
        restaurantButton.state = .off
        
        if currentVenue != nil {
            for businessType in currentVenue!.businessType {
                switch businessType {
                case .Restaurant:
                    restaurantButton.state = .on
                case .Bar:
                    barButton.state = .on
                case .Club:
                    clubButton.state = .on
                case .Outdoors:
                    outdoorsButton.state = .on
                case .LiveMusic:
                    liveMusicButton.state = .on
                case .Family:
                    familyButton.state = .on
                }
            }
            
        }
    }
    
    private func getCity() {
        veniceButton.state = .off
        sarasotaButton.state = .off
        bradentonButton.state = .off
        stPeteButton.state = .off
        tampaButton.state = .off
        yborButton.state = .off
        
        if currentVenue?.city != nil {
            for city in currentVenue!.city {
                switch city {
                case .Venice:
                    veniceButton.state = .on
                case .Sarasota:
                    sarasotaButton.state = .on
                case .Bradenton:
                    bradentonButton.state = .on
                case .StPete:
                    stPeteButton.state = .on
                case .Tampa:
                    tampaButton.state = .on
                case .Ybor:
                    yborButton.state = .on
                case .All:
                    break
                }
            }
        }
    }
    
    private func addTypeAndCityTo(_ newVenue: Venue) {
        newVenue.city = []
        newVenue.businessType = []
        for button in cityArray {
            if button.state == .on {
                switch button {
                case veniceButton:
                    newVenue.city.append(.Venice)
                case sarasotaButton:
                    newVenue.city.append(.Sarasota)
                case bradentonButton:
                    newVenue.city.append(.Bradenton)
                case stPeteButton:
                    newVenue.city.append(.StPete)
                case tampaButton:
                    newVenue.city.append(.Tampa)
                case yborButton:
                    newVenue.city.append(.Ybor)
                default:
                    break
                }
            }
        }
        
        for button in venueTypeButtonArray {
            if button.state == .on {
                switch button {
                case restaurantButton:
                    newVenue.businessType.append(.Restaurant)
                case barButton:
                    newVenue.businessType.append(.Bar)
                case clubButton:
                    newVenue.businessType.append(.Club)
                case outdoorsButton:
                    newVenue.businessType.append(.Outdoors)
                case liveMusicButton:
                    newVenue.businessType.append(.LiveMusic)
                case familyButton:
                    newVenue.businessType.append(.Family)
                default:
                    break
                }
            }
        }
    }
}

