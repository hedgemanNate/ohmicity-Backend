//
//  MainTableViewCell.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 7/24/21.
//

import Cocoa

class MainTableViewCell: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Clears Color Coding
        textField?.textColor = .white
        layer?.backgroundColor = .clear
    }
    
}
