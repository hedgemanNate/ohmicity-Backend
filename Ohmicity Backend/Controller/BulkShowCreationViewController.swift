//
//  BulkShowCreationViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 9/6/21.
//

import Cocoa

class BulkShowCreationViewController: NSViewController {
    //MARK: Properties
    //TableViews
    var bandResultsArray = [Band]()
    var venueResultsArray = [BusinessFullData]()
    
    var addedShowsToBePushedArray = [Show]()
    
    
    @IBOutlet weak var bandsTableView: NSTableView!
    @IBOutlet weak var venueTableView: NSTableView!
    
    @IBOutlet weak var bandSearchField: NSSearchField!
    @IBOutlet weak var venueSearchField: NSSearchField!
    
    //Buttons
    @IBOutlet weak var show1CheckBoxButton: NSButton!
    @IBOutlet weak var show2CheckBoxButton: NSButton!
    @IBOutlet weak var show3CheckBoxButton: NSButton!
    @IBOutlet weak var show4CheckBoxButton: NSButton!
    
    @IBOutlet weak var addShowsButton: NSButton!
    var defualtColor: CGColor?
    @IBOutlet weak var pushShowsButton: NSButton!
    
    //Calendars
    @IBOutlet weak var calendar1: NSDatePicker!
    @IBOutlet weak var calendar2: NSDatePicker!
    @IBOutlet weak var calendar3: NSDatePicker!
    @IBOutlet weak var calendar4: NSDatePicker!
    
    //MessageCenter
    @IBOutlet weak var messageCenterTextField: NSTextField!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    //MARK: UpdateViews
    private func updateViews() {
        setUpTableViews()
        clearTextFields()
        resetCheckBoxes()
        bandResultsArray = localDataController.bandArray
        venueResultsArray = localDataController.businessArray
        bandsTableView.reloadData()
        venueTableView.reloadData()
        show1CheckBoxButton.resignFirstResponder()
        bandSearchField.becomeFirstResponder()
        
        checkBoxLogic()
        
        //UI For Buttons
        defualtColor = addShowsButton.layer?.backgroundColor
    }
    
    private func setUpTableViews() {
        bandsTableView.delegate = self
        bandsTableView.dataSource = self
        venueTableView.delegate = self
        venueTableView.dataSource = self
    }
    
    private func resetCheckBoxes() {
        show1CheckBoxButton.state = .off
        checkBoxLogic()
    }
    
    private func clearTextFields() {
        bandSearchField.stringValue = ""
        venueSearchField.stringValue = ""
        messageCenterTextField.stringValue = ""
    }
    
    private func checkBoxLogic() {
        if show1CheckBoxButton.state == .on {
            show2CheckBoxButton.isEnabled = true
        } else {
            show2CheckBoxButton.state = .off
            show2CheckBoxButton.isEnabled = false
        }
        
        if show2CheckBoxButton.state == .on {
            show3CheckBoxButton.isEnabled = true
        } else {
            show3CheckBoxButton.state = .off
            show3CheckBoxButton.isEnabled = false
        }
        
        if show3CheckBoxButton.state == .on {
            show4CheckBoxButton.isEnabled = true
        } else {
            show4CheckBoxButton.state = .off
            show4CheckBoxButton.isEnabled = false
        }
    }
    
    //MARK: Button Actions
    
    @IBAction func addShowsButtonTapped(_ sender: Any) {
        dateFormatter.dateFormat = dateFormat1
        var bulkShowCreationCounter = 0
        var band: Band?
        var venue: BusinessFullData?
        
        let bandIndex = bandsTableView.selectedRow
        let venueIndex = venueTableView.selectedRow
        
        if bandIndex < 0 {
            messageCenterTextField.stringValue = "Select A Band"
            return
            
        } else {
            band = bandResultsArray[bandIndex]
        }
        
        if venueIndex < 0 {
            messageCenterTextField.stringValue = "Select A Venue"
            return
        } else {
            venue = venueResultsArray[venueIndex]
        }
        
        if show1CheckBoxButton.state == .on {
            let dateString = dateFormatter.string(from: calendar1.dateValue)
            var show = Show(band: band!.name, venue: venue!.name, dateString: dateString, date: calendar1.dateValue)
            show.city = venue?.city
            show.city?.append(.All)
            if localDataController.showArray.contains(show) {
                messageCenterTextField.stringValue.append("Show1 already exists")
            }
            localDataController.showArray.append(show)
            addedShowsToBePushedArray.append(show)
            bulkShowCreationCounter += 1
        }
        
        if show2CheckBoxButton.state == .on {
            let dateString = dateFormatter.string(from: calendar2.dateValue)
            var show = Show(band: band!.name, venue: venue!.name, dateString: dateString, date: calendar2.dateValue)
            show.city = venue?.city
            show.city?.append(.All)
            if localDataController.showArray.contains(show) {
                messageCenterTextField.stringValue.append("Show2 already exists")
            }
            localDataController.showArray.append(show)
            addedShowsToBePushedArray.append(show)
            bulkShowCreationCounter += 1
        }
        
        if show3CheckBoxButton.state == .on {
            let dateString = dateFormatter.string(from: calendar3.dateValue)
            var show = Show(band: band!.name, venue: venue!.name, dateString: dateString, date: calendar3.dateValue)
            show.city = venue?.city
            show.city?.append(.All)
            if localDataController.showArray.contains(show) {
                messageCenterTextField.stringValue.append("Show3 already exists")
            }
            localDataController.showArray.append(show)
            addedShowsToBePushedArray.append(show)
            bulkShowCreationCounter += 1
        }
        
        if show4CheckBoxButton.state == .on {
            let dateString = dateFormatter.string(from: calendar4.dateValue)
            var show = Show(band: band!.name, venue: venue!.name, dateString: dateString, date: calendar4.dateValue)
            show.city = venue?.city
            show.city?.append(.All)
            if localDataController.showArray.contains(show) {
                messageCenterTextField.stringValue.append("Show4 already exists")
            }
            localDataController.showArray.append(show)
            addedShowsToBePushedArray.append(show)
            bulkShowCreationCounter += 1
        }
        
        resetCheckBoxes()
        messageCenterTextField.stringValue = "\(bulkShowCreationCounter) Shows Added"
        
        //Color Indication
        DispatchQueue.main.async {
            self.addShowsButton.layer?.backgroundColor = NSColor.green.cgColor
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                self.addShowsButton.layer?.backgroundColor = self.defualtColor
            })
        }
        
        localDataController.saveShowData()
    }
    
    @IBAction func pushShowsButtonTapped(_ sender: Any) {
        for show in addedShowsToBePushedArray {
            do {
                try ref.showDataPath.document(show.showID).setData(from: show, encoder: .init(), completion: { error in
                    if let err = error {
                        NSLog(err.localizedDescription)
                        DispatchQueue.main.async {
                            self.pushShowsButton.layer?.backgroundColor = NSColor.red.cgColor
                            self.messageCenterTextField.stringValue = err.localizedDescription
                            self.timer.invalidate()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                                self.pushShowsButton.layer?.backgroundColor = self.defualtColor
                            })
                        }
                    } else {
                        self.show1CheckBoxButton.state = .off
                        self.checkBoxLogic()
                        self.addedShowsToBePushedArray.removeAll(where:{ $0 == show})
                        DispatchQueue.main.async {
                            self.pushShowsButton.layer?.backgroundColor = NSColor.green.cgColor
                            self.timer.invalidate()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                                self.pushShowsButton.layer?.backgroundColor = self.defualtColor
                            })
                        }
                    }
                })
            } catch {
                NSLog("Error pushing shows in BulkShowCreationViewController")
            }
        }
    }
    
    
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        resetCheckBoxes()
        clearTextFields()
        bandsTableView.reloadData()
        venueTableView.reloadData()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        bandResultsArray = localDataController.bandArray
        venueResultsArray = localDataController.businessArray
        bandsTableView.reloadData()
        venueTableView.reloadData()
    }
    
    
    //Checkbox Actions--------------------------------
    @IBAction func checkbox1Toggled(_ sender: Any) {
        checkBoxLogic()
    }
    
    @IBAction func checkbox2Toggled(_ sender: Any) {
        checkBoxLogic()
    }
    
    @IBAction func checkbox3Toggled(_ sender: Any) {
        checkBoxLogic()
    }
    
    @IBAction func checkbox4Toggled(_ sender: Any) {
        checkBoxLogic()
    }
    //Checkbox Actions End----------------------------
    
    //MARK: SearchBars
    @IBAction func bandSearchFieldActive(_ sender: NSSearchField) {
        bandSearch()
    }
    
    @IBAction func venueSearchFieldActive(_ sender: Any) {
        venueSearch()
    }
}


//MARK: TableView
extension BulkShowCreationViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case bandsTableView:
            return bandResultsArray.count
        case venueTableView:
            return venueResultsArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableView {
        case bandsTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BandCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = bandResultsArray[row].name
                return cell
            }
        case venueTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = venueResultsArray[row].name
                return cell
            }
        default:
            return nil
        }
        return NSTableCellView()
    }
}

//MARK: Search
extension BulkShowCreationViewController {
    
    private func bandSearch() {
        if bandSearchField.stringValue == "" {
            bandResultsArray = localDataController.bandArray
            bandsTableView.reloadData()
        } else {
            bandResultsArray = localDataController.bandArray.filter({($0.name.localizedCaseInsensitiveContains(bandSearchField.stringValue))})
            DispatchQueue.main.async {
                self.bandsTableView.reloadData()
                self.bandsTableView.scrollRowToVisible(0)
            }
        }
    }
    
    private func venueSearch() {
        if venueSearchField.stringValue == "" {
            venueResultsArray = localDataController.businessArray
            venueTableView.reloadData()
        } else {
            venueResultsArray = localDataController.businessArray.filter({($0.name.localizedCaseInsensitiveContains(venueSearchField.stringValue))})
            DispatchQueue.main.async {
                self.venueTableView.reloadData()
                self.venueTableView.scrollRowToVisible(0)
            }
        }
    }
}
