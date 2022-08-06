import XCTest
@testable import Editor

class EmptyViewController: NSViewController {
    
    private lazy var contentView = NSView()
    
    let controlsView = ControlsView()
    
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
