import Samples
import XCTest

final class SampleIntegrationTests: XCTestCase {
    func test_download() async throws {
        let sut = SampleLoader()

        try! await sut.download(document: drinkitProject)
    }
    
    func test_loadStructure() async throws {
        let sut = SampleLoader()
        
        let structure = try await sut.loadStructure()
    }
}
