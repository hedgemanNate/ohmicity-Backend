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
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bandTableView.delegate = self
        bandTableView.dataSource = self
        bandTableView.doubleAction = #selector(bandTableClick)
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.doubleAction = #selector(tagsTableClick)
        updateViews()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
    }

    @IBAction func addTagButtonTapped(_ sender: Any) {
        let tag = tagController.bandTags[bandTableIndex]
        let newTag = newTagTextField.stringValue
        tag.variations.append(newTag)
        tagsTableView.reloadData()
        localDataController.saveBandTagData()
    }

    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        
    }
    
    @objc private func bandTableClick() {
        self.tagsTableView.reloadData()
    }
    
    @objc private func tagsTableClick() {
        self.newTagTextField.stringValue = "\(tagController.bandTags[self.bandTableView.selectedRow].variations[self.tagsTableView.selectedRow])"
    }
}

//MARK: TableView
extension BandTagViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let bandTag = tagController.bandTags[bandTableIndex]
            
        
        
        switch tableView {
        case bandTableView:
            return tagController.bandTags.count
        case tagsTableView:
            return bandTag.variations.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case bandTableView:
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("BandTagCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(tagController.bandTags[row].variations[0])"
                return cell
            }
            
        case tagsTableView:
            let bandTag = tagController.bandTags[bandTableIndex]
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("VariationCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "\(row + 1): \(bandTag.variations[row])"
                return cell
            }
        default:
            return NSTableCellView()
        }
        return nil
    }
}
