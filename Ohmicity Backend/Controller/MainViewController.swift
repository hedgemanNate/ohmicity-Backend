//
//  MainViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/20/21.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift




class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //MARK: Properties
    var originalArray: [Band] = []
    var filteredArray: [Band] = []
    var inOrderArray: [Show] = []
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var ohmButton: NSButton!
    @IBOutlet weak var alertTextField: NSTextField!
    
    
    @IBOutlet weak var loadFileButton: NSButton!
    @IBOutlet weak var consolidateButton: NSButton!
    @IBOutlet weak var saveVenuesButton: NSButton!
    @IBOutlet weak var editVenueButton: NSButton!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var pullDataButton: NSButtonCell!
    
    @IBOutlet weak var addBusinessButton: NSButton!
    @IBOutlet weak var editBusinessButton: NSButton!
    @IBOutlet weak var deleteBusinessButton: NSButton!
    @IBOutlet weak var pushBusinessButton: NSButton!
    
    @IBOutlet weak var addBandButton: NSButton!
    @IBOutlet weak var editBandButton: NSButton!
    @IBOutlet weak var deleteBandButton: NSButton!
    @IBOutlet weak var pushBandButton: NSButton!
    
    @IBOutlet weak var addShowButton: NSButton!
    @IBOutlet weak var editShowButton: NSButton!
    @IBOutlet weak var deleteShowButton: NSButton!
    @IBOutlet weak var pushShowButton: NSButton!
    
    @IBOutlet weak var rawJSONDataButton: NSButton!
    
    @IBOutlet weak var localBusinessesButton: NSButton!
    @IBOutlet weak var remoteBusinessButton: NSButton!
    
    @IBOutlet weak var localBandsButton: NSButton!
    @IBOutlet weak var remoteBandsButton: NSButton!
    
    @IBOutlet weak var localShowsButton: NSButton!
    @IBOutlet weak var remoteShowsButton: NSButton!

    @IBOutlet weak var showAmountLabel: NSTextField!
    @IBOutlet weak var removeShowTextField: NSTextField!
    
    var today = ""
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        notificationCenter.addObserver(self, selector: #selector(businessUpdatedAlertRecieved), name: NSNotification.Name("businessUpdated"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(showsUpdated), name: NSNotification.Name("showsUpdated"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(bandUpdatedAlertRecieved), name: NSNotification.Name("bandsUpdated"), object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        updateViews()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: Buttons Tapped Functions
    
    @IBAction func loadFileButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = true
        dialog.allowedFileTypes = ["json"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let results = dialog.urls // Pathname of the file
            
            for result in results {
                let url = URL(fileURLWithPath: result.path)
                parseDataController.path = url
                parseDataController.loadPath {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.editVenueButton.isEnabled = true
                self.consolidateButton.isEnabled = true
                self.rawJSONDataButton.state = .on
                self.saveVenuesButton.isEnabled = true
            }
            
            print("table reloaded1")
        } else {
            // User clicked on "Cancel"
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.clearButton.isEnabled = true
        }
        print("table reloaded2")
        
    }
    
    //MARK: Venue/JSON Buttons Tapped
    @IBAction func consolidateButtonTapped(_ sender: Any) {
        let was = parseDataController.jsonDataArray.count
        
        let reduce = parseDataController.jsonDataArray.reduce(into: [:], {$0[$1, default: 0] += 1})
        let sorted = reduce.sorted(by: {$0.value > $1.value})
        let map    = sorted.map({$0.key})
        let orderedArray = map.sorted { $0.venueName ?? "CORRUPTED" < $1.venueName ?? "CORRUPTED" }
        parseDataController.jsonDataArray = orderedArray
        parseDataController.jsonDataArray.removeAll(where: {$0.venueName == nil})
        let now = parseDataController.jsonDataArray.count
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        self.alertTextField.stringValue = "Shows were: \(was). And are now: \(now)"
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        parseDataController.jsonDataArray = []
        localDataController.saveJsonData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.clearButton.isEnabled = false
            self.consolidateButton.isEnabled = false
            self.saveVenuesButton.isEnabled = false
            self.editVenueButton.isEnabled = false
        }
    }
    
    @IBAction func saveNewShowsButtonTapped(_ sender: Any) {
        var cleanedJSONArray: [RawJSON] = []
        
        //Parsing to make Shows based on Businesses
        for venue in parseDataController.jsonDataArray {
            for business in localDataController.businessArray {
                if venue.venueName == business.name && venue.shows != nil {
                    NSLog("Found Matching Venues")
                    
                    for show in venue.shows! {
                        if show.showTime!.contains("2021") || show.showTime!.contains("2020") ||
                            show.showTime!.contains("2019") || show.showTime!.contains("2018") ||
                            show.showTime!.contains("2016") || show.showTime!.contains("2021") {
                            
                            NSLog("\(show) IS OLD")
                        } else {
                            
                            //New Shows
                            var newShow = Show(band: show.bandName!, venue: venue.venueName!, dateString: show.showTime!)
                            newShow.fixShowTime()
                            
                            let dts = newShow.dateString
                            newShow.dateString = "\(dts)" + " \(newShow.time)"
                            newShow.city = business.city
                            
                            //Checks two date formatts to create a date and time for the shows
                            dateFormatter.dateFormat = dateFormat1
                            if let date = dateFormatter.date(from: newShow.dateString) {
                                newShow.date = date
                            } else {
                                dateFormatter.dateFormat = dateFormat2
                                if let date = dateFormatter.date(from: newShow.dateString) {
                                    newShow.date = date
                                } else {
                                    dateFormatter.dateFormat = dateFormat3
                                    if let date = dateFormatter.date(from: newShow.dateString) {
                                        newShow.date = date
                                    }
                                }
                            }
                            
                            
                            if localDataController.showArray.contains(newShow) == false {
                                localDataController.showArray.append(newShow)
                                self.alertTextField.stringValue = "\(newShow.venue): \(newShow.dateString) Show Added"
                            }
                            
                            
                            //New Bands
                            let newBand = Band(name: show.bandName!)
                            if localDataController.bandArray.contains(newBand) == false {
                                localDataController.bandArray.append(newBand)
                            }
                            
                            cleanedJSONArray.append(venue)
                        }
                    }
                }
            }
        }
        
        for venue in cleanedJSONArray {
            parseDataController.jsonDataArray.removeAll(where: {$0 == venue})
        }
        
        localDataController.showArray.removeDuplicates()
        
        localDataController.saveJsonData()
        print("All Raw Shows Saved")
        localDataController.saveShowData()
        print("All Relevant Shows Saved")
        localDataController.saveBandData()
        print("All Bands Saved")
    
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
        
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
    }
    
    //MARK: Edit Buttons Tapped
    @IBAction func editVenueButtonTapped(_ sender: Any) {
        if tableView.selectedRow < 0 {
            return print("No Venue Selected")
        } else {
            performSegue(withIdentifier: "editVenueSegue", sender: self)
        }
        
    }
    
    @IBAction func editBusinessButtonTapped(_ sender: Any) {
        if tableView.selectedRow < 0 {
            return
        } else {
            performSegue(withIdentifier: "editBusinessSegue", sender: self)
        }
    }
    
    @IBAction func editBandButtonTapped(_ sender: Any) {
        if tableView.selectedRow < 0 {
            return
        } else {
            performSegue(withIdentifier: "editBandSegue", sender: self)
        }
    }
    
    @IBAction func editShowButtonTapped(_ sender: Any) {
        if tableView.selectedRow < 0 {
            return
        } else {
            performSegue(withIdentifier: "editShowSegue", sender: self)
        }
    }
    
    @IBAction func removeShowButtonTapped(_ sender: Any) {
        localDataController.showArray = []
        
        DispatchQueue.main.async { [self] in
            showAmountLabel.stringValue = "\(localDataController.showArray.count) Shows"
            tableView.reloadData()
        }
        
        localDataController.saveShowData()
    }
    
    //MARK: Push Buttons Tapped
    @IBAction func pushBusinessButtonTapped(_ sender: Any) {
        let fullBusinessData = localDataController.businessArray
        let ref = FireStoreReferenceManager.businessFullDataPath
        for business in fullBusinessData {
            
            do {
                try ref.document(business.venueID ?? UUID.init().uuidString).setData(from: business)
                self.alertTextField.stringValue = "Push Successfull"
            } catch let error {
                    NSLog(error.localizedDescription)
                self.alertTextField.stringValue = "Error pushing Business"
            }
        }
    }
    
    @IBAction func pushBandButtonTapped(_ sender: Any) {
        let bandData = localDataController.bandArray
        let ref = FireStoreReferenceManager.bandDataPath
        for band in bandData {
            do {
                try ref.document(band.bandID ).setData(from: band)
                self.alertTextField.stringValue = "Push Successfull"
            } catch let error {
                    NSLog(error.localizedDescription)
                self.alertTextField.stringValue = "Error pushing Band"
            }
        }
    }
    
    @IBAction func pushShowButtonTapped(_ sender: Any) {
        let showData = localDataController.showArray
        let ref = FireStoreReferenceManager.showDataPath
        for show in showData {
            
            var pushedShow = show
            pushedShow.lastModified = Timestamp()
            do {
                try ref.document(pushedShow.showID ).setData(from: pushedShow)
                self.alertTextField.stringValue = "Push Successfull"
            } catch let error {
                    NSLog(error.localizedDescription)
                self.alertTextField.stringValue = "Error pushing Show"
            }
        }
    }
    
    //MARK: Delete Buttons Tapped
    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
        let index = tableView.selectedRow
        if localBusinessesButton.state == .on && tableView.selectedRow != -1 {
            localDataController.businessArray.remove(at: index)
            localDataController.saveBusinessData()
        } else if remoteBusinessButton.state == .on && remoteDataController.remoteBusinessArray != [] {
            let business = remoteDataController.remoteBusinessArray[index]
            remoteDataController.remoteBusinessArray.remove(at: index)
            FireStoreReferenceManager.businessFullDataPath.document(business.venueID!).delete
            { (err) in
                if let err = err {
                    //MARK: Alert Here
                  NSLog("Error deleting Business: \(err)")
                    self.alertTextField.stringValue = "Error deleting Business"
                } else {
                    NSLog("Delete Successfull")
                    self.alertTextField.stringValue = "Delete Successfull"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func deleteBandButtonTapped(_ sender: Any) {
        let index = tableView.selectedRow
        let band = remoteDataController.remoteBandArray[index]
        
        if localBandsButton.state == .on {
            localDataController.bandArray.remove(at: index)
            localDataController.saveBandData()
        } else if remoteBandsButton.state == .on {
            remoteDataController.remoteBandArray.remove(at: index)
            FireStoreReferenceManager.bandDataPath.document(band.bandID).delete
            { (err) in
                if let err = err {
                    //MARK: Alert Here
                  NSLog("Error deleting Band: \(err)")
                    self.alertTextField.stringValue = "Error deleting Band"
                } else {
                    NSLog("Delete Successfull")
                    self.alertTextField.stringValue = "Delete Successfull"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func deleteShowButtonTapped(_ sender: Any) {
        let index = tableView.selectedRow
        let show = remoteDataController.remoteShowArray[index]
        
        if localShowsButton.state == .on {
            localDataController.showArray.remove(at: index)
            localDataController.saveShowData()
        } else if remoteShowsButton.state == .on {
            remoteDataController.remoteShowArray.remove(at: index)
            FireStoreReferenceManager.showDataPath.document(show.showID).delete
            { (err) in
                if let err = err {
                    //MARK: Alert Here
                  NSLog("Error deleting Band: \(err)")
                    self.alertTextField.stringValue = "Error deleting Band"
                } else {
                    NSLog("Delete Successfull")
                    self.alertTextField.stringValue = "Delete Successfull"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: Remote Data Handling
    @IBAction func pullDataButtonTapped(_ sender: Any) {
        if localBusinessesButton.state == .on || remoteBusinessButton.state == .on {
            getRemoteBusinessData()
        } else if localBandsButton.state == .on || remoteBandsButton.state == .on {
            getRemoteBandData()
        } else if localShowsButton.state == .on || remoteShowsButton.state == .on {
            getRemoteShowData()
        }
    }
    
    @IBAction func copyRemoteData(_ sender: Any) {
        copyRemoteData()
    }
    
    
    
    //MARK: Radio Buttons Local
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        
        if self.rawJSONDataButton.state == .on && parseDataController.jsonDataArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.loadFileButton.isEnabled = true
                self.pullDataButton.isEnabled = false
            }
            
        } else if self.rawJSONDataButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.loadFileButton.isEnabled = true
                self.consolidateButton.isEnabled = true
                self.saveVenuesButton.isEnabled = true
                self.editVenueButton.isEnabled = true
                self.clearButton.isEnabled = true
                self.pullDataButton.isEnabled = false
            }
            
        } else if self.localBusinessesButton.state == .on && localDataController.businessArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBusinessButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Business Data"
            }
            
        } else if self.localBusinessesButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBusinessButton.isEnabled = true
                self.editBusinessButton.isEnabled = true
                self.deleteBusinessButton.isEnabled = true
                self.pushBusinessButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Business Data"
                
            }
            
        } else if self.localBandsButton.state == .on && localDataController.bandArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBandButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Band Data"
            }
            
        } else if self.localBandsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBandButton.isEnabled = true
                self.editBandButton.isEnabled = true
                self.deleteBandButton.isEnabled = true
                self.pushBandButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Band Data"
            }
        } else if self.localShowsButton.state == .on && localDataController.showArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addShowButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Show Data"
            }
        } else if self.localShowsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addShowButton.isEnabled = true
                self.editShowButton.isEnabled = true
                self.deleteShowButton.isEnabled = true
                self.pushShowButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Show Data"
            }
            //MARK: Radio Buttons Remote
        } else if self.remoteBusinessButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBusinessButton.isEnabled = true
                self.editBusinessButton.isEnabled = true
                self.deleteBusinessButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Business Data"
            }
        } else if self.remoteBandsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBandButton.isEnabled = true
                self.editBandButton.isEnabled = true
                self.deleteBandButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Band Data"
            }
        } else if self.remoteShowsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addShowButton.isEnabled = true
                self.editShowButton.isEnabled = true
                self.deleteShowButton.isEnabled = true
                self.pullDataButton.isEnabled = true
                self.pullDataButton.title = "Pull Show Data"
            }
        }
    }
    
    @IBAction func ohmButtonToggled(_ sender: Any) {
        
        
        if ohmButton.state == .on {
            originalArray = localDataController.bandArray
            filteredArray = localDataController.bandArray.filter({$0.ohmPick == true})
            localDataController.bandArray = filteredArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            localDataController.bandArray = originalArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: UpdateView Functions
    private func updateViews() {
        dateFormatter.dateFormat = dateFormat3
        today = dateFormatter.string(from: Date())
        
        rawJSONDataButton.state = .on
        localDataController.loadBusinessData()
        localDataController.loadBusinessBasicData()
        localDataController.loadJsonData()
        localDataController.loadShowData()
        localDataController.loadBandData()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.showsUpdated()
        }
        
        if parseDataController.jsonDataArray == [] {
            DispatchQueue.main.async {
                self.buttonController(false)
                self.loadFileButton.isEnabled = true
            }
        } else if parseDataController.jsonDataArray != [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.loadFileButton.isEnabled = true
                self.consolidateButton.isEnabled = true
                self.saveVenuesButton.isEnabled = true
                self.editVenueButton.isEnabled = true
                self.clearButton.isEnabled = true
            }
        }
    }
    
    //MARK: Load Remote Data:+ Alerts Here
    private func getRemoteBandData() {
        print("Running Remote Band")
        FireStoreReferenceManager.bandDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                NSLog("Error getting bandData: \(err)")
            } else {
                self.alertTextField.stringValue = "Got band data"
                remoteDataController.remoteBandArray = []
                for band in querySnapshot!.documents {
                    let result = Result {
                        try band.data(as: Band.self)
                    }
                    switch result {
                    case .success(let band):
                        print("Success Result: getBandData")
                        if let band = band {
                            remoteDataController.remoteBandArray.append(band)
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding band: \(error)")
                        self.alertTextField.stringValue = "Failed to get band data"
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func getRemoteBusinessData() {
        print("Running Remote Business")
        FireStoreReferenceManager.businessFullDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                NSLog("Error getting bandData: \(err)")
            } else {
                self.alertTextField.stringValue = "Got business data"
                remoteDataController.remoteBusinessArray = []
                for business in querySnapshot!.documents {
                    let result = Result {
                        try business.data(as: BusinessFullData.self)
                    }
                    switch result {
                    case .success(let business):
                        print("Success Result: getBusinessData")
                        if let business = business {
                            remoteDataController.remoteBusinessArray.append(business)
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding business: \(error)")
                        self.alertTextField.stringValue = "Failed to get business data"
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func getRemoteShowData() {
        print("Running Remote Show")
        FireStoreReferenceManager.showDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                NSLog("Error getting bandData: \(err)")
            } else {
                self.alertTextField.stringValue = "Got show data"
                remoteDataController.remoteShowArray = []
                for show in querySnapshot!.documents {
                    let result = Result {
                        try show.data(as: Show.self)
                    }
                    switch result {
                    case .success(let show):
                        print("Success Result: getShowData")
                        if let show = show {
                            remoteDataController.remoteShowArray.append(show)
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding band: \(error)")
                        self.alertTextField.stringValue = "Failed to get show data"
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Copy Remote Data
    private func copyRemoteData() {
        if localBusinessesButton.state == .on || remoteBusinessButton.state == .on {
            localDataController.businessArray = remoteDataController.remoteBusinessArray
            alertTextField.stringValue = "Business Data Copied"
        } else if localBandsButton.state == .on || remoteBandsButton.state == .on {
            localDataController.bandArray = remoteDataController.remoteBandArray
            alertTextField.stringValue = "Band Data Copied"
        } else if localShowsButton.state == .on || remoteShowsButton.state == .on {
            localDataController.showArray = remoteDataController.remoteShowArray
            alertTextField.stringValue = "Show Data Copied"
        }
    }
    
    
    //MARK: TableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        if rawJSONDataButton.state == .on {
            return parseDataController.jsonDataArray.count
        } else if localBusinessesButton.state == .on {
            return localDataController.businessArray.count
        } else if localBandsButton.state == .on {
            return localDataController.bandArray.count
        } else if localShowsButton.state == .on {
            return localDataController.showArray.count
        } else if remoteBusinessButton.state == .on {
            return remoteDataController.remoteBusinessArray.count
        } else if remoteBandsButton.state == .on {
            return remoteDataController.remoteBandArray.count
        } else if remoteShowsButton.state == .on {
            return remoteDataController.remoteShowArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
            
            if rawJSONDataButton.state == .on {
                cell.textField?.stringValue = "\(row + 1): \(parseDataController.jsonDataArray[row].venueName ?? "CORRUPTED")"
                
            } else if localBusinessesButton.state == .on && localDataController.businessArray != [] {
                cell.textField?.stringValue = "\(row + 1): \(localDataController.businessArray[row].name!)"
                
            }  else if localBandsButton.state == .on && localDataController.bandArray != [] {
                if localDataController.bandArray[row].ohmPick == true {
                    cell.textField?.stringValue = "\(row + 1): \(localDataController.bandArray[row].name): !OHM!"
                    
                } else {
                    cell.textField?.stringValue = "\(row + 1): \(localDataController.bandArray[row].name)"
                }
                
            } else if localShowsButton.state == .on && localDataController.showArray != [] {
                inOrderArray = localDataController.showArray.sorted(by: {$0.date < $1.date})

                cell.textField?.stringValue = "\(row + 1): \(inOrderArray[row].venue): \(inOrderArray[row].dateString): *\(inOrderArray[row].band)*"
                
                //Color Coding
                let show = inOrderArray[row]
                dateFormatter.dateFormat = dateFormat3
                let showDate = dateFormatter.string(from: show.date)
                
                if showDate == today {
                    cell.textField?.textColor = .purple
                }
                
                if show.noTime == true {
                    cell.textField?.textColor = .red
                }
                
                if show.ohmPick == true {
                    cell.layer?.backgroundColor = NSColor.yellow.cgColor
                }
                
                
                
            } else if remoteBusinessButton.state == .on {
                cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBusinessArray[row].name!)"
                
            } else if remoteBandsButton.state == .on {
                if remoteDataController.remoteBandArray[row].ohmPick == true {
                    cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBandArray[row].name): !OHM!"
                    
                } else {
                    cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBandArray[row].name)"
                    
                }
            } else if remoteShowsButton.state == .on {
                let inOrder: [Show] = remoteDataController.remoteShowArray.sorted(by: {$0.date < $1.date})
                inOrderArray = inOrder
                cell.textField?.stringValue = "\(row + 1): \(inOrderArray[row].venue): \(inOrderArray[row].dateString): *\(inOrder[row].band)*"
            }
            
            return cell
        }
        
        return  nil
    }
    
    
    //MARK: Segue
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let indexPath = tableView.selectedRow
        
        if segue.identifier == "editVenueSegue" {
            
            guard let venueVC = segue.destinationController as? VenueDetailViewController else {return}
            venueVC.currentVenue = parseDataController.jsonDataArray[indexPath]
            
            //Local Business Handling:
        } else if segue.identifier == "editBusinessSegue" && localBusinessesButton.state == .on {
            guard let businessVC = segue.destinationController as? VenueDetailViewController else {return}
            businessVC.currentBusiness = localDataController.businessArray[indexPath]
            
            //Remote Business Handling:
        } else if segue.identifier == "editBusinessSegue" && remoteBusinessButton.state == .on {
            guard let businessVC = segue.destinationController as? VenueDetailViewController else {return}
            businessVC.currentBusiness = remoteDataController.remoteBusinessArray[indexPath]
            
            //Local Band Handling:
        } else if segue.identifier == "editBandSegue" && localBandsButton.state == .on {
            guard let bandVC = segue.destinationController as? BandDetailViewController else {return}
            bandVC.currentBand = localDataController.bandArray[indexPath]
            
            //Remote Band Handling:
        } else if segue.identifier == "editBandSegue" && remoteBandsButton.state == .on {
            guard let bandVC = segue.destinationController as? BandDetailViewController else {return}
            bandVC.currentBand = remoteDataController.remoteBandArray[indexPath]
            
            //Local Show Handling
        } else if segue.identifier == "editShowSegue" && localShowsButton.state == .on {
            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
            showVC.currentShow = inOrderArray[indexPath]
            
            //Remote Show Handling
        } else if segue.identifier == "editShowSegue" && remoteShowsButton.state == .on {
            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
            showVC.currentShow = inOrderArray[indexPath]
        }
        
        
    }
    
}

    //MARK: Helper Functions
extension MainViewController {
    
    private func buttonController(_ state:Bool) {
        loadFileButton.isEnabled = state
        consolidateButton.isEnabled = state
        saveVenuesButton.isEnabled = state
        editVenueButton.isEnabled = state
        clearButton.isEnabled = state
        addBusinessButton.isEnabled = state
        editBusinessButton.isEnabled = state
        deleteBusinessButton.isEnabled = state
        pushBusinessButton.isEnabled = state
        addBandButton.isEnabled = state
        editBandButton.isEnabled = state
        deleteBandButton.isEnabled = state
        pushBandButton.isEnabled = state
        addShowButton.isEnabled = state
        editShowButton.isEnabled = state
        deleteShowButton.isEnabled = state
        pushShowButton.isEnabled = state
    }
    
    @objc func showsUpdated() {
        //MARK: REMOVE OLD SHOWS
        //let currentDate = Date()
        //localDataController.showArray.removeAll(where: {$0.date! < currentDate})
        
        DispatchQueue.main.async {
            self.showAmountLabel.stringValue = "\(localDataController.showArray.count) Shows"
            self.tableView.reloadData()
        }
    }
    
    @objc func businessUpdatedAlertRecieved() {
        saveVenuesButton.state = .on
        if self.localBusinessesButton.state == .on && localDataController.businessArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBusinessButton.isEnabled = true
            }
            
        } else if self.localBusinessesButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBusinessButton.isEnabled = true
                self.editBusinessButton.isEnabled = true
            }
            
        }
    }
    
    @objc func bandUpdatedAlertRecieved() {
        if localBandsButton.state == .on {
            DispatchQueue.main.async { [self] in
                tableView.reloadData()
            }
        }
    }
}

