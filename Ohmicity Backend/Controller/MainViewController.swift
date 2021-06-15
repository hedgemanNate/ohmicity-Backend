//
//  MainViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/20/21.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase




class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var loadFileButton: NSButton!
    @IBOutlet weak var consolidateButton: NSButton!
    @IBOutlet weak var saveVenuesButton: NSButton!
    @IBOutlet weak var editVenueButton: NSButton!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var emptyButton: NSButtonCell!
    
    @IBOutlet weak var addBusinessButton: NSButton!
    @IBOutlet weak var editBusinessButton: NSButton!
    
    @IBOutlet weak var addBandButton: NSButton!
    @IBOutlet weak var editBandButton: NSButton!
    
    @IBOutlet weak var rawJSONDataButton: NSButton!
    
    @IBOutlet weak var localBusinessesButton: NSButton!
    @IBOutlet weak var remoteBusinessButton: NSButton!
    
    @IBOutlet weak var localBandsButton: NSButton!
    @IBOutlet weak var remoteBandsButton: NSButton!
    
    @IBOutlet weak var localShowsButton: NSButton!
    @IBOutlet weak var remoteShowsButton: NSButton!
    @IBOutlet weak var addShowButton: NSButton!
    @IBOutlet weak var editShowButton: NSButton!

    @IBOutlet weak var showAmountLabel: NSTextField!
    
    
    @IBOutlet weak var removeShowTextField: NSTextField!
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
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
    
    @IBAction func removeShowButtonTapped(_ sender: Any) {
        localDataController.showArray = []
        
        DispatchQueue.main.async { [self] in
            showAmountLabel.stringValue = "\(localDataController.showArray.count)"
            tableView.reloadData()
        }
        
        localDataController.saveShowData()
    }
    
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
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
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
    
    @IBAction func saveVenuesButtonTapped(_ sender: Any) {
        var cleanedJSONArray: [RawJSON] = []
        
        for venue in parseDataController.jsonDataArray {
            for business in localDataController.businessArray {
                if venue.venueName == business.name && venue.shows != nil {
                    print("Found Matching Venues")
                    for show in venue.shows! {
                        //print(show)
                        var newShow = Show(band: show.bandName!, venue: venue.venueName!, dateString: show.showTime!)
                        newShow.fixShowTime()
                        
                        if localDataController.showArray.contains(newShow) == false {
                            localDataController.showArray.append(newShow)
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
        print(localDataController.showArray)
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
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
    
    @IBAction func emptyButtonTapped(_ sender: Any) {
        
    }
    
    //MARK: Radio Buttons
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        
        if self.rawJSONDataButton.state == .on && parseDataController.jsonDataArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.loadFileButton.isEnabled = true
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
            }
            
        } else if self.localBusinessesButton.state == .on && localDataController.businessArray == [] {
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
            
        } else if self.localBandsButton.state == .on && localDataController.bandArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBandButton.isEnabled = true
            }
            
        } else if self.localBandsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addBandButton.isEnabled = true
                self.editBandButton.isEnabled = true
            }
        } else if self.localShowsButton.state == .on && localDataController.showArray == [] {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addShowButton.isEnabled = true
            }
        } else if self.localShowsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.buttonController(false)
                self.addShowButton.isEnabled = true
                self.editShowButton.isEnabled = true
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
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
            
            if rawJSONDataButton.state == .on {
                cell.textField?.stringValue = "\(row + 1): \(parseDataController.jsonDataArray[row].venueName ?? "CORRUPTED")"
            } else if localBusinessesButton.state == .on && localDataController.businessArray != [] {
                cell.textField?.stringValue = "\(row + 1): \(localDataController.businessArray[row].name)"
            }  else if localBandsButton.state == .on && localDataController.bandArray != [] {
                cell.textField?.stringValue = "\(row + 1): \(localDataController.bandArray[row].name)"
            } else if localShowsButton.state == .on && localDataController.showArray != [] {
                cell.textField?.stringValue = "\(row + 1): \(localDataController.showArray[row].venue): \(localDataController.showArray[row].dateString)"
            } else {
                cell.textField?.stringValue = "No Data"
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
            
        } else if segue.identifier == "editBusinessSegue" {
            guard let businessVC = segue.destinationController as? VenueDetailViewController else {return}
            businessVC.currentBusiness = localDataController.businessArray[indexPath]
            
        } else if segue.identifier == "editBandSegue" {
            guard let bandVC = segue.destinationController as? BandDetailViewController else {return}
            bandVC.currentBand = localDataController.bandArray[indexPath]
            
        } else if segue.identifier == "editShowSegue" {
            guard let showVC = segue.destinationController as? ShowDetailViewController else {return}
            showVC.currentShow = localDataController.showArray[indexPath]
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
        addBandButton.isEnabled = state
        editBandButton.isEnabled = state
        addShowButton.isEnabled = state
        editShowButton.isEnabled = state
        
    }
    
    @objc func showsUpdated() {
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

