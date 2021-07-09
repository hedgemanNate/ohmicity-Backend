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
    
    var currentVenue: RawJSON?
    var currentBusiness: BusinessFullData?
    var image: NSImage?
    var imageData: Data?
    
    var scheduleTextFieldsArray: [NSTextField] = []
    var businessTypeButtonsArray: [NSButton] = []
    
    @IBOutlet weak var tableView: NSTableView!
    var currentBusinessShows: [Show]?
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    //Text Fields
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var phoneTextField: NSTextField!
    @IBOutlet weak var starsTextField: NSTextField!
    @IBOutlet weak var websiteTextField: NSTextField!
    @IBOutlet weak var photoDeleteTextField: NSTextField!
    
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
    @IBOutlet weak var loadLogoButton: NSButton!
    @IBOutlet weak var loadPicturesButton: NSButton!
    @IBOutlet weak var deletePicsButton: NSButton!
    @IBOutlet weak var pushBusinessButton: NSButton!
    
    @IBOutlet weak var resturantButton: NSButton!
    @IBOutlet weak var barButton: NSButton!
    @IBOutlet weak var clubButton: NSButton!
    @IBOutlet weak var outdoorsButton: NSButton!
    @IBOutlet weak var liveMusicButton: NSButton!
    @IBOutlet weak var familyButton: NSButton!
    
    
    //Pictures
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
            image = imageController.addBusinessImage(file: result!)
            logoImageView.image = image
            
            let imageData = NSData(contentsOf: result!)
            self.imageData = imageData as Data?
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
            currentBusiness?.pics.append(data)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func photoDeleteButtonTapped(_ sender: Any) {
        guard let index = collectionView.selectionIndexes.first else {return}
        currentBusiness?.pics.remove(at: index)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    @IBAction func updateBusinessButtonTapped(_ sender: Any) {
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        let stars = Int(starsTextField.stringValue) ?? 0
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        
        //Picture Handling
        currentBusiness?.logo = imageData
        
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
        
        let hours = Hours(mon: mondayOpenTextField.stringValue, tues: tuesdayOpenTextField.stringValue, wed: wednesdayOpenTextField.stringValue, thur: thursdayOpenTextField.stringValue, fri: fridayOpenTextField.stringValue, sat: saturdayOpenTextField.stringValue, sun: sundayOpenTextField.stringValue)
        
        currentBusiness?.hours = hours
        currentBusiness?.lastModified = Timestamp()
        
        localDataController.saveBusinessData()
        localDataController.saveBusinessBasicData()
        
    }
    
    @IBAction func makeBusinessButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = false
            self.pushBusinessButton.isEnabled = true
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
        
        newBusiness.stars = Int(stars)!
        
        
        let hours = Hours(mon: mondayOpenTextField.stringValue, tues: tuesdayOpenTextField.stringValue, wed: wednesdayOpenTextField.stringValue, thur: thursdayOpenTextField.stringValue, fri: fridayOpenTextField.stringValue, sat: saturdayOpenTextField.stringValue, sun: sundayOpenTextField.stringValue)
        
        newBusiness.hours = hours
        newBusiness.lastModified = Timestamp()
        
        
        //MARK: Basic Business Data: Removed
        //Is not needed as of yet. Maybe one day

//        let newBusinessBasic = BusinessBasicData(venueID: newBusiness.venueID!, name: newBusiness.name!, logo: newBusiness.logo, stars: newBusiness.stars)
//        localDataController.businessBasicArray.append(newBusinessBasic)
//        localDataController.saveBusinessBasicData()
        
        localDataController.businessArray.append(newBusiness)
        
        localDataController.saveBusinessData()
        
        localDataController.saveShowData()
        activateDelete()
        notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        print("Save Button Tapped")
        
        
        //Adding Shows To Local Data
        guard let shows = currentVenue?.shows else {return}
        for show in shows {
            let newShow: Show = Show(band: show.bandName!, venue: currentVenue!.venueName!, dateString: show.showTime!)
            
            localDataController.showArray.append(newShow)
        }
    }
    
    @IBAction func pushBusinessButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.businessFullDataPath
        currentBusiness?.lastModified = Timestamp()
        
        do {
            try ref.document(currentBusiness!.venueID ?? UUID.init().uuidString).setData(from: currentBusiness)
        } catch let error {
                NSLog(error.localizedDescription)
        }
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
    
    //MARK: Genre CheckkBox Buttons
    @IBAction func resturantButtonTapped(_ sender: Any) {
        if resturantButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Resturant)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Resturant})
        }
    }
    @IBAction func barButtonTapped(_ sender: Any) {
        if barButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Bar)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Bar})
        }
    }
    @IBAction func clubButtonTapped(_ sender: Any) {
        if clubButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Club)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Club})
        }
    }
    @IBAction func outdoorsButtonTapped(_ sender: Any) {
        if outdoorsButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Outdoors)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Outdoors})
        }
    }
    @IBAction func liveMusicButtonTapped(_ sender: Any) {
        if liveMusicButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.LiveMusic)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.LiveMusic})
        }
    }
    @IBAction func familyButtonTapped(_ sender: Any) {
        if familyButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Family)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Family})
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
        collectionView.delegate = self
        collectionView.dataSource = self
        
        logoImageView.imageAlignment = .alignCenter
        logoImageView.imageScaling = .scaleProportionallyDown
        
        if currentVenue != nil {
            updateBusinessButton.isEnabled = false
            nameTextField.stringValue = currentVenue!.venueName!
            deleteButton.isEnabled = false
            pushBusinessButton.isEnabled = false
            updateBusinessButton.isEnabled = false
            loadPicturesButton.isEnabled = false
            deletePicsButton.isEnabled = false
            pushBusinessButton.isEnabled = false
            
        } else if currentBusiness != nil {
            inputBusinessHours()
            addBusinessType()
            makeBusinessButton.isEnabled = false
            pushBusinessButton.isEnabled = true
            nameTextField.stringValue = currentBusiness!.name!
            addressTextField.stringValue = currentBusiness!.address!
            phoneTextField.stringValue = String(currentBusiness!.phoneNumber!)
            starsTextField.stringValue = String(currentBusiness?.stars ?? 0)
            websiteTextField.stringValue = currentBusiness!.website!
            
            mondayOpenTextField.stringValue = currentBusiness?.hours?.monday ?? "No Hours"
            tuesdayOpenTextField.stringValue = currentBusiness?.hours?.tuesday ?? "No Hours"
            wednesdayOpenTextField.stringValue = currentBusiness?.hours?.wednesday ?? "No Hours"
            thursdayOpenTextField.stringValue = currentBusiness?.hours?.thursday  ?? "No Hours"
            fridayOpenTextField.stringValue = currentBusiness?.hours?.friday ?? "No Hours"
            saturdayOpenTextField.stringValue = currentBusiness?.hours?.saturday ?? "No Hours"
            sundayOpenTextField.stringValue = currentBusiness?.hours?.sunday ?? "No Hours"
            
            
            //Initializing currentBusinessShows Array
            currentBusinessShows = localDataController.showArray.filter({$0.venue == currentBusiness?.name})
            
            if currentBusiness?.ohmPick == true {
                ohmPick.state = .on
            } else {
                ohmPick.state = .off
            }
            
            //Image Handling Should Happen Last
            guard let logo = currentBusiness?.logo else {return}
            imageData = logo
            image = NSImage(data: imageData!)
            logoImageView.image = image
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
        
        deleteButton.isEnabled = false
    }
}

//MARK: CollectionView
extension VenueDetailViewController {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return (currentBusiness?.pics.count) ?? 0
        }
        
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            
            let image = NSImage(data: (currentBusiness?.pics[indexPath.item])!)
            
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("BusinessPhoto"), for: indexPath)
            guard let pictureItem = item as? BusinessPhoto else { return item }
            
            pictureItem.view.wantsLayer = true
            //pictureItem.imageView?.imageAlignment = .alignCenter
            pictureItem.imageView?.imageScaling = .scaleProportionallyDown
            pictureItem.imageView?.image = image
            
            return pictureItem
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
            return nil
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
    
    
    private func inputBusinessHours() {
        if currentBusiness != nil {
            mondayOpenTextField.stringValue = (currentBusiness?.hours?.monday)!
            tuesdayOpenTextField.stringValue = (currentBusiness?.hours?.tuesday)!
            wednesdayOpenTextField.stringValue = (currentBusiness?.hours?.wednesday)!
            thursdayOpenTextField.stringValue = (currentBusiness?.hours?.thursday)!
            fridayOpenTextField.stringValue = (currentBusiness?.hours?.friday)!
            saturdayOpenTextField.stringValue = (currentBusiness?.hours?.saturday)!
            sundayOpenTextField.stringValue = (currentBusiness?.hours?.sunday)!
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
            for businessType in currentBusiness!.businessType {
                switch businessType {
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
