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
    @IBOutlet weak var bandTableView: NSTableView!
    @IBOutlet weak var tagsTableView: NSTableView!
    @IBOutlet weak var lastImportTableView: NSTableView!
    
    
    var bandTableIndex: Int {
        var bandTableIndex = bandTableView.selectedRow
        if bandTableIndex < 0 {
            bandTableIndex = 0
        }
        return bandTableIndex
    }
    
    var filterArray = [BandTag]()
    var newBandArray = [String]()
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        bandTableView.delegate = self
        bandTableView.dataSource = self
        bandTableView.doubleAction = #selector(venueTableClick)
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.doubleAction = #selector(tagsTableClick)
        
        lastImportTableView.delegate = self
        lastImportTableView.dataSource = self
        lastImportTableView.doubleAction = #selector(importTableClick)
        
    }
    
    
    //MARK: Button Functions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let tag = filterArray[bandTableIndex].variations[tagsTableView.selectedRow]
        filterArray[bandTableIndex].variations.removeAll(where: {$0 == tag})
        tagsTableView.reloadData()
    }

    @IBAction func addTagButtonTapped(_ sender: Any) {
        let tag = filterArray[bandTableIndex]
        let newTag = newTagTextField.stringValue
        tag.variations.append(newTag)
        tagsTableView.reloadData()
        localDataController.saveBandTagData()
        newTagTextField.stringValue = ""
    }
    
    @IBAction func searchFieldSearching(_ sender: Any) {
        filterArray = tagController.bandTags.filter({$0.variations.contains(where: {$0.localizedCaseInsensitiveContains(searchTextField.stringValue)})})
        
        DispatchQueue.main.async {
            self.bandTableView.reloadData()
            self.tagsTableView.reloadData()
        }
        
        if searchTextField.stringValue == "" {
            setFilterArray()
        }
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: UpdateViews
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        //newTagTextField.becomeFirstResponder()
        getNewBands()
        setFilterArray()
    }
    
    
    //MARK: Functions
    private func getNewBands() {
        let rawShows = rawShowDataController.rawShowsArray
        let bands = localDataController.bandArray
        
        for show in rawShows {
            if bands.contains(where: {$0.name == show.band}) {
                continue
            } else {
                newBandArray.append(show.band)
            }
        }
    }
    
    private func setFilterArray() {
        filterArray = tagController.bandTags
        DispatchQueue.main.async {
            self.bandTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func venueTableClick() {
        self.tagsTableView.reloadData()
    }
    
    @objc private func tagsTableClick() {
        self.newTagTextField.stringValue = "\(filterArray[self.bandTableView.selectedRow].variations[self.tagsTableView.selectedRow])"
    }
    
    @objc private func importTableClick() {
        self.newTagTextField.stringValue = "\(newBandArray[lastImportTableView.selectedRow])"
    }
}

//MARK: TableView
extension BandTagViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
    
        switch tableView {
        case bandTableView:
            return filterArray.count
        case tagsTableView:
            return filterArray[bandTableIndex].variations.count
        case lastImportTableView:
            return newBandArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case bandTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("BandTagCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(filterArray[row].variations[0])"
                return cell
            }
            
        case tagsTableView:
            let bandTag = filterArray[bandTableIndex]
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
