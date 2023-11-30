//
//  SwiftUIView.swift
//  
//
//  Created by Alex Agapov on 29.09.2023.
//

import CustomDump
import SwiftUI
import Document

public struct PresentationView: View {

    public enum Constants {
        public static let controlsWidth: CGFloat = 500
        public static let leadingSpacer: CGFloat = 100
        public static let cursorButtonPadding: CGFloat = 24

        static let selectedControlPadding: CGFloat = 40
    }

    @StateObject var model: PresentationModel

    let scrollViewSize = CGSize(width: 600, height: 900)

    var minimalScaleFactor: CGFloat {
        guard 
            model.document.imageSize.width != 0,
            model.document.imageSize.height != 0
        else {
            return 1
        }
        let h = scrollViewSize.width / model.document.imageSize.width
        let v = scrollViewSize.height / model.document.imageSize.height

        // TODO: Add minimal limit for long documents
        return min(h, v)
    }

    public init(model: PresentationModel) {
        self._model = .init(wrappedValue: model)
    }

    public var body: some View {
        ZStack {
            Color.clear
            HStack {
                Spacer(minLength: PresentationView.Constants.leadingSpacer)
                if #available(macOS 13.0, *) {
                    canvasScroll
                        .scrollIndicators(.never)
                        .scrollDisabled(true)
                } else {
                    canvasScroll
                }
                list
            }
            .onKeyboardShortcut(key: .leftArrow, modifiers: []) {
                model.handle(.prev)
            }
            .onKeyboardShortcut(key: .rightArrow, modifiers: []) {
                model.handle(.next)
            }
        }
        .frame(
            minWidth: scrollViewSize.width +
                Constants.leadingSpacer +
                Constants.controlsWidth,
            minHeight: scrollViewSize.height
        )
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
                    width: model.document.imageSize.width * minimalScaleFactor,
                    height: model.document.imageSize.height * minimalScaleFactor
                )
                .scaleEffect(CGSize(width: minimalScaleFactor,
                                    height: minimalScaleFactor))
        }
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let image = model.document.image {
            Image(nsImage: image)
                .resizable()
                .frame(
                    width: model.document.imageSize.width,
                    height: model.document.imageSize.height
                )
        } else {
            Color.gray
                .opacity(0.25)
                .frame(width: model.document.imageSize.width,
                       height: model.document.imageSize.height)
        }
    }

    private var controlsOverlay: some View {
        ZStack(alignment: .topLeading) {
            // We don't need editing here so id can be generated at start
            ForEach(model.document.orderedControls, id: \.id) { control in
                switch control.cast {
                    case .container(let container):
                        controlContainer(container)
                    case .element(let element):
                        controlElement(element)
                    case .frame(_):
                        // TODO: Add frame
                        fatalError()
                }
            }
        }
    }

    private func controlContainer(_ container: A11yContainer) -> some View {
        ZStack(alignment: .topLeading) {
            controlRectangle(container)
                .zIndex(-1)
                .accessibilityLabel(container.label)
            // TODO: extractElements doesn't see anything inside container
            ForEach(container.elements.extractElements(), id: \.id) {
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
    private func controlRectangle(_ control: any ArtboardElement) -> some View {
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
                model.handle(.hover(control, inside))
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
        ScrollView {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(model.document.orderedControls), id: \.id) { item in
                        listItem(item)
                    }
                }
                .padding(EdgeInsets(top: 80, leading: Constants.cursorButtonPadding, bottom: 80, trailing: 80))
                // Frame's width should be fixed. Otherwise hover effect brakes for long text
                // For long text list's width recalculates and hover lose y coordinate
                .frame(width: PresentationView.Constants.controlsWidth)
                .onChange(of: model.selectedControl, perform: { newValue in
                    if let newValue {
                        withAnimation(PresentationModel.Constants.animation) {
                            proxy.scrollTo(newValue.id, anchor: .center)
                        }
                    }
                })
            }
            .accessibilityHidden(true) // VoiceOver should read elements over the image
        }
    }

    @ViewBuilder
    private func listItem(
        _ item: any ArtboardElement
    ) -> some View {
        switch item.cast {
        case .container(let container):
            VStack(alignment: .leading, spacing: 4) {
                controlText(container)
                // TODO: Should not be extractElements. Should be able to render any number of layers inside
                ForEach(container.elements.extractElements(), id: \.id) { element in
                    controlText(element)
                        .id(element.id)
                        .overlay(alignment: .leading) {
                            if let index = model.document.flatControls.firstIndex(of: element.id) {
                                listButton(element, index: index)
                            }
                        }.onTapGesture {
                            select(element)
                        }
                        .padding(.horizontal, 16)
                }
            }
        case .element(let element):
            controlText(element)
                .id(element.id)
                .overlay(alignment: .leading) {
                    if let index = model.document.flatControls.firstIndex(of: element.id) {
                        listButton(element, index: index)
                    }
                }.onTapGesture {
                    select(element)
                }

        case .frame(let frame):
            VStack(alignment: .leading, spacing: 4) {
                controlText(frame)
                Text("Frame todo")
                // Should be listItem
            }
        }
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
                        model.handle(.increment(element))
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    .buttonStyle(.borderless)
                    .disabled(!element.adjustableOptions.canIncrement)
                    Button {
                        model.handle(.decrement(element))
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                    .keyboardShortcut(.downArrow, modifiers: [])
                    .buttonStyle(.borderless)
                    .disabled(!element.adjustableOptions.canDecrement)
                }
            }
            if
                let previousItemId = model.document.flatControls[safe: index - 1],
                let previousItem = model.document.controls[previousItemId],
                isControlSelected(previousItem)
            {
                Button {
                    if let nextItemId = model.document.flatControls[safe: index],
                       let nextItem = model.document.controls[nextItemId] {
                        select(nextItem)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .buttonStyle(.borderless)
            }
            if
                let nextItemId = model.document.flatControls[safe: index + 1],
                let nextItem = model.document.controls[nextItemId],
                isControlSelected(nextItem)
            {
                Button {
                    if let previousItemId = model.document.flatControls[safe: index],
                       let previousItem = model.document.controls[previousItemId] {
                        select(previousItem)
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.leading, -Constants.cursorButtonPadding)
    }

    @ViewBuilder
    private func controlText(_ control: any ArtboardElement) -> some View {
        Group {
            switch control.cast {
                case .container(let container):
                    Text(container.label)
                        .font(font(for: container))
                        .multilineTextAlignment(.leading)
                        .overlay(alignment: .leading) {
                            Image(systemName: "chevron.forward")
                                .padding(.leading, -12)
                                .opacity(0.6)
                        }
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
                case .frame(let frame):
                    Text(frame.label)
                        .font(font(for: frame))
                        .multilineTextAlignment(.leading)
                        .overlay(alignment: .leading) {
                            Image(systemName: "chevron.forward")
                                .padding(.leading, -12)
                                .opacity(0.6)
                        }
            }
        }
    }
    
    private func font(for control: any ArtboardElement) -> NSFont {
        let isSelected = isControlSelected(control)
        
        return .preferredFont(forTextStyle: isSelected ? .headline : .footnote)
            .withSize(isSelected ? 40 : 20)
    }
    
    private func font(for container: A11yContainer) -> SwiftUI.Font {
        Font.system(size: 20)
    }

    private func font(for frame: Frame) -> SwiftUI.Font {
        Font.system(size: 20)
    }

    func select(_ control: any ArtboardElement) {
        model.handle(.select(control))
    }

    func isControlSelected(_ control: any ArtboardElement) -> Bool {
        control.cast == model.selectedControl?.cast
    }

    func isControlHovered(_ control: any ArtboardElement) -> Bool {
        control.cast == model.hoveredControl?.cast
    }
}

extension View {
    /// Adds an underlying hidden button with a performing action that is triggered on pressed shortcut
    /// - Parameters:
    ///   - key: Key equivalents consist of a letter, punctuation, or function key that can be combined with an optional set of modifier keys to specify a keyboard shortcut.
    ///   - modifiers: A set of key modifiers that you can add to a gesture.
    ///   - perform: Action to perform when the shortcut is pressed
    public func onKeyboardShortcut(key: KeyEquivalent, modifiers: EventModifiers = .command, perform: @escaping () -> ()) -> some View {
        ZStack {
            Button("") {
                perform()
            }
            .opacity(0)
            .keyboardShortcut(key, modifiers: modifiers)

            self
        }
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
        
        self.init(model: .init(document: presentation))
    }
    
    static func make(sampleRelativePath: String) -> PresentationView {
        PresentationView(path: samplesURL.appendingPathComponent(sampleRelativePath + ".vodesign"))
    }
}

let id = UUID()
let id2 = UUID()
let id3 = UUID()
let id4 = UUID()

let frame1 = CGRect(x: 30, y: 30, width: 20, height: 20)
let frame2 = CGRect(x: 70, y: 70, width: 20, height: 20)
let frame3 = CGRect(x: 170, y: 170, width: 40, height: 40)

let samplesURL = URL(fileURLWithPath: "/Users/agpone/Developer/VoiceOverSamples")
#Preview {
    Group {
//        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Главная страница")
//        PresentationView.make(sampleRelativePath: "Ru/Dodo Pizza/Меню")
//        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Авиа фильтры")
//        PresentationView.make(sampleRelativePath: "Ru/OneTwoTrip/Пассажиры")
    }
}

#endif
