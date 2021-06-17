//
//  RemoteDataController.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/17/21.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class RemoteDataController {
    
    //Properties
    var remoteBusinessArray: [BusinessFullData] = []
    var remoteBasicBusinessArray: [BusinessBasicData] = []
    var remoteBandsArray: [Band] = []
    var remoteShowArray: [Show] = []

}

var remoteDataController = RemoteDataController()
