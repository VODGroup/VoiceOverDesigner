import Foundation

class ProjectPath {
    static let repository = URL(string: "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main")!
    
    init(document: DocumentPath) {
        self.document = document
    }
    
    private let document: DocumentPath
    
    func documentBaseURL() -> URL {
        resultDocumentPath(for: Self.repository
            .appendingPathComponent(document.relativePath))
    }
    
    static func structurePath() -> URL {
        Self.repository.appendingPathComponent("structure.json")
    }
    
    func resultDocumentPath(for base: URL) -> URL {
        base
            .appendingPathComponent(document.name)
            .appendingPathExtension("vodesign")
    }
    
    func cachaPath() -> URL {
        let resultDocumentPath = resultDocumentPath(for: cacheFolder())
        return resultDocumentPath
    }
    
    func files(of document: DocumentPath) -> [URL] {
        let fileDocument = documentBaseURL()
        
        return document.files.map { file in
            fileDocument.appendingPathComponent(file)
        }
    }
    
    func cacheFolder() -> URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("com.akaDuality.VoiceOver-Designer")
            .appendingPathExtension("Samples")
    }
}
