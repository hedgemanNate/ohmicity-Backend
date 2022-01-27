//
//  LocalDataStorage.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/3/21.
//

import Foundation

class LocalBackupDataStorageController {
    
    static var venueArray: [Venue] = []
    static var bandArray: [Band] = []
    static var showArray: [Show] = []
    
    //Search Functionality
    var businessResults = [Venue]()
    var bandResults = [Band]()
    var showResults = [Show]()
    
//MARK: Business Data
    static func loadBusinessData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBusinessData") {
            if let decoded = try? JSONDecoder().decode([Venue].self, from: data) {
                LocalBackupDataStorageController.venueArray = decoded.sorted(by: {$0.name < $1.name})
                print("Business Data Loaded")
                //return
            }
        }
    }
    
    static func saveBusinessData() {
        if let encoded = try? JSONEncoder().encode(LocalBackupDataStorageController.venueArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedBusinessData")
            print("Business Data Saved")
        }
    }
    
}

//MARK: Band Data
extension LocalBackupDataStorageController {
    static func loadBandData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBandData") {
            if let decoded = try? JSONDecoder().decode([Band].self, from: data) {
                LocalBackupDataStorageController.bandArray = decoded.sorted(by: {$0.name < $1.name})
                print("Band Data Loaded")
                return
            }
        }
    }
    
    static func saveBandData() {
        if let encoded = try? JSONEncoder().encode(LocalBackupDataStorageController.bandArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedBandData")
            print("Band Data Saved")
        }
    }
    
    static func loadBackupBandData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBackupBandData") {
            if let decoded = try? JSONDecoder().decode([Band].self, from: data) {
                LocalBackupDataStorageController.bandArray = decoded.sorted(by: {$0.name < $1.name})
                print("Backup Band Data Loaded")
                return
            }
        }
    }
    
    static func saveBackupBandData() {
        if let encoded = try? JSONEncoder().encode(LocalBackupDataStorageController.bandArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedBackupBandData")
            print("Backup Band Data Saved")
        }
    }
    
}

//MARK: Scrapped Data
extension LocalBackupDataStorageController {
    static func loadJsonData() {
        if let data = UserDefaults.standard.data(forKey: "SavedJsonData") {
            if let decoded = try? JSONDecoder().decode([ShowData].self, from: data) {
                RawShowDataController.rawShowsArray = decoded
                print("JSON Data Loaded")
                return
            }
        }
    }
    
    static func saveJsonData() {
        
        if let encoded = try? JSONEncoder().encode(RawShowDataController.rawShowsArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedJsonData")
            print("Json Data Saved")
        }
        
    }
}
    
//MARK: Show data
extension LocalBackupDataStorageController {
    static func loadShowData() {
        if let data = UserDefaults.standard.data(forKey: "SavedShowData") {
            if let decoded = try? JSONDecoder().decode([Show].self, from: data) {
                LocalBackupDataStorageController.showArray = decoded.sorted(by: {$0.date < $1.date})
                print("Show Data Loaded")
                return
            }
        }
    }
    
    static func saveShowData() {
        if let encoded = try? JSONEncoder().encode(LocalBackupDataStorageController.showArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedShowData")
            print("Show Data Saved")
        }
    }
}

//MARK: Tag Data
extension LocalBackupDataStorageController {
    static func loadBandTagData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBandTagData") {
            if let decoded = try? JSONDecoder().decode([BandTag].self, from: data) {
                TagController.bandTags = decoded
                print("Band Tags Loaded")
                //return
            }
        }
    }
    
    static func saveBandTagData() {
        if let encoded = try? JSONEncoder().encode(TagController.bandTags) {
            UserDefaults.standard.set(encoded, forKey: "SavedBandTagData")
            print("Band Tags Saved")
        }
    }
    
    static func loadBackupBandTagData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBackupBandTagData") {
            if let decoded = try? JSONDecoder().decode([BandTag].self, from: data) {
                TagController.bandTags = decoded
                print("Band Tags Loaded")
                //return
            }
        }
    }
    
    static func saveBackupBandTagData() {
        if let encoded = try? JSONEncoder().encode(TagController.bandTags) {
            UserDefaults.standard.set(encoded, forKey: "SavedBackupBandTagData")
            print("Band Tags Saved")
        }
    }
    
    
    static func loadVenueTagData() {
        if let data = UserDefaults.standard.data(forKey: "SavedVenueTagData") {
            if let decoded = try? JSONDecoder().decode([VenueTag].self, from: data) {
                TagController.venueTags = decoded
                print("Venue Tags Loaded")
                //return
            }
        }
    }
    
    static func saveVenueTagData() {
        if let encoded = try? JSONEncoder().encode(TagController.venueTags) {
            UserDefaults.standard.set(encoded, forKey: "SavedVenueTagData")
            print("Venue Tags Saved")
        }
    }
}
