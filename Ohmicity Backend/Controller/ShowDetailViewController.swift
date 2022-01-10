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
    
    //TableViews
    @IBOutlet weak var showsTableView: NSTableView!
    @IBOutlet weak var venueBandTableView: NSTableView!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var businessNameTextField: NSTextField!
    @IBOutlet weak var messageCenter: NSTextField!
    
    //Buttons
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPickCheckbox: NSButton!
    @IBOutlet weak var showOnHoldCheckbox: NSButton!
    @IBOutlet weak var pushButton: NSButton!
    @IBOutlet weak var saveBackupButton: NSButton!
    @IBOutlet weak var loadBackupButton: NSButton!
    @IBOutlet weak var enableBackupButton: NSButton!
    @IBOutlet weak var filterXityPicksButton: NSButton!
    @IBOutlet weak var filterShowsDropDown: NSComboBox!
    
    //Date Picker
    @IBOutlet weak var datePicker: NSDatePicker!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        showsTableView.delegate = self
        showsTableView.dataSource = self
        venueBandTableView.delegate = self
        venueBandTableView.dataSource = self
        
        updateViews()
        dateFormatter.dateFormat = dateFormat1
    }
    
    //MARK: UpdateViews
    private func updateViews() {
        //tableView.delegate = self
        //tableView.dataSource = self
        
        if currentShow != nil {
            self.title = "Edit Show"
            bandNameTextField.stringValue = currentShow!.band
            businessNameTextField.stringValue = currentShow!.venue
            
            datePicker.dateValue = currentShow!.date
            
            dateFormatter.dateFormat = dateFormat3
            
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
            deleteButton.isEnabled = false
            pushButton.isEnabled = false
            showOnHoldCheckbox.isEnabled = false
            ohmPickCheckbox.isEnabled = false
        }
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
    
    @IBAction func lastMessageButtonTapped(_ sender: Any) {
        messageCenter.stringValue = lastMessage
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if currentShow != nil {
            currentShow?.dateString = dateFormatter.string(from: datePicker.dateValue)
            
            var editedShow = currentShow
            editedShow?.dateString = dateFormatter.string(from: datePicker.dateValue)
            editedShow?.time = dateFormatter.string(from: datePicker.dateValue)
            editedShow?.date = datePicker.dateValue
            editedShow?.lastModified = Timestamp()
            
            if ohmPickCheckbox.state == .on {
                editedShow?.ohmPick = true
            } else {
                editedShow?.ohmPick = false
            }
            
            if showOnHoldCheckbox.state == .on {
                editedShow?.onHold = true
            } else {
                editedShow?.onHold = false
            }
            
            localDataController.showArray.removeAll(where: {$0.showID == editedShow?.showID})
            localDataController.showArray.append(editedShow!)
            
            currentShow = editedShow
            
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            localDataController.saveShowData()
            self.messageCenter.stringValue = "Show Updated"
            startMessageCenterTimer()
        } else {
            
            var newShow = Show(band: bandNameTextField.stringValue, venue: businessNameTextField.stringValue, dateString: dateFormatter.string(from: datePicker.dateValue))
            
            newShow?.lastModified = Timestamp()
            localDataController.showArray.append(newShow!)
            
            currentShow = newShow
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            self.messageCenter.stringValue = "Show Created And Saved"
            startMessageCenterTimer()
        }
    }
    
    
    @IBAction func pushButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.showDataPath
        currentShow?.lastModified = Timestamp()
        do {
            try ref.document(currentShow!.showID).setData(from: currentShow)
            self.messageCenter.stringValue = "Show Pushed"
            startMessageCenterTimer()
        } catch let error {
            NSLog(error.localizedDescription)
            self.messageCenter.stringValue = "\(error.localizedDescription)"
            startMessageCenterTimer()
        }
    }
    
    @IBAction func deleteLocallyButtonTapped(_ sender: Any) {
        
        //Delete Locally
        guard let show = currentShow else {return}
        localDataController.showArray.removeAll(where: {$0 == show})
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
        localDataController.saveShowData()
        
        //Put On Hold Remotely
        remoteDataController.remoteShowArray.removeAll(where: {$0 == currentShow})
        currentShow!.onHold = true
        
        guard let show = currentShow else {return}
        
        FireStoreReferenceManager.showDataPath.document(show.showID).updateData(["onHold" : true]) { err in
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
    }
    
    @IBAction func removeAllLocalShowsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveBackupButtonTapped(_ sender: Any) {
    }
    
    @IBAction func loadBackupButtonTapped(_ sender: Any) {
    }
    
    @IBAction func enableBackupButtonTapped(_ sender: Any) {
    }
    
    @IBAction func showListXityPicksButtonTapped(_ sender: Any) {
    }
    
    @IBAction func pushAllShowsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func copySelectedShowButtonTapped(_ sender: Any) {
    }
    
    @IBAction func copyAllShowsButtonTapped(_ sender: Any) {
    }
    
    //MARK: Radio Buttons
    @IBAction func searchVenueBandRadioButtonsTapped(_ sender: Any) {
    }
    
    
    @IBAction func searchShowsRadioButtonsTapped(_ sender: Any) {
        
    }
    
    //MARK: Search Fields Functions
    @IBAction func showListSearchField(_ sender: Any) {
    }
    
    @IBAction func venueBandSearchField(_ sender: Any) {
    }
    
    
}

extension ShowDetailViewController {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: nil) as? NSTableCellView {
            
            return cell
        }
        return nil
    }
    
    //MARK: TABLEVIEW CODE - Just add a new tableview and uncomment
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        if self.bandRadioButton.state == .on {
//            let index = tableView.selectedRow
//
//            if tableView.isRowSelected(index) {
//                bandNameTextField.stringValue = localDataController.bandArray[index].name
//            }
//
//        } else if self.businessRadioButton.state == .on {
//            let index = tableView.selectedRow
//
//            if tableView.isRowSelected(index) {
//                businessNameTextField.stringValue = localDataController.businessArray[index].name
//            }
//        }
//    }
}
