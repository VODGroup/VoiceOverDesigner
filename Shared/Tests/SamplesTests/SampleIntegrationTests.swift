@testable import Samples
import XCTest

final class SampleIntegrationTests: XCTestCase {
    func test_download() async throws {
        let sut = SampleLoader(document: pizzaProject)

        XCTAssertFalse(sut.isFullyLoaded())
        let documentPath = try! await sut.download()
        XCTAssertTrue(sut.isFullyLoaded())
        
        addTeardownBlock {
            // Clear cache
            try FileManager.default.removeItem(at: documentPath)
        }
    }
}

final class SamplesIntegrationTests: XCTestCase {
    
    func test_loadStructure() async throws {
        let sut = SamplesLoader()
        
        let structure = try await sut.loadStructure()
        
        XCTAssertFalse(structure.languages.isEmpty)
        // TODO: Test another properties?
    }
}
