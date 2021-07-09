//
//  BandDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa
import FirebaseFirestore

class BandDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //Properties
    var currentBand: Band?
    var shows: [Show] = []
    var image: NSImage?
    var imageData: Data?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var logoImageView: NSImageView!
    
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
    @IBOutlet weak var popButton: NSButton!
    @IBOutlet weak var metalButton: NSButton!
    
    
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
            currentBand?.photo = imageData
            if ohmPickButton.state == .on {
                currentBand?.ohmPick = true
            } else {
                currentBand?.ohmPick = false
            }
            
            if localDataController.bandArray.contains(currentBand!) == false {
                localDataController.bandArray.append(currentBand!)
            }
            
            currentBand?.lastModified = Timestamp()
            
            localDataController.saveBandData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
            
        } ifNil: { [self] in
            let newBand = Band(name: bandNameTextField.stringValue, mediaLink: bandMediaLinkTextField.stringValue, ohmPick: ohmPickButton.state)
            newBand.photo = imageData
            newBand.lastModified = Timestamp()
            localDataController.bandArray.append(newBand)
            localDataController.saveBandData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
        }

    }
    
    @IBAction func pushhButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.bandDataPath
        currentBand?.lastModified = Timestamp()
        do {
            try ref.document(currentBand!.bandID).setData(from: currentBand)
            print("Maybe a good push to database: Wait for error")
        } catch let error {
                NSLog(error.localizedDescription)
        }
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        localDataController.bandArray.removeAll(where: {$0 == currentBand})
        localDataController.saveBandData()
        notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
    }
    
    @IBAction func loadPictureButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["png", "jpeg", "jpg", "tiff", "webp"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            image = imageController.addBusinessImage(file: result!)
            logoImageView.image = image
            
            let imageData = NSData(contentsOf: result!)
            self.imageData = (imageData! as Data)
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    //MARK: Genre CheckBoxes Tapped
    @IBAction func rockButtonTapped(_ sender: Any) {
        if rockButton.state == .on {
            currentBand?.genre.append(Genre.Rock)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Rock})
        }
    }
    @IBAction func bluesButtonTapped(_ sender: Any) {
        if bluesButton.state == .on {
            currentBand?.genre.append(Genre.Blues)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Blues})
        }
    }
    @IBAction func jazzButtonTapped(_ sender: Any) {
        if jazzButton.state == .on {
            currentBand?.genre.append(Genre.Jazz)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Jazz})
        }
    }
    @IBAction func danceButtonTapped(_ sender: Any) {
        if danceButton.state == .on {
            currentBand?.genre.append(Genre.Dance)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Dance})
        }
    }
    @IBAction func reggaeButtonTapped(_ sender: Any) {
        if reggaeButton.state == .on {
            currentBand?.genre.append(Genre.Reggae)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Reggae})
        }
    }
    @IBAction func countryButtonTapped(_ sender: Any) {
        if countryButton.state == .on {
            currentBand?.genre.append(Genre.Country)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Country})
        }
    }
    @IBAction func funkButtonTapped(_ sender: Any) {
        if funkButton.state == .on {
            currentBand?.genre.append(Genre.FunkSoul)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.FunkSoul})
        }
    }
    @IBAction func edmButtonTapped(_ sender: Any) {
        if edmButton.state == .on {
            currentBand?.genre.append(Genre.EDM)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.EDM})
        }
    }
    @IBAction func hiphopButtonTapped(_ sender: Any) {
        if hiphopButton.state == .on {
            currentBand?.genre.append(Genre.HipHop)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.HipHop})
        }
    }
    @IBAction func djButtonTapped(_ sender: Any) {
        if djButton.state == .on {
            currentBand?.genre.append(Genre.DJ)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.DJ})
        }
    }
    @IBAction func popButtonTapped(_ sender: Any) {
        if popButton.state == .on {
            currentBand?.genre.append(Genre.Pop)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Pop})
        }
    }
    @IBAction func metalButtonTapped(_ sender: Any) {
        if metalButton.state == .on {
            currentBand?.genre.append(Genre.Metal)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Metal})
        }
    }
    
    
    
    //MARK: UpdateViews
    private func updateViews() {
        showArraySetup()
        reloadTableView()
        fillData()
        
        logoImageView.imageAlignment = .alignCenter
        logoImageView.imageScaling = .scaleProportionallyDown
        
        checkCurrentObject { [self] in
            deleteButton.isEnabled = true
            if currentBand?.ohmPick == true {
                ohmPickButton.state = .on
            }
            
            if currentBand!.photo != nil {
                imageData = currentBand?.photo
                image = NSImage(data: imageData! as Data)
                logoImageView.image = image
            }
            
        } ifNil: { [self] in
            deleteButton.isEnabled = false
        }

    }
    
}

//MARK: Helper Functions
extension BandDetailViewController {
    
    
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
            bandMediaLinkTextField.stringValue = currentBand!.mediaLink ?? "This musician doesn have anything for you to listen to..."
            
            if currentBand != nil {
                for genre in currentBand!.genre {
                    switch genre {
                    case .Rock:
                        rockButton.state = .on
                    case .Blues:
                        bluesButton.state = .on
                    case .Jazz:
                        jazzButton.state = .on
                    case .Dance:
                        danceButton.state = .on
                    case .Reggae:
                        reggaeButton.state = .on
                    case .Country:
                        countryButton.state = .on
                    case .FunkSoul:
                        funkButton.state = .on
                    case .EDM:
                        edmButton.state = .on
                    case .HipHop:
                        hiphopButton.state = .on
                    case .DJ:
                        djButton.state = .on
                    case .Pop:
                        popButton.state = .on
                    case .Metal:
                        metalButton.state = .on
                    }
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

//MARK: Tableview
extension BandDetailViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Band") {
            let bandIdentifier = NSUserInterfaceItemIdentifier("BandCell")
            guard let cellView = tableView.makeView(withIdentifier: bandIdentifier, owner: self) as? NSTableCellView else {return nil}
            cellView.textField?.stringValue = shows[row].venue
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
