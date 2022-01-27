//
//  RemoteDataController.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/17/21.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class RemoteDataController {
    
    //Properties
    static var venueArray: [Venue] = []
    static var bandArray: [Band] = []
    static var showArray: [Show] = []
    
    var businessResults = [Venue]()
    var bandResults = [Band]()
    var showResults = [Show]()
    
    let db = Firestore.firestore()
    
    static func getRemoteBandData() {
        print("Running Remote Band")
        workRef.bandDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                NSLog("Error getting bandData: \(err)")
            } else {
                NSLog("Got band data")
                RemoteDataController.bandArray = []
                for band in querySnapshot!.documents {
                    let result = Result {
                        try band.data(as: Band.self)
                    }
                    switch result {
                    case .success(let band):
                        if let band = band {
                            RemoteDataController.bandArray.append(band)
                        }
                    case .failure(let error):
                        print("Error decoding band: \(error.localizedDescription)")
                        NSLog("Failed to get band data")
                    }
                }
                
                let band = RemoteDataController.bandArray.sorted(by: {$0.name < $1.name})
                RemoteDataController.bandArray = band
                NSLog("Band data collection complete.")
                notificationCenter.post(name: NSNotification.Name("GotBandData"), object: nil)
            }
        }
        
    }
    
    static func getRemoteShowData(){
        print("Running Remote Show")
        workRef.showDataPath.getDocuments { (querySnapshot, err) in
            if let err = err {
                NSLog("Error getting showData: \(err.localizedDescription)")
            } else {
                NSLog("Got show data")
                RemoteDataController.showArray = []
                for show in querySnapshot!.documents {
                    let result = Result {
                        try show.data(as: Show.self)
                    }
                    switch result {
                    case .success(let show):
                        if let show = show {
                            RemoteDataController.showArray.append(show)
                        }
                    case .failure(let error):
                        print("Error decoding show: \(error.localizedDescription)")
                        NSLog("Failed to get show data")
                    }
                }
                
                let show = RemoteDataController.showArray.sorted(by: {$0.date < $1.date})
                RemoteDataController.showArray = show
                NSLog("Show data collection complete.")
                notificationCenter.post(name: NSNotification.Name("GotShowData"), object: nil)
            }
        }
    }
    
    static func getRemoteVenueData() {
        workRef.allVenueDataPath.getDocuments { querySnapshot, err in
            if let err = err {
                NSLog("Error getting venueData: \(err.localizedDescription)")
            } else {
                RemoteDataController.venueArray = []
                for venue in querySnapshot!.documents {
                    let result = Result {
                        try venue.data(as: Venue.self)
                    }
                    switch result {
                    case .success(let venue):
                        if let venue = venue {
                            RemoteDataController.venueArray.append(venue)
                        }
                    case .failure(let error):
                        NSLog(error.localizedDescription)
                    }
                }
                RemoteDataController.venueArray.sort(by: {$0.name < $1.name})
                NSLog("Venue data collection complete.")
                notificationCenter.post(name: NSNotification.Name("GotVenueData"), object: nil)
            }
        }
    }
}

//var RemoteDataController = RemoteDataController()
