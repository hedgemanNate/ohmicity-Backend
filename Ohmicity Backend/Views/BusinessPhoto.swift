//
//  BusinessPhoto.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 6/30/21.
//

import Cocoa

class BusinessPhoto: NSCollectionViewItem {
    
    //Properties
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = 3
                view.layer?.borderColor = NSColor.yellow.cgColor
            } else {
                view.layer?.borderWidth = 0
            }
        }
    }
    
}
