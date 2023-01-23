import Foundation

extension VODesignDocument {
    public static func quickLook(documentURL: URL) -> URL {
        documentURL
            .appendingPathComponent(QuickLookFolderName)
            .appendingPathComponent(QuickLookFileName)
    }
}
