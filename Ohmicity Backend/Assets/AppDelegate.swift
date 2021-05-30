//
//  AppDelegate.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/20/21.
//

import Cocoa
import FirebaseCore
import FirebaseDatabase

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

