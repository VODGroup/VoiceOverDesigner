import XCTest

class DocumentTests: DesignerTests {
    
    func createNewProject() {
        projects
            .createNewProject()
        
        project
            .selectNewWindow()
    }
    
    override func setUp() {
        super.setUp()
        
        createNewProject()
    }
    
    override func tearDownWithError() throws {
        project.close(delete: true)
    }
}
