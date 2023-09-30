//
//  File.swift
//  
//
//  Created by Alex Agapov on 30.09.2023.
//

import Foundation

public struct VODesignDocumentPresentation {
    public let controls: [any AccessibilityView]
    public let image: Image?
    public let imageSize: CGSize
    public let frameInfo: FrameInfo

    public init(
        controls: [any AccessibilityView],
        image: Image?,
        imageSize: CGSize,
        frameInfo: FrameInfo
    ) {
        self.controls = controls
        self.image = image
        self.imageSize = imageSize
        self.frameInfo = frameInfo
    }

    public init(_ document: VODesignDocumentProtocol) {
        self.controls = document.controls
        self.image = document.image
        self.imageSize = document.imageSize
        self.frameInfo = document.frameInfo
    }
}
