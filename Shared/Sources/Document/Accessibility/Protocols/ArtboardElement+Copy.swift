//
//  ArtboardElement+Copy.swift
//
//
//  Created by Mikhail Rubanov on 31.10.2023.
//

import Foundation

extension ArtboardElement {
    public func copy() -> any ArtboardElement {
        switch self.cast {
        case .frame(let frame):
            return Frame.copy(from: frame)
        case .container(let container):
            return A11yContainer.copy(from: container)
        case .element(let element):
            return A11yDescription.copy(from: element)
        }
    }
    
    public func copyWithoutLabel() -> any ArtboardElement {
        let copy = self.copy()
        copy.label = ""
        return copy
    }
}

extension Array where Element == any ArtboardElement {
    func copy() -> [Element] {
        map({ element in
            element.copy()
        })
    }
}

extension Frame {
    public static func copy(from frame: Frame) -> Frame {
        Frame(id: frame.id,
              label: frame.label,
              imageLocation: frame.imageLocation,
              frame: frame.frame,
              elements: frame.elements.copy()
        )
    }
}

extension A11yContainer {
    public static func copy(from model: A11yContainer) -> A11yContainer {
        A11yContainer(
            id: UUID(),
            elements: model.elements.copy(),
            frame: model.frame,
            label: model.label,
            isModal: model.isModal,
            isTabTrait: model.isTabTrait,
            isEnumerated: model.isEnumerated,
            containerType: model.containerType,
            navigationStyle: model.navigationStyle
        )
    }
}

extension A11yDescription {
    
    public static func copy(from descr: A11yDescription) -> A11yDescription {
        A11yDescription(
            id: UUID(),
            isAccessibilityElement: descr.isAccessibilityElement,
            label: descr.label,
            value: descr.value,
            hint: descr.hint,
            trait: descr.trait,
            frame: descr.frame,
            adjustableOptions: descr.adjustableOptions,
            customActions: descr.customActions
        )
    }
}
