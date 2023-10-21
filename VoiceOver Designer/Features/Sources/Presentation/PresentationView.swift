//
//  SwiftUIView.swift
//  
//
//  Created by Alex Agapov on 29.09.2023.
//

import SwiftUI
import Document

public struct PresentationView: View {
    public enum Constants {
        public static let controlsWidth: CGFloat = 300
        public static let windowPadding: CGFloat = 80

        static let selectedControlPadding: CGFloat = 40
        static let animation: Animation = .linear(duration: 0.15)
    }

    @State var document: VODesignDocumentPresentation

    @State var selectedControl: (any AccessibilityView)?
    @State var hoveredControl: (any AccessibilityView)?

    let scrollViewSize = CGSize(width: 600, height: 900)
    
    var minimalScaleFactor: CGFloat {
        guard 
            document.imageSizeScaled.width != 0, 
            document.imageSizeScaled.height != 0
        else {
            return 1
        }
        let h = scrollViewSize.width / document.imageSizeScaled.width
        let v = scrollViewSize.height / document.imageSizeScaled.height
        
        // TODO: Add minimal limit for long documents
        return min(h, v)
    }
    
    public var body: some View {
        ZStack {
            Color.clear
            HStack {
                if #available(macOS 13.0, *) {
                    scroll
                        .scrollIndicators(.never)
                        .scrollDisabled(true)
                } else {
                    scroll
                }
                list
            }
        }
        .frame(
            minWidth: scrollViewSize.width +
                PresentationView.Constants.controlsWidth +
                PresentationView.Constants.windowPadding,
            minHeight: scrollViewSize.height +
                PresentationView.Constants.windowPadding
        )
        .aspectRatio(1, contentMode: .fit)
    }

    public init(document: VODesignDocumentPresentation) {
        _document = .init(initialValue: document)
        _selectedControl = .init(initialValue: document.flatControls.first)
    }

    @ViewBuilder
    private var scroll: some View {
        ScrollView([.horizontal, .vertical]) {
            scrollContent
                .accessibilityHidden(true)
                .overlay(alignment: .topLeading) {
                    controls
                }
                .frame(
                    width: document.imageSizeScaled.width * minimalScaleFactor,
                    height: document.imageSizeScaled.height * minimalScaleFactor
                )
                .scaleEffect(CGSize(width: minimalScaleFactor,
                                    height: minimalScaleFactor))
        }
    }

    @ViewBuilder
    private var scrollContent: some View {
        if let image = document.image {
            Image(nsImage: image)
                .resizable()
                .frame(
                    width: document.imageSizeScaled.width,
                    height: document.imageSizeScaled.height
                )
        } else {
            Color.clear
                .frame(width: document.imageSize.width,
                       height: document.imageSize.height)
        }
    }

    private var controls: some View {
        ZStack(alignment: .topLeading) {
            // TODO: label as id - bad idea. We should provide truly unique id.
            // We don't need editing here so id can be generated at start
            ForEach(document.controls, id: \.label) { control in
                switch control.cast {
                    case .container(let container):
                        controlContainer(container)
                    case .element(let element):
                        controlElement(element)
                }
            }
        }
    }

    private func controlContainer(_ container: A11yContainer) -> some View {
        ZStack(alignment: .topLeading) {
            controlRectangle(container)
                .zIndex(-1)
                .accessibilityLabel(container.label)
            ForEach(container.elements, id: \.label) {
                controlElement($0)
            }
        }
        // TODO: accessibility modifiers
    }

    private func controlElement(_ element: A11yDescription) -> some View {
        controlRectangle(element)
            .accessibilityHidden(!element.isAccessibilityElement)
            .accessibilityLabel(element.label)
            .accessibilityHint(element.hint)
            .accessibilityValue(element.value)
//                            .accessibilityAddTraits(element.trait)
//                            adjustableOptions: AdjustableOptions,
//                            customActions: A11yCustomActions
    }

    @ViewBuilder
    private func controlRectangle(_ control: any AccessibilityView) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .foregroundStyle(
                { () -> SwiftUI.Color in
                    switch (isControlSelected(control), isControlHovered(control)) {
                        case (true, _):
                            return Color(nsColor: control.color.withSystemEffect(.deepPressed))
                        case (false, true):
                            return Color(nsColor: control.color.withSystemEffect(.pressed))
                        case (false, false):
                            return Color(nsColor: control.color)
                    }
                }()
            )
            .offset(
                x: control.frame.origin.x,
                y: control.frame.origin.y
            )
            .frame(width: control.frame.width, height: control.frame.height)
            .onHover { inside in
                withAnimation(Constants.animation) {
                    if inside {
                        hoveredControl = control
                    } else {
                        hoveredControl = nil
                    }
                }
            }
            .onTapGesture {
                select(control)
            }
            .contentShape(
                Rectangle()
                    .offset(
                        x: control.frame.origin.x,
                        y: control.frame.origin.y
                    )
            )
    }

    // MARK: - List

    private var list: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(document.controls.enumerated()), id: \.1.label) { index, control in
                Group {
                    switch control.cast {
                        case .container(let container):
                            VStack(alignment: .leading, spacing: 4) {
                                controlText(container)
                                ForEach(container.elements, id: \.label) { element in
                                    controlText(element)
                                        .padding(.leading, 16)
                                        .overlay(alignment: .leadingFirstTextBaseline) {
                                            if let index = document.flatControls.firstIndex(of: element) {
                                                listButton(
                                                    element,
                                                    index: index
                                                )
                                            }
                                        }
                                }
                            }
                            .padding(
                                .vertical,
                                isControlSelected(control) ? Constants.selectedControlPadding : 0
                            )
                        case .element(let element):
                            controlText(element)
                                .overlay(alignment: .leading) {
                                    if let index = document.flatControls.firstIndex(of: element) {
                                        listButton(element, index: index)
                                    }
                                }
                    }
                }
            }
        }
        .padding(.leading, 24)
        .padding(8)
        .frame(width: 300, alignment: .leading)
    }

    private func listButton(
        _ element: A11yDescription,
        index: Int
    ) -> some View {
        Group {
            if
                isControlSelected(element),
                element.adjustableOptions.options.count > 1
            {
                VStack {
                    Button {
                        element.adjustableOptions.accessibilityIncrement()
                        document.update(control: element)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    .buttonStyle(.borderless)
                    .disabled(!element.adjustableOptions.canIncrement)
                    Button {
                        element.adjustableOptions.accessibilityDecrement()
                        document.update(control: element)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                    .keyboardShortcut(.downArrow, modifiers: [])
                    .buttonStyle(.borderless)
                    .disabled(!element.adjustableOptions.canDecrement)
                }
            }
            if
                let previousItem = document.flatControls[safe: index - 1],
                isControlSelected(previousItem)
            {
                Button {
                    if let nextItem = document.flatControls[safe: index] {
                        select(nextItem)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .buttonStyle(.borderless)
            }
            if
                let nextItem = document.flatControls[safe: index + 1],
                isControlSelected(nextItem)
            {
                Button {
                    if let previousItem = document.flatControls[safe: index] {
                        select(previousItem)
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .buttonStyle(.borderless)
            }
        }
        .padding(.leading, -24)
    }

    @ViewBuilder
    private func controlText(_ control: any AccessibilityView) -> some View {
        Group {
            switch control.cast {
                case .container(let container):
                    Text(container.label)
                        .font(isControlSelected(control) ? .headline : .body)
                        .multilineTextAlignment(.leading)
                        .overlay(alignment: .leading) {
                            Image(systemName: "chevron.forward")
                                .padding(.leading, -12)
                                .opacity(0.6)
                        }
                        .padding(
                            .vertical,
                            isControlSelected(control) ? Constants.selectedControlPadding : 0
                        )
                case .element(let element):
                    Text(AttributedString(
                        element
                            .voiceOverTextAttributed(font: .preferredFont(
                                forTextStyle: isControlSelected(control) ? .headline : .body
                            ))
                    ))
                    .multilineTextAlignment(.leading)
                    .padding(
                        .vertical,
                        isControlSelected(control) ? Constants.selectedControlPadding : 0
                    )
            }
        }
    }

    func select(_ control: any AccessibilityView) {
        guard control is A11yDescription else { return }
        withAnimation(Constants.animation) {
            selectedControl = control
        }
    }

    func isControlSelected(_ control: any AccessibilityView) -> Bool {
        control.cast == selectedControl?.cast
    }

    func isControlHovered(_ control: any AccessibilityView) -> Bool {
        control.cast == hoveredControl?.cast
    }
}

extension Collection {
    private func distance(from startIndex: Index) -> Int {
        distance(from: startIndex, to: self.endIndex)
    }

    private func distance(to endIndex: Index) -> Int {
        distance(from: self.startIndex, to: endIndex)
    }

    subscript(safe index: Index) -> Iterator.Element? {
        if distance(to: index) >= 0 && distance(from: index) > 0 {
            return self[index]
        }
        return nil
    }
}

#if DEBUG

private let controls: [any AccessibilityView] = [
    A11yContainer(
        id: UUID(),
        elements: [
            A11yDescription(
                id: UUID(),
                isAccessibilityElement: true,
                label: "Long long long long long long long long long long long name",
                value: "",
                hint: "",
                trait: .button,
                frame: .init(x: 100, y: 100, width: 50, height: 50),
                adjustableOptions: .init(options: []),
                customActions: .defaultValue
            ),
            A11yDescription(
                id: UUID(),
                isAccessibilityElement: true,
                label: "Next element",
                value: "25",
                hint: "",
                trait: .adjustable,
                frame: .init(x: 120, y: 120, width: 60, height: 60),
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
        id: UUID(),
        isAccessibilityElement: true,
        label: "haha",
        value: "1",
        hint: "Some hint",
        trait: .adjustable,
        frame: .init(x: 10, y: 10, width: 50, height: 50),
        adjustableOptions: .init(options: ["1", "2"], currentIndex: 1),
        customActions: .defaultValue
    ),
    A11yDescription(
        id: UUID(),
        isAccessibilityElement: true,
        label: "wow",
        value: "",
        hint: "",
        trait: .button,
        frame: .init(x: 150, y: 250, width: 80, height: 20),
        adjustableOptions: .init(options: []),
        customActions: .defaultValue
    )
]

private let previewDocument = VODesignDocumentPresentation(
    controls: controls,
    flatControls: controls.flatMap {
        switch $0.cast {
            case .container(let container):
                return container.elements
            case .element(let element):
                return [element]
        }
    },
    image: nil,
    imageSize: .init(width: 300, height: 300),
    frameInfo: .default
)

#Preview {
    PresentationView(document: previewDocument)
}

#endif
