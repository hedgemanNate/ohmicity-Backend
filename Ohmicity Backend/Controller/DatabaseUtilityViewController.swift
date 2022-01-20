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
        
        
    }
    
    
    
    

    private func splitBandsIntoGroups() -> Int {
        let numOfBands = RemoteDataController.bandArray.count
        let result: Int = numOfBands / 60
        return result
        
    }
}
