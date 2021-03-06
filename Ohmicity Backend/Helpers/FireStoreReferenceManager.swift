//
//  FireStoreReferenceManager.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/18/21.
//

import Foundation
import FirebaseFirestore

struct FireStoreReferenceManager {
    static let environment = "remoteData"
    static let fireDataBase = Firestore.firestore()
    
    static let businessFullDataPath = fireDataBase.collection(environment).document(environment).collection("businessFullData")
    
    static let bandDataPath = fireDataBase.collection(environment).document(environment).collection("bandData")
    
    static let showDataPath = fireDataBase.collection(environment).document(environment).collection("showData")
    
    static let businessBannerAdDataPath = fireDataBase.collection(environment).document(environment).collection("businessBannerAdData")
    
    static let recommendationDataDataPath = fireDataBase.collection(environment).document(environment).collection("recommendationData")
    
    static let userDataPath = fireDataBase.collection(environment).document(environment).collection("userData")

}

let ref = FireStoreReferenceManager.self

struct WorkingOffRemoteManager {
    static let working = "workingData"
    static let fireDataBase = Firestore.firestore()
    
    static let allVenueDataPath = fireDataBase.collection(working).document(working).collection("allVenueData")
    static let allShowDataPath = fireDataBase.collection(working).document(working).collection("allShowData")
    static let allBandDataPath = fireDataBase.collection(working).document(working).collection("allBandData")
    static let allBannerDataPath = fireDataBase.collection(working).document(working).collection("allBannerData")
    
    static let showDataPath = fireDataBase.collection(working).document(working).collection("showData")
    static let bandDataPath = fireDataBase.collection(working).document(working).collection("bandData")
    static let bandTagDataPath = fireDataBase.collection(working).document(working).collection("tagData")
}

let workRef = WorkingOffRemoteManager.self

struct ProductionManager {
    static let production = "productionData"
    static let fireDataBase = Firestore.firestore()
    
    static let allShowDataPath = fireDataBase.collection(production).document(production).collection("allShowData")
    static let allVenueDataPath = fireDataBase.collection(production).document(production).collection("allVenueData")
    static let allBandDataPath = fireDataBase.collection(production).document(production).collection("allBandData")
    
    static let allUserDataPath = fireDataBase.collection(production).document(production).collection("allUserData")
    static let allBannerDataPath = fireDataBase.collection(production).document(production).collection("allBannerData")
    
}
