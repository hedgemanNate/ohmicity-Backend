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
    //Properties
    var currentShow: Show?
    
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var businessNameTextField: NSTextField!
    
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPickCheckbox: NSButton!
    @IBOutlet weak var showOnHoldCheckbox: NSButton!
    @IBOutlet weak var bandRadioButton: NSButton!
    @IBOutlet weak var businessRadioButton: NSButton!
    @IBOutlet weak var pushButton: NSButton!
    
    //@IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var datePicker: NSDatePicker!
    
    @IBOutlet weak var messageCenter: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        dateFormatter.dateFormat = dateFormat1
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
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
        } else {
            var newShow = Show(band: bandNameTextField.stringValue, venue: businessNameTextField.stringValue, dateString: dateFormatter.string(from: datePicker.dateValue))
            newShow.lastModified = Timestamp()
            localDataController.showArray.append(newShow)
            
            currentShow = newShow
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            self.messageCenter.stringValue = "Show Created And Saved"
        }
    }
    
    
    @IBAction func pushButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.showDataPath
        currentShow?.lastModified = Timestamp()
        do {
            try ref.document(currentShow!.showID).setData(from: currentShow)
            self.messageCenter.stringValue = "Show Pushed"
        } catch let error {
            NSLog(error.localizedDescription)
            self.messageCenter.stringValue = "\(error.localizedDescription)"
        }
    }
    
    
    @IBAction func deleteRemotelyButtonTapped(_ sender: Any) {
        guard let show = currentShow else {return}
        remoteDataController.remoteShowArray.removeAll(where: {$0 == show})
        
        FireStoreReferenceManager.showDataPath.document(show.showID).delete { (err) in
            if let err = err {
                //MARK: Alert Here
                NSLog("Error deleting Band: \(err)")
                self.messageCenter.stringValue = "Error deleting Band: \(err)"
            } else {
                NSLog("Delete Successful")
                self.messageCenter.stringValue = "Delete Successful"
                notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
                print("\(show)")
            }
        }
    }
    
    @IBAction func deleteLocallyButtonTapped(_ sender: Any) {
        guard let show = currentShow else {return}
        localDataController.showArray.removeAll(where: {$0 == show})
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "showsUpdated")))
        localDataController.saveShowData()
        self.view.window?.close()
    }
    
    
    //MARK: Radio Buttons
    
    @IBAction func radioButtonsTapped(_ sender: Any) {
        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
    }
    
    
    //MARK: UpdateViews
    private func updateViews() {
        //tableView.delegate = self
        //tableView.dataSource = self
        
        bandRadioButton.state = .on
        
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
    
}

extension ShowDetailViewController {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.bandRadioButton.state == .on {
            return localDataController.bandArray.count
        } else if self.businessRadioButton.state == .on {
            return localDataController.businessArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: nil) as? NSTableCellView {
            
            if self.bandRadioButton.state == .on {
                cell.textField?.stringValue = localDataController.bandArray[row].name
                
            } else if self.businessRadioButton.state == .on {
                cell.textField?.stringValue = localDataController.businessArray[row].name
            }
            
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
