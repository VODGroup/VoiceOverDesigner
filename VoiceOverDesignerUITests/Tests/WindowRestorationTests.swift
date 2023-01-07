import XCTest

class WindowRestorationTests: DesignerTests {
    func test_shouldRestoreEmptyDocument() throws {
        lauchApp()
        
        recent.createNewProject()
        
        recent.close()

        lauchApp()
        
        // TODO: Verify new document
    }
    
    func testRec() {
        lauchApp()
        
        
    }
}
