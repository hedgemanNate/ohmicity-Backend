//
//  VenueTagViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 1/5/22.
//

import Cocoa

class VenueTagViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //MARK: Properties
    
    //Table Views
    @IBOutlet weak var venueTableView: NSTableView!
    @IBOutlet weak var tagsTableView: NSTableView!
    
    //Text Fields
    @IBOutlet weak var newTagTextField: NSTextField!
    @IBOutlet weak var searchTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
    }

    @IBAction func addTagButtonTapped(_ sender: Any) {
    }

    private func updateViews() {
            self.preferredContentSize = NSSize(width: 1320, height: 780)
        }
}
