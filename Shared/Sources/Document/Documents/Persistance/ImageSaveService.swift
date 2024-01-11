//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 22.07.2022.
//

import Foundation
import Artboard

class ImageSaveService: FileKeeperService {
    func load() throws -> Image? {
        let data = try Data(contentsOf: file)
        return Image(data: data)
    }
}

#if os(macOS)
import AppKit

extension ImageSaveService {
    
    func save(image: Image, to path: URL) throws {
        if isHeicSupported, let heicData = image.heic() {
            try heicData.write(to: file)
        } else if let data = image.png() {
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
    
    func heic(compressionQuality: CGFloat = 1) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
            let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return nil }
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            [kCGImageDestinationLossyCompressionQuality: compressionQuality,
                            kCGImagePropertyOrientation: CGImagePropertyOrientation.up] as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return mutableData as Data
    }
}

#elseif os(iOS) || os(visionOS)
import CoreGraphics
import UIKit

extension Image {
    func png() -> Data? {
        pngData()
    }
    
    func heic(compressionQuality: CGFloat = 1) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
            let cgImage = cgImage
        else { return nil }
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            [kCGImageDestinationLossyCompressionQuality: compressionQuality,
                            kCGImagePropertyOrientation: cgImageOrientation.rawValue] as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return mutableData as Data
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
}

#endif

#if os(visionOS)
var isHeicSupported: Bool {
    false
}
#else
var isHeicSupported: Bool {
    (CGImageDestinationCopyTypeIdentifiers() as! [String]).contains("public.heic")
}
#endif
