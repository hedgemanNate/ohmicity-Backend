//
//  BannerAdsViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 8/26/21.
//

import Cocoa
import FirebaseFirestore
import FirebaseFirestoreSwift

class BannerAdsViewController: NSViewController {
    
    //General Properties
    var currentBannerAd: BusinessBannerAd? {
        didSet {
            clientSelectedInTableView()
        }
    }
    var currentBusiness: Venue? {
        didSet {
            businessSelectedInTableView()
        }
    }
    
    var image: NSImage?
    var bannerAdImageData: Data?
    
    @IBOutlet weak var bannerAdImageView: NSImageView!
    @IBOutlet weak var businessNameTextField: NSTextField!
    @IBOutlet weak var businessIDTextField: NSTextField!
    @IBOutlet weak var adLinkTextField: NSTextField!
    @IBOutlet weak var adIDTextField: NSTextField!
    @IBOutlet weak var promotionalTextField: NSTextField!
    
    @IBOutlet weak var publishedButton: NSButton!
    
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    
    //Table View Properties
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var showAllBusinessesButton: NSButton!
    @IBOutlet weak var showClientsButton: NSButton!
    var businessResultsArray = [Venue]()
    var clientResultsArray = [BusinessBannerAd]()
    var clientFullArray = [BusinessBannerAd]()
    
    //MessageCenter
    @IBOutlet weak var messageCenterTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        updateViews()
    }
    
    @IBAction func breaker(_ sender: Any) {
        
    }
    
    
    //MARK: Button Actions
    @IBAction func tableViewRadioButtonAction(_ sender: Any) {
        if showAllBusinessesButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else if showClientsButton.state == .on {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func loadImageButtonTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["png", "jpeg", "jpg", "tiff"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            image = imageController.addImage(file: result!)
            bannerAdImageView.image = image
            
            let imageData = NSData(contentsOf: result!)
            self.bannerAdImageData = imageData as Data?
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        if bannerAdImageData == nil { messageCenterTextField.stringValue = "Can't Save, No Image Data"; return }
        saveBannerAdToCurrentBannerAd()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteBannerAd()
        clientResultsArray.removeAll(where: {$0 == currentBannerAd})
        clearAd()
        tableView.reloadData()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        clearAd()
    }
    
    //MARK: Functions
    
    
    //MARK: UpdateViews
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
        getBusinessAdData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func clearAd() {
        currentBannerAd = nil
        DispatchQueue.main.async { [self] in
            businessNameTextField.stringValue = ""
            businessIDTextField.stringValue = ""
            adIDTextField.stringValue = ""
            adLinkTextField.stringValue = ""
            promotionalTextField.stringValue = ""
            publishedButton.state = .off
            if #available(macOS 11.0, *) {
                bannerAdImageView.image = NSImage.init(systemSymbolName: "photo", accessibilityDescription: "system photo")
            } else {
                // Fallback on earlier versions
            }
            bannerAdImageData = nil
            messageCenterTextField.stringValue = "Cleared"
        }
    }
    
    private func clientSelectedInTableView() {
        guard let cba = currentBannerAd else {return}
        businessNameTextField.stringValue = cba.businessName
        businessIDTextField.stringValue = cba.businessID ?? ""
        adIDTextField.stringValue = cba.adID
        adLinkTextField.stringValue = cba.adLink
        promotionalTextField.stringValue = cba.promotionalText
        bannerAdImageView.image = NSImage(data: cba.image)
        bannerAdImageData = cba.image
        startDatePicker.dateValue = cba.startDate
        endDatePicker.dateValue = cba.endDate
        if cba.isPublished {
            publishedButton.state = .on
        } else {
            publishedButton.state = .off
        }
    }
    
    private func businessSelectedInTableView() {
        businessNameTextField.stringValue = currentBusiness!.name
        businessIDTextField.stringValue = currentBusiness!.venueID ?? ""
    }
    
    private func saveBannerAdToCurrentBannerAd() {
        if currentBannerAd == nil {
            guard let bannerAdData = bannerAdImageData else { return }
            let cba = BusinessBannerAd(name: businessNameTextField.stringValue, image: bannerAdData, link: adLinkTextField.stringValue, start: startDatePicker.dateValue, finish: endDatePicker.dateValue, text: promotionalTextField.stringValue)
            cba.businessID = businessIDTextField.stringValue
            
            switch publishedButton.state {
            case .on:
                cba.isPublished = true
            case .off:
                cba.isPublished = false
            default:
                break
            }
            pushBusinessAd(cba)
            currentBannerAd = cba
            clientFullArray.append(cba)
            clientFullArray.sort(by: {$0.businessName < $1.businessName})
            clientResultsArray = clientFullArray
            tableView.reloadData()
        } else {
            currentBannerAd?.image = bannerAdImageData!
            currentBannerAd?.promotionalText = promotionalTextField.stringValue
            currentBannerAd?.startDate = startDatePicker.dateValue
            currentBannerAd?.endDate = endDatePicker.dateValue
            currentBannerAd?.adLink = adLinkTextField.stringValue
            
            switch publishedButton.state {
            case .on:
                currentBannerAd!.isPublished = true
            case .off:
                currentBannerAd!.isPublished = false
            default:
                break
            }
            
            pushBusinessAd(currentBannerAd!)
            messageCenterTextField.stringValue = "Banner Ad Updated"
            tableView.reloadData()
        }
    }
    
    @objc private func doubleClicked() {
        if showAllBusinessesButton.state == .on {
            let row = tableView.selectedRow
            if row < 0 {return}
            currentBusiness = LocalBackupDataStorageController.venueArray[row]
        } else {
            let row = tableView.selectedRow
            if row < 0 {return}
            currentBannerAd = clientResultsArray[row]
        }
    }
    
    //MARK: NetworkCalls
    private func getBusinessAdData() {
        ref.businessBannerAdDataPath.getDocuments { querySnapshot, error in
            if let error = error {
                self.messageCenterTextField.stringValue = "\(error.localizedDescription)"
            } else {
                for bannerAd in querySnapshot!.documents {
                    let result = Result {
                        try bannerAd.data(as: BusinessBannerAd.self)
                    }
                    switch result {
                    case .success(let success):
                        if let bannerAd = success {
                            self.clientFullArray.append(bannerAd)
                        } else {
                            self.messageCenterTextField.stringValue = "Banner Ad is not in database"
                        }
                    case .failure(let failure):
                        self.messageCenterTextField.stringValue = "Failed to decode Banner Ad from database: \(failure.localizedDescription)"
                    }
                }
                self.clientResultsArray = self.clientFullArray.sorted(by: {$0.businessName < $1.businessName})
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func pushBusinessAd(_ bannerAd: BusinessBannerAd) {
        do {
            bannerAd.lastModified = Timestamp()
            try ref.businessBannerAdDataPath.document(bannerAd.adID).setData(from: bannerAd)
            messageCenterTextField.stringValue = "Banner Ad Saved"
        } catch let error {
            messageCenterTextField.stringValue = error.localizedDescription
        }
    }
    
    private func deleteBannerAd() {
        if currentBannerAd != nil {
            ref.businessBannerAdDataPath.document(currentBannerAd!.adID).delete()
            messageCenterTextField.stringValue = "Delete Successful"
        } else {
            messageCenterTextField.stringValue = "Delete Failed"
        }
    }
}


//MARK: TableView Protocols/Functions
extension BannerAdsViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.doubleAction = #selector(doubleClicked)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if showAllBusinessesButton.state == .on {
            return LocalBackupDataStorageController.venueArray.count
        } else {
            return clientResultsArray.count
        }
    }
        
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BusinessCell"), owner: nil) as? NSTableCellView {
            
            if showAllBusinessesButton.state == .on {
                cell.textField?.stringValue = LocalBackupDataStorageController.venueArray[row].name
            } else {
                cell.textField?.stringValue = clientResultsArray[row].businessName
            }
            return cell
        }
        return nil
    }
}

