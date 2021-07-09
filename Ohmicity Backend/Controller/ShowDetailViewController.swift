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
    @IBOutlet weak var ohmPickButton: NSButton!
    @IBOutlet weak var bandRadioButton: NSButton!
    @IBOutlet weak var businessRadioButton: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if currentShow != nil {
            var editedShow = localDataController.showArray.first(where: {$0 == currentShow!})
            editedShow?.dateString = startDateTextField.stringValue
            editedShow?.time = startTimeTextField.stringValue
            editedShow?.lastModified = Timestamp()
            
            localDataController.showArray.removeAll(where: {$0.showID == editedShow?.showID})
            localDataController.showArray.append(editedShow!)
            
            if ohmPickButton.state == .on {
                currentShow?.ohmPick = true
            } else {
                currentShow?.ohmPick = false
            }
            
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
            localDataController.saveShowData()
        } else {
            var newShow = Show(band: bandNameTextField.stringValue, venue: businessNameTextField.stringValue, dateString: startDateTextField.stringValue)
            newShow.time = startTimeTextField.stringValue
            newShow.lastModified = Timestamp()
            localDataController.showArray.append(newShow)
            localDataController.saveShowData()
            notificationCenter.post(name: NSNotification.Name("showsUpdated"), object: nil)
        }
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
            bandNameTextField.stringValue = currentShow!.band
            businessNameTextField.stringValue = currentShow!.venue
            startDateTextField.stringValue = "\(currentShow!.dateString)"
            startTimeTextField.stringValue = "\(currentShow?.time ?? "No Time")"
            deleteButton.isEnabled = true
            
            switch currentShow?.ohmPick {
            
            case false:
                ohmPickButton.state = .off
            case true:
                ohmPickButton.state = .on
            case .none:
                return
            case .some(_):
                return
            }
        } else {
            deleteButton.isEnabled = false
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
                cell.textField?.stringValue = localDataController.businessArray[row].name!
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
                businessNameTextField.stringValue = localDataController.businessArray[index].name!
            }
        }
    }
}
