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
    var venueFilterArray = [BusinessFullData]() {didSet {venueBandTableView.reloadData()}}
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
    
    @IBOutlet weak var xityPicksButton: NSButton!
    var xityPicksFilter = false
    
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
        self.preferredContentSize = NSSize(width: 1320, height: 780)
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
            let tempVenue = LocalDataStorageController.venueArray.first(where: {$0.venueID == currentShow?.venue})
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
        venueFilterArray = LocalDataStorageController.venueArray.sorted(by: {$0.name < $1.name})
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
        let tempVenue = LocalDataStorageController.venueArray.first(where: {$0.name == venueNameTextField.stringValue})
        guard let tempVenue = tempVenue else {return}
        
        let tempBand = RemoteDataController.bandArray.first(where: {$0.name == bandNameTextField.stringValue})
        guard let tempBand = tempBand else {return}
        
        let tempDate = dateFormatter.string(from: datePicker.dateValue)
        
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
            currentShow?.date = datePicker.dateValue
            
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
    
    @IBAction func deleteLocallyButtonTapped(_ sender: Any) {
        
        //Delete Locally
        guard let show = currentShow else {return}
        LocalDataStorageController.showArray.removeAll(where: {$0 == show})
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
        LocalDataStorageController.saveShowData()
        
        //Put On Hold Remotely
        RemoteDataController.showArray.removeAll(where: {$0 == currentShow})
        currentShow!.onHold = true
        
        guard let show = currentShow else {return}
        
        workRef.showDataPath.document(show.showID).updateData(["onHold" : true]) { err in
            if let err = err {
                //MARK: Alert Here
                NSLog("Error Putting Show On Hold: \(err)")
                self.messageCenter.stringValue = "Error Puttig Show On Hold: \(err)"
                self.startMessageCenterTimer()
            } else {
            NSLog("Show is on hold")
            self.messageCenter.stringValue = "Show is on hold"
            self.startMessageCenterTimer()
            notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
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
    
    
    @IBAction func saveBackupButtonTapped(_ sender: Any) {
    }
    
    @IBAction func loadBackupButtonTapped(_ sender: Any) {
    }
    
    @IBAction func enableBackupButtonTapped(_ sender: Any) {
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
        for show in LocalDataStorageController.showArray {
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
            showSearchTextField.isEnabled = true
            xityPicksButton.isEnabled = false
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray.sorted(by: {$0.lastModified.seconds < $1.lastModified.seconds})
            } else {
                showFilterArray = RemoteDataController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        } else if remoteButton.state == .on {
            showSearchTextField.isEnabled = true
            xityPicksButton.isEnabled = true
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
            } else {
                showFilterArray = RemoteDataController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        } else if backupButton.state == .on {
            showSearchTextField.isEnabled = false
            xityPicksButton.isEnabled = false
            if showSearchTextField.stringValue == "" {
                showFilterArray = LocalDataStorageController.showArray
            showSearchTextField.isEnabled = false
            showFilterArray = LocalDataStorageController.showArray.filter({$0.bandDisplayName .localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
            }
        }
    }
    
    //MARK: Search Fields Functions
    @IBAction func showListSearchField(_ sender: Any) {
        if backupButton.state == .on {
            if showSearchTextField.stringValue == "" {
                showFilterArray = LocalDataStorageController.showArray
            } else {
                showFilterArray = LocalDataStorageController.showArray.filter({$0.bandDisplayName.localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
                showsTableView.reloadData()
            }
        } else {
            if showSearchTextField.stringValue == "" {
                showFilterArray = RemoteDataController.showArray
                showsTableView.reloadData()
            } else {
                showFilterArray = RemoteDataController.showArray.filter({$0.bandDisplayName.localizedCaseInsensitiveContains(showSearchTextField.stringValue)})
                showsTableView.reloadData()
            }
        }
    }
    
    @IBAction func venueBandSearchField(_ sender: Any) {
        if venueButton.state == .on {
            if venueBandSearchTextField.stringValue == "" {
                venueFilterArray = LocalDataStorageController.venueArray
            } else {
                venueFilterArray = LocalDataStorageController.venueArray.filter({$0.name.localizedCaseInsensitiveContains(venueBandSearchTextField.stringValue)})
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
                guard let venue = LocalDataStorageController.venueArray.first(where: {$0.venueID == showFilterArray[row].venue}) else {return NSTableCellView()}
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
                
                guard let band = RemoteDataController.bandArray.first(where: {$0.bandID == showFilterArray[row].band}) else {return cellTagIssue}
                
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BandCell"), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = "\(showFilterArray[row].bandDisplayName): \(band.name)"
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
