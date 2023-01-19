//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 22.07.2022.
//

import Foundation

#if os(iOS)
import UIKit
public typealias Image = UIImage

#elseif os(macOS)
import AppKit
public typealias Image = NSImage
#endif


class ImageSaveService: FileKeeperService {
    func load() throws -> Image? {
        let data = try Data(contentsOf: file)
        return Image(data: data)
    }
}

#if os(macOS)

extension ImageSaveService {
    
    func save(image: Image, to path: URL) throws {
        if let data = image.png() {
            try data.write(to: file)
        } else {
            // TODO: Handle errors
        }
    }
}

extension Image {
    func png() -> Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = size // display size in points
        return imageRep.representation(using: .png, properties: [:])
    }
}

#endif

