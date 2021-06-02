//
//  MainViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/20/21.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase



class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //Properties
    @IBOutlet weak var scrapeDataButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let dataController = ParseDataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    
    @IBAction func testButtonTapped(_ sender: Any) {
        guard let path = dataController.path else {return NSLog("No file found")}
        print(path)
    }
    
    
    @IBAction func scrapeDataButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let url = URL(fileURLWithPath: result!.path)
                
                dataController.path = url
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func parseDataTapped(_ sender: Any) {
        dataController.loadPath()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataController.dataArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "VenueCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(row + 1): \(dataController.dataArray[row].venueName)"
            
            return cell
        }
        
        return  nil
    }
    
}

// MARK: Data Source
extension MainViewController {
    
}
