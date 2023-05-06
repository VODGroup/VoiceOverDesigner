@testable import Canvas

class CanvasAfterDidLoadTests: CanvasPresenterTests {
    override func setUp() {
        super.setUp()
        
        didLoad()
    }
    
    func setupManualCopyCommand() -> ManualCopyCommand {
        let copyCommand = ManualCopyCommand()
        controller.controlsView.copyListener = copyCommand
        return copyCommand
    }
}
