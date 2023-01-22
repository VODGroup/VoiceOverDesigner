import Foundation
import Document
import XCTest

public class Sample {
    
    public init() {}
    
    public func image(name: String) -> Image? {
#if os(macOS)
        return Bundle.module.image(forResource: name)
#elseif os(iOS)
        return Image(named: name, in: Bundle.module, with: nil)
#endif
    }
    
    public func documentPath(name: String) -> URL? {
        return Bundle.module.url(forResource: name, withExtension: "vodesign")
    }
    
    public func document(
        name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> VODesignDocument {
        let path = try XCTUnwrap(
            documentPath(name: name),
            file: file, line: line)
        
#if os(macOS)
        let document = VODesignDocument(file: path)
#elseif os(iOS)
        let document = VODesignDocument(fileURL: path)
#endif
        return document
    }
}
