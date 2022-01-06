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
        localDataController.loadShowData()
        updateViews()
    }
    
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        numberOfNewShowsLabel.stringValue = "\(rawShowDataController.rawShowsArray.count)"
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
                rawShowDataController.path = url
                rawShowDataController.loadShowsPath {
                    localDataController.saveJsonData()
                    DispatchQueue.main.async {
                        self.showsTableView.reloadData()
                        self.numberOfNewShowsLabel.stringValue = "\(rawShowDataController.rawShowsArray.count)"
                    }
                }
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        rawShowDataController.rawShowsArray = []
        showsTableView.reloadData()
    }
    
    @IBAction func assignButtonTapped(_ sender: Any) {
        
        let rawShowsArray = rawShowDataController.rawShowsArray
        
        for rawShow in rawShowsArray {
            let band = tagController.scanBandTags(band: rawShow.band)
            let venue = tagController.scanVenueTags(venue: rawShow.venue)
            
            let newShow = Show(band: band.bandID, venue: venue.venueID, dateString: rawShow.dateString)
            
            guard let newShow = newShow else { continue }
            if newShow.venue == "Blank" {continue}
            
            localDataController.showArray.append(newShow)
            
        }
        
    }
    
    @IBAction func doubleCheckButtonTapped(_ sender: Any) {
        let bandArray = localDataController.bandArray
        
        for band in bandArray {
            let newTag = BandTags(bandID: band.bandID, variations: [band.name])
            tagController.bandTags.append(newTag)
        }
        
        localDataController.saveBandTagData()
    }
}


//MARK: Functions
extension ImportShowsViewController {
    
    private func doubleCheck(show: Show) {
        
    }
}




//MARK: TableView
extension ImportShowsViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rawShowDataController.rawShowsArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let show = rawShowDataController.rawShowsArray[row]
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = "\(row + 1): \(show.venue) | \(show.band) | \(show.dateString)"
            
            return cell
        }
        return nil
    }
    
}
