////
////  MainViewController.swift
////  Ohmicity Backend
////
////  Created by Nathan Hedgeman on 5/20/21.
////
//
//import Cocoa
//import FirebaseCore
//import FirebaseDatabase
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//
//
//
//
//class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
//    
//    //MARK: Properties
//    var originalArray = [Band]()
//    var filteredBandArray = [Band]()
//    var removeBandsArray = [Band]()
//    var showsInOrderArray = [Show]()
//    var bandsInOrderArray = [Band]()
//    var businessesInOrderArray = [BusinessFullData]()
//    
//    @IBOutlet weak var tableView: NSTableView!
//    @IBOutlet weak var ohmButton: NSButton!
//    @IBOutlet weak var alertTextField: NSTextField!
//    
//    @IBOutlet weak var showAmountLabel: NSTextField!
//    @IBOutlet weak var versionLabel: NSTextField!
//    
//    
//    @IBOutlet weak var searchBarField: NSSearchField!
//    
//    
//    @IBOutlet weak var loadFileButton: NSButton!
//    @IBOutlet weak var consolidateButton: NSButton!
//    @IBOutlet weak var saveVenuesButton: NSButton!
//    @IBOutlet weak var editVenueButton: NSButton!
//    @IBOutlet weak var clearButton: NSButton!
//    @IBOutlet weak var pullDataButton: NSButtonCell!
//    
//    @IBOutlet weak var addBusinessButton: NSButton!
//    @IBOutlet weak var editBusinessButton: NSButton!
//    @IBOutlet weak var deleteBusinessButton: NSButton!
//    @IBOutlet weak var pushBusinessButton: NSButton!
//    
//    @IBOutlet weak var addBandButton: NSButton!
//    @IBOutlet weak var editBandButton: NSButton!
//    @IBOutlet weak var deleteBandButton: NSButton!
//    @IBOutlet weak var pushBandButton: NSButton!
//    
//    @IBOutlet weak var addShowButton: NSButton!
//    @IBOutlet weak var editShowButton: NSButton!
//    @IBOutlet weak var deleteShowButton: NSButton!
//    @IBOutlet weak var pushShowButton: NSButton!
//    
//    @IBOutlet weak var rawJSONDataButton: NSButton!
//    
//    @IBOutlet weak var localBusinessButton: NSButton!
//    @IBOutlet weak var remoteBusinessButton: NSButton!
//    
//    @IBOutlet weak var localBandsButton: NSButton!
//    @IBOutlet weak var remoteBandsButton: NSButton!
//    @IBOutlet weak var newBandsButton: NSButton!
//    
//    @IBOutlet weak var localShowsButton: NSButton!
//    @IBOutlet weak var remoteShowsButton: NSButton!
//    
//    
//    
//    var today = ""
//    
//    //MARK: ViewDidLoad
//    override func viewDidLoad() {
//        FirebaseApp.configure()
//        Database.database().isPersistenceEnabled = true
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.target = self
//        tableView.doubleAction = #selector(doubleClicked)
//        
//        notificationCenter.addObserver(self, selector: #selector(businessUpdatedAlertReceived), name: NSNotification.Name("businessUpdated"), object: nil)
//        notificationCenter.addObserver(self, selector: #selector(showsUpdated), name: NSNotification.Name("showsUpdated"), object: nil)
//        notificationCenter.addObserver(self, selector: #selector(bandUpdatedAlertReceived), name: NSNotification.Name("bandsUpdated"), object: nil)
//        
//        updateViews()
//    }
//
//    
//    @IBAction func breaker(_ sender: Any) {
//        
//    }
//    
//    //MARK: Function Buttons
//    @IBAction func removeDoubleBandsButtonTapped(_ sender: Any) {
//        removeDoubleBands()
//    }
//    
//    @IBAction func removeBandsWithNoShowsButtonTapped(_ sender: Any) {
//        removeBandsWithNoShows()
//    }
//    
//    //MARK: Buttons Tapped Functions
//    
//    @IBAction func loadFileButtonTapped(_ sender: Any) {
//        let dialog = NSOpenPanel();
//        dialog.title                   = "Choose a file| Our Code World"
//        dialog.showsResizeIndicator    = true
//        dialog.showsHiddenFiles        = false
//        dialog.allowsMultipleSelection = false
//        dialog.canChooseDirectories = false
//        dialog.allowsMultipleSelection = true
//        dialog.allowedFileTypes = ["json"]
//        
//        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
//            let results = dialog.urls // Pathname of the file
//            
//            for result in results {
//                let url = URL(fileURLWithPath: result.path)
//                rawShowDataController.path = url
//                rawShowDataController.loadShowsPath {
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//                
//            }
//            
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.editVenueButton.isEnabled = true
//                self.consolidateButton.isEnabled = true
//                self.rawJSONDataButton.state = .on
//                self.saveVenuesButton.isEnabled = true
//            }
//            
//            print("table reloaded1")
//        } else {
//            // User clicked on "Cancel"
//            return
//        }
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            self.clearButton.isEnabled = true
//        }
//        print("table reloaded2")
//        
//    }
//    
//    //MARK: Venue/JSON Buttons Tapped
//    @IBAction func consolidateButtonTapped(_ sender: Any) {
////        let was = parseDataController.jsonDataArray.count
////
////        let reduce = parseDataController.jsonDataArray.reduce(into: [:], {$0[$1, default: 0] += 1})
////        let sorted = reduce.sorted(by: {$0.value > $1.value})
////        let map    = sorted.map({$0.key})
////        let orderedArray = map.sorted { $0.venueName ?? "CORRUPTED" < $1.venueName ?? "CORRUPTED" }
////        parseDataController.jsonDataArray = orderedArray
////        parseDataController.jsonDataArray.removeAll(where: {$0.venueName == nil})
////        parseDataController.resultsArray = parseDataController.jsonDataArray
////        let now = parseDataController.resultsArray.count
////
////        DispatchQueue.main.async {
////            self.tableView.reloadData()
////        }
////
////        self.alertTextField.stringValue = "Shows were: \(was). And are now: \(now)"
//    }
//    
//    @IBAction func clearButtonTapped(_ sender: Any) {
//        rawShowDataController.rawShowsArray = []
//        rawShowDataController.rawShowsResultsArray = rawShowDataController.rawShowsArray
//        LocalDataStorageController.saveJsonData()
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            self.clearButton.isEnabled = false
//            self.consolidateButton.isEnabled = false
//            self.saveVenuesButton.isEnabled = false
//            self.editVenueButton.isEnabled = false
//        }
//    }
//    
//    
//    //MARK: Save New Shows
//    @IBAction func saveNewShowsButtonTapped(_ sender: Any) {
////        var cleanedJSONArray: [RawJSON] = []
////
////        //Parsing to make Shows based on Businesses
////        for venue in parseDataController.jsonDataArray {
////            for business in localDataController.businessArray {
////                if venue.venueName == business.name && venue.shows != nil {
////                    NSLog("Found Matching Venues")
////
////                    guard let shows = venue.shows else {continue}
////
////                    for show in shows {
////                        //New Shows
////                        //Remove Problem Band Names from Data
////                        var bandName = ""
////
////                        for band in localDataController.bandArray {
////
////                            guard let rawBand = show.band else {
////                                alertTextField.stringValue = "\(venue.venueName ?? "Some Venue") is missing band for \(show.dateString ?? "Some Date") show"
////                                continue
////                            }
////
////                            if rawBand.localizedCaseInsensitiveContains(band.name) {
////                                NSLog("\(rawBand) linked to \(band.name)")
////                                bandName = band.name
////                                break
////                            } else if rawBand == "band" {
////                                break
////
////                            } else {
////                                bandName = rawBand
////                            }
////
////
////                        }
////
////                        let showTime = show.dateString!
////
////                        //var newShow = Show(band: bandName, venue: venue.venueName!, dateString: showTime)
////
////                        newShow.lastModified = Timestamp()
////                        newShow.dateString = show.dateString!
////                        newShow.city = business.city
////                        newShow.city?.append(.All)
////
////                        //Checks two date formats to create a date and time for the shows
////                        dateFormatter.dateFormat = dateFormat4
////                        if let date = dateFormatter.date(from: newShow.dateString) {
////                            newShow.date = date
////                        }
////
////                        //Adds a new show and checks if old shows exist to put them on hold
////                        if localDataController.showArray.contains(newShow) == true {
////
////                            guard var holdShow = localDataController.showArray.first(where: {$0 == newShow}) else { continue }
////                            holdShow.onHold = true
////                            holdShow.lastModified = Timestamp()
////
////                            localDataController.showArray.removeAll(where: {$0 == newShow})
////
////                            localDataController.showArray.append(holdShow)
////                            localDataController.showArray.append(newShow)
////                        } else {
////                            localDataController.showArray.append(newShow)
////                        }
////
////                        //Adds a new band and prevents duplicates of bands already added
////                        let newBand = Band(name: bandName)
////                        if localDataController.bandArray.contains(newBand) == false {
////                            localDataController.bandArray.append(newBand)
////                        }
////
////                        cleanedJSONArray.append(venue)
////                    }
////                }
////            }
////        }
////
////
////        for venue in cleanedJSONArray {
////            //parseDataController.jsonDataArray.removeAll(where: {$0 == venue})
////        }
////        parseDataController.resultsArray = parseDataController.jsonDataArray
////
////        localDataController.showArray.removeDuplicates()
////
////        localDataController.saveJsonData()
////        print("All Raw Shows Saved")
////        localDataController.saveShowData()
////        print("All Relevant Shows Saved")
////        localDataController.saveBandData()
////        print("All Bands Saved")
////
////        DispatchQueue.main.async { [self] in
////            tableView.reloadData()
////        }
////
////        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
//    }
//    
//    //MARK: Edit Buttons Tapped
//    @IBAction func editVenueButtonTapped(_ sender: Any) {
//        if tableView.selectedRow < 0 {
//            return print("No Venue Selected")
//        } else {
//            performSegue(withIdentifier: "editVenueSegue", sender: self)
//        }
//        
//    }
//    
//    @IBAction func editBusinessButtonTapped(_ sender: Any) {
//        if tableView.selectedRow < 0 {
//            return
//        } else {
//            performSegue(withIdentifier: "editBusinessSegue", sender: self)
//        }
//    }
//    
//    @IBAction func editBandButtonTapped(_ sender: Any) {
//        if tableView.selectedRow < 0 {
//            return
//        } else {
//            performSegue(withIdentifier: "editBandSegue", sender: self)
//        }
//    }
//    
//    @IBAction func editShowButtonTapped(_ sender: Any) {
//        if tableView.selectedRow < 0 {
//            return
//        } else {
//            performSegue(withIdentifier: "editShowSegue", sender: self)
//        }
//    }
//    
//    
//    //MARK: Remove/Delete Shows
//    @IBAction func removeAllShowsButtonTapped(_ sender: Any) {
//        LocalDataStorageController.showArray = []
//        
//        DispatchQueue.main.async { [self] in
//            showAmountLabel.stringValue = "\(LocalDataStorageController.showArray.count) Shows"
//            tableView.reloadData()
//        }
//        
//        LocalDataStorageController.saveShowData()
//    }
//    
//    @IBAction func removeOldShowsButtonTapped(_ sender: Any) {
//        let threeHoursAgo = Date().addingTimeInterval(-10800)
//        var showsToDeleteArray = [Show]()
//        
//        for show in LocalDataStorageController.showArray {
//            if show.date < threeHoursAgo {
//                showsToDeleteArray.append(show)
//            }
//        }
//        
//        for show in RemoteDataController.showArray {
//            if show.date < threeHoursAgo {
//                showsToDeleteArray.append(show)
//            }
//        }
//        
//        print(showsToDeleteArray.count)
//        for show in showsToDeleteArray {
//            LocalDataStorageController.showArray.removeAll(where: {$0 == show})
//            
//            ref.showDataPath.document(show.showID).delete { [self] err in
//                if let err = err {
//                    alertTextField.stringValue = err.localizedDescription
//                    NSLog(err.localizedDescription)
//                } else {
//                    alertTextField.stringValue = "\(showsToDeleteArray.count) Shows Deleting From Local And Remote"
//                }
//            }
//            
//        }
//        
//        LocalDataStorageController.saveShowData()
//        alertTextField.stringValue = "\(showsToDeleteArray.count) Shows Deleted"
//        tableView.reloadData()
//    }
//    
//    
//    
//    //MARK: Push Buttons Tapped
//    @IBAction func pushBusinessButtonTapped(_ sender: Any) {
//        let fullBusinessData = LocalDataStorageController.businessArray
//        let ref = FireStoreReferenceManager.businessFullDataPath
//        for business in fullBusinessData {
//            do {
//                try ref.document(business.venueID ?? UUID.init().uuidString).setData(from: business)
//                self.alertTextField.stringValue = "Push Successful"
//            } catch let error {
//                NSLog(error.localizedDescription)
//                self.alertTextField.stringValue = "Error pushing Business"
//            }
//        }
//    }
//    
//    @IBAction func pushBandButtonTapped(_ sender: Any) {
//        let bandData = LocalDataStorageController.bandArray
//        let ref = FireStoreReferenceManager.bandDataPath
//        for band in bandData {
//            do {
//                try ref.document(band.bandID).setData(from: band) { err in
//                    if let err = err {
//                        self.alertTextField.stringValue = "\(err.localizedDescription)"
//                        NSLog(err.localizedDescription)
//                    } else {
//                        self.alertTextField.stringValue = "Push Successful"
//                    }
//                }
//                
//                
//                
//            } catch let error {
//                NSLog(error.localizedDescription)
//                self.alertTextField.stringValue = "Error pushing Band"
//            }
//        }
//    }
//    
//    @IBAction func pushShowButtonTapped(_ sender: Any) {
//        let showData = LocalDataStorageController.showArray
//        let bandData = LocalDataStorageController.bandArray
//        for show in showData {
//            var num = 0
//            do {
//                try ref.showDataPath.document(show.showID ).setData(from: show) { err in
//                    if let err = err {
//                        self.alertTextField.stringValue = "\(err.localizedDescription)"
//                        NSLog(err.localizedDescription)
//                    } else {
//                        num += 1
//                        self.alertTextField.stringValue = "Show Push Success: Number \(num)"
//                    }
//                }
//            } catch let error {
//                NSLog(error.localizedDescription)
//                self.alertTextField.stringValue = "Error pushing Show"
//            }
//        }
//        
//        for band in bandData {
//            var num = 0
//            do {
//                try ref.bandDataPath.document(band.bandID).setData(from: band) { err in
//                    if let err = err {
//                        self.alertTextField.stringValue = "\(err.localizedDescription)"
//                        NSLog(err.localizedDescription)
//                    } else {
//                        num += 1
//                        self.alertTextField.stringValue = "Band Push Success: Number \(num)"
//                    }
//                }
//            } catch {
//                NSLog(error.localizedDescription)
//                self.alertTextField.stringValue = "Error pushing Band: \(band.name)"
//            }
//        }
//    }
//    
//    //MARK: Delete Buttons Tapped
//    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
//        let index = tableView.selectedRow
//        let business = LocalDataStorageController.businessResults[index]
//        
//        if localBusinessButton.state == .on && tableView.selectedRow != -1 {
//            LocalDataStorageController.businessArray.removeAll(where: {$0 == business})
//            
//            LocalDataStorageController.saveBusinessData()
//        } else if remoteBusinessButton.state == .on && RemoteDataController.businessArray != [] {
//            RemoteDataController.businessArray.removeAll(where: {$0 == business})
//            FireStoreReferenceManager.businessFullDataPath.document(business.venueID).delete
//            { (err) in
//                if let err = err {
//                    //MARK: Alert Here
//                    NSLog("Error deleting Business: \(err)")
//                    self.alertTextField.stringValue = "Error deleting Business"
//                } else {
//                    NSLog("Delete Successful")
//                    self.alertTextField.stringValue = "Delete Successful"
//                }
//            }
//        }
//        
//        DispatchQueue.main.async {
//            notificationCenter.post(Notification(name: Notification.Name(rawValue: "businessUpdated")))
//            self.tableView.reloadData()
//        }
//    }
//    
//    @IBAction func deleteBandButtonTapped(_ sender: Any) {
//        var index = tableView.selectedRow
//        if index == -1 {
//            return
//        }
//        var band = LocalDataStorageController.bandResults[index]
//        
//        if localBandsButton.state == .on {
//            LocalDataStorageController.bandArray.removeAll(where: {$0.bandID == band.bandID})
//            LocalDataStorageController.bandResults.removeAll(where: {$0.bandID == band.bandID})
//            LocalDataStorageController.saveBandData()
//            tableView.reloadData()
//            
//        } else if remoteBandsButton.state == .on {
//            index = tableView.selectedRow
//            band = RemoteDataController.bandResults[index]
//            RemoteDataController.bandArray.removeAll(where: {$0 == band})
//            RemoteDataController.bandResults.removeAll(where: {$0.bandID == band.bandID})
//            FireStoreReferenceManager.bandDataPath.document(band.bandID).delete
//            { (err) in
//                if let err = err {
//                    //MARK: Alert Here
//                    NSLog("Error deleting Band: \(err)")
//                    self.alertTextField.stringValue = "Error deleting Band"
//                } else {
//                    NSLog("Delete Successful")
//                    self.alertTextField.stringValue = "Delete Successful"
//                }
//            }
//            
//        } else if newBandsButton.state == .on {
//            LocalDataStorageController.bandArray.removeAll(where: {$0.bandID == band.bandID})
//            LocalDataStorageController.bandResults.removeAll(where: {$0.bandID == band.bandID})
//            LocalDataStorageController.saveBandData()
//            tableView.reloadData()
//        }
//        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            print("Reloaded")
//        }
//    }
//    
//    @IBAction func deleteShowButtonTapped(_ sender: Any) {
//        if localShowsButton.state == .on {
//            let index = tableView.selectedRow
//            let show = LocalDataStorageController.showResults[index]
//            LocalDataStorageController.showArray.removeAll(where: {$0 == show})
//            LocalDataStorageController.saveShowData()
//        } else if remoteShowsButton.state == .on {
//            let index = tableView.selectedRow
//            let show = RemoteDataController.showResults[index]
//            RemoteDataController.showArray.removeAll(where: {$0 == show})
//            RemoteDataController.showResults = RemoteDataController.showArray
//            print(show)
//            ref.showDataPath.document(show.showID).delete
//            { (err) in
//                if let err = err {
//                    //MARK: Alert Here
//                    NSLog(err.localizedDescription)
//                    self.alertTextField.stringValue = err.localizedDescription
//                } else {
//                    NSLog("Delete Successful")
//                    self.alertTextField.stringValue = "Delete Successful"
//                    print("\(show)")
//                }
//            }
//        }
//        
//        DispatchQueue.main.async {
//            notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
//            self.tableView.reloadData()
//        }
//    }
//    
//    
//    //MARK: Search Button/TextField
//    @IBAction func searchBar(_ sender: Any) {
//        search()
//    }
//    
//    
//    
//    
//    //MARK: Show On Hold
//    @IBAction func showHoldButtonTapped(_ sender: Any) {
//        let index = tableView.selectedRow
//        var show = showsInOrderArray[index]
//        show.onHold = true
//        show.lastModified = Timestamp()
//        do {
//            try ref.showDataPath.document(show.showID).setData(from: show)
//        } catch {
//            NSLog("Error Pushing Updated Show")
//            alertTextField.stringValue = "Error Pushing Updated Show"
//        }
//        
//        LocalDataStorageController.saveShowData()
//                
//    }
//    
//    
//    //MARK: Remote Data Handling
//    @IBAction func pullDataButtonTapped(_ sender: Any) {
//        if remoteBusinessButton.state == .on {
//            getRemoteBusinessData()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        } else if localBandsButton.state == .on || remoteBandsButton.state == .on {
//            getRemoteBandData()
//        } else if localShowsButton.state == .on || remoteShowsButton.state == .on {
//            getRemoteShowData()
//        }
//    }
//    
//    @IBAction func copyRemoteData(_ sender: Any) {
//        copyRemoteData()
//    }
//    
//    
//    
//    //MARK: Radio Buttons Local
//    @IBAction func radioButtonChanged(_ sender: AnyObject) {
//        searchBarField.isEnabled = true
//        searchBarField.stringValue = ""
//        searchBarField.becomeFirstResponder()
//        
//        notificationCenter.post(Notification(name: Notification.Name(rawValue: "businessUpdated")))
//        notificationCenter.post(Notification(name: Notification.Name(rawValue: "bandsUpdated")))
//        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
//        
//        if self.rawJSONDataButton.state == .on && rawShowDataController.rawShowsArray == [] {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.loadFileButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//            }
//            
//        } else if self.rawJSONDataButton.state == .on {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.loadFileButton.isEnabled = true
//                self.consolidateButton.isEnabled = true
//                self.saveVenuesButton.isEnabled = true
//                self.editVenueButton.isEnabled = true
//                self.clearButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//            }
//            
//        } else if self.localBusinessButton.state == .on && LocalDataStorageController.businessArray == [] {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBusinessButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//            
//        } else if self.localBusinessButton.state == .on {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBusinessButton.isEnabled = true
//                self.editBusinessButton.isEnabled = true
//                self.deleteBusinessButton.isEnabled = true
//                self.pushBusinessButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//                
//            }
//            
//        } else if self.localBandsButton.state == .on && LocalDataStorageController.bandArray == [] {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBandButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//            
//        } else if self.localBandsButton.state == .on {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBandButton.isEnabled = true
//                self.editBandButton.isEnabled = true
//                self.deleteBandButton.isEnabled = true
//                self.pushBandButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//            
//        } else if self.newBandsButton.state == .on {
//            DispatchQueue.main.async {
//                self.bringNewBandsToTop()
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBandButton.isEnabled = true
//                self.editBandButton.isEnabled = true
//                self.deleteBandButton.isEnabled = true
//                self.pushBandButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//            
//        } else if self.localShowsButton.state == .on && LocalDataStorageController.showArray == [] {
//            searchBarField.isEnabled = false
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addShowButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//        } else if self.localShowsButton.state == .on {
//            searchBarField.isEnabled = false
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addShowButton.isEnabled = true
//                self.editShowButton.isEnabled = true
//                self.deleteShowButton.isEnabled = true
//                self.pushShowButton.isEnabled = true
//                self.pullDataButton.isEnabled = false
//                self.pullDataButton.title = "Choose Remote Data"
//            }
//            //MARK: Radio Buttons Remote
//        } else if self.remoteBusinessButton.state == .on {
//            notificationCenter.post(Notification(name: Notification.Name(rawValue: "businessUpdated")))
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBusinessButton.isEnabled = true
//                self.editBusinessButton.isEnabled = true
//                self.deleteBusinessButton.isEnabled = true
//                self.pullDataButton.isEnabled = true
//                self.pullDataButton.title = "Pull Business Data"
//            }
//        } else if self.remoteBandsButton.state == .on {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBandButton.isEnabled = true
//                self.editBandButton.isEnabled = true
//                self.deleteBandButton.isEnabled = true
//                self.pullDataButton.isEnabled = true
//                self.pullDataButton.title = "Pull Band Data"
//            }
//        } else if self.remoteShowsButton.state == .on {
//            searchBarField.isEnabled = false
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addShowButton.isEnabled = true
//                self.editShowButton.isEnabled = true
//                self.deleteShowButton.isEnabled = true
//                self.pullDataButton.isEnabled = true
//                self.pullDataButton.title = "Pull Show Data"
//            }
//        }
//    }
//    
//    @IBAction func ohmButtonToggled(_ sender: Any) {
//        
//        
//        if ohmButton.state == .on {
//            originalArray = LocalDataStorageController.bandArray
//            filteredBandArray = LocalDataStorageController.bandArray.filter({$0.ohmPick == true})
//            LocalDataStorageController.bandArray = filteredBandArray
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        } else {
//            LocalDataStorageController.bandArray = originalArray
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    
//    //MARK: UpdateView Functions
//    private func updateViews() {
//        versionLabel.stringValue = " Version \((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!)" 
//        dateFormatter.dateFormat = dateFormat3
//        today = dateFormatter.string(from: Date())
//        
//        rawJSONDataButton.state = .on
//        LocalDataStorageController.loadBusinessData()
//        LocalDataStorageController.loadJsonData()
//        LocalDataStorageController.loadShowData()
//        LocalDataStorageController.loadBandData()
//        LocalDataStorageController.loadBandTagData()
//        LocalDataStorageController.loadVenueTagData()
//        
//        //Search Functionality
//        inOrderArrays()
//        rawShowDataController.rawShowsResultsArray = rawShowDataController.rawShowsArray
//        LocalDataStorageController.businessResults = LocalDataStorageController.businessArray
//        RemoteDataController.businessResults = RemoteDataController.businessArray
//        LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//        
//        searchBarField.nextKeyView = tableView
//        tableView.nextKeyView = searchBarField
//        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            self.showsUpdated()
//        }
//        
//        if rawShowDataController.rawShowsArray == [] {
//            DispatchQueue.main.async {
//                self.buttonController(false)
//                self.loadFileButton.isEnabled = true
//            }
//        } else if rawShowDataController.rawShowsArray != [] {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.loadFileButton.isEnabled = true
//                self.consolidateButton.isEnabled = true
//                self.saveVenuesButton.isEnabled = true
//                self.editVenueButton.isEnabled = true
//                self.clearButton.isEnabled = true
//            }
//        }
//    }
//    
//    //MARK: Load Remote Data:+ Alerts Here
//    private func getRemoteBandData() {
//        print("Running Remote Band")
//        FireStoreReferenceManager.bandDataPath.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                NSLog("Error getting bandData: \(err)")
//            } else {
//                self.alertTextField.stringValue = "Got band data"
//                RemoteDataController.bandArray = []
//                for band in querySnapshot!.documents {
//                    let result = Result {
//                        try band.data(as: Band.self)
//                    }
//                    switch result {
//                    case .success(let band):
//                        print("Success Result: getBandData")
//                        if let band = band {
//                            RemoteDataController.bandArray.append(band)
//                        } else {
//                            print("Document does not exist")
//                        }
//                    case .failure(let error):
//                        print("Error decoding band: \(error)")
//                        self.alertTextField.stringValue = "Failed to get band data"
//                    }
//                }
//                
//                let band = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
//                RemoteDataController.bandArray = band
//                RemoteDataController.bandResults = RemoteDataController.bandArray
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    private func getRemoteBusinessData() {
//        print("Running Remote Business")
//        FireStoreReferenceManager.businessFullDataPath.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                NSLog("Error getting bandData: \(err)")
//            } else {
//                self.alertTextField.stringValue = "Got business data"
//                RemoteDataController.businessArray = []
//                for business in querySnapshot!.documents {
//                    let result = Result {
//                        try business.data(as: BusinessFullData.self)
//                    }
//                    switch result {
//                    case .success(let business):
//                        print("Success Result: getBusinessData")
//                        if let business = business {
//                            RemoteDataController.businessArray.append(business)
//                        } else {
//                            print("Document does not exist")
//                        }
//                    case .failure(let error):
//                        print("Error decoding business: \(error)")
//                        self.alertTextField.stringValue = "Failed to get business data"
//                    }
//                }
//                let biz = RemoteDataController.businessArray.sorted(by: {$0.name < $1.name})
//                RemoteDataController.businessArray = biz
//                RemoteDataController.businessResults = RemoteDataController.businessArray
//                
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    private func getRemoteShowData() {
//        print("Running Remote Show")
//        FireStoreReferenceManager.showDataPath.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                NSLog("Error getting bandData: \(err)")
//            } else {
//                self.alertTextField.stringValue = "Got show data"
//                RemoteDataController.showArray = []
//                for show in querySnapshot!.documents {
//                    let result = Result {
//                        try show.data(as: Show.self)
//                    }
//                    switch result {
//                    case .success(let show):
//                        print("Success Result: getShowData")
//                        if let show = show {
//                            RemoteDataController.showArray.append(show)
//                        } else {
//                            print("Document does not exist")
//                        }
//                    case .failure(let error):
//                        print("Error decoding band: \(error)")
//                        self.alertTextField.stringValue = "Failed to get show data"
//                    }
//                }
//                RemoteDataController.showResults = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    //MARK: Copy Remote Data
//    private func copyRemoteData() {
//        if localBusinessButton.state == .on || remoteBusinessButton.state == .on {
//            LocalDataStorageController.businessArray = RemoteDataController.businessArray
//            LocalDataStorageController.businessResults = LocalDataStorageController.businessArray
//            LocalDataStorageController.saveBusinessData()
//            alertTextField.stringValue = "Business Data Copied"
//        } else if localBandsButton.state == .on || remoteBandsButton.state == .on {
//            LocalDataStorageController.bandArray = RemoteDataController.bandArray
//            LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//            LocalDataStorageController.saveBandData()
//            alertTextField.stringValue = "Band Data Copied"
//        } else if localShowsButton.state == .on || remoteShowsButton.state == .on {
//            LocalDataStorageController.showArray = RemoteDataController.showArray
//            LocalDataStorageController.saveShowData()
//            alertTextField.stringValue = "Show Data Copied"
//        }
//    }
//    
//    
//    
//    
//    //MARK: TableView
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        if rawJSONDataButton.state == .on {
//            return rawShowDataController.rawShowsResultsArray.count
//        } else if localBusinessButton.state == .on {
//            return LocalDataStorageController.businessResults.count
//        } else if localBandsButton.state == .on {
//            return LocalDataStorageController.bandResults.count
//        } else if localShowsButton.state == .on {
//            return LocalDataStorageController.showArray.count
//        } else if remoteBusinessButton.state == .on {
//            return RemoteDataController.businessResults.count
//        } else if remoteBandsButton.state == .on {
//            return RemoteDataController.bandResults.count
//        } else if remoteShowsButton.state == .on {
//            return RemoteDataController.showResults.count
//        } else if newBandsButton.state == .on {
//            return LocalDataStorageController.bandResults.count
//        }
//        return 1
//    }
//    
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        
//        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
//            
//            //RawJSON
//            if rawJSONDataButton.state == .on {
////                guard ((cell.textField?.stringValue = "\(row + 1): \(parseDataController.resultsArray[row].venueName ?? "CORRUPTED")") != nil) else {return NSTableCellView()}
////
//                //Local Businesses
//            } else if localBusinessButton.state == .on && LocalDataStorageController.businessArray != [] {
//                cell.textField?.stringValue = "\(row + 1): \(LocalDataStorageController.businessResults[row].name)"
//                
//                
//                //Local Bands
//            }  else if localBandsButton.state == .on && LocalDataStorageController.bandArray != [] {
//                
//                if LocalDataStorageController.bandResults[row].ohmPick == true {
//                    cell.textField?.stringValue = "\(row + 1): \(LocalDataStorageController.bandResults[row].name): !OHM!"
//                } else {
//                    cell.textField?.stringValue = "\(row + 1): \(LocalDataStorageController.bandResults[row].name)"
//                }
//                
//                if LocalDataStorageController.bandResults[row].photo != nil {
//                    cell.textField?.textColor = .orange
//                }
//                
//                //New Bands
//            } else if newBandsButton.state == .on && LocalDataStorageController.bandArray != [] {
//                cell.textField?.stringValue = "\(row + 1): \(LocalDataStorageController.bandResults[row].name)"
//                
//                if LocalDataStorageController.bandResults[row].photo != nil {
//                    cell.textField?.textColor = .orange
//                }
//                
//                //Local Shows
//            } else if localShowsButton.state == .on && LocalDataStorageController.showArray != [] {
//                showsInOrderArray = LocalDataStorageController.showArray.sorted(by: {$0.date < $1.date})
//                let show = showsInOrderArray[row]
//                
//                dateFormatter.dateFormat = dateFormatShowInfo
//                let showDay = dateFormatter.string(from: show.date)
//                cell.textField?.textColor = .white
//                
//                cell.textField?.stringValue = "\(row + 1): \(showDay): \(showsInOrderArray[row].venue):  *\(showsInOrderArray[row].band)*"
//                
//                //Show Color Coding
//                
//                dateFormatter.dateFormat = dateFormat3
//                let showDate = dateFormatter.string(from: show.date)
//                
//                if showDate == today {
//                    cell.textField?.textColor = .orange
//                }
//                
//                if show.onHold == true {
//                    cell.textField?.textColor = .red
//                }
//                
//                if show.ohmPick == true {
//                    cell.layer?.backgroundColor = NSColor.yellow.cgColor
//                    cell.textField?.textColor = .black
//                }
//                
//                //Remote Businesses
//            } else if remoteBusinessButton.state == .on {
//                let business = RemoteDataController.businessResults[row]
//                cell.textField?.stringValue = "\(row + 1): \(business.name): \(business.venueID)"
//                
//                //Remote Bands
//            } else if remoteBandsButton.state == .on {
//                let band = RemoteDataController.bandResults[row]
//                
//                if RemoteDataController.bandResults[row].ohmPick == true {
//                    cell.textField?.stringValue = "\(row + 1): \(band.name): \(band.bandID)"
//                } else {
//                    cell.textField?.stringValue = "\(row + 1): \(band.name): \(band.bandID)"
//                }
//                
//                //Remote Shows
//            } else if remoteShowsButton.state == .on {
//                RemoteDataController.showResults = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
//                let show = RemoteDataController.showResults[row]
//                cell.textField?.stringValue = "\(row + 1): \(show.dateString): \(show.venue): \(show.showID)"
//            }
//            
//            return cell
//        }
//        
//        return  nil
//    }
//    
//    
//    
//    
//    //MARK: Segue
//    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        let indexPath = tableView.selectedRow
//        
//        if segue.identifier == "editVenueSegue" {
//            
////            guard let venueVC = segue.destinationController as? VenueDetailViewController else {return}
////            venueVC.currentVenue = parseDataController.resultsArray[indexPath]
//            
//            //Local Business Handling:
//        } else if segue.identifier == "editBusinessSegue" && localBusinessButton.state == .on {
//            guard let businessVC = segue.destinationController as? VenueDetailViewController else {return}
//            businessVC.currentBusiness = LocalDataStorageController.businessResults[indexPath]
//            
//            //Remote Business Handling:
//        } else if segue.identifier == "editBusinessSegue" && remoteBusinessButton.state == .on {
//            guard let businessVC = segue.destinationController as? VenueDetailViewController else {return}
//            businessVC.currentBusiness = RemoteDataController.businessResults[indexPath]
//            
//            //Local Band Handling:
//        } else if segue.identifier == "editBandSegue" && localBandsButton.state == .on || newBandsButton.state == .on {
//            guard let bandVC = segue.destinationController as? BandDetailViewController else {return}
//            bandVC.currentBand = LocalDataStorageController.bandResults[indexPath]
//            
//            //Remote Band Handling:
//        } else if segue.identifier == "editBandSegue" && remoteBandsButton.state == .on {
//            guard let bandVC = segue.destinationController as? BandDetailViewController else {return}
//            bandVC.currentBand = RemoteDataController.bandResults[indexPath]
//            
//            //Local Show Handling
//        } else if segue.identifier == "editShowSegue" && localShowsButton.state == .on {
//            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
//            showVC.currentShow = showsInOrderArray[indexPath]
//            
//            //Remote Show Handling
//        } else if segue.identifier == "editShowSegue" && remoteShowsButton.state == .on {
//            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
//            showVC.currentShow = RemoteDataController.showResults[indexPath]
//        }
//        
//        
//    }
//    
//}
//
////MARK: Helper Functions
//extension MainViewController {
//    
//    private func inOrderArrays() {
//        let biz = LocalDataStorageController.businessArray.sorted(by: {$0.name < $1.name})
//        let band = LocalDataStorageController.bandArray.sorted(by: {$0.name < $1.name})
//        let show = LocalDataStorageController.showArray.sorted(by: {$0.date < $1.date})
//        
//        LocalDataStorageController.businessArray = biz
//        LocalDataStorageController.bandArray = band
//        LocalDataStorageController.showArray = show
//        
//        LocalDataStorageController.businessResults = LocalDataStorageController.businessArray
//        LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//        LocalDataStorageController.showResults = LocalDataStorageController.showArray
//        
//        let bizRemote = RemoteDataController.businessArray.sorted(by: {$0.name < $1.name})
//        let bandRemote = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
//        let showRemote = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
//        
//        RemoteDataController.businessArray = bizRemote
//        RemoteDataController.bandArray = bandRemote
//        RemoteDataController.showArray = showRemote
//        
//        RemoteDataController.businessResults = RemoteDataController.businessArray
//        RemoteDataController.bandResults = RemoteDataController.bandArray
//        RemoteDataController.showResults = RemoteDataController.showArray
//    }
//    
//    private func bringNewBandsToTop() {
//        let newBands = LocalDataStorageController.bandArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
//        LocalDataStorageController.bandArray = newBands
//        LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//    }
//    
//    private func buttonController(_ state:Bool) {
//        loadFileButton.isEnabled = state
//        consolidateButton.isEnabled = state
//        saveVenuesButton.isEnabled = state
//        editVenueButton.isEnabled = state
//        clearButton.isEnabled = state
//        addBusinessButton.isEnabled = state
//        editBusinessButton.isEnabled = state
//        deleteBusinessButton.isEnabled = state
//        pushBusinessButton.isEnabled = state
//        addBandButton.isEnabled = state
//        editBandButton.isEnabled = state
//        deleteBandButton.isEnabled = state
//        pushBandButton.isEnabled = state
//        addShowButton.isEnabled = state
//        editShowButton.isEnabled = state
//        deleteShowButton.isEnabled = state
//        pushShowButton.isEnabled = state
//    }
//    
//    //DoubleClickFunctions
//    @objc private func doubleClicked() {
//        if rawJSONDataButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editVenueSegue", sender: self)
//            }
//            
//        } else if localBusinessButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editBusinessSegue", sender: self)
//            }
//            
//        } else if remoteBusinessButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editBusinessSegue", sender: self)
//            }
//            
//        } else if localBandsButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editBandSegue", sender: self)
//            }
//        
//        } else if newBandsButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editBandSegue", sender: self)
//            }
//            
//        } else if remoteBandsButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editBandSegue", sender: self)
//            }
//            
//        } else if localShowsButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editShowSegue", sender: self)
//            }
//            
//        } else if remoteShowsButton.state == .on {
//            if tableView.selectedRow < 0 {
//                return
//            } else {
//                performSegue(withIdentifier: "editShowSegue", sender: self)
//            }
//        }
//    }
//    
//    @objc func showsUpdated() {
//        inOrderArrays()
//        DispatchQueue.main.async {
//            if self.localShowsButton.state == .on {
//                self.showAmountLabel.stringValue = "\(LocalDataStorageController.showArray.count) Shows"
//            } else if self.remoteShowsButton.state == .on {
//                self.showAmountLabel.stringValue = "\(RemoteDataController.showArray.count) Shows"
//            }
//            self.tableView.reloadData()
//        }
//    }
//    
//    @objc func businessUpdatedAlertReceived() {
//        saveVenuesButton.state = .on
//        if self.localBusinessButton.state == .on && LocalDataStorageController.businessArray == [] {
//            inOrderArrays()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBusinessButton.isEnabled = true
//            }
//            
//        } else if self.localBusinessButton.state == .on {
//            inOrderArrays()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.buttonController(false)
//                self.addBusinessButton.isEnabled = true
//                self.editBusinessButton.isEnabled = true
//            }
//            
//        }
//    }
//    
//    @objc func bandUpdatedAlertReceived() {
//        //inOrderArrays()
//        DispatchQueue.main.async { [self] in
//            tableView.reloadData()
//        }
//        
//    }
//}
//
//
////MARK: Search
//extension MainViewController {
//    
//    private func search() {
//        if rawJSONDataButton.state == .on {
////            if searchBarField.stringValue != "" {
////                let json = parseDataController.jsonDataArray
////                parseDataController.resultsArray = json.filter({($0.venueName?.localizedCaseInsensitiveContains(searchBarField.stringValue))!})
////
////                DispatchQueue.main.async {
////                    self.tableView.reloadData()
////                    let index = NSIndexSet(index: 0)
////                    self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: false)
////                    self.tableView.scrollRowToVisible(0)
////                }
////            } else {
////                parseDataController.resultsArray = parseDataController.jsonDataArray
////                DispatchQueue.main.async {
////                    self.tableView.reloadData()
////                }
////            }
//        } else if localBusinessButton.state == .on {
//            if searchBarField.stringValue != "" {
//                let business = LocalDataStorageController.businessArray
//                LocalDataStorageController.businessResults = business.filter({($0.name.localizedCaseInsensitiveContains(searchBarField.stringValue))})
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    let index = NSIndexSet(index: 0)
//                    self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: false)
//                    self.tableView.scrollRowToVisible(0)
//                }
//            } else {
//                LocalDataStorageController.businessResults = LocalDataStorageController.businessArray
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        } else if remoteBusinessButton.state == .on {
//            if searchBarField.stringValue != "" {
//                let business = RemoteDataController.businessArray
//                RemoteDataController.businessResults = business.filter({($0.name.localizedCaseInsensitiveContains(searchBarField.stringValue))})
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    let index = NSIndexSet(index: 0)
//                    self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: false)
//                    self.tableView.scrollRowToVisible(0)
//                }
//            } else {
//                RemoteDataController.businessResults = RemoteDataController.businessArray
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        } else if localBandsButton.state == .on {
//            if searchBarField.stringValue != "" {
//                let band = LocalDataStorageController.bandArray
//                LocalDataStorageController.bandResults = band.filter({($0.name.localizedCaseInsensitiveContains(searchBarField.stringValue))})
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    let index = NSIndexSet(index: 0)
//                    self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: false)
//                    self.tableView.scrollRowToVisible(0)
//                }
//            } else {
//                LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        } else if remoteBandsButton.state == .on {
//            if searchBarField.stringValue != "" {
//                let band = RemoteDataController.bandArray
//                RemoteDataController.bandResults = band.filter({($0.name.localizedCaseInsensitiveContains(searchBarField.stringValue))})
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    let index = NSIndexSet(index: 0)
//                    self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: false)
//                    self.tableView.scrollRowToVisible(0)
//                }
//            } else {
//                RemoteDataController.bandResults = RemoteDataController.bandArray
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//}
//
//
////MARK: Function Buttons
//extension MainViewController {
//    
//    private func removeDoubleBands() {
//        var newDuplicatedBands = [Band]()
//        //Finds exactly spelled double bands
//        for band1 in LocalDataStorageController.bandArray {
//            for band2 in LocalDataStorageController.bandArray {
//                if band1.name == band2.name && band1.lastModified.dateValue() > band2.lastModified.dateValue() {
//                    newDuplicatedBands.append(band1)
//                }
//            }
//        }
//        
//        for band1 in newDuplicatedBands {
//            LocalDataStorageController.bandArray.removeAll(where: {$0.bandID == band1.bandID})
//        }
//        
//        LocalDataStorageController.bandResults = LocalDataStorageController.bandArray
//        tableView.reloadData()
//    }
//    
//    private func removeBandsWithNoShows() {
//        
//        for band in LocalDataStorageController.bandArray {
//            var bandShowNumbers = 0
//            for show in LocalDataStorageController.showArray {
//                if show.band == band.name {
//                    bandShowNumbers += 1
//                }
//            }
//            if bandShowNumbers == 0 && band.photo == nil { removeBandsArray.append(band); print(band.name) } else { continue }
//        }
//        
//        for band in removeBandsArray {
//            LocalDataStorageController.bandArray.removeAll(where: {$0 == band})
//        }
//        
//    }
//}
//
