//
//  DatabaseUtilityViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/10/22.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseUtilityViewController: NSViewController {
    
    //Properties
    @IBOutlet weak var messageTextField: NSTextField!
    
    var imageData: Data?
    
    override func viewDidLoad() {
        self.preferredContentSize = NSSize(width: 1320, height: 860)
        super.viewDidLoad()
    }
    
    //MARK: Production Button/Functions
    @IBAction func pushAllToProduction(_ sender: Any) {
        if ProductionShowController.allShows.shows == [] {
            messageTextField.textColor = .red
            messageTextField.stringValue = "First build development shows then push here"
            messageTextField.textColor = .white
            return
        }
        
        if ProductionBandController.allBands == [] {
            messageTextField.textColor = .red
            messageTextField.stringValue = "First build development bands then push here"
            messageTextField.textColor = .white
            return
        }
        
        
        //Bands
        var documentIDs = [String]()
        
        DispatchQueue.main.async {
            self.messageTextField.stringValue = "Getting document id's in the database..."
            sleep(UInt32(0.25))
        }
        
        
        //First get all document ids to delete them
        ProductionManager.allBandDataPath.getDocuments { snap, err in
            if let _ = err {
                self.messageTextField.stringValue = "Error getting document ID's for deletion"
            } else {
                self.messageTextField.stringValue = "Got \(snap!.documents.count) id's"
                for doc in snap!.documents {
                    let group =  try? doc.data(as: GroupOfProductionBands.self)
                    documentIDs.append(group?.groupOfProductionBandsID ?? "non")
                }
                
                //Second delete bands
                self.messageTextField.stringValue = "Starting to delete bands"
                var docNum = 0
                for doc in documentIDs {
                    ProductionManager.allBandDataPath.document(doc).delete { err in
                        if let err = err {
                            self.messageTextField.stringValue = err.localizedDescription
                        } else {
                            docNum += 1
                            self.messageTextField.stringValue = "\(docNum)/\(documentIDs.count) band groups deleted."
                        }
                    }
                }
            }
            
            //Third Push Bands
            var bandGroupCount = 0
            let totalNumberOfBands = ProductionBandController.allBands.count
            self.messageTextField.stringValue = "Pushing Bands..."
            for bandGroup in ProductionBandController.allBands {
                do {
                    try ProductionManager.allBandDataPath.document("\(bandGroup.groupOfProductionBandsID)").setData(from: bandGroup, completion: { err in
                        if let err = err {
                            DispatchQueue.main.async {
                                self.messageTextField.stringValue = err.localizedDescription
                            }
                            sleep(5)
                        } else {
                            bandGroupCount += 1
                            DispatchQueue.main.async {
                                self.messageTextField.stringValue = "\(bandGroupCount)/\(totalNumberOfBands) of the band groups were pushed."
                            }
                        }
                    })
                } catch let error {
                    print(error)
                }
            }
            self.messageTextField.textColor = .green
            self.messageTextField.stringValue = "Shows And Bands are now LIVE"
            self.messageTextField.textColor = .white
        }
        
        //Shows
        try? ProductionManager.allShowDataPath.document(ProductionShowController.allShows.allProductionShowsID).setData(from: ProductionShowController.allShows) { err in
            if let err = err {
                self.messageTextField.stringValue = err.localizedDescription
            } else {
                self.messageTextField.stringValue = "All Shows Pushed To Production"
            }
        }
    }
    
    
    
    
    
    //MARK: Developing Buttons
    @IBAction func pushAllBandsToDevelopingDBButtonTapped(_ sender: Any) {
        let breakUpBands = RemoteDataController.bandArray.chunked(into: splitBandsIntoGroups())
        ProductionBandController.allBands = []
        
        for group in breakUpBands {
            var groupedBands = GroupOfProductionBands(bands: [SingleProductionBand]())
            for band in group {
                let singleBand = SingleProductionBand(bandID: band.bandID, name: band.name, photo: band.photo, genre: band.genre, mediaLink: band.mediaLink, ohmPick: band.ohmPick)
                groupedBands.bands.append(singleBand)
                continue
            }
            ProductionBandController.allBands.append(groupedBands)
        }
        
        var documentIDs = [String]()
        
        DispatchQueue.main.async {
            self.messageTextField.stringValue = "Getting document id's in the database..."
            sleep(UInt32(0.25))
        }
        
        
        //First get all document ids to delete them
        workRef.allBandDataPath.getDocuments { snap, err in
            if let _ = err {
                self.messageTextField.stringValue = "Error getting document ID's for deletion"
            } else {
                self.messageTextField.stringValue = "Got \(snap!.documents.count) id's"
                for doc in snap!.documents {
                    let group =  try? doc.data(as: GroupOfProductionBands.self)
                    documentIDs.append(group?.groupOfProductionBandsID ?? "non")
                }
                
                //Second delete bands
                self.messageTextField.stringValue = "Starting to delete bands"
                var docNum = 0
                for doc in documentIDs {
                    workRef.allBandDataPath.document(doc).delete { err in
                        if let err = err {
                            self.messageTextField.stringValue = err.localizedDescription
                        } else {
                            docNum += 1
                            self.messageTextField.stringValue = "\(docNum)/\(documentIDs.count) band groups deleted."
                        }
                    }
                }
            }
            
            //Third Push Bands
            var bandGroupCount = 0
            let totalNumberOfBands = ProductionBandController.allBands.count
            self.messageTextField.stringValue = "Pushing Bands..."
            for bandGroup in ProductionBandController.allBands {
                do {
                    try workRef.allBandDataPath.document("\(bandGroup.groupOfProductionBandsID)").setData(from: bandGroup, completion: { err in
                        if let err = err {
                            DispatchQueue.main.async {
                                self.messageTextField.stringValue = err.localizedDescription
                            }
                            sleep(5)
                        } else {
                            bandGroupCount += 1
                            DispatchQueue.main.async {
                                self.messageTextField.stringValue = "\(bandGroupCount)/\(totalNumberOfBands) of the band groups were pushed."
                            }
                        }
                    })
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    
    
    
    @IBAction func pushAllVenuesToDevelopingDBButtonTapped(_ sender: Any) {
        self.messageTextField.stringValue = "Pushing Venues..."
        var docNum = 0
        for venue in RemoteDataController.venueArray {
            do {
                try workRef.allVenueDataPath.document(venue.venueID).setData(from: venue, completion: { err in
                    if let err = err {
                        self.messageTextField.stringValue = err.localizedDescription
                    } else {
                        docNum += 1
                        self.messageTextField.stringValue = "\(docNum)/\(RemoteDataController.venueArray.count) Venues pushed"
                    }
                })
            } catch let error {
                messageTextField.stringValue = error.localizedDescription
                NSLog(error.localizedDescription)
            }
            
        }
        messageTextField.stringValue = "All Venues Pushed"
    }
    
    @IBAction func pushAllShowsToDevelopingDBButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            let singleShow = SingleProductionShow(showID: show.showID, venue: show.venue, band: show.band, collaboration: [], bandDisplayName: show.bandDisplayName, date: show.date, ohmPick: show.ohmPick)
            ProductionShowController.allShows.shows.append(singleShow)
        }
        
        self.messageTextField.stringValue = "Pushing Shows..."
        do {
            try workRef.allShowDataPath.document(ProductionShowController.allShows.allProductionShowsID).setData(from: ProductionShowController.allShows) { err in
                if let err = err {
                    self.messageTextField.stringValue = err.localizedDescription
                } else {
                    self.messageTextField.stringValue = "All Development Shows Pushed"
                }
            }
        } catch let error {
            self.messageTextField.stringValue = error.localizedDescription
        }
        
    }
    
    @IBAction func lenaButton(_ sender: Any) {
        //        messageTextField.textColor = .red
        //        messageTextField.stringValue = "😘😘😘😘 Love You Babe!!! 😘😘😘😘😘"
        
        //Copy User Data To Production
        ProductionManager.allBannerDataPath.getDocuments { snap, err in
            if let err = err {
                NSLog(err.localizedDescription)
            } else {
                RemoteDataController.businessAd = snap!.documents.compactMap({ ads in
                    try? ads.data(as: BusinessBannerAd.self)
                })
            }
        }
    }
    
    @IBAction func multipurposeButton(_ sender: Any) {
        TagController.venueTags = []
        
        for venue in RemoteDataController.venueArray {
            let newTag = VenueTag(venueID: venue.venueID, variations: [venue.name])
            TagController.venueTags.append(newTag)
        }
        
        LocalBackupDataStorageController.saveVenueTagData()
        print(TagController.venueTags)
    }
    
    
    //MARK: Functions
    private func splitBandsIntoGroups() -> Int {
        let numOfBands = RemoteDataController.bandArray.count
        let result: Int = numOfBands / 60
        return result
        
    }
}
