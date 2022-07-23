//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 22.07.2022.
//

import Foundation

class ImageSaveService {
    func load(from path: URL) throws -> Image? {
        let imageURL = path.appendingPathComponent("screen.png")
        let data = try Data(contentsOf: imageURL)
        return Image(data: data)
    }
}

#if os(iOS)
import UIKit
public typealias Image = UIImage

#elseif os(macOS)
import AppKit
public typealias Image = NSImage
extension ImageSaveService {
    
    func save(image: NSImage, to path: URL) throws {
        if let data = UIImagePNGRepresentation(image) {
            try data.write(to: path.appendingPathComponent("screen.png"))
        } else {
            // TODO: Handle errors
        }
    }
    
    func UIImagePNGRepresentation(_ image: Image) -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = image.size // display size in points
        return imageRep.representation(using: .png, properties: [:])
    }
}

#endif

