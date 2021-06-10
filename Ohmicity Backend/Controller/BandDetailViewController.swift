//
//  BandDetailViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/5/21.
//

import Cocoa

class BandDetailViewController: NSViewController {
    
    //Properties
    var currentBand: Band?
    @IBOutlet weak var tableView: NSTableView!
    
    //TextFields
    @IBOutlet weak var bandNameTextField: NSTextField!
    @IBOutlet weak var bandMediaLinkTextField: NSTextField!
    
    //Buttons
    @IBOutlet weak var rockButton: NSButton!
    @IBOutlet weak var bluesButton: NSButton!
    @IBOutlet weak var jazzButton: NSButton!
    @IBOutlet weak var danceButton: NSButton!
    @IBOutlet weak var reggaeButton: NSButton!
    @IBOutlet weak var countryButton: NSButton!
    @IBOutlet weak var funkButton: NSButton!
    @IBOutlet weak var edmButton: NSButton!
    @IBOutlet weak var hiphopButton: NSButton!
    @IBOutlet weak var djButton: NSButton!
    
    @IBOutlet weak var loadPictureButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    var genreButtonArray: [NSButton] = []
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    private func updateViews() {
        genreButtonSetup()
    }
    
}

//MARK: Helper Functions
extension BandDetailViewController {
    
    private func genreButtonSetup() {
        genreButtonArray = [
            rockButton, bluesButton,
            jazzButton, danceButton,
            reggaeButton, countryButton,
            funkButton, edmButton,
            hiphopButton, djButton
        ]
        
        guard let currentBand = currentBand else {
            return
        }
        
        for genre in currentBand.genre {
            switch genre {
            case .rock:
                rockButton.state = .on
            case .blues:
                bluesButton.state = .on
            case .jazz:
                jazzButton.state = .on
            case .dance:
                danceButton.state = .on
            case .reggae:
                reggaeButton.state = .on
            case .country:
                countryButton.state = .on
            case .funkSoul:
                funkButton.state = .on
            case .edm:
                edmButton.state = .on
            case .hiphop:
                hiphopButton.state = .on
            case .dj:
                djButton.state = .on
            }
        }
    }
}
