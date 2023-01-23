import Foundation

extension VODesignDocument {
    public static func quickLook(documentURL: URL) -> URL {
        documentURL
            .appendingPathComponent(FolderName.quickLook)
            .appendingPathComponent(FileName.quickLookFile)
    }
}
