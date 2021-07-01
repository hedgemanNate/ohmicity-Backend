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
    var remoteBusinessArray: [BusinessFullData] = []
    var remoteBasicBusinessArray: [BusinessBasicData] = []
    var remoteBandArray: [Band] = []
    var remoteShowArray: [Show] = []
    
    let db = Firestore.firestore()

}

var remoteDataController = RemoteDataController()
