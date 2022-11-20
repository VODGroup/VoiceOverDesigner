import Foundation

let QuickLookFolderName = "QuickView"
let QuickLookFileName = "Preview.png"

extension VODesignDocument {
    public static func quickLook(documentURL: URL) -> URL {
        documentURL
            .appendingPathComponent(QuickLookFolderName)
            .appendingPathComponent(QuickLookFileName)
    }
}
