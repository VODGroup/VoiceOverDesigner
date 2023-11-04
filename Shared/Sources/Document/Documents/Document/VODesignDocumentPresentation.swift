//
//  File.swift
//  
//
//  Created by Alex Agapov on 30.09.2023.
//

import Foundation

public struct VODesignDocumentPresentation {
    public private(set) var controls: [any ArtboardElement]
    public private(set) var flatControls: [A11yDescription]
    public let image: Image?
    public let imageSize: CGSize

    public init(
        controls: [any ArtboardElement],
        flatControls: [A11yDescription],
        image: Image?,
        imageSize: CGSize
    ) {
        self.controls = controls
        self.flatControls = flatControls
        self.image = image
        self.imageSize = imageSize
    }

    public init(_ document: VODesignDocumentProtocol) {
        self.controls = document.artboard.controlsWithoutFrames
        self.flatControls = document.artboard.controlsWithoutFrames.extractElements()

        if let firstFrame = document.artboard.frames.first {
            let image = document.artboard.imageLoader.image(for: firstFrame)
            self.image = image
            self.imageSize = firstFrame.frame.size
        } else {
            self.image = nil
            self.imageSize = .zero
        }
    }

    public mutating func update(control: A11yDescription) {
        // TODO: Restore
        controls = controls.map {
            if $0.cast == control.cast {
                return control
            }
            return $0
        }
        flatControls = flatControls.map {
            if $0 == control {
                return control
            }
            return $0
        }
    }
}
