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
    private let end   = CGPoint(x: 60, y: 60)
    private let rect  = CGRect(x: 10, y: 10, width: 50, height: 50)
    
    // MARK: Drawning
    func test_rectangleDrawnOnTheFly() {
        sut.mouseDown(on: start)
        sut.mouseDragged(on: end)
        
        XCTAssertEqual(controller.view.layer?.sublayers?.first?.frame,
                       rect, "Draw")
        
        XCTAssertNil(sut.document.controls.first, "but not saved yet")
    }
    
    func test_drawRectangle_onMouseUp() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: end)
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       rect)
    }
    
    func test_drawSmallerThanMinimalWidth_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: start.offset(x: 10, y: 50))
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(origin: CGPoint(x: 10 + 5 - 44/2,
                                              y: 10),
                              size: CGSize(width: 44, height: 50)))
    }
    
    func test_drawSmallerThanMinimalHeight_shouldIncreaseSizeToMinimal_andKeepCenter() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: start.offset(x: 50, y: 10))
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(origin: CGPoint(x: 10,
                                              y: 10 +  5 - 44/2),
                              size: CGSize(width: 50, height: 44)))
    }
    
    func test_notDrawIfSizeIsSmallerThan5px() {
        sut.mouseDown(on: start)
        sut.mouseUp(on: start.offset(x: 4, y: 4))
        
        XCTAssertNil(sut.document.controls.first)
    }
    
    func test_drawInReverseDirection() {
        sut.mouseDown(on: end)
        sut.mouseUp(on: start)
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       rect)
    }
    
    // MARK: Editing
    func test_movementFor5px_shouldTranslateRect() {
        drawRect()
        
        // Move
        sut.mouseDown(on: CGPoint(x: 15, y: 15))
        sut.mouseDragged(on: CGPoint(x: 17, y: 17))
        sut.mouseDragged(on: CGPoint(x: 18, y: 18))
        sut.mouseDragged(on: CGPoint(x: 20, y: 20)) // 5px from start
        
        XCTAssertEqual(sut.document.controls.count, 1)
        XCTAssertEqual(sut.document.controls.first?.frame,
                       rect.offsetBy(dx: 5, dy: 5))
        
        XCTAssertNil(router.didShowSettingsForControl, "Not open settings at the end of translation")
    }
    
    // MARK: Routing
    func test_openSettings() {
        drawRect()
        
        sut.mouseDown(on: CGPoint(x: 10, y: 10))
        XCTAssertNil(router.didShowSettingsForControl)
        
        sut.mouseUp(on: CGPoint(x: 10, y: 10)) // Slightly move is restricted
//        sut.mouseUp(on: CGPoint(x: 12, y: 12)) // Slightly move is possible
        
        XCTAssertNotNil(router.didShowSettingsForControl)
        XCTAssertEqual(sut.document.controls.first?.frame,
                       rect, "Keep frame")
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

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> Self {
        return CGPoint(x: self.x + x,
                       y: self.y + y)
    }
}
