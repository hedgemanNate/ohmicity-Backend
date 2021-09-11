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
    var genreButtonArray: [NSButton] = []
    
    var image: NSImage?
    var imageData: Data?
    
    var timer = Timer()
    
    //Views
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var logoImageView: NSImageView!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var bandMediaLinkTextField: NSTextField!
    @IBOutlet weak var buttonBoxView: NSBox!
    
    //Genre Buttons
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
    @IBOutlet weak var easyListeningButton: NSButton!
    @IBOutlet weak var gospelButton: NSButton!
    @IBOutlet weak var jamBandButton: NSButton!
    @IBOutlet weak var experimentalButton: NSButton!
    @IBOutlet weak var metalButton: NSButton!
    
    //Buttons
    @IBOutlet weak var pushBandButton: NSButton!
    @IBOutlet weak var saveBandButton: NSButton!
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var ohmPickButton: NSButtonCell!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        updateViews()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    private func buttonIndication(color: NSColor) {
        var counter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { time in
            if counter < 2 {
                DispatchQueue.main.async {
                    self.buttonBoxView.fillColor = color
                }
                counter += 1
            } else if counter == 2{
                DispatchQueue.main.async {
                    self.buttonBoxView.fillColor = .black
                }
                counter = 0
                self.timer.invalidate()
            }
        })
    }
    
    
    //MARK: Buttons Tapped Functions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        
        checkCurrentObject { [self] in
            if localDataController.bandArray.contains(currentBand!) {
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
                buttonIndication(color: .green)
                
            } else {
                localDataController.bandArray.append(currentBand!)
                localDataController.saveBandData()
                notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
                buttonIndication(color: .green)
            }
            
        } ifNil: { [self] in
            let newBand = Band(name: bandNameTextField.stringValue, mediaLink: bandMediaLinkTextField.stringValue, ohmPick: ohmPickButton.state)
            newBand.photo = imageData
            newBand.lastModified = Timestamp()
            
            if localDataController.bandArray.contains(newBand) {
                return
                    buttonIndication(color: .orange)
            }
            
            currentBand = newBand
            localDataController.bandArray.append(newBand)
            localDataController.saveBandData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
            buttonIndication(color: .green)
        }

    }
    
    @IBAction func pushButtonTapped(_ sender: Any) {
        let ref = FireStoreReferenceManager.bandDataPath
        do {
            currentBand?.lastModified = Timestamp()
            try ref.document(currentBand!.bandID).setData(from: currentBand)
            print("Maybe a good push to database: Wait for error")
            buttonIndication(color: .green)
        } catch let error {
                NSLog(error.localizedDescription)
            buttonIndication(color: .red)
        }
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
            image = imageController.addImage(file: result!)
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
    
    @IBAction func experimentalButtonTapped(_ sender: Any) {
        if experimentalButton.state == .on {
            currentBand?.genre.append(Genre.Experimental)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Experimental})
        }
    }
    
    @IBAction func easyListeningButtonTapped(_ sender: Any) {
        if easyListeningButton.state == .on {
            currentBand?.genre.append(Genre.EasyListening)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.EasyListening})
        }
    }
    
    @IBAction func gospelButtonTapped(_ sender: Any) {
        if gospelButton.state == .on {
            currentBand?.genre.append(Genre.Gospel)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.Gospel})
        }
    }
    
    @IBAction func jamBandButtonTapped(_ sender: Any) {
        if jamBandButton.state == .on {
            currentBand?.genre.append(Genre.JamBand)
        } else {
            currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
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
            title = "Edit \(currentBand!.name)"
            if currentBand?.ohmPick == true {
                ohmPickButton.state = .on
            }
            
            if currentBand!.photo != nil {
                imageData = currentBand?.photo
                image = NSImage(data: imageData! as Data)
                logoImageView.image = image
            }
            
        } ifNil: { [self] in
            
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
            bandMediaLinkTextField.stringValue = currentBand!.mediaLink ?? ""
            
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
                    case .Experimental:
                        experimentalButton.state = .on
                    case .JamBand:
                        jamBandButton.state = .on
                    case .Gospel:
                        gospelButton.state = .on
                    case .EasyListening:
                        easyListeningButton.state = .on
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
