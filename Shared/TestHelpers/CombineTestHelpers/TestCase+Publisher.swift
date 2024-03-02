import Combine
import XCTest

extension XCTestCase {
    
    @discardableResult
    public func perform<T: Publisher>(
        _ action: () async -> Void,
        thenAwait publisher: T,
        numberOfCall: Int = 1,
        file: StaticString = #file,
        line: UInt = #line) async throws -> T.Output
    {
        return try await awaitPublisher(
            publisher,
            numberOfCall: numberOfCall,
            after: {
                _ = await action()
            }, file: file, line: line)
    }
    
    @discardableResult
    public func awaitPublisher<T: Publisher>(
        _ publisher: T,
        numberOfCall: Int = 1,
        timeout: TimeInterval = 1,
        after action: () async -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        expectation.expectedFulfillmentCount = numberOfCall
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                expectation.fulfill()
                result = .success(value)
            }
        )
        
        await action()
        await fulfillment(of: [expectation], timeout: timeout)
        
        cancellable.cancel()
        
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        
        return try unwrappedResult.get()
    }
}
