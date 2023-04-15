import XCTest
@testable import CanvasAppKit

class EmptyViewController: NSViewController {
    
    private lazy var contentView = NSView()
    
    let controlsView = ContentView()
    
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
