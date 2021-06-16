//
//  ImageController.swift
//  Ohmicity Backend
//
//  Created by Nate Hedgeman on 6/16/21.
//

import Foundation
import Cocoa

class ImageController {
    
    func addBusinessImage(file: URL) -> NSImage{
        let imageData = NSData(contentsOf: file)!
        let image = NSImage(data: imageData as Data)
        return image!
    }
}

let imageController = ImageController()


extension NSBitmapImageRep {
    var jpeg: Data? { representation(using: .jpeg, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var jpeg: Data? { tiffRepresentation?.bitmap?.jpeg }
}
