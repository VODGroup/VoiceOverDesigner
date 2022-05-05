//
//  EditorPresenterTests.swift
//  VoiceOver DesignerTests
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import XCTest
@testable import Editor
import Document

class EditorPresenterTests: XCTestCase {

    var sut: EditorPresenter!
    var router: RouterMock!
    
    var controller: NSViewController!
    
    override func setUp() {
        super.setUp()
        
        controller = EmptyViewController()
        
        sut = EditorPresenter()
        sut.document = VODesignDocument(fileName: "Test",
                                        rootPath: URL(fileURLWithPath: ""))
        
        router = RouterMock()
        sut.didLoad(ui: controller.view, router: router)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: sut.document.fileURL!)
        super.tearDown()
    }
    
    private let start = CGPoint(x: 10, y: 10)
    private let end   = CGPoint(x: 30, y: 30)
    
    // MARK: Drawning
    func test_rectangleDrawnOnTheFly() {
        sut.mouseDown(on: start)
        sut.mouseDragged(on: end)
        
        XCTAssertEqual(controller.view.layer?.sublayers?.first?.frame,
                       CGRect(x: 10, y: 10, width: 20, height: 20), "Draw")
        
        XCTAssertNil(sut.document.controls.first, "but not saved yet")
    }
    
    func test_drawRectangle_onMouseUp() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: end)
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(x: 10, y: 10, width: 20, height: 20))
    }
    
    func test_drawInReverseDirection() {
        sut.mouseDown(on: end)
        sut.mouseUp(on: start)
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(x: 10, y: 10, width: 20, height: 20))
    }
    
    // MARK: Editing
//    func test_movementFor5px_shouldTranslateRect() {
//        drawRect()
//        
//        // Move
//        sut.mouseDown(on: CGPoint(x: 15, y: 15))
//        sut.mouseDragged(on: CGPoint(x: 20, y: 20))
//        
//        XCTAssertEqual(sut.document.controls.count, 1)
//        XCTAssertEqual(sut.document.controls.first?.frame,
//                       CGRect(x: 15, y: 15, width: 20, height: 20))
//    }
    
    // MARK: Routing
    func test_openSettings() {
        drawRect()
        
        sut.mouseDown(on: CGPoint(x: 10, y: 10))
        XCTAssertNil(router.didShowSettingsForControl)
        
        sut.mouseUp(on: CGPoint(x: 12, y: 12))
        
        XCTAssertNotNil(router.didShowSettingsForControl)
    }
    
    // MARK: - DSL
    func drawRect() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: end)
    }
}


class EmptyViewController: NSViewController {
    
    private lazy var contentView = NSView()
    
    override func loadView() {
        view = contentView
        view.layer = CALayer()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

import Settings
class RouterMock: RouterProtocol {
    var didShowSettingsForControl: A11yControl?
    func showSettings(for control: A11yControl, delegate: SettingsDelegate) {
        didShowSettingsForControl = control
    }
}
