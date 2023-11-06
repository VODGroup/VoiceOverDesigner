import Foundation
import Document
import XCTest

public class Sample {
    
    public init() {}
    
    public static var image3xScale = "screenWith3xScale.png"
    
    public func image(name: String) throws -> Image {
#if os(macOS)
        return try XCTUnwrap(Bundle.module.image(forResource: name))
#elseif os(iOS)
        return try XCTUnwrap(Image(named: name, in: Bundle.module, with: nil))
#endif
    }
    
    public func image3x() -> Image {
        try! image(name: Sample.image3xScale)
    }
    
    public func documentPath(name: String) -> URL? {
        return Bundle.module.url(forResource: name, withExtension: "vodesign")
    }
    
    public func resourcesPath() -> URL {
        Bundle.module.resourceURL!
    }
    
    public func document(
        name: String,
        testCase: XCTestCase,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> VODesignDocument {
        let path = try XCTUnwrap(
            documentPath(name: name),
            file: file, line: line)
        
        let fileManager = FileManager.default
        let cacheFolder = fileManager.urls(for: .cachesDirectory,
                                           in: .userDomainMask).first!
        let copyPath = cacheFolder.appendingPathComponent(name)
        
        testCase.addTeardownBlock {
            try? FileManager.default.removeItem(at: copyPath)
        }
        
        try fileManager.copyItem(
            at: path,
            to: copyPath
        )
        
        
#if os(macOS)
        let document = VODesignDocument(file: copyPath)
#elseif os(iOS)
        let document = VODesignDocument(fileURL: copyPath)
#endif
        
        return document
    }
}
