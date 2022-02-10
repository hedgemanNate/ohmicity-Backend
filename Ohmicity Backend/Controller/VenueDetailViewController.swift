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
    var image: NSImage?
    var logoData: Data?
    var businessPicsData: [Data] = []
    
    var timer = Timer()
    
    var scheduleTextFieldsArray: [NSTextField] = []
    var businessTypeButtonsArray: [NSButton] = []
    
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
    var venueTypeArray = [NSButton]()
    
    @IBOutlet weak var remoteRadioButton: NSButton!
    @IBOutlet weak var backupRadioButton: NSButton!
    
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
        venueTypeArray = [restaurantButton, barButton, clubButton, outdoorsButton, liveMusicButton, familyButton]
        
        showsTableView.delegate = self
        showsTableView.dataSource = self
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        showsTableView.reloadData()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
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
    
    //MARK: Radio Buttons
    @IBAction func venueTableViewDataSourceRadioButtons(_ sender: Any) {
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
            
            if currentVenue != nil {
                currentVenue?.pics.append(data)
            } else {
                businessPicsData.append(data)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    //MARK: Delete Button Tapped
    @IBAction func photoDeleteButtonTapped(_ sender: Any) {
        guard let index = collectionView.selectionIndexes.first else {return}
        
        if currentVenue != nil {
            currentVenue?.pics.remove(at: index)
        } else {
            businessPicsData.remove(at: index)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
                } else {
                    RemoteDataController.venueArray.removeAll(where: {$0 == currentVenue})
                    self.venuesTableView.reloadData()
                    self.removeShows {self.showsTableView.reloadData()}
                    self.messageCenter.stringValue = "Venue Deleted"
                }
            }
        }
    }
    
    
    
    //MARK: Save Business - Pick Up Here 2/10/22
    @IBAction func saveBusinessButtonTapped(_ sender: Any) {
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        
        let numberString = phoneString.filter("0123456789".contains)
        guard let phoneNumber = Int(numberString) else {
            messageCenter.stringValue = "Return on phone number"
            return
        }
        
        //Picture Handling
        currentVenue?.logo = logoData
        currentVenue?.name = name
        currentVenue?.address = address
        currentVenue?.website = website
        currentVenue?.phoneNumber = phoneNumber
        if ohmPick.state == .on {
            currentVenue?.ohmPick = true
        } else if ohmPick.state == .off {
            currentVenue?.ohmPick = false
        }
        
        let hours = Hours(mon: mondayOpenTextField.stringValue, tues: tuesdayOpenTextField.stringValue, wed: wednesdayOpenTextField.stringValue, thur: thursdayOpenTextField.stringValue, fri: fridayOpenTextField.stringValue, sat: saturdayOpenTextField.stringValue, sun: sundayOpenTextField.stringValue)
        
        currentVenue?.hours = hours
        currentVenue?.lastModified = Timestamp()
        
        if !LocalBackupDataStorageController.venueArray.contains(currentVenue!) {
            LocalBackupDataStorageController.venueArray.append(currentVenue!)
        }
        
        LocalBackupDataStorageController.saveBusinessData()
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "businessUpdated")))
        buttonIndication2(color: .green)
        
    }
    
    
    //MARK: Make Business
    @IBAction func makeBusinessButtonTapped(_ sender: Any) {
        
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        
        
        let newBusiness = Venue(name: name, address: address, phoneNumber: phoneNumber, website: website)
        print("Business Created")
        
        newBusiness.logo = logoData
        newBusiness.pics = businessPicsData
        newBusiness.city = []
        
        for button in cityArray {
            if button.state == .on {
                switch button {
                case veniceButton:
                    newBusiness.city.append(.Venice)
                case sarasotaButton:
                    newBusiness.city.append(.Sarasota)
                case bradentonButton:
                    newBusiness.city.append(.Bradenton)
                case stPeteButton:
                    newBusiness.city.append(.StPete)
                case tampaButton:
                    newBusiness.city.append(.Tampa)
                case yborButton:
                    newBusiness.city.append(.Ybor)
                default:
                    break
                }
            }
        }
        
        for button in venueTypeArray {
            if button.state == .on {
                switch button {
                case restaurantButton:
                    newBusiness.businessType.append(.Restaurant)
                case barButton:
                    newBusiness.businessType.append(.Bar)
                case clubButton:
                    newBusiness.businessType.append(.Club)
                case outdoorsButton:
                    newBusiness.businessType.append(.Outdoors)
                case liveMusicButton:
                    newBusiness.businessType.append(.LiveMusic)
                case familyButton:
                    newBusiness.businessType.append(.Family)
                default:
                    break
                }
            }
        }
        
        
        let hours = Hours(mon: mondayOpenTextField.stringValue, tues: tuesdayOpenTextField.stringValue, wed: wednesdayOpenTextField.stringValue, thur: thursdayOpenTextField.stringValue, fri: fridayOpenTextField.stringValue, sat: saturdayOpenTextField.stringValue, sun: sundayOpenTextField.stringValue)
        
        newBusiness.hours = hours
        newBusiness.lastModified = Timestamp()
        
        currentVenue = newBusiness
        
        LocalBackupDataStorageController.venueArray.append(newBusiness)
        LocalBackupDataStorageController.saveBusinessData()
        LocalBackupDataStorageController.saveBackupShowData()
        
        notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        print("Save Button Tapped")
        
        //Function Light Notification Of Action Acknowledged
        buttonIndication2(color: .green)
    }
    
    @IBAction func pushBusinessButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.businessFullDataPath
        currentVenue?.lastModified = Timestamp()
        
        do {
            try ref.document(currentVenue!.venueID).setData(from: currentVenue)
            buttonIndication2(color: .green)
        } catch let error {
            NSLog(error.localizedDescription)
            buttonIndication2(color: .red)
        }
    }
    
    
    
    //MARK: Business Type CheckBox Buttons
    @IBAction func restaurantButtonTapped(_ sender: Any) {
        if restaurantButton.state == .on {
            currentVenue?.businessType.append(BusinessType.Restaurant)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.Restaurant})
        }
    }
    @IBAction func barButtonTapped(_ sender: Any) {
        if barButton.state == .on {
            currentVenue?.businessType.append(BusinessType.Bar)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.Bar})
        }
    }
    @IBAction func clubButtonTapped(_ sender: Any) {
        if clubButton.state == .on {
            currentVenue?.businessType.append(BusinessType.Club)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.Club})
        }
    }
    @IBAction func outdoorsButtonTapped(_ sender: Any) {
        if outdoorsButton.state == .on {
            currentVenue?.businessType.append(BusinessType.Outdoors)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.Outdoors})
        }
    }
    @IBAction func liveMusicButtonTapped(_ sender: Any) {
        if liveMusicButton.state == .on {
            currentVenue?.businessType.append(BusinessType.LiveMusic)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.LiveMusic})
        }
    }
    @IBAction func familyButtonTapped(_ sender: Any) {
        if familyButton.state == .on {
            currentVenue?.businessType.append(BusinessType.Family)
        } else {
            currentVenue?.businessType.removeAll(where: {$0 == BusinessType.Family})
        }
    }
    
    //MARK: City CheckBox Buttons
    @IBAction func veniceButtonTapped(_ sender: Any) {
        if veniceButton.state == .on {
            currentVenue?.city.append(City.Venice)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.Venice})
        }
    }
    @IBAction func sarasotaButtonTapped(_ sender: Any) {
        if sarasotaButton.state == .on {
            currentVenue?.city.append(City.Sarasota)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.Sarasota})
        }
    }
    
    @IBAction func bradentonButtonTapped(_ sender: Any) {
        if bradentonButton.state == .on {
            currentVenue?.city.append(City.Bradenton)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.Bradenton})
        }
    }
    
    @IBAction func stPeteButtonTapped(_ sender: Any) {
        if stPeteButton.state == .on {
            currentVenue?.city.append(City.StPete)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.StPete})
        }
    }
    
    @IBAction func tampaButtonTapped(_ sender: Any) {
        if tampaButton.state == .on {
            currentVenue?.city.append(City.Tampa)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.Tampa})
        }
    }
    
    @IBAction func yborButtonTapped(_ sender: Any) {
        if yborButton.state == .on {
            currentVenue?.city.append(City.Ybor)
        } else {
            currentVenue?.city.removeAll(where: {$0 == City.Ybor})
        }
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
            inputBusinessHours()
            addBusinessType()
            addCity()

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
            
            
            //Initializing currentBusinessShows Array
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
            
        } else {
            self.title = "Edit Blank Venue"
        }
    }
}

//MARK: CollectionView
extension VenueDetailViewController {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentVenue != nil {
            return currentVenue!.pics.count
        } else {
            return businessPicsData.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        var image = NSImage()
        
        if currentVenue != nil {
            guard let pictures = currentVenue?.pics else {return NSCollectionViewItem()}
            
            if let pic = NSImage(data: pictures[indexPath.item]) {
                image = pic
            } else {
                if let pic = NSImage(data: businessPicsData[indexPath.item]) {
                    image = pic
                }
            }
            
            
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
            if remoteRadioButton.state == .on {
                return RemoteDataController.venueArray.count
            } else {
                return LocalBackupDataStorageController.venueArray.count
            }
            
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
                cellView.textField?.stringValue = "Remote: " + RemoteDataController.venueArray[row].name
                return cellView
            } else {
                cellView.textField?.stringValue = "BackUp: " + LocalBackupDataStorageController.venueArray[row].name
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



//MARK: Helper Functions
extension VenueDetailViewController {
    
    @objc private func doubleClicked() {
        //performSegue(withIdentifier: "editShowSegue", sender: self)
        var venue: Venue?
        if remoteRadioButton.state == .on {
            venue = RemoteDataController.venueArray[venuesTableView.selectedRow]
            currentVenue = venue
        } else {
            venue = LocalBackupDataStorageController.venueArray[venuesTableView.selectedRow]
            currentVenue = venue
        }
    }
    
    private func removeShows(completion: @escaping () -> Void) {
        LocalBackupDataStorageController.showArray.removeAll(where: {$0.venue == currentVenue?.venueID})
        completion()
    }
    
    
    private func inputBusinessHours() {
        if currentVenue != nil {
            mondayOpenTextField.stringValue = (currentVenue?.hours?.monday)!
            tuesdayOpenTextField.stringValue = (currentVenue?.hours?.tuesday)!
            wednesdayOpenTextField.stringValue = (currentVenue?.hours?.wednesday)!
            thursdayOpenTextField.stringValue = (currentVenue?.hours?.thursday)!
            fridayOpenTextField.stringValue = (currentVenue?.hours?.friday)!
            saturdayOpenTextField.stringValue = (currentVenue?.hours?.saturday)!
            sundayOpenTextField.stringValue = (currentVenue?.hours?.sunday)!
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
    
    private func addCity() {
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
}

