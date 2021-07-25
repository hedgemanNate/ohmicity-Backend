//
//  MainViewCell.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 7/23/21.
//

import Cocoa

class MainViewCell: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        
        self.textField?.textColor = .white
    }
    
}
