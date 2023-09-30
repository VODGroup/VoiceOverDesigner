//
//  SwiftUIView.swift
//  
//
//  Created by Alex Agapov on 29.09.2023.
//

import SwiftUI
import Document

public struct PresentationView: View {

    let document: VODesignDocumentPresentation
    @State var selectedControl: (any AccessibilityView)?

    public var body: some View {
        ZStack {
            Color.clear
            HStack {
                if #available(macOS 13.0, *) {
                    scroll
                        .scrollIndicators(.never)
                } else {
                    scroll
                }
                list
            }
        }
    }

    public init(document: VODesignDocumentPresentation) {
        self.document = document
        selectedControl = document.controls.first
    }

    @ViewBuilder
    private var scroll: some View {
        ScrollView([.horizontal, .vertical]) {
            scrollContent
                .accessibilityHidden(true)
                .overlay(alignment: .topLeading) {
                    controls
                }
        }
        .frame(
            minWidth: min(400, document.imageSize.width),
            idealWidth: document.imageSize.width,
            minHeight: min(400, document.imageSize.height),
            idealHeight: document.imageSize.height
        )
    }

    @ViewBuilder
    private var scrollContent: some View {
        if let image = document.image {
            Image(nsImage: image)
                .resizable()
                .frame(
                    width: document.imageSize.width / document.frameInfo.imageScale,
                    height: document.imageSize.height / document.frameInfo.imageScale
                )
        } else {
            Color.clear
                .frame(width: document.imageSize.width, height: document.imageSize.height)
        }
    }

    private var controls: some View {
        ZStack(alignment: .topLeading) {
            ForEach(document.controls, id: \.label) { control in
                switch control.cast {
                    case .container(let container):
                        controlRectangle(control)
                            .zIndex(-1)
                            .accessibilityLabel(container.label)

                        // TODO: accessibility modifiers
                    case .element(let element):
                        controlRectangle(control)
                            .accessibilityHidden(!element.isAccessibilityElement)
                            .accessibilityLabel(element.label)
                            .accessibilityHint(element.hint)
                            .accessibilityValue(element.value)
//                            .accessibilityAddTraits(element.trait)
//                            adjustableOptions: AdjustableOptions,
//                            customActions: A11yCustomActions
                }
            }
        }
    }

    @ViewBuilder
    private func controlRectangle(_ control: any AccessibilityView) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .foregroundStyle(
                {
                    isControlSelected(control)
                    ? Color(nsColor: control.color.withAlphaComponent(0.8))
                    : Color(nsColor: control.color)
                }()
            )
            .offset(
                x: control.frame.origin.x,
                y: control.frame.origin.y
            )
            .frame(width: control.frame.width, height: control.frame.height)
    }

    // MARK: - List

    private var list: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(document.controls, id: \.label) { control in
                switch control.cast {
                    case .container(let container):
                        controlText(control)
                            .opacity(isControlSelected(control) ? 1 : 0.4)
                        ForEach(container.elements, id: \.label) { element in
                            controlText(element)
                                .opacity(isControlSelected(control) ? 1 : 0.4)
                                .padding(.leading, 16)
                        }
                    case .element(let element):
                        controlText(control)
                            .opacity(isControlSelected(control) ? 1 : 0.4)
                }
            }
        }
        .padding(16)
        .frame(minWidth: 300, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func controlText(_ control: any AccessibilityView) -> some View {
        switch control.cast {
            case .container(let container):
                Text(container.label)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            case .element(let element):
                Text(AttributedString(
                    element
                        .voiceOverTextAttributed(font: .preferredFont(forTextStyle: .body))
                ))
                .multilineTextAlignment(.leading)
        }
    }

    func isControlSelected(_ control: any AccessibilityView) -> Bool {
        control.cast == selectedControl?.cast
    }
}

let previewDocument = VODesignDocumentPresentation(
    controls: [
        A11yContainer(
            elements: [
                A11yDescription(
                    isAccessibilityElement: true,
                    label: "Long long long long long long long long long long long name",
                    value: "",
                    hint: "",
                    trait: .button,
                    frame: .init(x: 100, y: 100, width: 50, height: 50),
                    adjustableOptions: .init(options: []),
                    customActions: .defaultValue
                )
            ],
            frame: .init(x: 80, y: 80, width: 90, height: 90),
            label: "Some container",
            isModal: false,
            isTabTrait: false,
            isEnumerated: false,
            containerType: .semanticGroup,
            navigationStyle: .automatic
        ),
        A11yDescription(
            isAccessibilityElement: true,
            label: "haha",
            value: "1",
            hint: "Some hint",
            trait: .header,
            frame: .init(x: 10, y: 10, width: 50, height: 50),
            adjustableOptions: .init(options: []),
            customActions: .defaultValue
        ),
        A11yDescription(
            isAccessibilityElement: true,
            label: "wow",
            value: "",
            hint: "",
            trait: .button,
            frame: .init(x: 100, y: 100, width: 50, height: 50),
            adjustableOptions: .init(options: []),
            customActions: .defaultValue
        )
    ],
    image: nil,
    imageSize: .init(width: 300, height: 300),
    frameInfo: .default
)

#Preview {
    PresentationView(
        document: previewDocument
    )
}
