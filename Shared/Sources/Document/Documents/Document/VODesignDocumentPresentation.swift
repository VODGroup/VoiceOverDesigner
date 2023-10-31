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
    public let frameInfo: FrameInfo

    public init(
        controls: [any ArtboardElement],
        flatControls: [A11yDescription],
        image: Image?,
        imageSize: CGSize,
        frameInfo: FrameInfo
    ) {
        self.controls = controls
        self.flatControls = flatControls
        self.image = image
        self.imageSize = imageSize
        self.frameInfo = frameInfo
    }

    public init(_ document: VODesignDocumentProtocol) {
        self.controls = document.controls
        self.flatControls = document.controls.reduce(into: [], { partialResult, view in
            switch view.cast {
                case .container(let container):
                // partialResult.append(contentsOf: container.elements)
                // TODO: Restore
                fatalError()
                case .element(let element):
                    partialResult.append(element)
                case .frame(_):
                    // TODO: Add support
                    fatalError()
            }
        })
        
        // TODO: Read from frame
        fatalError("Read from first frame")
//        self.image = document.image
//        self.imageSize = document.imageSize
//        self.frameInfo = document.frameInfo
    }

    public mutating func update(control: any ArtboardElement) {
        // TODO: Restore
//        controls = controls.map {
//            if $0.cast == control.cast {
//                return control
//            }
//            return $0
//        }
//        if let element = control.element {
//            flatControls = flatControls.map {
//                if $0 == element {
//                    return element
//                }
//                return $0
//            }
//        }
    }
}
