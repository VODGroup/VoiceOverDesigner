@testable import Editor

class EditorAfterDidLoadTests: EditorPresenterTests {
    override func setUp() {
        super.setUp()
        
        didLoad()
    }
}
