//
//  PresentationModel.swift
//
//
//  Created by Alex Agapov on 05.11.2023.
//

import Foundation
import Document
import SwiftUI

final class PresentationModel: ObservableObject {
    public enum Constants {
        static let animation: Animation = .linear(duration: 0.15)
    }

    enum Action {
        case hover(any ArtboardElement, _ isInside: Bool)
        case select(any ArtboardElement)
        case prev
        case next
        case increment(A11yDescription)
        case decrement(A11yDescription)
    }

    @Published var document: VODesignDocumentPresentation

    @Published var selectedControl: A11yDescription?
    @Published var hoveredControl: (any ArtboardElement)?

    public init(document: VODesignDocumentPresentation) {
        self.document = document
        selectedControl = document.flatControls.first
            .flatMap {
            document.controls[$0] as? A11yDescription
        }
    }

    public func handle(_ action: Action) {
        switch action {
        case .select(let artboardElement):
            guard let control = artboardElement as? A11yDescription else { return }
            withAnimation(Constants.animation) {
                selectedControl = control
            }
        case .prev:
            if
                let selected = selectedControl,
                let index = document.flatControls.firstIndex(of: selected.id),
                let prevIndex = document.flatControls[safe: index - 1],
                let prev = document.controls[prevIndex]
            {
                handle(.select(prev))
            }
        case .next:
            if
                let selected = selectedControl,
                let index = document.flatControls.firstIndex(of: selected.id),
                let nextIndex = document.flatControls[safe: index + 1],
                let next = document.controls[nextIndex]
            {
                handle(.select(next))
            }
        case .hover(let control, let isInside):
            withAnimation(Constants.animation) {
                if isInside {
                    hoveredControl = control
                } else {
                    hoveredControl = nil
                }
            }
        case .increment(let control):
            control.adjustableOptions.accessibilityIncrement()
            document.update(control: control)
        case .decrement(let control):
            control.adjustableOptions.accessibilityDecrement()
            document.update(control: control)
        }
    }
}
