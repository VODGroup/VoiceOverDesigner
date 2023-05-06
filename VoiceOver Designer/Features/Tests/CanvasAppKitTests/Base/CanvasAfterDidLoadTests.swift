@testable import Canvas

class CanvasAfterDidLoadTests: CanvasPresenterTests {
    override func setUp() {
        super.setUp()
        
        didLoadAndAppear()
    }
    
    func setupManualCopyCommand() -> ManualCopyCommand {
        let copyCommand = ManualCopyCommand()
        controller.controlsView.copyListener = copyCommand
        return copyCommand
    }
}
