//
//  ImportShowsViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Cocoa

class ImportShowsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    //MARK: Properties
    //Table Views
    @IBOutlet weak var showsTableView: NSTableView!
    
    
    //Labels
    @IBOutlet weak var numberOfNewShowsLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showsTableView.dataSource = self
        showsTableView.delegate = self
        
    }
    
    //MARK: Buttons
    @IBAction func importButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose Show Data"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = true
        dialog.canChooseDirectories = true
        dialog.allowedFileTypes = ["json"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let results = dialog.urls // Pathname of the file
            
            for result in results {
                let url = URL(fileURLWithPath: result.path)
                parseDataController.path = url
                parseDataController.loadPath {
                    DispatchQueue.main.async {
                        self.showsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
    }
    
    @IBAction func assignButtonTapped(_ sender: Any) {
    }
    
    @IBAction func doubleCheckButtonTapped(_ sender: Any) {
    }
    
    
}
