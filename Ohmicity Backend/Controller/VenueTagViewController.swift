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
    @IBOutlet weak var tagsTableView: NSTableView!
    @IBOutlet weak var variationsTableView: NSTableView!
    @IBOutlet weak var venuesTableView: NSTableView!
    
    
    var tagsTableIndex: Int {
        var venueTableIndex = tagsTableView.selectedRow
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
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.doubleAction = #selector(tagsTableClick)
        
        variationsTableView.delegate = self
        variationsTableView.dataSource = self
        variationsTableView.doubleAction = #selector(variationTableClick)
        
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        venuesTableView.doubleAction = #selector(venuesTableClick)
        
    }
    
    
    //MARK: Button Functions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let variation = filterArray[tagsTableIndex].variations[variationsTableView.selectedRow]
        filterArray[tagsTableIndex].variations.removeAll(where: {$0 == variation})
        variationsTableView.reloadData()
    }

    @IBAction func addVariationButtonTapped(_ sender: Any) {
        let tag = filterArray[tagsTableIndex]
        let newTag = newTagTextField.stringValue
        tag.variations.append(newTag)
        variationsTableView.reloadData()
        LocalBackupDataStorageController.saveBandTagData()
        newTagTextField.stringValue = ""
    }
    
    @IBAction func addTagButtonTapped(_ sender: Any) {
        if newTagTextField.stringValue == "" {return}
        if venuesTableView.selectedRow < 0 {return}
        
        let venue = RemoteDataController.venueArray[venuesTableView.selectedRow]
        let newTag = VenueTag(venueID: venue.venueID, variations: [venue.name])
        
        if TagController.venueTags.contains(where: {$0.venueID == newTag.venueID}) {return}
        TagController.venueTags.append(newTag)
        
    }
    
    @IBAction func searchFieldSearching(_ sender: Any) {
        filterArray = TagController.venueTags.filter({$0.variations.contains(where: {$0.localizedCaseInsensitiveContains(searchTextField.stringValue)})})
        
        DispatchQueue.main.async {
            self.tagsTableView.reloadData()
            self.variationsTableView.reloadData()
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
        setFilterArray()
    }
    
    
    //MARK: Functions
    
    private func setFilterArray() {
        filterArray = TagController.venueTags
        DispatchQueue.main.async {
            self.tagsTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func tagsTableClick() {
        self.variationsTableView.reloadData()
    }
    
    @objc private func variationTableClick() {
        self.newTagTextField.stringValue = "\(filterArray[self.tagsTableView.selectedRow].variations[self.variationsTableView.selectedRow])"
    }
    
    @objc private func venuesTableClick() {
        self.newTagTextField.stringValue = RemoteDataController.venueArray[venuesTableView.selectedRow].name
    }
}

//MARK: TableView
extension VenueTagViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
    
        switch tableView {
        case tagsTableView:
            return filterArray.count
        case variationsTableView:
            return filterArray[tagsTableIndex].variations.count
        case venuesTableView:
            return RemoteDataController.venueArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case tagsTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VenueTagCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(filterArray[row].variations[0])"
                return cell
            }
            
        case variationsTableView:
            let venueTag = filterArray[tagsTableIndex]
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VariationCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(venueTag.variations[row])"
                return cell
            }
        
        case venuesTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ImportCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(RemoteDataController.venueArray[row].name)"
                return cell
            }
            
        default:
            return NSTableCellView()
        }
        return NSTableCellView()
    }
}
