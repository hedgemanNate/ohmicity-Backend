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
    var currentBand: Band? {
        didSet {
            updateViews()
        }
    }
    
    var selectedBand: Band {
        let tempBand = filteredBandArray[bandsTableView.selectedRow]
        return tempBand
    }
    
    //Arrays
    var showsArray = [Show]() {
        didSet {
            showsTableView.reloadData()
        }
    }
    
    var filteredBandArray = [Band]() {
        didSet {
            bandsTableView.reloadData()
        }
    }
    var genreButtonArray: [NSButton] = []
    
    var image: NSImage?
    var imageData: Data?
    
    var timer = Timer()
    
    //TableViews
    @IBOutlet weak var bandsTableView: NSTableView!
    @IBOutlet weak var showsTableView: NSTableView!
    @IBOutlet weak var tagsTableView: NSTableView!
    
    
    //Views
    @IBOutlet weak var logoImageView: NSImageView!
    @IBOutlet weak var buttonBoxView: NSBox!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var bandMediaLinkTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSSearchField!
    @IBOutlet weak var alertTextField: NSTextField!
    
    
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
    @IBOutlet weak var latinButton: NSButton!
    @IBOutlet weak var worldButton: NSButton!
    @IBOutlet weak var folkButton: NSButton!
    @IBOutlet weak var americanaButton: NSButton!
    @IBOutlet weak var classicRockButton: NSButton!
    @IBOutlet weak var classicalButton: NSButton!
    
    //Buttons
    @IBOutlet weak var pushBandButton: NSButton!
    @IBOutlet weak var saveBandButton: NSButton!
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var ohmPickButton: NSButton!
    @IBOutlet weak var capitalize: NSButton!
    @IBOutlet weak var makeSelectedTag: NSButton!
    @IBOutlet weak var addTag: NSButton!
    @IBOutlet weak var deleteTag: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var copyAllBandsFromRemote: NSButton!
    @IBOutlet weak var copySelectedBandFromRemote: NSButton!
    @IBOutlet weak var backupSafetySwitch: NSButton!
    @IBOutlet weak var saveBackupButton: NSButton!
    @IBOutlet weak var loadBackupButton: NSButton!
    @IBOutlet weak var filterDropDownButton: NSPopUpButton!
    
    
    
    //Labels
    @IBOutlet weak var lastUpdatedLabel: NSTextField!
    @IBOutlet weak var bandIDLabel: NSTextField!
    
    @IBOutlet weak var newButton: NSButton!
    @IBOutlet weak var localButton: NSButton!
    @IBOutlet weak var remoteButton: NSButton!
    
    
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 810)
        initialLoading()
        
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    //MARK: UpdateViews
    private func updateViews() {
        showsTableView.reloadData()
        tagsTableView.reloadData()
        
        fillData()
        showArraySetup()
        
        logoImageView.imageAlignment = .alignCenter
        logoImageView.imageScaling = .scaleProportionallyDown
        
        
        checkCurrentObject { [self] in
            if currentBand?.ohmPick == true {
                ohmPickButton.state = .on
            }
            
            if currentBand!.photo != nil {
                imageData = currentBand?.photo
                image = NSImage(data: imageData! as Data)
                logoImageView.image = image
            } else {
                logoImageView.image = .none
            }
            
            dateFormatter.dateFormat = dateFormat4
            guard let lastDate = currentBand?.lastModified.dateValue() else {return NSLog("No lastModified for \(currentBand?.name ?? "This Band")")}
            
            lastUpdatedLabel.stringValue = "\(dateFormatter.string(from: lastDate))"
            
        } ifNil: {
            //DO NOTHING
        }
    }
    
    private func initialLoading() {
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
        localButton.state = .on
        filteredBandArray = localDataController.bandArray.sorted(by: {$0.name < $1.name})
        getRemoteBandData()
        bandsTableView.doubleAction = #selector(loadInBand)
        bandsTableView.dataSource = self
        bandsTableView.delegate = self
        showsTableView.dataSource = self
        showsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.delegate = self
        fillGenreButtonArray()
        filteredBandArray = localDataController.bandArray.sorted(by: {$0.name < $1.name})
        
    }
    
    private func fillGenreButtonArray() {
        genreButtonArray = [
            rockButton,
            bluesButton,
            jazzButton,
            danceButton,
            reggaeButton,
            countryButton,
            funkButton,
            edmButton,
            hiphopButton,
            djButton,
            popButton,
            easyListeningButton,
            gospelButton,
            jamBandButton,
            experimentalButton,
            metalButton,
            latinButton,
            worldButton,
            folkButton,
            americanaButton,
            classicRockButton,
            classicalButton,
            ohmPickButton
        ]
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
    
    
    //MARK: Band  Detail Buttons Functions
    @IBAction func capitalizeButtonTapped(_ sender: Any) {
        let oldName = bandNameTextField.stringValue
        let lowerName = oldName.lowercased()
        let finalName = lowerName.capitalized
        
        bandNameTextField.stringValue = finalName
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkCurrentObject { [self] in
            if localDataController.bandArray.contains(currentBand!) {
                //Update Shows For Band
                let oldBandName = currentBand?.name
                let newBandName = bandNameTextField.stringValue
                
                
                if oldBandName != newBandName {
                    currentBand?.name = newBandName
                    for var show in localDataController.showArray {
                        if show.band == oldBandName {
                            show.band = newBandName
                            
                            localDataController.showArray.removeAll(where: {$0 == show})
                            show.lastModified = Timestamp()
                            localDataController.showArray.append(show)
                        }
                    }
                    localDataController.saveShowData()
                }
                
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
                buttonIndication(color: .orange)
                return
            }
            
            let newTag = BandTag(band: newBand)
            currentBand = newBand
            localDataController.bandArray.append(newBand)
            tagController.bandTags.append(newTag)
            localDataController.saveBandData()
            localDataController.saveBandTagData()
            notificationCenter.post(name: NSNotification.Name("bandsUpdated"), object: nil)
            buttonIndication(color: .green)
        }

    }
    
    @IBAction func goToLinkButtonTapped(_ sender: Any) {
        if bandMediaLinkTextField.stringValue != "" {
            let url = URL(string: "\(bandMediaLinkTextField.stringValue)")!
            NSWorkspace.shared.open(url)
        } else {
            alertTextField.stringValue = "Band has no media link".capitalized
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
    
    @IBAction func deleteLoadedButtonTapped(_ sender: Any) {
        guard let currentBand = currentBand else {return}
        checkCurrentObject {
            localDataController.bandArray.removeAll(where: {$0 == self.currentBand})
            self.currentBand = nil
            self.updateViews()
            self.alertTextField.stringValue = "\(currentBand.name) Deleted"
            localDataController.saveBandData()
        } ifNil: {
            self.alertTextField.stringValue = "COULD NOT DELETE BECAUSE NO BAND IS LOADED"
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
    
    //MARK: Tag Buttons Functions
    @IBAction func makeTagButtonTapped(_ sender: Any) {
        guard let currentBand = currentBand else {return}
        let newTag = BandTag(band: currentBand)
        tagController.bandTags.append(newTag)
        localDataController.saveBandTagData()
        tagsTableView.reloadData()
    }
    
    
    @IBAction func addTagButtonTapped(_ sender: Any) {
        let tag = tagController.bandTags.first(where: {$0.bandID == selectedBand.bandID})
        tag?.variations.append(bandNameTextField.stringValue)
        tagsTableView.reloadData()
        localDataController.saveBandTagData()
    }
    
    @IBAction func deleteTagButtonTapped(_ sender: Any) {
        let tag = tagController.bandTags.first(where: {$0.bandID == selectedBand.bandID})
        let selectedVariation = tag?.variations[tagsTableView.selectedRow]
        guard let index = tag?.variations.firstIndex(where: {$0 == selectedVariation}) else {return}
        tag?.variations.remove(at: index)
        tagsTableView.reloadData()
        //localDataController.saveBandTagData()
    }
    
    
    //MARK: Band List Buttons Functions
    @IBAction func makeSelectedButtonTapped(_ sender: Any) {
        if bandsTableView.numberOfSelectedRows == 0 {return}
        let tempBand = selectedBand
        guard let currentBand = currentBand else { return }
        
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Are You Sure?"
        alert.addButton(withTitle: "Yes. Do it.")
        alert.addButton(withTitle: "Cancel")
        alert.informativeText = "Make \(tempBand.name) a TAG for \(currentBand.name) and delete \(tempBand.name) from band list?"
        let res = alert.runModal()
        
        //Adds functionality to the first button (Yes. Do it")
        if res == .alertFirstButtonReturn {
            makeBandATag()
        }
    }
    
    @IBAction func removeBandDoubleButtonTapped(_ sender: Any) {
        var newDuplicatedBands = [Band]()
        //Finds exactly spelled double bands
        for band1 in localDataController.bandArray {
            for band2 in localDataController.bandArray {
                if band1.name == band2.name && band1.lastModified.seconds < band2.lastModified.seconds {
                    newDuplicatedBands.append(band1)
                }
            }
        }
        
        for band1 in newDuplicatedBands {
            localDataController.bandArray.removeAll(where: {$0.bandID == band1.bandID})
            localDataController.bandArray.append(band1)
        }
        filteredBandArray = localDataController.bandArray
    }
    
    
    @IBAction func deleteSelectedBand(_ sender: Any) {
        let tempBand = selectedBand
        if remoteButton.state == .on {
//            remoteDataController.remoteBandArray.removeAll(where: {$0 == tempBand})
//            filteredBandArray.removeAll(where: {$0 == tempBand})
            
            let remoteIndex = remoteDataController.remoteBandArray.firstIndex(of: tempBand)
            guard let remoteIndex = remoteIndex else {return}
            
            let filteredIndex = filteredBandArray.firstIndex(of: tempBand)
            guard let filteredIndex = filteredIndex else {return}
            
            remoteDataController.remoteBandArray.remove(at: remoteIndex)
            filteredBandArray.remove(at: filteredIndex)


            ref.bandDataPath.document(tempBand.bandID).delete { err in
                if let err = err {
                    self.alertTextField.stringValue = "\(err.localizedDescription)"
                } else {
                    self.alertTextField.stringValue = "\(tempBand.name) was deleted from the database."
                }
            }
        } else {
            //localDataController.bandArray.removeAll(where: {$0 == tempBand})
            //filteredBandArray.removeAll(where: {$0 == tempBand})
            
            let filteredIndex = filteredBandArray.firstIndex(of: tempBand)
            guard let filteredIndex = filteredIndex else {return}
            
            let localIndex = localDataController.bandArray.firstIndex(of: tempBand)
            guard let localIndex = localIndex else {return}
            
            localDataController.bandArray.remove(at: localIndex)
            filteredBandArray.remove(at: filteredIndex)
            
            self.alertTextField.stringValue = "\(tempBand.name) deleted"
            localDataController.saveBandData()
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        switch filterDropDownButton.indexOfSelectedItem {
        case 0:
            filteredBandArray = localDataController.bandArray.filter({$0.photo != nil})
            
        case 1:
            filteredBandArray = localDataController.bandArray.filter({$0.photo == nil})
            
        case 2: filteredBandArray = localDataController.bandArray.filter({$0.ohmPick == true})
        
        default:
            break
        }
    }
    
    @IBAction func clearFilterButtonTapped(_ sender: Any) {
        filteredBandArray = localDataController.bandArray
    }
    
    
    
    
    @IBAction func copySelectedBandFromRemoteButtonTapped(_ sender: Any) {
        if remoteButton.state == .on {
            let tempBand = selectedBand
            localDataController.bandArray.removeAll(where: {$0 == tempBand})
            filteredBandArray.removeAll(where: {$0 == tempBand})
            
            localDataController.bandArray.append(tempBand)
            filteredBandArray.append(tempBand)
            alertTextField.stringValue = "Bands Copied From Remote"
            localDataController.saveBandData()
            
        } else {
            alertTextField.stringValue = "Switch to remote data before copying"
        }
    }
    
    @IBAction func copyAllBandsFromRemoteButtonTapped(_ sender: Any) {
        if remoteButton.state == .on {
            localDataController.bandArray = remoteDataController.remoteBandArray
            filteredBandArray = localDataController.bandArray
            alertTextField.stringValue = "Bands Copied From Remote"
            localDataController.saveBandData()
        } else {
            alertTextField.stringValue = "Switch to remote data before copying"
        }
    }
    
    //MARK: Band Data Backup Functions
    @IBAction func backupSafetySwitch(_ sender: Any) {
        switch backupSafetySwitch.state {
        case .off:
            saveBackupButton.isEnabled = false
            loadBackupButton.isEnabled = false
        case .on:
            saveBackupButton.isEnabled = true
            loadBackupButton.isEnabled = true
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [self] in
            backupSafetySwitch.state = .off
            saveBackupButton.isEnabled = false
            loadBackupButton.isEnabled = false
        }
    }
    
    @IBAction func saveBackupButtonTapped(_ sender: Any) {
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
        localDataController.saveBackupBandData()
        alertTextField.stringValue = "Band Data Backup Saved"
    }
    
    @IBAction func loadBackupButtonTapped(_ sender: Any) {
        backupSafetySwitch.state = .off
        saveBackupButton.isEnabled = false
        loadBackupButton.isEnabled = false
        localDataController.loadBackupBandData()
        alertTextField.stringValue = "Band Data Backup Loaded"
        filteredBandArray = localDataController.bandArray
    }
    
    
    
    //MARK: Radio Buttons
    
    @IBAction func radioButtonsChanged(_ sender: Any) {
        if newButton.state == .on {
            if searchTextField.stringValue == "" {
                filteredBandArray = localDataController.bandArray.sorted(by: {$0.lastModified.seconds < $1.lastModified.seconds})
            } else {
                filteredBandArray = localDataController.bandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
            
            
        } else if localButton.state == .on {
            if searchTextField.stringValue == "" {
                filteredBandArray = localDataController.bandArray.sorted(by: {$0.name < $1.name})
            } else {
                filteredBandArray = localDataController.bandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
            
            
        } else if remoteButton.state == .on {
            filteredBandArray = remoteDataController.remoteBandArray
            if searchTextField.stringValue == "" {
                filteredBandArray = remoteDataController.remoteBandArray
            } else {
                filteredBandArray = filteredBandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
        }
    }
    
    //MARK: Search TextField
    @IBAction func searchingTextField(_ sender: Any) {
        if localButton.state == .on {
            if searchTextField.stringValue == "" {
                filteredBandArray = localDataController.bandArray.sorted(by: {$0.name < $1.name})
            } else {
                filteredBandArray = localDataController.bandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
        } else if remoteButton.state == .on {
            if searchTextField.stringValue == "" {
                filteredBandArray = remoteDataController.remoteBandArray
            } else {
                filteredBandArray = remoteDataController.remoteBandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
        } else if newButton.state == .on {
            if searchTextField.stringValue == "" {
                filteredBandArray = localDataController.bandArray.sorted(by: {$0.lastModified.seconds < $1.lastModified.seconds})
            } else {
                filteredBandArray = localDataController.bandArray.filter({$0.name.localizedCaseInsensitiveContains(searchTextField.stringValue)})
            }
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
    //Not Connected
    @IBAction func latinButtonTapped(_ sender: Any) {
        if latinButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    @IBAction func worldButtonTapped(_ sender: Any) {
        if worldButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    @IBAction func folkButtonTapped(_ sender: Any) {
        if folkButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    @IBAction func americanaButtonTapped(_ sender: Any) {
        if americanaButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    @IBAction func classicRockButtonTapped(_ sender: Any) {
        if classicRockButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    @IBAction func classicalButtonTapped(_ sender: Any) {
        if classicalButton.state == .on {
            //currentBand?.genre.append(Genre.JamBand)
        } else {
            //currentBand?.genre.removeAll(where: {$0 == Genre.JamBand})
        }
    }
    
}

//MARK: Helper Functions
extension BandDetailViewController {
    
    private func showArraySetup() {
        checkCurrentObject { [self] in
            showsArray = localDataController.showArray.filter({$0.band == currentBand!.bandID})
            showsTableView.reloadData()
        } ifNil: {
            return
        }
    }
    
    private func reloadTableViews() {
        DispatchQueue.main.async {
            self.showsTableView.reloadData()
            self.tagsTableView.reloadData()
        }
    }
    
    @objc private func loadInBand() {
        currentBand = selectedBand
        showsArray = localDataController.showArray.filter({$0.band == selectedBand.name})
        updateViews()
    }
    
    private func makeBandATag() {
        let tempBand = selectedBand
        guard let currentBand = currentBand else { return }
        guard let currentBandTags = tagController.bandTags.first(where: {$0.bandID == currentBand.bandID}) else { return }
        currentBandTags.variations.append(tempBand.name)
        
        localDataController.bandArray.removeAll(where: {$0.bandID == tempBand.bandID})
        filteredBandArray.removeAll(where: {$0.bandID == tempBand.bandID})
        tagController.bandTags.removeAll(where: {$0.bandID == tempBand.bandID})
        tagsTableView.reloadData()
        bandsTableView.reloadData()
        
        localDataController.saveBandData()
        localDataController.saveBandTagData()
        
    }
    
    private func fillData() {
        for genre in genreButtonArray {
            genre.state = .off
        }
        
        checkCurrentObject() { [self] in
            bandNameTextField.stringValue = currentBand!.name
            bandMediaLinkTextField.stringValue = currentBand!.mediaLink ?? ""
            bandIDLabel.stringValue = currentBand!.bandID
            
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
                    /*
                    case .latin:
                        latinButton.state = .on
                    case .world:
                        worldButton.state = .on
                    case .folk:
                        folkButton.state = .on
                    case .americana:
                        americanaButton.state = .on
                    case classicRock:
                        classicRockButton.state = .on
                    case classical:
                        classicalButton.state = .on
                    */
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


//MARK: Database Functions
extension BandDetailViewController {
    private func getRemoteBandData() {
        print("Running Remote Band")
        FireStoreReferenceManager.bandDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                self.alertTextField.stringValue = "Error getting bandData: \(err)"
            } else {
                self.alertTextField.stringValue = "Got band data"
                remoteDataController.remoteBandArray = []
                for band in querySnapshot!.documents {
                    let result = Result {
                        try band.data(as: Band.self)
                    }
                    switch result {
                    case .success(let band):
                        if let band = band {
                            remoteDataController.remoteBandArray.append(band)
                        }
                    case .failure(let error):
                        print("Error decoding band: \(error.localizedDescription)")
                        self.alertTextField.stringValue = "Failed to get band data"
                    }
                }
                
                let band = remoteDataController.remoteBandArray.sorted(by: {$0.name < $1.name})
                remoteDataController.remoteBandArray = band
            }
        }
    }
}

//MARK: Tableview
extension BandDetailViewController {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case showsTableView:
            return showsArray.count
            
        case bandsTableView:
            return filteredBandArray.count
            
        case tagsTableView:
            return tagController.bandTags.first(where: {$0.bandID == currentBand?.bandID})?.variations.count ?? 0
        
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case showsTableView:
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Venue") {
                guard let venue = localDataController.businessArray.first(where: {$0.venueID == showsArray[row].venue}) else {return NSTableCellView()}
                
                let venueIdentifier = NSUserInterfaceItemIdentifier("VenueCell")
                guard let cell = tableView.makeView(withIdentifier: venueIdentifier, owner: self) as? NSTableCellView else {return nil}
                cell.textField?.stringValue = venue.name
                return cell
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "Time") {
                let showTimeIdentifier = NSUserInterfaceItemIdentifier("TimeCell")
                guard let cell = tableView.makeView(withIdentifier: showTimeIdentifier, owner: self) as? NSTableCellView else {return nil}
                let showTime = showsArray[row].dateString
                cell.textField?.stringValue = showTime
                return cell
            }
            return nil
            
        case bandsTableView:
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "OhmColumn") {
                let ohmColumnIdentifier = NSUserInterfaceItemIdentifier("OhmCell")
                guard let cell = tableView.makeView(withIdentifier: ohmColumnIdentifier, owner: self) as? NSTableCellView else {return nil}
                
                if filteredBandArray[row].ohmPick == true { cell.textField?.stringValue = "Xity Pick" } else { cell.textField?.stringValue = "" }
                cell.textField?.textColor = .purple
                return cell
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "BandNameColumn") {
                let bandNameCellIdentifier = NSUserInterfaceItemIdentifier("BandNameCell")
                guard let cell = tableView.makeView(withIdentifier: bandNameCellIdentifier, owner: self) as? NSTableCellView else {return nil}
                
                cell.textField?.stringValue = filteredBandArray[row].name
                cell.textField?.textColor = .white
                if filteredBandArray[row].photo != nil { cell.textField?.textColor = .orange}
                cell.prepareForReuse()
                return cell
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "BandIDColumn") {
                let bandIDCellIdentifier = NSUserInterfaceItemIdentifier("BandIDCell")
                guard let cell = tableView.makeView(withIdentifier: bandIDCellIdentifier, owner: self) as? NSTableCellView else {return nil}
                
                cell.textField?.stringValue = filteredBandArray[row].bandID
                return cell
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "NumberColumn") {
                let bandNumberCellIdentifier = NSUserInterfaceItemIdentifier("BandNumberCell")
                guard let cell = tableView.makeView(withIdentifier: bandNumberCellIdentifier, owner: self) as? NSTableCellView else {return nil}
                
                cell.textField?.stringValue = "\(row + 1)"
                cell.textField?.textColor = .white
                if filteredBandArray[row].photo != nil { cell.textField?.textColor = .orange}
                if filteredBandArray[row].ohmPick == true { cell.textField?.textColor = .purple}
                cell.prepareForReuse()
                return cell
                
            }
            return nil
            
        case tagsTableView:
            let tagCell = NSUserInterfaceItemIdentifier("TagCell")
            guard let cell = tableView.makeView(withIdentifier: tagCell, owner: self) as? NSTableCellView else {return nil}
            cell.textField?.stringValue = tagController.bandTags.first(where: {$0.bandID == currentBand?.bandID})?.variations[row] ?? "No Variations Found"
            return cell
        default:
            return nil
        }
    }
}
