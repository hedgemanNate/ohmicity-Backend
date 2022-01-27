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
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 1320, height: 780)
    }
    
    //MARK: Production Button/Functions
    @IBAction func pushAllToProduction(_ sender: Any) {
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 1
        
        let pushBands1 = BlockOperation {
            self.pushBands()
        }
        
        let pushShows2 = BlockOperation {
            self.pushShows()
        }
        
        let pushVenues3 = BlockOperation {
            self.pushVenues()
        }
        
        opQueue.addOperations([pushBands1, pushShows2, pushVenues3], waitUntilFinished: true)
    }
    
    private func pushBands() {
        let breakUpBands = RemoteDataController.bandArray.chunked(into: splitBandsIntoGroups())
        
        for group in breakUpBands {
            var groupedBands = GroupOfProductionBands(bands: [SingleProductionBand]())
            for band in group {
                
                let singleBand = SingleProductionBand(bandID: band.bandID, name: band.name, photo: band.photo, genre: band.genre, mediaLink: band.mediaLink, ohmPick: band.ohmPick)
                groupedBands.bands.append(singleBand)
                continue
            }
            ProductionBandController.allBands.append(groupedBands)
        }
        
        var bandGroupCount = 0
        
        for bandGroup in ProductionBandController.allBands {
            bandGroupCount += 1
            do {
                try ProductionManager.allBandDataPath.document("\(bandGroupCount)-\(UUID().uuidString)").setData(from: bandGroup)
            } catch let error {
                messageTextField.stringValue = error.localizedDescription
                NSLog(error.localizedDescription)
            }
        }
    }
    
    private func pushShows() {
        for show in RemoteDataController.showArray {
            let singleShow = SingleProductionShow(showID: show.showID, venue: show.venue, band: show.band, collaboration: [], bandDisplayName: show.bandDisplayName, date: show.date, ohmPick: show.ohmPick)
            ProductionShowController.allShows.shows.append(singleShow)
        }
        
        do {
            try ProductionManager.allShowDataPath.document(ProductionShowController.allShows.allProductionShowsID).setData(from: ProductionShowController.allShows)
        } catch let error {
            self.messageTextField.stringValue = error.localizedDescription
            NSLog(error.localizedDescription)
        }
    }
    
    private func pushVenues() {
        for venue in RemoteDataController.venueArray {
            do {
                try ProductionManager.allVenueDataPath.document(venue.venueID).setData(from: venue)
            } catch let error {
                messageTextField.stringValue = error.localizedDescription
                NSLog(error.localizedDescription)
            }
        }
    }
    
    //MARK: Developing Buttons
    @IBAction func pushAllBandsToDevelopingDBButtonTapped(_ sender: Any) {
        let breakUpBands = RemoteDataController.bandArray.chunked(into: splitBandsIntoGroups())
        
        for group in breakUpBands {
            var groupedBands = GroupOfProductionBands(bands: [SingleProductionBand]())
            for band in group {
                
                let singleBand = SingleProductionBand(bandID: band.bandID, name: band.name, photo: band.photo, genre: band.genre, mediaLink: band.mediaLink, ohmPick: band.ohmPick)
                groupedBands.bands.append(singleBand)
                continue
            }
            ProductionBandController.allBands.append(groupedBands)
        }
        
        var bandGroupCount = 0
        
        for bandGroup in ProductionBandController.allBands {
            bandGroupCount += 1
            do {
                try workRef.allBandDataPath.document("\(bandGroupCount)-\(UUID().uuidString)").setData(from: bandGroup, completion: { err in
                    if let err = err {
                        self.messageTextField.stringValue = err.localizedDescription
                    } else {
                        self.messageTextField.stringValue = "Group Of Production Bands Pushed"
                    }
                })
            } catch let error {
                print(error)
            }
            if bandGroupCount == ProductionBandController.allBands.count {
                messageTextField.stringValue = "All Bands Finished Pushing"
            }
        }
    }
    
    @IBAction func pushAllVenuesToDevelopingDBButtonTapped(_ sender: Any) {
        for venue in RemoteDataController.venueArray {
            do {
                try workRef.allVenueDataPath.document(venue.venueID).setData(from: venue)
            } catch let error {
                messageTextField.stringValue = error.localizedDescription
                NSLog(error.localizedDescription)
            }
        }
    }
    
    @IBAction func pushAllShowsToDevelopingDBButtonTapped(_ sender: Any) {
        for show in RemoteDataController.showArray {
            let singleShow = SingleProductionShow(showID: show.showID, venue: show.venue, band: show.band, collaboration: [], bandDisplayName: show.bandDisplayName, date: show.date, ohmPick: show.ohmPick)
            ProductionShowController.allShows.shows.append(singleShow)
        }
        
        do {
            try workRef.allShowDataPath.document(ProductionShowController.allShows.allProductionShowsID).setData(from: ProductionShowController.allShows) { err in
                if let err = err {
                    self.messageTextField.stringValue = err.localizedDescription
                } else {
                    self.messageTextField.stringValue = "All Production Shows Pushed"
                }
            }
        } catch let error {
            self.messageTextField.stringValue = error.localizedDescription
        }
        
    }
    
    @IBAction func tester(_ sender: Any) {
        messageTextField.textColor = .red
        messageTextField.stringValue = "😘😘😘😘 Love You Babe!!! 😘😘😘😘😘"
    }
    
    //MARK: Functions
    private func splitBandsIntoGroups() -> Int {
        let numOfBands = RemoteDataController.bandArray.count
        let result: Int = numOfBands / 60
        return result
        
    }
}
