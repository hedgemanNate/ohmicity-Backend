//
//  ShowDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa
import FirebaseFirestore
import FirebaseFirestoreSwift

class ShowDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    //Properties
    var currentShow: Show?
    
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var businessNameTextField: NSTextField!
    @IBOutlet weak var startDateTextField: NSTextField!
    @IBOutlet weak var startTimeTextField: NSTextField!
    
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var ohmPickCheckbox: NSButton!
    @IBOutlet weak var showOnHoldCheckbox: NSButton!
    @IBOutlet weak var bandRadioButton: NSButton!
    @IBOutlet weak var businessRadioButton: NSButton!
    @IBOutlet weak var pushButton: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if currentShow != nil {
            currentShow?.dateString = startDateTextField.stringValue
            let date = setTime()
            
            var editedShow = currentShow
            editedShow?.dateString = startDateTextField.stringValue
            editedShow?.time = startTimeTextField.stringValue
            editedShow?.date = date

            
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
        } else {
            var newShow = Show(band: bandNameTextField.stringValue, venue: businessNameTextField.stringValue, dateString: startDateTextField.stringValue)
            newShow.time = startTimeTextField.stringValue
            newShow.lastModified = Timestamp()
            localDataController.showArray.append(newShow)
            
            currentShow = newShow
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        }
    }
    
    //Makes a Date out of Start Date And Time
    private func setTime() -> Date {
        let dateString = "\(startDateTextField.stringValue) \(startTimeTextField.stringValue)"
        
        dateFormatter.dateFormat = dateFormat2
        guard let date = dateFormatter.date(from: dateString) else {return Date()}
        return date
    }
    
    
    @IBAction func pushButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.showDataPath
        currentShow?.lastModified = Timestamp()
        do {
            try ref.document(currentShow!.showID).setData(from: currentShow)
        } catch let error {
                NSLog(error.localizedDescription)
        }
    }
    
    
    
    //MARK: Radio Buttons
    
    @IBAction func radioButtonsTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: UpdateViews
    private func updateViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        bandRadioButton.state = .on
        
        if currentShow != nil {
            self.title = "Edit Show"
            bandNameTextField.stringValue = currentShow!.band
            businessNameTextField.stringValue = currentShow!.venue
            
//            let date = currentShow!.dateString
//            if let index = (date.range(of: "2021")?.upperBound) {
//
//                let newDate = String(date.prefix(upTo: index))
//                startDateTextField.stringValue = newDate
//            }
            
            dateFormatter.dateFormat = dateFormat3
            let dateString = dateFormatter.string(from: currentShow!.date)
            
            startDateTextField.stringValue = "\(dateString)"
            startTimeTextField.stringValue = "\(currentShow?.time ?? "")"
            
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.bandRadioButton.state == .on {
            let index = tableView.selectedRow
            
            if tableView.isRowSelected(index) {
                bandNameTextField.stringValue = localDataController.bandArray[index].name
            }
            
        } else if self.businessRadioButton.state == .on {
            let index = tableView.selectedRow
            
            if tableView.isRowSelected(index) {
                businessNameTextField.stringValue = localDataController.businessArray[index].name
            }
        }
    }
}
