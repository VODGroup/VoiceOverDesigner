import SnapshotTesting
import XCTest

/// https://jaanus.com/snapshot-testing-xcode-cloud/
/// - Parameters:
///   - testBundleResourceURL: Resource URL that contains a folder with the reference screenshots.
///     For SPM module tests, the folder will be named `__Snapshots__/TestClassName`.
///     For top-level app target tests, the folder will be named simply `TestClassName`.
public func assertSnapshot<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    testBundleResourceURL: URL,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    
    let testClassFileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
    let testClassName = testClassFileURL.deletingPathExtension().lastPathComponent
    
    let folderCandidates = [
        // For SPM modules.
        testBundleResourceURL.appendingPathComponent("__Snapshots__").appendingPathComponent(testClassName),
        // For top-level xcodeproj app target.
        testBundleResourceURL.appendingPathComponent(testClassName)
    ]
    
    // Default case: snapshots are not present in test bundle. This will fall back to standard SnapshotTesting behavior,
    // where the snapshots live in `__Snapshots__` folder that is adjacent to the test class.
    var snapshotDirectory: String? = nil
    
    for folder in folderCandidates {
        let referenceSnapshotURLInTestBundle = folder.appendingPathComponent("\(sanitizePathComponent(testName)).1.txt")
        if FileManager.default.fileExists(atPath: referenceSnapshotURLInTestBundle.path) {
            // The snapshot file is present in the test bundle, so we will instruct snapshot-testing to use the folder
            // pointing to the snapshots in the test bundle, instead of the default.
            // This is the code path that Xcode Cloud will follow, if everything is set up correctly.
            snapshotDirectory = folder.path
        }
    }
    
    let failure = SnapshotTesting.verifySnapshot(
        matching: try value(),
        as: snapshotting,
        record: false,
        snapshotDirectory: snapshotDirectory,
        file: file,
        testName: testName,
        line: line
    )
    
    if let message = failure {
        XCTFail(message, file: file, line: line)
    }
}

// Copied from swift-snapshot-testing
private func sanitizePathComponent(_ string: String) -> String {
    return string
        .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
        .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
}
