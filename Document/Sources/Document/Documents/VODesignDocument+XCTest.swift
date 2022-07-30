#if canImport(XCTest) && canImport(AppKit)

import Foundation

extension VODesignDocument {
    public static func testDocument(
        name: String,
        saveImmediately: Bool = false
    ) -> VODesignDocument {
        let document = VODesignDocument(file: testURL(name: name))
        if saveImmediately {
            document.save()
        }
        return document
    }
    
    public static func removeTestDocument(name: String) throws {
        try FileManager.default
            .removeItem(at: testURL(name: name))
    }
    
    public static func testURL(name: String) -> URL {
        return Self.path
            .appendingPathComponent("\(name).vodesign",
                                    isDirectory: false)
    }
    
    public static var path: URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first!
    }
    
    public func save() {
        save(to: fileURL!, ofType: Self.vodesign, for: .saveOperation) { error in
            Swift.print(error)
            // TODO: Handle
        }
    }
    
    public func read() throws {
        try read(from: fileURL!, ofType: Self.vodesign)
    }
}
#endif
