//
//  PresentationModelTests.swift
//
//
//  Created by Alex Agapov on 05.11.2023.
//

@testable import Presentation
import CustomDump
import Foundation
import XCTest
import Document

final class PresentationModelTests: XCTestCase {

    var model: PresentationModel!

    override func setUp() {
        model = .init(
            document: {
                let document = VODesignDocument()
                let artboard = Artboard(
                    frames: [
                        .init(
                            label: "",
                            imageName: "",
                            frame: .zero,
                            elements: [
                                fakeDescription(
                                    uuid: uuid_fake(0),
                                    trait: .header
                                ),
                                fakeContainer(
                                    uuid: uuid_fake(9),
                                    elements: [
                                        fakeDescription(
                                            uuid: uuid_fake(1),
                                            trait: .button
                                        )
                                    ]
                                )
                            ]
                        )
                    ],
                    controlsWithoutFrames: []
                )
                artboard.imageLoader = DummyImageLoader()
                document.artboard = artboard
                return .init(document)
            }()
        )
    }

    public func test_model_initialSetup() {
        XCTAssertNoDifference(
            model.selectedControl,
            fakeDescription(
                uuid: uuid_fake(0),
                trait: .header
            ) // 1st element
        )
    }

    public func test_model_nextAction_triggersChange() {
        model.handle(.next)
        XCTAssertNoDifference(
            model.selectedControl,
            fakeDescription(
                uuid: uuid_fake(1),
                trait: .button
            ) // 2nd element
        )
    }

    public func test_model_prevAction_triggersNoChange() {
        model.handle(.prev)
        XCTAssertNoDifference(
            model.selectedControl,
            fakeDescription(
                uuid: uuid_fake(0),
                trait: .header
            ) // 1st element
        )
    }

    public func test_model_hoverAction_activatesHoverOnOneElement() {
        XCTAssertNil(model.hoveredControl)
        model.handle(
            .hover(fakeDescription(uuid: uuid_fake(1), trait: .button), true)
        )
        XCTAssertNoDifference(
            model.hoveredControl?.cast,
            fakeDescription(
                uuid: uuid_fake(1),
                trait: .button
            ).cast
        )
    }

    public func test_model_hoverAction_deactivatesHoverOnOneElement() {
        model.handle(
            .hover(fakeDescription(uuid: uuid_fake(1), trait: .button), true)
        )
        XCTAssertNoDifference(
            model.hoveredControl?.cast,
            fakeDescription(
                uuid: uuid_fake(1),
                trait: .button
            ).cast
        )
        model.handle(
            .hover(fakeDescription(uuid: uuid_fake(1), trait: .button), false)
        )
        XCTAssertNil(model.hoveredControl)
    }
}

/// from 0 to 9
private func uuid_fake(_ number: Int) -> UUID {
    UUID(uuidString: "00000000-0000-0000-0000-00000000000\(number % 10)")!
}

private func fakeDescription(
    uuid: UUID,
    trait: A11yTraits
) -> A11yDescription {
    A11yDescription(
        id: uuid,
        isAccessibilityElement: true,
        label: "description",
        value: "",
        hint: "",
        trait: trait,
        frame: .zero,
        adjustableOptions: .init(options: []),
        customActions: .defaultValue
    )
}

private func fakeContainer(
    uuid: UUID,
    elements: [A11yDescription] = []
) -> A11yContainer {
    A11yContainer(
        id: uuid,
        elements: elements,
        frame: .zero,
        label: "container"
    )
}
