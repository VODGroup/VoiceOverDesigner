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
    
    override func setUp() {
        super.setUp()
        
        let controller = EmptyViewController()
        
        sut = EditorPresenter()
        sut.document = VODesignDocument(fileName: "Test",
                                        rootPath: URL(fileURLWithPath: ""))
        
        router = RouterMock()
        sut.didLoad(ui: controller.view, router: router)
    }
    
    private let start = CGPoint(x: 10, y: 10)
    private let end   = CGPoint(x: 30, y: 30)
    
    // MARK: Drawning
    func test_rectangleDrawnOnTheFly() {
        sut.mouseDown(on: start)
        sut.mouseDragged(on: end)
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(x: 10, y: 10, width: 20, height: 20))
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
    
    // MARK: Routing
    func test_openSettings() {
        sut.mouseDown(on: CGPoint(x: 10, y: 10))
        sut.mouseUp(on: CGPoint(x: 12, y: 12))
        
        XCTAssertNotNil(router.didShowSettingsForControl)
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
