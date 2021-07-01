//
//  MainViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/20/21.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestoreSwift




class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //MARK: Properties
    var originalArray: [Band] = []
    var filteredArray: [Band] = []
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var ohmButton: NSButton!
    
    
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
                        self.clearButton.isEnabled = true
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
            
            print("table reloaded")
        } else {
            // User clicked on "Cancel"
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("table reloaded")
        
    }
    
    //MARK: Venue Buttons Tapped
    @IBAction func consolidateButtonTapped(_ sender: Any) {
        let reduce = parseDataController.jsonDataArray.reduce(into: [:], {$0[$1, default: 0] += 1})
        let sorted = reduce.sorted(by: {$0.value > $1.value})
        let map    = sorted.map({$0.key})
        let orderedArray = map.sorted { $0.venueName ?? "CORRUPTED" < $1.venueName ?? "CORRUPTED" }
        parseDataController.jsonDataArray = orderedArray
        parseDataController.jsonDataArray.removeAll(where: {$0.venueName == nil})
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
                    print("Found Matching Venues")
                    for show in venue.shows! {
                        
                        //New Shows
                        var newShow = Show(band: show.bandName!, venue: venue.venueName!, dateString: show.showTime!)
                        newShow.fixShowTime()
                        
                        let dateFormat = "MMMM d, yyyy"
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = dateFormat
                        let date = dateFormatter.date(from: newShow.dateString)
                        newShow.date = date
                        
                        if localDataController.showArray.contains(newShow) == false {
                            localDataController.showArray.append(newShow)
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
    
    @IBAction func pullDataButtonTapped(_ sender: Any) {
        if localBusinessesButton.state == .on || remoteBusinessButton.state == .on {
            getRemoteBusinessData()
        } else if localBandsButton.state == .on || remoteBandsButton.state == .on {
            getRemoteBandData()
        } else if localShowsButton.state == .on || remoteShowsButton.state == .on {
            getRemoteShowData()
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
            } catch let error {
                    NSLog(error.localizedDescription)
            }
        }
    }
    
    @IBAction func pushBandButtonTapped(_ sender: Any) {
        let bandData = localDataController.bandArray
        let ref = FireStoreReferenceManager.bandDataPath
        for band in bandData {
            do {
                try ref.document(band.bandID ).setData(from: band)
            } catch let error {
                    NSLog(error.localizedDescription)
            }
        }
    }
    
    @IBAction func pushShowButtonTapped(_ sender: Any) {
        let showData = localDataController.showArray
        let ref = FireStoreReferenceManager.showDataPath
        for show in showData {
            
            do {
                try ref.document(show.showID ).setData(from: show)
            } catch let error {
                    NSLog(error.localizedDescription)
            }
        }
    }
    
    //MARK: Delete Buttons Tapped
    @IBAction func deleteBusinessButtonTapped(_ sender: Any) {
        let index = tableView.selectedRow
        let business = remoteDataController.remoteBusinessArray[index]
        
        if localBusinessesButton.state == .on {
            localDataController.businessArray.remove(at: index)
            localDataController.saveBusinessData()
        } else if remoteBusinessButton.state == .on {
            remoteDataController.remoteBusinessArray.remove(at: index)
            FireStoreReferenceManager.businessFullDataPath.document(business.venueID!).delete
            { (err) in
                if let err = err {
                    //MARK: Alert Here
                  NSLog("Error deleting Business: \(err)")
                } else {
                    NSLog("Delete Successfull")
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
                } else {
                    NSLog("Delete Successfull")
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
                } else {
                    NSLog("Delete Successfull")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        rawJSONDataButton.state = .on
        localDataController.loadBusinessData()
        localDataController.loadBusinessBasicData()
        localDataController.loadJsonData()
        localDataController.loadShowData()
        localDataController.loadBandData()
        
        getRemoteBandData()
        getRemoteBusinessData()
        getRemoteShowData()
        
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
                        print("Error decoding band: \(error)")
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
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
                cell.textField?.stringValue = "\(row + 1): \(localDataController.showArray[row].venue): \(localDataController.showArray[row].dateString): *\(localDataController.showArray[row].band)*"
            } else if remoteBusinessButton.state == .on {
                cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBusinessArray[row].name!)"
            } else if remoteBandsButton.state == .on {
                if remoteDataController.remoteBandArray[row].ohmPick == true {
                    cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBandArray[row].name): !OHM!"
                } else {
                    cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteBandArray[row].name)"
                }
            } else if remoteShowsButton.state == .on {
                cell.textField?.stringValue = "\(row + 1): \(remoteDataController.remoteShowArray[row].venue): \(remoteDataController.remoteShowArray[row].dateString): *\(remoteDataController.remoteShowArray[row].band)*"
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
            showVC.currentShow = localDataController.showArray[indexPath]
            
            //Remote Show Handling
        } else if segue.identifier == "editShowSegue" && remoteShowsButton.state == .on {
            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
            showVC.currentShow = remoteDataController.remoteShowArray[indexPath]
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
        let currentDate = Date()
        //Remove Old Shows
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

