@testable import Samples
import XCTest

final class SampleIntegrationTests: XCTestCase {
    func test_download() async throws {
        let sut = SampleLoader(document: drinkitProject)

        XCTAssertFalse(sut.isFullyLoaded())
        let url = try! await sut.download()
        XCTAssertTrue(sut.isFullyLoaded())
        
        addTeardownBlock {
            // Clear cache
            try FileManager.default.removeItem(at: sut.documentPathInCache)
        }
    }
}

final class SamplesIntegrationTests: XCTestCase {
    
    func test_loadStructure() async throws {
        let sut = SamplesLoader()
        
        let structure = try await sut.loadStructure()
    }
}
