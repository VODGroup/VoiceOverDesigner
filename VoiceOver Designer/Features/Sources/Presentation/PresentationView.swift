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
            document.imageSize.width != 0,
            document.imageSize.height != 0
        else {
            return 1
        }
        let h = scrollViewSize.width / document.imageSize.width
        let v = scrollViewSize.height / document.imageSize.height
        
        // TODO: Add minimal limit for long documents
        return min(h, v)
    }
    
    public var body: some View {
        ZStack {
            Color.clear
            HStack {
                if #available(macOS 13.0, *) {
                    canvasScroll
                        .scrollIndicators(.never)
                        .scrollDisabled(true)
                } else {
                    canvasScroll
                }
                ScrollView {
                    list
                }.accessibilityHidden(true) // VoiceOver should read elements over the image
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
    private var canvasScroll: some View {
        ScrollView([.horizontal, .vertical]) {
            backgroundImage
                .accessibilityHidden(true) // Hide image...
                .overlay(alignment: .topLeading) {
                    controlsOverlay // ... but reveal controls
                }
                .frame(
                    width: document.imageSize.width * minimalScaleFactor,
                    height: document.imageSize.height * minimalScaleFactor
                )
                .scaleEffect(CGSize(width: minimalScaleFactor,
                                    height: minimalScaleFactor))
        }
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let image = document.image {
            Image(nsImage: image)
                .resizable()
                .frame(
                    width: document.imageSize.width,
                    height: document.imageSize.height
                )
        } else {
            Color.clear
                .frame(width: document.imageSize.width,
                       height: document.imageSize.height)
        }
    }

    private var controlsOverlay: some View {
        ZStack(alignment: .topLeading) {
            // We don't need editing here so id can be generated at start
            ForEach(document.controls, id: \.id) { control in
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
            ForEach(container.elements, id: \.id) {
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
                    if isControlHovered(control) {
                        return Color(nsColor: control.color.withSystemEffect(.deepPressed))
                    } else {
                        return Color(nsColor: control.color)
                    }
                }()
            )
            .overlay {
                if isControlSelected(control) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.black, style: .init(lineWidth: 8))
                        .foregroundStyle(.clear)
                        .padding(-6) // Outer border
                }
            }
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
            ForEach(Array(document.controls.enumerated()), id: \.1.id) { index, control in
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
                                }.onTapGesture {
                                    select(element)
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
                            .voiceOverTextAttributed(
                                font: font(for: element),
                                breakParts: true
                            )
                    ))
                    .multilineTextAlignment(.leading)
                    .padding(
                        .vertical,
                        isControlSelected(control) ? Constants.selectedControlPadding : 0
                    )
            }
        }
    }
    
    private func font(for control: any AccessibilityView) -> NSFont {
        let isSelected = isControlSelected(control)
        
        return .preferredFont(forTextStyle: isSelected ? .headline : .footnote)
            .withSize(isSelected ? 30 : 20)
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

extension PresentationView {
    init(path: URL) {
        let document = VODesignDocument(file: path)
        let presentation = VODesignDocumentPresentation(document)
        
        self.init(document: presentation)
    }
    
    static func make(sampleRelativePath: String) -> PresentationView {
        PresentationView(path: samplesURL.appendingPathComponent(sampleRelativePath + ".vodesign"))
    }
}


let samplesURL = URL(fileURLWithPath: "/Users/mikhail/Developer/VoiceOverSamples")
#Preview {
    Group {
        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Главная страница")
        PresentationView.make(sampleRelativePath: "Ru/Dodo Pizza/Меню")
        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Авиа фильтры")
        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Пассажиры")
    }
}

#endif
