//
//  EditorPresenterTests.swift
//  VoiceOver DesignerTests
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import XCTest
@testable import VoiceOver_Designer

class EditorPresenterTests: XCTestCase {

    func testExample() throws {
        let controller = EmptyViewController()
        
        let sut = EditorPresenter()
        sut.didLoad(ui: controller.view, controller: controller)
        
        sut.mouseDown(on: CGPoint(x: 10, y: 10))
        sut.mouseUp(on: CGPoint(x: 30, y: 30))
        
        XCTAssertEqual(sut.document.controls.first?.frame,
                       CGRect(x: 10, y: 10, width: 20, height: 20))
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
