import Foundation

public struct SamplesStructure: Codable, Equatable {
    public init(languages: [String : [Project]]) {
        self.languages = languages
    }
    
    public let languages: [String:[Project]]
}

public struct Project: Codable, Equatable {
    public init(name: String, documents: [DocumentPath]) {
        self.name = name
        self.documents = documents
    }
    
    public let name: String
    public let documents: [DocumentPath]
}

public struct DocumentPath: Equatable {
    public init(relativePath: String, name: String, files: [String], fileSize: Int, version: Int) {
        self.relativePath = relativePath
        self.name = name
        self.files = files
        self.fileSize = fileSize
        self.version = version
    }
    
    public let relativePath: String
    public let name: String
    public let files: [String]
    /// In kilobytes
    public let fileSize: Int
    public let version: Int
}

extension DocumentPath: Codable {}
