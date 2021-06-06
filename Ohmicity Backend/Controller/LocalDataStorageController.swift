//
//  LocalDataStorage.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/3/21.
//

import Foundation

class LocalDataStorageController {
    
    var businessArray: [BusinessFullData] = []
    var bandArray: [Band] = []
    var showArray: [Show] = []
    
//MARK: Business Data
    func loadBusinessData() {
        if let data = UserDefaults.standard.data(forKey: "SavedOhmData") {
            if let decoded = try? JSONDecoder().decode([BusinessFullData].self, from: data) {
                self.businessArray = decoded
                print("Business Data Loaded")
                return
            }
        }
    }
    
    func saveBusinessData() {
        if let encoded = try? JSONEncoder().encode(businessArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedOhmData")
            print("Business Data Saved")
        }
    }
}

//MARK: Band Data
extension LocalDataStorageController {
    func loadBandData() {
        if let data = UserDefaults.standard.data(forKey: "SavedBandData") {
            if let decoded = try? JSONDecoder().decode([BusinessFullData].self, from: data) {
                self.businessArray = decoded
                print("Band Data Loaded")
                return
            }
        }
    }
    
    func saveBandData() {
        if let encoded = try? JSONEncoder().encode(businessArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedBandData")
            print("Band Data Saved")
        }
    }
}

//MARK: Raw JSON data
extension LocalDataStorageController {
    func loadJsonData() {
        if let data = UserDefaults.standard.data(forKey: "SavedJsonData") {
            if let decoded = try? JSONDecoder().decode([RawJSON].self, from: data) {
                parseDataController.dataArray = decoded
                print("JSON Data Loaded")
                return
            }
        }
    }
    
    func saveJsonData() {
        if let encoded = try? JSONEncoder().encode(parseDataController.dataArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedJsonData")
            print("Json Data Saved")
        }
    }
}
    
//MARK: Raw Show data
extension LocalDataStorageController {
    func loadShowData() {
        if let data = UserDefaults.standard.data(forKey: "SavedShowData") {
            if let decoded = try? JSONDecoder().decode([Show].self, from: data) {
                self.showArray = decoded
                print("Show Data Loaded")
                return
            }
        }
    }
    
    func saveShowData() {
        if let encoded = try? JSONEncoder().encode(showArray) {
            UserDefaults.standard.set(encoded, forKey: "SavedShowData")
            print("Show Data Saved")
        }
    }
}

let localDataController = LocalDataStorageController()
