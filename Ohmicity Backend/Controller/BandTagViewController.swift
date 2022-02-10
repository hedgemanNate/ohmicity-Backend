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
    @IBOutlet weak var bandsTableView: NSTableView!
    
    
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
    
    var selectedBand: Band?
    
    var variationsTableViewCount = 0
    
    //Arrays
    var filterBandArray = [Band]()
    var filterArray = [BandTag]()
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    @IBOutlet weak var bandSearchField: NSSearchField!
    @IBOutlet weak var messagesTextField: NSTextFieldCell!
    
    //Label
    @IBOutlet weak var tagIDLabel: NSTextField!
    @IBOutlet weak var bandIDLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 860)
        updateViews()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        tagTableView.doubleAction = #selector(tagsTableClick)
        
        variationsTableView.delegate = self
        variationsTableView.dataSource = self
        variationsTableView.doubleAction = #selector(variationsTableClick)
        
        bandsTableView.delegate = self
        bandsTableView.dataSource = self
        bandsTableView.doubleAction = #selector(bandsTableClick)
    }
    
    //MARK: UpdateViews
    private func updateViews() {
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
        LocalBackupDataStorageController.saveBandTagData()
    }
    
    @IBAction func deleteTagsWithNoBands(_ sender: Any) {
        for tag in TagController.bandTags {
            if !RemoteDataController.bandArray.contains(where: {$0.bandID == tag.bandID}) {
                TagController.bandTags.removeAll(where: {$0.bandID == tag.bandID})
                tagTableView.reloadData()
            }
            
        }
        LocalBackupDataStorageController.saveBandTagData()
    }
    
    
    @IBAction func deleteVariationButtonTapped(_ sender: Any) {
        let tempVariation = filterArray[tagTableIndex].variations[variationsTableView.selectedRow]
        
        let neededTag = TagController.bandTags.first(where: {$0.bandID == selectedTag.bandID})
        neededTag?.variations.removeAll(where: {$0 == tempVariation})
        
        filterArray[tagTableIndex].variations.removeAll(where: {$0 == tempVariation})
        variationsTableView.reloadData()
        
        LocalBackupDataStorageController.saveBandTagData()
        
    }
    
    @IBAction func clearAllTags(_ sender: Any) {
        TagController.bandTags = []
        LocalBackupDataStorageController.saveBandTagData()
    }
    
    @IBAction func createAllNewTags(_ sender: Any) {
        let bandArray = RemoteDataController.bandArray
        
        for band in bandArray {
            let newTag = BandTag(band: band)
            TagController.bandTags.append(newTag)
        }
        
        LocalBackupDataStorageController.saveBandTagData()
    }
    
    @IBAction func addTagButtonTapped(_ sender: Any) {
        guard let selectedBand = selectedBand else {return}
        let newTag = BandTag(band: selectedBand)
        for tag in TagController.bandTags {
            if tag.variations.contains(newTag.variations[0]) {
                TagController.bandTags.removeAll(where: {$0.bandID == tag.bandID})
            }
        }
        TagController.bandTags.append(newTag)
        tagTableView.reloadData()
        messagesTextField.stringValue = "\(newTag.variations[0]) added to Tags"
    }
    
    @IBAction func addVariationButtonTapped(_ sender: Any) {
        selectedTag.variations.append(newTagTextField.stringValue)
        variationsTableView.reloadData()
        LocalBackupDataStorageController.saveBandTagData()
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
    
    @IBAction func bandSearchFieldSearching(_ sender: Any) {
        if bandSearchField.stringValue == "" {
            filterBandArray = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
        } else {
            filterBandArray = RemoteDataController.bandArray.filter({$0.name.localizedCaseInsensitiveContains(bandSearchField.stringValue)})
        }
        bandsTableView.reloadData()
    }
    
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: Functions
    private func getNewBands() {
//        let rawShows = RawShowDataController.rawShowsArray
//        let bands = LocalDataStorageController.bandArray
//
//        for show in rawShows {
//            if bands.contains(where: {$0.name == show.band}) {
//                continue
//            } else {
//                filterBandArray.append(show.band)
//            }
//        }
    }
    
    private func setFilterArray() {
        filterArray = TagController.bandTags
        filterBandArray = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
        DispatchQueue.main.async {
            self.tagTableView.reloadData()
            self.bandsTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func tagsTableClick() {
        variationsTableViewCount = selectedTag.variations.count
        tagIDLabel.stringValue = selectedTag.bandID
        self.variationsTableView.reloadData()
    }
    
    @objc private func variationsTableClick() {
        self.newTagTextField.stringValue = "\(selectedVariation)"
    }
    
    @objc private func bandsTableClick() {
        self.newTagTextField.stringValue = filterBandArray[bandsTableView.selectedRow].name
        selectedBand = filterBandArray[bandsTableView.selectedRow]
        guard let selectedBand = selectedBand else {return}
        bandIDLabel.stringValue = selectedBand.bandID
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
        case bandsTableView:
            return filterBandArray.count
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
        
        case bandsTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ImportCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(filterBandArray[row].name)"
                return cell
            }
            
        default:
            return NSTableCellView()
        }
        return NSTableCellView()
    }
}
