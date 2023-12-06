//
//  File.swift
//  
//
//  Created by Alex Agapov on 30.09.2023.
//

import Foundation

public struct VODesignDocumentPresentation {
    /// Storage for all elements.
    /// Containers are unwrapped and every element inside is stored.
    public private(set) var controls: [UUID: any ArtboardElement]
    /// Elements order
    public let orderedControlIds: [UUID]

    public private(set) var orderedControls: [any ArtboardElement]

    /// Subset of controls containing ONLY A11yDescription elements.
    /// Used for navigating <->
    public private(set) var flatControls: [UUID]

    public let image: Image?
    public let imageSize: CGSize

    public init(
        controls: [UUID: any ArtboardElement],
        orderedControlIds: [UUID],
        flatControls: [UUID],
        image: Image?,
        imageSize: CGSize
    ) {
        self.controls = controls
        self.orderedControlIds = orderedControlIds
        self.orderedControls = orderedControlIds.compactMap { controls[$0] }
        self.flatControls = flatControls
        self.image = image
        self.imageSize = imageSize
    }

    public init(_ document: VODesignDocumentProtocol) {
        var order: [UUID] = []
        var flatOrder: [UUID] = []
        self.controls = document.artboard.frames
            .reduce(into: [:], { result, frame in
                frame.elements.forEach {
                    result[$0.id] = $0
                    order.append($0.id)
                    for element in $0.extractElements() {
                        result[element.id] = element
                        flatOrder.append(element.id)
                    }
                }
            })

        for control in document.artboard.controlsOutsideOfFrames {
            self.controls[control.id] = control
            order.append(control.id)
            for element in control.extractElements() {
                self.controls[element.id] = element
                flatOrder.append(element.id)
            }
        }

        self.orderedControlIds = order
        self.flatControls = flatOrder

        self.orderedControls = []
        for orderedControlId in orderedControlIds {
            if let control = self.controls[orderedControlId] {
                self.orderedControls.append(control)
            }
        }

        if let firstFrame = document.artboard.frames.first {
            let image = document.artboard.imageLoader.image(for: firstFrame)
            self.image = image
            self.imageSize = firstFrame.frame.size
        } else {
            self.image = nil
            self.imageSize = .zero
        }
    }

    /// Used for updating element. Adjustable properties
    public mutating func update(control: A11yDescription) {
        controls[control.id] = control
        self.orderedControls = orderedControlIds.compactMap { controls[$0] }
    }
}
