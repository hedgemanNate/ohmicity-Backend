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
    
    var bandTableIndex: Int {
        var bandTableIndex = bandTableView.selectedRow
        if bandTableIndex < 0 {
            bandTableIndex = 0
        }
        return bandTableIndex
    }
    
    var filterArray = [BandTags]()
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        bandTableView.delegate = self
        bandTableView.dataSource = self
        bandTableView.doubleAction = #selector(bandTableClick)
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.doubleAction = #selector(tagsTableClick)
        
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
    
    
    
    //MARK: UpdateViews
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        //newTagTextField.becomeFirstResponder()
        setFilterArray()
    }
    
    
    //MARK: Functions
    private func setFilterArray() {
        filterArray = tagController.bandTags
        DispatchQueue.main.async {
            self.bandTableView.reloadData()
            //self.tagsTableView.reloadData()
        }
    }
    
    @objc private func bandTableClick() {
        self.tagsTableView.reloadData()
    }
    
    @objc private func tagsTableClick() {
        self.newTagTextField.stringValue = "\(filterArray[self.bandTableView.selectedRow].variations[self.tagsTableView.selectedRow])"
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
        default:
            return NSTableCellView()
        }
        return NSTableCellView()
    }
}
