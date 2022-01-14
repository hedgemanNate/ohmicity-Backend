//
//  BandTagViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Cocoa

class BandTagViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    //MARK: Properties
    
    //Table Views
    @IBOutlet weak var tagTableView: NSTableView!
    @IBOutlet weak var variationsTableView: NSTableView!
    @IBOutlet weak var lastImportTableView: NSTableView!
    
    
    var tagTableIndex: Int {
        var tagTableIndex = tagTableView.selectedRow
        if tagTableIndex < 0 {
            tagTableIndex = 0
        }
        return tagTableIndex
    }
    
    var selectedTag: BandTag {
        return filterArray[tagTableView.selectedRow]
    }
    
    var selectedVariation: String {
        return selectedTag.variations[variationsTableView.selectedRow]
    }
    
    var variationsTableViewCount = 0
    
    //Arrays
    var filterArray = [BandTag]()
    var newBandArray = [String]()
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        tagTableView.doubleAction = #selector(tagsTableClick)
        
        variationsTableView.delegate = self
        variationsTableView.dataSource = self
        variationsTableView.doubleAction = #selector(variationsTableClick)
        
        lastImportTableView.delegate = self
        lastImportTableView.dataSource = self
        lastImportTableView.doubleAction = #selector(importTableClick)
        
    }
    
    //MARK: UpdateViews
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        getNewBands()
        setFilterArray()
    }
    
    //MARK: Button Functions
    @IBAction func deleteTagButtonTapped(_ sender: Any) {
        let tempTag = filterArray[tagTableView.selectedRow]
        
        let tagIndex = TagController.bandTags.firstIndex(where: {$0.bandID == tempTag.bandID})
        guard let tagIndex = tagIndex else {return}
        TagController.bandTags.remove(at: tagIndex)
        
        let tagIndex2 = filterArray.firstIndex(where: {$0.bandID == tempTag.bandID})
        guard let tagIndex2 = tagIndex2 else {return}
        filterArray.remove(at: tagIndex2)

        tagTableView.reloadData()
        variationsTableView.reloadData()
        LocalDataStorageController.saveBandTagData()
    }
    
    @IBAction func deleteTagsWithNoBands(_ sender: Any) {
        for tag in TagController.bandTags {
            if !RemoteDataController.bandArray.contains(where: {$0.bandID == tag.bandID}) {
                TagController.bandTags.removeAll(where: {$0.bandID == tag.bandID})
                tagTableView.reloadData()
            }
            
        }
        LocalDataStorageController.saveBandTagData()
    }
    
    
    @IBAction func deleteVariationButtonTapped(_ sender: Any) {
        let tempVariation = filterArray[tagTableIndex].variations[variationsTableView.selectedRow]
        
        let neededTag = TagController.bandTags.first(where: {$0.bandID == selectedTag.bandID})
        neededTag?.variations.removeAll(where: {$0 == tempVariation})
        
        filterArray[tagTableIndex].variations.removeAll(where: {$0 == tempVariation})
        variationsTableView.reloadData()
        
        LocalDataStorageController.saveBandTagData()
        
    }
    
    @IBAction func clearAllTags(_ sender: Any) {
        TagController.bandTags = []
        LocalDataStorageController.saveBandTagData()
    }
    
    @IBAction func createAllNewTags(_ sender: Any) {
        let bandArray = RemoteDataController.bandArray
        
        for band in bandArray {
            let newTag = BandTag(band: band)
            TagController.bandTags.append(newTag)
        }
        
        LocalDataStorageController.saveBandTagData()
    }
    
    @IBAction func addTagButtonTapped(_ sender: Any) {
        let tag = filterArray[tagTableIndex]
        let newTag = newTagTextField.stringValue
        tag.variations.append(newTag)
        variationsTableView.reloadData()
        LocalDataStorageController.saveBandTagData()
        newTagTextField.stringValue = ""
    }
    
    @IBAction func addVariationButtonTapped(_ sender: Any) {
        selectedTag.variations.append(newTagTextField.stringValue)
        variationsTableView.reloadData()
        LocalDataStorageController.saveBandTagData()
    }
    
    
    @IBAction func searchFieldSearching(_ sender: Any) {
        var variationArray = [BandTag]()
        var bandIDArray = [BandTag]()
    
        variationArray = TagController.bandTags.filter({$0.variations.contains(where: {$0.localizedCaseInsensitiveContains(searchTextField.stringValue)})})
        bandIDArray = TagController.bandTags.filter({$0.bandID.localizedCaseInsensitiveContains(searchTextField.stringValue)})
        
        filterArray = variationArray + bandIDArray
        
        DispatchQueue.main.async {
            self.tagTableView.reloadData()
        }
        
        if searchTextField.stringValue == "" {
            setFilterArray()
        }
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: Functions
    private func getNewBands() {
        let rawShows = RawShowDataController.rawShowsArray
        let bands = LocalDataStorageController.bandArray
        
        for show in rawShows {
            if bands.contains(where: {$0.name == show.band}) {
                continue
            } else {
                newBandArray.append(show.band)
            }
        }
    }
    
    private func setFilterArray() {
        filterArray = TagController.bandTags
        DispatchQueue.main.async {
            self.tagTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func tagsTableClick() {
        variationsTableViewCount = selectedTag.variations.count
        self.variationsTableView.reloadData()
    }
    
    @objc private func variationsTableClick() {
        self.newTagTextField.stringValue = "\(selectedVariation)"
    }
    
    @objc private func importTableClick() {
        self.newTagTextField.stringValue = "\(newBandArray[lastImportTableView.selectedRow])"
    }
}

//MARK: TableView
extension BandTagViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
    
        switch tableView {
        case tagTableView:
            return filterArray.count
        case variationsTableView:
            return filterArray[tagTableIndex].variations.count
        case lastImportTableView:
            return newBandArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case tagTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("BandTagCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(filterArray[row].variations[0])"
                return cell
            }
            
        case variationsTableView:
            let bandTag = filterArray[tagTableIndex]
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VariationCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(bandTag.variations[row])"
                return cell
            }
        
        case lastImportTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ImportCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(newBandArray[row])"
                return cell
            }
            
        default:
            return NSTableCellView()
        }
        return NSTableCellView()
    }
}
