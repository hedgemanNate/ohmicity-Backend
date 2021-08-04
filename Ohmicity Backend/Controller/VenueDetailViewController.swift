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
    
    
    var currentBusinessShows: [Show]?
    var currentVenue: RawJSON?
    var currentBusiness: BusinessFullData?
    var image: NSImage?
    var logoData: Data?
    var businessPicsData: [Data] = []
    
    var timer = Timer()
    
    var scheduleTextFieldsArray: [NSTextField] = []
    var businessTypeButtonsArray: [NSButton] = []
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
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
    @IBOutlet weak var makeBusinessButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
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
    var venueTypeArray = [NSButton]()
    
    
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
        updateViews()
        
        cityArray = [veniceButton, sarasotaButton, bradentonButton, stPeteButton, tampaButton, yborButton]
        
        venueTypeArray = [resturantButton, barButton, clubButton, outdoorsButton, liveMusicButton, familyButton]
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
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
                counter = 0
                self.timer.invalidate()
            }
        })
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
            image = imageController.addBusinessImage(file: result!)
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
            
            if currentBusiness != nil {
                currentBusiness?.pics.append(data)
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
        
        if currentBusiness != nil {
            currentBusiness?.pics.remove(at: index)
        } else {
            businessPicsData.remove(at: index)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
    
    
    
    //MARK: Save Business
    @IBAction func saveBusinessButtonTapped(_ sender: Any) {
        let name = nameTextField.stringValue
        let address = addressTextField.stringValue
        let website = websiteTextField.stringValue
        let phoneString = phoneTextField.stringValue
        let stars = Int(starsTextField.stringValue) ?? 0
        
        let numberString = phoneString.filter("0123456789".contains)
        print(numberString)
        guard let phoneNumber = Int(numberString) else {return print("Return on phone number")}
        
        
        //Picture Handling
        currentBusiness?.logo = logoData
        
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
        
        if !localDataController.businessArray.contains(currentBusiness!) {
            localDataController.businessArray.append(currentBusiness!)
        }
        
        localDataController.saveBusinessData()
        buttonIndication2(color: .green)
        
    }
    
    
    //MARK: Make Business
    @IBAction func makeBusinessButtonTapped(_ sender: Any) {
        
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
                case resturantButton:
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
        
        currentBusiness = newBusiness
        
        localDataController.businessArray.append(newBusiness)
        localDataController.saveBusinessData()
        localDataController.saveShowData()
        
        notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        print("Save Button Tapped")
        
        buttonEnable(buttons:[saveButton,
                              pushBusinessButton,
                              loadLogoButton,
                              loadPicturesButton,
                              deletePicsButton])
        
        //Function Light Notification Of Action Acknowleged
        buttonIndication2(color: .green)
    }
    
    @IBAction func pushBusinessButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.businessFullDataPath
        currentBusiness?.lastModified = Timestamp()
        
        do {
            try ref.document(currentBusiness!.venueID ?? UUID.init().uuidString).setData(from: currentBusiness)
            buttonIndication2(color: .green)
        } catch let error {
            NSLog(error.localizedDescription)
            buttonIndication2(color: .red)
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
    
    
    
    
    //MARK: Business Type CheckBox Buttons
    @IBAction func resturantButtonTapped(_ sender: Any) {
        if resturantButton.state == .on {
            currentBusiness?.businessType.append(BusinessType.Restaurant)
        } else {
            currentBusiness?.businessType.removeAll(where: {$0 == BusinessType.Restaurant})
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
    
    //MARK: City CheckBox Buttons
    @IBAction func veniceButtonTapped(_ sender: Any) {
        if veniceButton.state == .on {
            currentBusiness?.city.append(City.Venice)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.Venice})
        }
    }
    @IBAction func sarasotaButtonTapped(_ sender: Any) {
        if sarasotaButton.state == .on {
            currentBusiness?.city.append(City.Sarasota)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.Sarasota})
        }
    }
    
    @IBAction func bradentonButtonTapped(_ sender: Any) {
        if bradentonButton.state == .on {
            currentBusiness?.city.append(City.Bradenton)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.Bradenton})
        }
    }
    
    @IBAction func stPeteButtonTapped(_ sender: Any) {
        if stPeteButton.state == .on {
            currentBusiness?.city.append(City.StPete)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.StPete})
        }
    }
    
    @IBAction func tampaButtonTapped(_ sender: Any) {
        if tampaButton.state == .on {
            currentBusiness?.city.append(City.Tampa)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.Tampa})
        }
    }
    
    @IBAction func yborButtonTapped(_ sender: Any) {
        if yborButton.state == .on {
            currentBusiness?.city.append(City.Ybor)
        } else {
            currentBusiness?.city.removeAll(where: {$0 == City.Ybor})
        }
    }
    
    //MARK: UpdateViews
    func updateViews() {
        buttonEnable(buttons: [makeBusinessButton, loadLogoButton])
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        logoImageView.imageAlignment = .alignCenter
        logoImageView.imageScaling = .scaleProportionallyDown
        
        if currentVenue != nil {
            self.title = "Edit \(currentVenue!.venueName!)"
            nameTextField.stringValue = currentVenue!.venueName!
            
        } else if currentBusiness != nil {
            self.title = "Edit \(currentBusiness!.name!)"
            inputBusinessHours()
            addBusinessType()
            buttonEnable(buttons:[saveButton,
                                  pushBusinessButton,
                                  loadLogoButton,
                                  loadPicturesButton,
                                  deletePicsButton])
            
//            //MARK: TEMP UNTIL DATA MODEL IS UPDATED
//            if currentBusiness?.city == nil {
//                currentBusiness?.city = []
//            }
            
            //Remove Above Temp But Keep addCity()
            addCity()
            
            
            nameTextField.stringValue = currentBusiness!.name!
            addressTextField.stringValue = currentBusiness!.address
            phoneTextField.stringValue = String(currentBusiness!.phoneNumber)
            starsTextField.stringValue = String(currentBusiness?.stars ?? 0)
            websiteTextField.stringValue = currentBusiness!.website
            
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
            logoData = logo
            image = NSImage(data: logoData!)
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
        
    }
}

//MARK: CollectionView
extension VenueDetailViewController {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentBusiness != nil {
            return currentBusiness!.pics.count
        } else {
            return businessPicsData.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        var image = NSImage()
        
        if currentBusiness != nil {
            guard let pictures = currentBusiness?.pics else {return NSCollectionViewItem()}
            
            if let pic = NSImage(data: pictures[indexPath.item]) {
                image = pic
            } else {
                let pictures = businessPicsData
                if let pic = NSImage(data: pictures[indexPath.item]) {
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
    
    func buttonEnable(buttons: [NSButton]) {
        makeBusinessButton.isEnabled = false
        saveButton.isEnabled = false
        loadLogoButton.isEnabled = false
        loadPicturesButton.isEnabled = false
        deletePicsButton.isEnabled = false
        pushBusinessButton.isEnabled = false
        
        let buttonArray = [
            makeBusinessButton,
            saveButton,
            loadLogoButton,
            loadPicturesButton,
            deletePicsButton,
            pushBusinessButton
        ]
        
        for button in buttons {
            if buttonArray.contains(button) {
                button.isEnabled = true
            }
        }
    }
    
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
                case .Restaurant:
                    resturantButton.state = .on
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
        
        if currentBusiness?.city != nil {
            for city in currentBusiness!.city {
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
                }
            }
        }
    }
}

