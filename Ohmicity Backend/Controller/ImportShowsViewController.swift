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
    //Array
    var showsArray = [Show]() {didSet{showsTableView.reloadData()}}
    var badTagArray = [String]() {didSet{showsTableView.reloadData()}}
    
    //Table Views
    @IBOutlet weak var showsTableView: NSTableView!
    
    @IBOutlet weak var messageTextField: NSTextField!
    
    
    //Labels
    @IBOutlet weak var numberOfNewShowsLabel: NSTextField!
    
    //Buttons
    @IBOutlet weak var unprocessedDataButton: NSButton!
    @IBOutlet weak var processedShowsButton: NSButton!
    @IBOutlet weak var badTagButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        showsTableView.dataSource = self
        showsTableView.delegate = self
        updateViews()
    }
    
    //MARK: Update Views
    private func updateViews() {
        showsTableView.reloadData()
        if unprocessedDataButton.state == .on {
            numberOfNewShowsLabel.stringValue = String(RawShowDataController.rawShowsArray.count)
        } else if processedShowsButton.state == .on {
            showsArray = RemoteDataController.showArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
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
                RawShowDataController.path = url
                RawShowDataController.loadShowsPath {
                    //LocalDataStorageController.saveJsonData()
                }
            }
            LocalDataStorageController.saverJsonData()
            DispatchQueue.main.async {
                self.showsTableView.reloadData()
                self.numberOfNewShowsLabel.stringValue = "\(RawShowDataController.rawShowsArray.count)"
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        RawShowDataController.rawShowsArray = []
        showsTableView.reloadData()
    }
    
    @IBAction func assignButtonTapped(_ sender: Any) {
        var noBandIDTag = 0
        var numberOfDuplicates = 0
        var noVenueIDTag = 0
        var badTag = 0
        var totalRejected = 0
        
        for rawShow in RawShowDataController.rawShowsArray {
            var venueID = ""
            var bandID = ""
            
            //Replace this line with *1* when venue tags are ready
            venueID = LocalDataStorageController.venueArray.first(where: {$0.name == rawShow.venue})?.venueID ?? "none"
            //
            
            if venueID == "none" {
                noVenueIDTag += 1
                print("\(noVenueIDTag): \(rawShow.venue) has no TAG")
                continue
            }
            
            
            //*1* Same code for venue tags above
            bandID = assignBandTagID(rawShow: rawShow)
            //
            
            if !RemoteDataController.bandArray.contains(where: {$0.bandID == bandID}) {
                badTag += 1
                print("\(badTag): \(rawShow.band) has a BAD TAG")
                badTagArray.append(bandID)
                continue
            }
            
            if bandID == "none" || bandID == "41639FC5-11B6-44D9-8EB3-2D5189E27C10" /*Trash Shows*/ {
                noBandIDTag += 1
                print("\(noBandIDTag): \(rawShow.band) has no TAG")
                continue
            }
            
            let newShow = Show(band: bandID, venue: venueID, dateString: rawShow.dateString, displayName: rawShow.band)
            guard let newShow = newShow else {continue}
            
            if showIsADuplicate(newShow: newShow) {
                numberOfDuplicates += 1
                print("\(numberOfDuplicates): \(rawShow.venue) \(rawShow.dateString) is a duplicate")
                continue
            }
            
            if newShow.date < Date() {continue}
            
            
            
            checkIfShowHasBeenUpdated(newShow: newShow)
            
            //Do on database
            do {
                try workRef.showDataPath.document(newShow.showID).setData(from: newShow) { err in
                    if let err = err {
                        self.messageTextField.stringValue = err.localizedDescription
                    }
                    RemoteDataController.showArray.append(newShow)
                    RawShowDataController.rawShowsArray.removeAll(where: {$0 == rawShow})
                    self.updateViews()
                }
            } catch let error {
                messageTextField.stringValue = error.localizedDescription
            }
        }
        totalRejected = noBandIDTag + noVenueIDTag + numberOfDuplicates + badTag
        
        messageTextField.stringValue = "Total Number Rejected: \(totalRejected)"
        
    }
    
    @IBAction func removeDoubleBookedShowsButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            checkIfShowHasBeenUpdated(newShow: show)
        }
    }
    
    //MARK: Radio Buttons
    @IBAction func tableViewRadioButtonsTapped(_ sender: Any) {
        if unprocessedDataButton.state == .on {
            numberOfNewShowsLabel.stringValue = String(RawShowDataController.rawShowsArray.count)
        } else if processedShowsButton.state == .on {
            showsArray = RemoteDataController.showArray.sorted(by: {$0.lastModified.seconds > $1.lastModified.seconds})
            numberOfNewShowsLabel.stringValue = String(showsArray.count)
        } else if badTagButton.state == .on {
            badTagArray.removeAll(where: {$0 == "none"})
            numberOfNewShowsLabel.stringValue = String(badTagArray.count)
        }
        
        showsTableView.reloadData()
    }
    
}


//MARK: Functions
extension ImportShowsViewController {
    
    private func assignBandTagID(rawShow: ShowData) -> String {
        var bandID = "none"
        
        for tag in TagController.bandTags {
            for variation in tag.variations {
                if rawShow.band.lowercased() == variation.lowercased() {
                    bandID = tag.bandID
                } else {
                    
                }
            }
        }
        
        return bandID
    }
    
    private func checkIfShowHasBeenUpdated(newShow: Show) {
        let venueArray = RemoteDataController.showArray.filter({$0.venue == newShow.venue})
        
        for show in venueArray {
            let hours = newShow.date.timeIntervalSince(show.date)
            let timeSpan = -7200.0...7200.0
            if timeSpan.contains(hours) {
                guard let index = RemoteDataController.showArray.firstIndex(where: {$0 == show}) else {return}
                var changedShow = RemoteDataController.showArray[index]
                
                workRef.showDataPath.document(show.showID).updateData(["onHold" : true, "lastModified" : Timestamp()]) { err in
                    if let err = err {
                        self.messageTextField.stringValue = err.localizedDescription
                    } else {
                        changedShow.onHold = true
                        changedShow.lastModified = Timestamp()
                        RemoteDataController.showArray.remove(at: index)
                        RemoteDataController.showArray.append(changedShow)
                    }
                }
            }
        }
    }
    
    private func showIsADuplicate(newShow: Show) -> Bool {
        for show in RemoteDataController.showArray {
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
            return RawShowDataController.rawShowsArray.count
        } else if processedShowsButton.state == .on {
            return showsArray.count
        } else if badTagButton.state == .on {
            return badTagArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if unprocessedDataButton.state == .on {
            
            let show = RawShowDataController.rawShowsArray[row]
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = "\(row + 1): \(show.venue) | \(show.band) | \(show.dateString)"
                
                return cell
            }
        } else if processedShowsButton.state == .on {
            let show = showsArray[row]
            guard let venue = LocalDataStorageController.venueArray.first(where: {$0.venueID == show.venue}) else {return nil}
            guard let band = RemoteDataController.bandArray.first(where: {$0.bandID == show.band}) else {return nil}
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = "\(row + 1): \(venue.name) | \(band.name) | \(show.dateString)"
                
                return cell
            }
        } else if badTagButton.state == .on {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("RawShowCell"), owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = "\(row + 1): \(badTagArray[row])"
                
                return cell
            }
        }
        return nil
    }
    
}

