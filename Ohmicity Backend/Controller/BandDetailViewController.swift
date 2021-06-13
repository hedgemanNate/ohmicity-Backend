//
//  BandDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa

class BandDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //Properties
    var currentBand: Band?
    var shows: [Show] = []
    @IBOutlet weak var tableView: NSTableView!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var bandMediaLinkTextField: NSTextField!
    
    //Buttons
    @IBOutlet weak var rockButton: NSButton!
    @IBOutlet weak var bluesButton: NSButton!
    @IBOutlet weak var jazzButton: NSButton!
    @IBOutlet weak var danceButton: NSButton!
    @IBOutlet weak var reggaeButton: NSButton!
    @IBOutlet weak var countryButton: NSButton!
    @IBOutlet weak var funkButton: NSButton!
    @IBOutlet weak var edmButton: NSButton!
    @IBOutlet weak var hiphopButton: NSButton!
    @IBOutlet weak var djButton: NSButton!
    var genreButtonArray: [NSButton] = []
    
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBOutlet weak var ohmPickButton: NSButtonCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        updateViews()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: Buttons Tapped Functions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkCurrentObject { [self] in
            currentBand?.name = bandNameTextField.stringValue
            currentBand?.mediaLink = bandMediaLinkTextField.stringValue
            addAndRemoveBandType(band: currentBand!)
            localDataController.saveBandData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
        } ifNil: { [self] in
            let newBand = Band(name: bandNameTextField.stringValue, mediaLink: bandMediaLinkTextField.stringValue, ohmPick: ohmPickButton.state)
            addAndRemoveBandType(band: newBand)
            localDataController.bandArray.append(newBand)
            localDataController.saveBandData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
        }

    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        localDataController.bandArray.removeAll(where: {$0 == currentBand})
        localDataController.saveBandData()
        notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
    }
    
    @IBAction func loadPictureButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: UpdateViews
    private func updateViews() {
        genreButtonSetup()
        showArraySetup()
        reloadTableView()
        fillData()
        
        checkCurrentObject { [self] in
            deleteButton.isEnabled = true
        } ifNil: { [self] in
            deleteButton.isEnabled = false
        }

    }
    
}

//MARK: Helper Functions
extension BandDetailViewController {
    
    private func genreButtonSetup() {
        genreButtonArray = [
            rockButton, bluesButton,
            jazzButton, danceButton,
            reggaeButton, countryButton,
            funkButton, edmButton,
            hiphopButton, djButton
        ]
        
        guard let currentBand = currentBand else {
            return
        }
        
        for genre in currentBand.genre {
            switch genre {
            case .rock:
                rockButton.state = .on
            case .blues:
                bluesButton.state = .on
            case .jazz:
                jazzButton.state = .on
            case .dance:
                danceButton.state = .on
            case .reggae:
                reggaeButton.state = .on
            case .country:
                countryButton.state = .on
            case .funkSoul:
                funkButton.state = .on
            case .edm:
                edmButton.state = .on
            case .hiphop:
                hiphopButton.state = .on
            case .dj:
                djButton.state = .on
            }
        }
    }
    
    private func addAndRemoveBandType(band: Band) {
        var genreNumber = 1
        
        for button in genreButtonArray {
            band.addAndRemoveGenreType(button: button, genreNumber: genreNumber)
            genreNumber += 1
            print("genre added")
        }
    }
    
    private func showArraySetup() {
        checkCurrentObject { [self] in
            shows = localDataController.showArray.filter({$0.band == currentBand!.name})
        } ifNil: {
            return
        }

        
    }
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func fillData() {
        checkCurrentObject() { [self] in
            bandNameTextField.stringValue = currentBand!.name
            bandMediaLinkTextField.stringValue = currentBand!.mediaLink ?? "No Link"
            for genre in currentBand!.genre {
                switch genre {
                case .rock:
                    genreButtonArray[0].state = .on
                case .blues:
                    genreButtonArray[1].state = .on
                case .jazz:
                    genreButtonArray[2].state = .on
                case .dance:
                    genreButtonArray[3].state = .on
                case .reggae:
                    genreButtonArray[4].state = .on
                case .country:
                    genreButtonArray[5].state = .on
                case .funkSoul:
                    genreButtonArray[6].state = .on
                case .edm:
                    genreButtonArray[7].state = .on
                case .hiphop:
                    genreButtonArray[8].state = .on
                case .dj:
                    genreButtonArray[9].state = .on
                }
            }
        } ifNil: {
            return
        }
    }
    
    private func checkCurrentObject(completion1: @escaping () -> Void, ifNil: @escaping () -> Void) {
        if currentBand != nil {
            completion1()
        } else {
            ifNil()
        }
    }
    
}

//MARK: Table
extension BandDetailViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Band") {
            let bandIdentifier = NSUserInterfaceItemIdentifier("BandCell")
            guard let cellView = tableView.makeView(withIdentifier: bandIdentifier, owner: self) as? NSTableCellView else {return nil}
            cellView.textField?.stringValue = shows[row].band
            return cellView
            
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Time") {
            let showTimeIdentifier = NSUserInterfaceItemIdentifier("TimeCell")
            guard let cellView = tableView.makeView(withIdentifier: showTimeIdentifier, owner: self) as? NSTableCellView else {return nil}
            let showTime = shows[row].dateString.replacingOccurrences(of: "\n", with: " ")
            cellView.textField?.stringValue = showTime
            return cellView
            
        }
        return nil
    }
}
