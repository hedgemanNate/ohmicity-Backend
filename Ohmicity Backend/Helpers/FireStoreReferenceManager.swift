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

}

let ref = FireStoreReferenceManager.self

struct WorkingOffRemoteManager {
    static let environment = "workingData"
    static let fireDataBase = Firestore.firestore()
    
    static let showDataPath = fireDataBase.collection(environment).document(environment).collection("workingShowData")
    static let bandDataPath = fireDataBase.collection(environment).document(environment).collection("workingBandData")
    static let bandTagDataPath = fireDataBase.collection(environment).document(environment).collection("workingBandTagData")
}

let workRef = WorkingOffRemoteManager.self
