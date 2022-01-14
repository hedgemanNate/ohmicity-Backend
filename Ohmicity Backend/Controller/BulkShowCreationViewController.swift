////
////  BulkShowCreationViewController.swift
////  Ohmicity Backend
////
////  Created by Nathan Hedgeman on 9/6/21.
////
//
//import Cocoa
//
//class BulkShowCreationViewController: NSViewController {
//    //MARK: Properties
//    //TableViews
//    var bandResultsArray = [Band]()
//    var venueResultsArray = [BusinessFullData]()
//    var showsArray = [Show]() {
//        didSet {
//            showsTableView.reloadData()
//            print("set")
//        }
//    }
//    
//    var addedShowsToBePushedArray = [Show]()
//    
//    
//    @IBOutlet weak var bandsTableView: NSTableView!
//    @IBOutlet weak var venueTableView: NSTableView!
//    @IBOutlet weak var showsTableView: NSTableView!
//    
//    @IBOutlet weak var bandSearchField: NSSearchField!
//    @IBOutlet weak var venueSearchField: NSSearchField!
//    
//    //Buttons
//    @IBOutlet weak var show1CheckBoxButton: NSButton!
//    @IBOutlet weak var show2CheckBoxButton: NSButton!
//    @IBOutlet weak var show3CheckBoxButton: NSButton!
//    @IBOutlet weak var show4CheckBoxButton: NSButton!
//    
//    @IBOutlet weak var addShowsButton: NSButton!
//    var defualtColor: CGColor?
//    @IBOutlet weak var pushShowsButton: NSButton!
//    
//    //Calendars
//    @IBOutlet weak var calendar1: NSDatePicker!
//    @IBOutlet weak var calendar2: NSDatePicker!
//    @IBOutlet weak var calendar3: NSDatePicker!
//    @IBOutlet weak var calendar4: NSDatePicker!
//    
//    //MessageCenter
//    @IBOutlet weak var messageCenterTextField: NSTextField!
//    var timer = Timer()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        updateViews()
//    }
//    
//    //MARK: UpdateViews
//    private func updateViews() {
//        setUpTableViews()
//        clearTextFields()
//        resetCheckBoxes()
//        bandResultsArray = LocalDataStorageController.bandArray
//        venueResultsArray = LocalDataStorageController.venueArray
//        bandsTableView.reloadData()
//        venueTableView.reloadData()
//        show1CheckBoxButton.resignFirstResponder()
//        bandSearchField.becomeFirstResponder()
//        
//        
//        checkBoxLogic()
//        
//        //UI For Buttons
//        defualtColor = addShowsButton.layer?.backgroundColor
//    }
//    
//    private func setUpTableViews() {
//        bandsTableView.delegate = self
//        bandsTableView.dataSource = self
//        venueTableView.delegate = self
//        venueTableView.dataSource = self
//        venueTableView.doubleAction = #selector(doubleClickOnVenue)
//        showsTableView.delegate = self
//        showsTableView.dataSource = self
//        showsTableView.doubleAction = #selector(doubleClickOnShow)
//    }
//    
//    @objc private func doubleClickOnVenue() {
//        print("click")
//        let indexPath = venueTableView.selectedRow
//        let venueName = venueResultsArray[indexPath].name
//        showsArray = LocalDataStorageController.showArray.filter({$0.venue == venueName})
//        showsArray.removeAll(where: {$0.onHold == true})
//        
//        DispatchQueue.main.async {
//            self.showsTableView.reloadData()
//        }
//    }
//    
//    @objc private func doubleClickOnShow() {
//        print("click")
//        performSegue(withIdentifier: "editShowSegue", sender: self)
//    }
//    
//    private func resetCheckBoxes() {
//        show1CheckBoxButton.state = .off
//        checkBoxLogic()
//    }
//    
//    private func clearTextFields() {
//        bandSearchField.stringValue = ""
//        venueSearchField.stringValue = ""
//        messageCenterTextField.stringValue = ""
//    }
//    
//    private func checkBoxLogic() {
//        if show1CheckBoxButton.state == .on {
//            show2CheckBoxButton.isEnabled = true
//        } else {
//            show2CheckBoxButton.state = .off
//            show2CheckBoxButton.isEnabled = false
//        }
//        
//        if show2CheckBoxButton.state == .on {
//            show3CheckBoxButton.isEnabled = true
//        } else {
//            show3CheckBoxButton.state = .off
//            show3CheckBoxButton.isEnabled = false
//        }
//        
//        if show3CheckBoxButton.state == .on {
//            show4CheckBoxButton.isEnabled = true
//        } else {
//            show4CheckBoxButton.state = .off
//            show4CheckBoxButton.isEnabled = false
//        }
//    }
//    
//    //MARK: Button Actions
//    
//    @IBAction func addShowsButtonTapped(_ sender: Any) {
//        
//    }
//    
//    @IBAction func pushShowsButtonTapped(_ sender: Any) {
//        for show in addedShowsToBePushedArray {
//            do {
//                try ref.showDataPath.document(show.showID).setData(from: show, encoder: .init(), completion: { error in
//                    if let err = error {
//                        NSLog(err.localizedDescription)
//                        DispatchQueue.main.async {
//                            self.pushShowsButton.layer?.backgroundColor = NSColor.red.cgColor
//                            self.messageCenterTextField.stringValue = err.localizedDescription
//                            self.timer.invalidate()
//                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
//                                self.pushShowsButton.layer?.backgroundColor = self.defualtColor
//                            })
//                        }
//                    } else {
//                        self.show1CheckBoxButton.state = .off
//                        self.checkBoxLogic()
//                        self.addedShowsToBePushedArray.removeAll(where:{ $0 == show})
//                        DispatchQueue.main.async {
//                            self.pushShowsButton.layer?.backgroundColor = NSColor.green.cgColor
//                            self.timer.invalidate()
//                            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
//                                self.pushShowsButton.layer?.backgroundColor = self.defualtColor
//                            })
//                        }
//                    }
//                })
//            } catch {
//                NSLog("Error pushing shows in BulkShowCreationViewController")
//            }
//        }
//    }
//    
//    
//    
//    @IBAction func resetButtonTapped(_ sender: Any) {
////        resetCheckBoxes()
////        clearTextFields()
////        bandsTableView.reloadData()
////        venueTableView.reloadData()
//    }
//    
//    @IBAction func refreshButtonTapped(_ sender: Any) {
//        bandResultsArray = LocalDataStorageController.bandArray
//        venueResultsArray = LocalDataStorageController.venueArray
//        bandsTableView.reloadData()
//        venueTableView.reloadData()
//    }
//    
//    
//    //Checkbox Actions--------------------------------
//    @IBAction func checkbox1Toggled(_ sender: Any) {
//        checkBoxLogic()
//    }
//    
//    @IBAction func checkbox2Toggled(_ sender: Any) {
//        checkBoxLogic()
//    }
//    
//    @IBAction func checkbox3Toggled(_ sender: Any) {
//        checkBoxLogic()
//    }
//    
//    @IBAction func checkbox4Toggled(_ sender: Any) {
//        checkBoxLogic()
//    }
//    //Checkbox Actions End----------------------------
//    
//    //MARK: SearchBars
//    @IBAction func bandSearchFieldActive(_ sender: NSSearchField) {
//        bandSearch()
//    }
//    
//    @IBAction func venueSearchFieldActive(_ sender: Any) {
//        venueSearch()
//    }
//}
//
//
////MARK: Segue
//extension BulkShowCreationViewController {
//    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "editShowSegue":
//            guard let destinationVC = segue.destinationController as? ShowDetailViewController else {return}
//            let indexPath = showsTableView.selectedRow
//            let show = showsArray[indexPath]
//            destinationVC.currentShow = show
//        default:
//            break
//        }
//    }
//}
//
//
////MARK: TableView
//extension BulkShowCreationViewController: NSTableViewDataSource, NSTableViewDelegate {
//    
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        switch tableView {
//        case bandsTableView:
//            return bandResultsArray.count
//        case venueTableView:
//            return venueResultsArray.count
//        case showsTableView:
//            return showsArray.count
//        default:
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        
//        switch tableView {
//        case bandsTableView:
//            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BandCell"), owner: nil) as? NSTableCellView {
//                cell.textField?.stringValue = bandResultsArray[row].name
//                return cell
//            }
//        case venueTableView:
//            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
//                cell.textField?.stringValue = venueResultsArray[row].name
//                return cell
//            }
//        case showsTableView:
//            let show = showsArray[row]
//            let date = dateFormatter.string(from: show.date)
//            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShowCell"), owner: nil) as? NSTableCellView {
//                
//                cell.textField?.textColor = .white
//                cell.textField?.backgroundColor = .clear
//                
//                dateFormatter.dateFormat = dateFormat3
//                let showDate = dateFormatter.string(from: show.date)
//                let today = dateFormatter.string(from: Date())
//                
//                if showDate == today {
//                    cell.textField?.textColor = .orange
//                }
//                
//                if show.ohmPick == true {
//                    cell.textField?.textColor = .black
//                    cell.textField?.backgroundColor = .yellow
//                }
//                
//                cell.textField?.stringValue = "\(date) - \(showsArray[row].band)"
//                return cell
//            }
//        default:
//            return nil
//        }
//        return NSTableCellView()
//    }
//        
//        
//}
//
////MARK: Search
//extension BulkShowCreationViewController {
//    
//    private func bandSearch() {
//        if bandSearchField.stringValue == "" {
//            bandResultsArray = LocalDataStorageController.bandArray
//            bandsTableView.reloadData()
//        } else {
//            bandResultsArray = LocalDataStorageController.bandArray.filter({($0.name.localizedCaseInsensitiveContains(bandSearchField.stringValue))})
//            DispatchQueue.main.async {
//                self.bandsTableView.reloadData()
//                self.bandsTableView.scrollRowToVisible(0)
//            }
//        }
//    }
//    
//    private func venueSearch() {
//        if venueSearchField.stringValue == "" {
//            venueResultsArray = LocalDataStorageController.venueArray
//            venueTableView.reloadData()
//        } else {
//            venueResultsArray = LocalDataStorageController.venueArray.filter({($0.name.localizedCaseInsensitiveContains(venueSearchField.stringValue))})
//            DispatchQueue.main.async {
//                self.venueTableView.reloadData()
//                self.venueTableView.scrollRowToVisible(0)
//            }
//        }
//    }
//}
