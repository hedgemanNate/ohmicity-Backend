//
//  ImportShowsViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Cocoa
import FirebaseFirestore

class ImportShowsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    //MARK: Properties
    //Table Views
    @IBOutlet weak var showsTableView: NSTableView!
    
    //Array
    var showsArray = [Show]() {didSet{showsTableView.reloadData()}}
    
    
    //Labels
    @IBOutlet weak var numberOfNewShowsLabel: NSTextField!
    
    //Buttons
    @IBOutlet weak var unprocessedDataButton: NSButton!
    @IBOutlet weak var processedShowsButton: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        showsTableView.dataSource = self
        showsTableView.delegate = self
        localDataController.loadShowData()
        updateViews()
    }
    
    //MARK: Update Views
    private func updateViews() {
        showsTableView.reloadData()
        if unprocessedDataButton.state == .on {
            numberOfNewShowsLabel.stringValue = String(rawShowDataController.rawShowsArray.count)
        } else if processedShowsButton.state == .on {
            showsArray = localDataController.showArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
            numberOfNewShowsLabel.stringValue = String(showsArray.count)
        }
    }
    
    @IBAction func breaker(_ sender: Any) {
        
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
                }
            }
            DispatchQueue.main.async {
                self.showsTableView.reloadData()
                self.numberOfNewShowsLabel.stringValue = "\(rawShowDataController.rawShowsArray.count)"
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        rawShowDataController.rawShowsArray = []
        showsTableView.reloadData()
    }
    
    @IBAction func assignButtonTapped(_ sender: Any) {
        for rawShow in rawShowDataController.rawShowsArray {
            var venueID = ""
            var bandID = ""
            
            //Replace this line with *1* when venue tags are ready
            venueID = localDataController.businessArray.first(where: {$0.name == rawShow.venue})?.venueID ?? "none"
            //
            
            if venueID == "none" {continue}
            
            print(rawShow.venue)
            print(venueID)
            
            //*1* Same code for venue tags above
            bandID = assignBandTagID(rawShow: rawShow)
            //
            
            print(rawShow.band)
            print(bandID)
            
            if bandID == "none" {continue}
            
            let newShow = Show(band: bandID, venue: venueID, dateString: rawShow.dateString)
            guard let newShow = newShow else {continue}
            
            checkIfShowHasBeenUpdated(newShow: newShow)
            if showIsADuplicate(newShow: newShow) {continue}
            
            
            localDataController.showArray.append(newShow)
            rawShowDataController.rawShowsArray.removeAll(where: {$0 == rawShow})
            
        }
        updateViews()
    }
    
    @IBAction func removeDoubleBookedShowsButtonTapped(_ sender: Any) {
        for show in localDataController.showArray {
            checkIfShowHasBeenUpdated(newShow: show)
        }
    }
    
    //MARK: Radio Buttons
    @IBAction func tableViewRadioButtonsTapped(_ sender: Any) {
        if unprocessedDataButton.state == .on {
            numberOfNewShowsLabel.stringValue = String(rawShowDataController.rawShowsArray.count)
        } else if processedShowsButton.state == .on {
            showsArray = localDataController.showArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
            numberOfNewShowsLabel.stringValue = String(showsArray.count)
        }
        showsTableView.reloadData()
    }
    
}


//MARK: Functions
extension ImportShowsViewController {
    
    private func assignBandTagID(rawShow: ShowData) -> String {
        var bandID = "none"
        
        for tag in tagController.bandTags {
            for variation in tag.variations {
                if rawShow.band.lowercased() == variation.lowercased() {
                    bandID = tag.bandID
                }
            }
        }
        
        return bandID
    }
    
    private func checkIfShowHasBeenUpdated(newShow: Show) {
        for var show in localDataController.showArray {
            if show.venue == newShow.venue {
                let hours = show.date.timeIntervalSinceReferenceDate - newShow.date.timeIntervalSinceReferenceDate
                
                let timeSpan = -7200.0...7200.0
                if timeSpan.contains(hours) {
                    show.onHold = true
                    show.lastModified = Timestamp()
                }
            }
        }
    }
    
    private func checkIfShowIsADuplicate(newShow: Show) {
        for var show in localDataController.showArray {
            if show.band == newShow.band && show.venue == newShow.venue && show.date == newShow.date {
                show.onHold = true
                show.lastModified = Timestamp()
            }
        }
    }
    
    private func showIsADuplicate(newShow: Show) -> Bool {
        for show in localDataController.showArray {
            if show.band == newShow.band && show.venue == newShow.venue && show.date == newShow.date {
                return true
            }
        }
        return false
    }
}




//MARK: TableView
extension ImportShowsViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if unprocessedDataButton.state == .on {
            return rawShowDataController.rawShowsArray.count
        } else if processedShowsButton.state == .on {
            return showsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if unprocessedDataButton.state == .on {
            
            let show = rawShowDataController.rawShowsArray[row]
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = "\(row + 1): \(show.venue) | \(show.band) | \(show.dateString)"
                
                return cell
            }
        } else if processedShowsButton.state == .on {
            let show = showsArray[row]
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = "\(row + 1): \(show.venue) | \(show.band) | \(show.dateString)"
                
                return cell
            }
        }
        return nil
    }
    
}

