//
//  ShowDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa
import AppKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ShowDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    //MARK: Properties
    var currentShow: Show? {didSet {updateViews()}}
    var timer = Timer()
    var lastMessage = ""
    var showFilterArray = [Show]() {didSet {showsTableView.reloadData()}}
    var venueFilterArray = [Venue]() {didSet {venueBandTableView.reloadData()}}
    var bandFilterArray = [Band]() {didSet {venueBandTableView.reloadData()}}
    
    //TableViews
    @IBOutlet weak var showsTableView: NSTableView!
    @IBOutlet weak var venueBandTableView: NSTableView!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var venueNameTextField: NSTextField!
    @IBOutlet weak var messageCenter: NSTextField!
    @IBOutlet weak var showSearchTextField: NSSearchField!
    @IBOutlet weak var venueBandSearchTextField: NSSearchField!
    
    //Buttons
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPickCheckbox: NSButton!
    @IBOutlet weak var showOnHoldCheckbox: NSButton!
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var saveBackupButton: NSButton!
    @IBOutlet weak var loadBackupButton: NSButton!
    @IBOutlet weak var enableBackupButton: NSButton!
    @IBOutlet weak var filterXityPicksButton: NSButton!
    @IBOutlet weak var filterShowsDropDown: NSComboBox!
    @IBOutlet weak var backupSafetySwitch: NSButton!
    
    
    @IBOutlet weak var xityPicksButton: NSButton!
    var xityPicksFilter = false
    @IBOutlet weak var buttonBoxView: NSBox!
    
    
    // Radio Buttons
    @IBOutlet weak var newButton: NSButton!
    @IBOutlet weak var backupButton: NSButton!
    @IBOutlet weak var remoteButton: NSButton!
    @IBOutlet weak var bandButton: NSButton!
    @IBOutlet weak var venueButton: NSButton!
    
    //Labels
    @IBOutlet weak var showIDLabel: NSTextField!
    
    
    //Date Picker
    @IBOutlet weak var datePicker: NSDatePicker!
    var resetDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 860)
        initialSetup()
        showsTableView.delegate = self
        showsTableView.dataSource = self
        showsTableView.doubleAction = #selector(showsTableDoubleClick)
        
        venueBandTableView.delegate = self
        venueBandTableView.dataSource = self
        venueBandTableView.doubleAction = #selector(venueBandTableDoubleClick)
        
        updateViews()
        dateFormatter.dateFormat = dateFormat4
    }
    
    //MARK: UpdateViews
    private func updateViews() {
        if currentShow != nil {
            let tempVenue = LocalBackupDataStorageController.venueArray.first(where: {$0.venueID == currentShow?.venue})
            guard let tempVenue = tempVenue else {
                clearAll()
                messageCenter.stringValue = "Error: Show Venue Is Corrupted. Needs New Tag."
                self.startMessageCenterTimer()
                currentShow = nil
                return
                
            }
            
            let tempBand = RemoteDataController.bandArray.first(where: {$0.bandID == currentShow?.band})
            guard let tempBand = tempBand else {
                clearAll()
                messageCenter.stringValue = "Error: Show Band Is Corrupted. Needs New Tag."
                self.startMessageCenterTimer()
                currentShow = nil
                return
            }
            
            self.title = "Edit \(currentShow!.bandDisplayName)'s Show"
            bandNameTextField.stringValue = tempBand.name
            venueNameTextField.stringValue = tempVenue.name
            showIDLabel.stringValue = currentShow!.showID
            
            
            showOnHoldCheckbox.isEnabled = true
            ohmPickCheckbox.isEnabled = true
            
            datePicker.dateValue = currentShow!.date
            
            deleteButton.isEnabled = true
            
            switch currentShow?.ohmPick {
            case false:
                ohmPickCheckbox.state = .off
            case true:
                ohmPickCheckbox.state = .on
            case .none:
                return
            case .some(_):
                return
            }
            
            switch currentShow?.onHold {
            case false:
                showOnHoldCheckbox.state = .off
            case true:
                showOnHoldCheckbox.state = .on
            case .none:
                return
            case .some(_):
                return
            }
            
            
        } else {
            self.title = "Edit Shows"
            deleteButton.isEnabled = false
            showOnHoldCheckbox.isEnabled = false
            ohmPickCheckbox.isEnabled = false
            deleteButton.isEnabled = false
        }
    }
    
    private func initialSetup() {
        remoteButton.state = .on
        showFilterArray = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
        venueFilterArray = LocalBackupDataStorageController.venueArray.sorted(by: {$0.name < $1.name})
        bandFilterArray = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
    }
    
    
    //MARK: Show Editing Button Functions
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @IBAction func messageCenterFunction(_ sender: Any) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
    }
    
    private func startMessageCenterTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
    }
    
    @objc private func clear() {
        lastMessage = messageCenter.stringValue
        messageCenter.stringValue = ""
    }
    
    private func clearAll() {
        currentShow = nil
        showIDLabel.stringValue = ""
        venueNameTextField.stringValue = ""
        bandNameTextField.stringValue = ""
        ohmPickCheckbox.state = .off
        showOnHoldCheckbox.state = .off
        
        ohmPickCheckbox.isEnabled = false
        showOnHoldCheckbox.isEnabled = false
    }
    
    
    
    @IBAction func lastMessageButtonTapped(_ sender: Any) {
        messageCenter.stringValue = lastMessage
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let tempVenue = LocalBackupDataStorageController.venueArray.first(where: {$0.name == venueNameTextField.stringValue})
        guard let tempVenue = tempVenue else {return}
        
        let tempBand = RemoteDataController.bandArray.first(where: {$0.name == bandNameTextField.stringValue})
        guard let tempBand = tempBand else {return}
        
        let datePickerValue = datePicker.dateValue
        let tempDate = dateFormatter.string(from: datePickerValue)
        
        if currentShow != nil {
            //Check Boxes
            if ohmPickCheckbox.state == .off {
                currentShow?.ohmPick = false
            } else {
                currentShow?.ohmPick = true
            }
            
            if showOnHoldCheckbox.state == .off {
                currentShow?.onHold = false
            } else {
                currentShow?.onHold = true
            }
            
            //Venue and Band
            currentShow?.venue = tempVenue.venueID
            currentShow?.band = tempBand.bandID
            currentShow?.bandDisplayName = tempBand.name
            
            
            //Date
            currentShow?.dateString = tempDate
            currentShow?.date = datePickerValue
            
            
            
            
        } else {
            
            
            let newShow = Show(band: tempBand.bandID, venue: tempVenue.venueID, dateString: tempDate, displayName: tempBand.name)
            
            guard var newShow = newShow else {return}

            if ohmPickCheckbox.state.rawValue == 0 {
                newShow.ohmPick = false
            } else {
                newShow.ohmPick = true
            }
            
            if showOnHoldCheckbox.state.rawValue == 0 {
                newShow.onHold = false
            } else {
                newShow.onHold = true
            }
            currentShow = newShow
        }
        
        guard var currentShow = currentShow else {return}
        currentShow.lastModified = Timestamp()
        RemoteDataController.showArray.removeAll(where: {$0.showID == currentShow.showID})
        RemoteDataController.showArray.append(currentShow)

        do {
            try workRef.showDataPath.document(currentShow.showID).setData(from: currentShow, completion: { error in
                if let error = error {
                    self.messageCenter.stringValue = error.localizedDescription
                    self.startMessageCenterTimer()
                } else {
                    if !RemoteDataController.showArray.contains(currentShow) {
                        RemoteDataController.showArray.append(currentShow)
                        self.showFilterArray.append(currentShow)
                        
                        if self.remoteButton.state == .on {
                            self.showFilterArray = self.showFilterArray.sorted(by: {$0.date < $1.date})
                        }
                        
                        if self.newButton.state == .on {
                            self.showFilterArray = self.showFilterArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
                        }
                        
                        self.showsTableView.reloadData()
                    } else {
                        RemoteDataController.showArray.removeAll(where: {$0.showID == currentShow.showID})
                        RemoteDataController.showArray.append(currentShow)
                        
                        self.showFilterArray.removeAll(where: {$0.showID == currentShow.showID})
                        self.showFilterArray.append(currentShow)
                        self.showFilterArray.sort(by: {$0.date < $1.date})
                        self.showsTableView.reloadData()
                    }
                    self.messageCenter.stringValue = "Show Saved"
                    self.startMessageCenterTimer()
                }
            })
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        currentShow = nil
        showIDLabel.stringValue = ""
        venueNameTextField.stringValue = ""
        bandNameTextField.stringValue = ""
        ohmPickCheckbox.state = .off
        showOnHoldCheckbox.state = .off
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        //Delete Locally
        guard let show = currentShow else {return}
        LocalBackupDataStorageController.showArray.removeAll(where: {$0 == show})
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
        LocalBackupDataStorageController.saveBackupShowData()
        
        
        guard let show = currentShow else {return}
        
        workRef.showDataPath.document(show.showID).delete { err in
            if let err = err {
                self.messageCenter.stringValue = err.localizedDescription
                self.buttonIndication2(color: .red)
            } else {
                RemoteDataController.showArray.removeAll(where: {$0 == show})
                self.showFilterArray.removeAll(where: {$0 == show})
                self.messageCenter.stringValue = "\(show.showID) has been deleted"
                self.showsTableView.reloadData()
                self.buttonIndication2(color: .green)
            }
        }
    }
    
    //MARK: Show List Button Functions
    @IBAction func removeOldShowsButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            if show.date < Date().addingTimeInterval(-10800) {
                workRef.showDataPath.document(show.showID).delete { err in
                    if let err = err {
                        self.messageCenter.stringValue = err.localizedDescription
                        self.startMessageCenterTimer()
                    } else {
                        RemoteDataController.showArray.removeAll(where: {$0.showID == show.showID})
                        self.showFilterArray.removeAll(where: {$0.showID == show.showID})
                        self.showsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    @IBAction func RemoveCorruptedFromDBButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            if !RemoteDataController.bandArray.contains(where: {$0.bandID == show.band}) {
                workRef.showDataPath.document(show.showID).delete { err in
                    if let err = err {
                        self.messageCenter.stringValue = err.localizedDescription
                    } else {
                        self.messageCenter.stringValue = "Corrupted Shows Removed"
                        self.startMessageCenterTimer()
                    }
                }
            }
        }
    }
    
    @IBAction func backupSafetySwitch(_ sender: Any) {
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
        LocalBackupDataStorageController.saveBackupShowData()
        messageCenter.stringValue = "Show Data Backup Saved"
    }
    
    @IBAction func loadBackupButtonTapped(_ sender: Any) {
        if backupButton.state == .on {
            LocalBackupDataStorageController.loadBackupShowData()
            showFilterArray = LocalBackupDataStorageController.showArray
            
            messageCenter.stringValue = "Show Data Backup Loaded"
        } else {
            messageCenter.stringValue = "Select Backup Radial before loading Backup"
        }
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
    }
    
    @IBAction func copySelectedShowToRemoteButtonTapped(_ sender: Any) {
        let selectedShow = showFilterArray[showsTableView.selectedRow]
        do {
            try workRef.showDataPath.document(selectedShow.showID).setData(from: selectedShow, completion: { err in
                if let err = err {
                    self.messageCenter.stringValue = err.localizedDescription
                    self.startMessageCenterTimer()
                } else {
                    self.messageCenter.stringValue = "Show copied to database"
                    self.startMessageCenterTimer()
                }
            })
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    @IBAction func copyAllShowsToRemoteButtonTapped(_ sender: Any) {
        for show in LocalBackupDataStorageController.showArray {
            do {
                try workRef.showDataPath.document(show.showID).setData(from: show, completion: { err in
                    if let err = err {
                        self.messageCenter.stringValue = err.localizedDescription
                        self.startMessageCenterTimer()
                    }
                })
                
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
    }
    
    @IBAction func xityPicksButtonTapped(_ sender: Any) {
        xityPicksFilter = !xityPicksFilter
        if xityPicksFilter == true {
            showFilterArray = RemoteDataController.showArray.filter({$0.ohmPick == true})
            showsTableView.reloadData()
        } else {
            showFilterArray = RemoteDataController.showArray
            showsTableView.reloadData()
        }
    }
    
    
    
    //MARK: Radio Buttons
    @IBAction func searchVenueBandRadioButtonsTapped(_ sender: Any) {
        venueBandTableView.reloadData()
    }
    
    
    @IBAction func searchShowsRadioButtonsTapped(_ sender: Any) {
        if newButton.state == .on {
            xityPicksButton.isEnabled = false
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray.sorted(by: {$0.lastModified.seconds < $1.lastModified.seconds})
            } else {
                showFilterArray = RemoteDataController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        } else if remoteButton.state == .on {
            xityPicksButton.isEnabled = true
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
            } else {
                showFilterArray = RemoteDataController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        } else if backupButton.state == .on {
            xityPicksButton.isEnabled = false
            if showSearchTextField.stringValue == "" {
                showFilterArray = LocalBackupDataStorageController.showArray
            } else {
                showFilterArray = LocalBackupDataStorageController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        }
    }
    
    //MARK: Search Fields Functions
    @IBAction func showListSearchField(_ sender: Any) {
        if backupButton.state == .on {
            if showSearchTextField.stringValue == "" {
                showFilterArray = LocalBackupDataStorageController.showArray
                showsTableView.reloadData()
            } else {
                let byBandArray = LocalBackupDataStorageController.showArray.filter({$0.bandDisplayName.localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
                
                showFilterArray = byBandArray
                showsTableView.reloadData()
            }
        } else {
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray
                showsTableView.reloadData()
            } else {
                let byBandArray = RemoteDataController.showArray.filter({$0.bandDisplayName.localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
                
                showFilterArray = byBandArray
                showFilterArray.sort(by: {$0.date < $1.date})
                showsTableView.reloadData()
            }
        }
    }
    
    @IBAction func venueBandSearchField(_ sender: Any) {
        if venueButton.state == .on {
            if venueBandSearchTextField.stringValue == "" {
                venueFilterArray = LocalBackupDataStorageController.venueArray
            } else {
                venueFilterArray = LocalBackupDataStorageController.venueArray.filter({$0.name.localizedCaseInsensitiveContains(venueBandSearchTextField.stringValue)})
            }
        }
        
        if bandButton.state == .on {
            if venueBandSearchTextField.stringValue == "" {
                bandFilterArray = RemoteDataController.bandArray
            } else {
                bandFilterArray = RemoteDataController.bandArray.filter({$0.name.localizedStandardContains(venueBandSearchTextField.stringValue)})
            }
        }
    }
}


//MARK: Functions
extension ShowDetailViewController {
    private func checkIfShowIsSpecial(show: Show, cell: NSTableCellView) -> NSTableCellView {
        if show.onHold {
            cell.textField?.textColor = .red
        }
        
        if show.ohmPick {
            cell.textField?.textColor = .purple
        }
        
        return cell
    }
    
    @objc private func showsTableDoubleClick() {
        currentShow = showFilterArray[showsTableView.selectedRow]
    }
    
    @objc private func venueBandTableDoubleClick() {
        if venueButton.state == .on {
            venueNameTextField.stringValue = venueFilterArray[venueBandTableView.selectedRow].name
        }
        
        if bandButton.state == .on {
            bandNameTextField.stringValue = bandFilterArray[venueBandTableView.selectedRow].name
        }
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
}

//MARK: Tableview
extension ShowDetailViewController {
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case showsTableView:
            return showFilterArray.count
        
        case venueBandTableView:
            if venueButton.state == .on {
                return venueFilterArray.count
            }
            
            if bandButton.state == .on {
                return bandFilterArray.count
            }
        
        default:
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableView {
        case showsTableView:
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "NumberColumn") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NumberCell"), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = String(row + 1)
                    cell.textField?.textColor = .white
                    return checkIfShowIsSpecial(show: showFilterArray[row], cell: cell)
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "VenueColumn") {
                guard let venue = LocalBackupDataStorageController.venueArray.first(where: {$0.venueID == showFilterArray[row].venue}) else {return NSTableCellView()}
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = venue.name
                    cell.textField?.textColor = .white
                    return checkIfShowIsSpecial(show: showFilterArray[row], cell: cell)
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "BandColumn") {
                
                var cellTagIssue = NSTableCellView()
                if let cellTagCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BandCell"), owner: nil) as? NSTableCellView {
                    cellTagCell.textField?.stringValue = showFilterArray[row].bandDisplayName
                    cellTagCell.textField?.textColor = .yellow
                    cellTagIssue = cellTagCell
                }
                
                var band: Band?
                
                if remoteButton.state == .on || newButton.state == .on {
                    guard let band1 = RemoteDataController.bandArray.first(where: {$0.bandID == showFilterArray[row].band}) else {return cellTagIssue}
                    band = band1
                } else if backupButton.state == .on {
                    guard let band1 = LocalBackupDataStorageController.bandArray.first(where: {$0.bandID == showFilterArray[row].band}) else {return cellTagIssue}
                    band = band1
                }
                
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BandCell"), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = "\(showFilterArray[row].bandDisplayName): \(band?.name ?? "No Name Found")"
                    cell.textField?.textColor = .white
                    return checkIfShowIsSpecial(show: showFilterArray[row], cell: cell)
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "DateColumn") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = showFilterArray[row].dateString
                    cell.textField?.textColor = .white
                    return checkIfShowIsSpecial(show: showFilterArray[row], cell: cell)
                }
            }
            
        case venueBandTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: nil) as? NSTableCellView {
                
                if venueButton.state == .on {
                    cell.textField?.stringValue = venueFilterArray[row].name
                    cell.textField?.textColor = .white
                }
                
                if bandButton.state == .on {
                    cell.textField?.stringValue = bandFilterArray[row].name
                    cell.textField?.textColor = .white
                }
                
                return cell
            }
        default:
            return NSTableCellView()
        }
        return nil
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
       
    }
}
