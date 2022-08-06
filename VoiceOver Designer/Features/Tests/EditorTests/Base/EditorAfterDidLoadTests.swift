@testable import Editor

class EditorAfterDidLoadTests: EditorTests {
    override func setUp() {
        super.setUp()
        
        didLoad()
    }
}
