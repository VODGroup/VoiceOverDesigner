import XCTest

class DocumentTests: DesignerTests {
    
    override func setUp() {
        super.setUp()
        
        projects.createNewProject()
    }
    
    override func tearDownWithError() throws {
        project.close(delete: true)
    }
}
