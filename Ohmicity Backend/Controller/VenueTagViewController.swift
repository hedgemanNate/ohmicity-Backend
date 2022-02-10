//
//  VenueTagViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Cocoa

class VenueTagViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //MARK: Properties
    
    //Table Views
    @IBOutlet weak var venueTableView: NSTableView!
    @IBOutlet weak var tagsTableView: NSTableView!
    @IBOutlet weak var bandsTableView: NSTableView!
    
    
    var venueTableIndex: Int {
        var venueTableIndex = venueTableView.selectedRow
        if venueTableIndex < 0 {
            venueTableIndex = 0
        }
        return venueTableIndex
    }
    
    var filterArray = [VenueTag]()
    var newVenueArray = [String]()
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 860)
        updateViews()
        venueTableView.delegate = self
        venueTableView.dataSource = self
        venueTableView.doubleAction = #selector(venueTableClick)
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.doubleAction = #selector(tagsTableClick)
        
        bandsTableView.delegate = self
        bandsTableView.dataSource = self
        bandsTableView.doubleAction = #selector(bandsTableClick)
        
    }
    
    
    //MARK: Button Functions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let tag = filterArray[venueTableIndex].variations[tagsTableView.selectedRow]
        filterArray[venueTableIndex].variations.removeAll(where: {$0 == tag})
        tagsTableView.reloadData()
    }

    @IBAction func addTagButtonTapped(_ sender: Any) {
        let tag = filterArray[venueTableIndex]
        let newTag = newTagTextField.stringValue
        tag.variations.append(newTag)
        tagsTableView.reloadData()
        LocalBackupDataStorageController.saveBandTagData()
        newTagTextField.stringValue = ""
    }
    
    @IBAction func searchFieldSearching(_ sender: Any) {
        filterArray = TagController.venueTags.filter({$0.variations.contains(where: {$0.localizedCaseInsensitiveContains(searchTextField.stringValue)})})
        
        DispatchQueue.main.async {
            self.venueTableView.reloadData()
            self.tagsTableView.reloadData()
        }
        
        if searchTextField.stringValue == "" {
            setFilterArray()
        }
    }
    
    @IBAction func breaker(_ sender: Any) {
        
        for venue in LocalBackupDataStorageController.venueArray {
            let newTag = VenueTag(venueID: venue.venueID, variations: [venue.name])
            TagController.venueTags.append(newTag)
            LocalBackupDataStorageController.saveVenueTagData()
        }
    }
    
    
    //MARK: UpdateViews
    private func updateViews() {
        //newTagTextField.becomeFirstResponder()
        getNewVenues()
        setFilterArray()
    }
    
    
    //MARK: Functions
    private func getNewVenues() {
        let rawShows = RawShowDataController.rawShowsArray
        let venues = LocalBackupDataStorageController.venueArray
        
        for show in rawShows {
            if venues.contains(where: {$0.name == show.venue}) {
                continue
            } else {
                newVenueArray.append(show.venue)
            }
        }
    }
    
    private func setFilterArray() {
        filterArray = TagController.venueTags
        DispatchQueue.main.async {
            self.venueTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func venueTableClick() {
        self.tagsTableView.reloadData()
    }
    
    @objc private func tagsTableClick() {
        self.newTagTextField.stringValue = "\(filterArray[self.venueTableView.selectedRow].variations[self.tagsTableView.selectedRow])"
    }
    
    @objc private func bandsTableClick() {
        self.newTagTextField.stringValue = "\(newVenueArray[bandsTableView.selectedRow])"
    }
}

//MARK: TableView
extension VenueTagViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
    
        switch tableView {
        case venueTableView:
            return filterArray.count
        case tagsTableView:
            return filterArray[venueTableIndex].variations.count
        case bandsTableView:
            return newVenueArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case venueTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VenueTagCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(filterArray[row].variations[0])"
                return cell
            }
            
        case tagsTableView:
            let venueTag = filterArray[venueTableIndex]
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VariationCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(venueTag.variations[row])"
                return cell
            }
        
        case bandsTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ImportCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(newVenueArray[row])"
                return cell
            }
            
        default:
            return NSTableCellView()
        }
        return NSTableCellView()
    }
}
