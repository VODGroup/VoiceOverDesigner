import XCTest

class DocumentTests: DesignerTests {
    
    override func setUp() {
        super.setUp()
        
//        projects.createNewProject() // It will be created automatically when there is no recent documents
    }
    
    override func tearDownWithError() throws {
        project.close(delete: true)
    }
}
