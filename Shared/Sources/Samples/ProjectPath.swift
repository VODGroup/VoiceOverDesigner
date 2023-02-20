import Foundation

class ProjectPath {
    static let repository = URL(string: "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main")!
    
    init(
        document: DocumentPath,
        cacheFolder: @escaping () -> URL =  FileManager.default.samplesCacheFolder
    ) {
        self.document = document
        self.cacheFolder = cacheFolder
    }
    
    private let document: DocumentPath
    private let cacheFolder: () -> URL
    
    func documentBaseURL() -> URL {
        documentLoadingPath(base: Self.repository
            .appendingPathComponent(document.relativePath))
    }
    
    static func structurePath() -> URL {
        Self.repository.appendingPathComponent("structure.json")
    }
    
    func documentLoadingPath(base: URL) -> URL {
        base
            .appendingPathComponent(document.name)
            .appendingPathExtension("vodesign")
    }
    
    func cachePath() -> URL {
        return cacheFolder()
            .appendingPathComponent(document.relativePath)
            .appendingPathComponent(document.name)
            .appendingPathExtension("vodesign")
    }
    
    func files(of document: DocumentPath) -> [URL] {
        let fileDocument = documentBaseURL()
        
        return document.files.map { file in
            fileDocument.appendingPathComponent(file)
        }
    }
    
    
}

extension FileManager {
    func cacheFolder() -> URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("com.akaDuality.VoiceOver-Designer")
    }
    
    func samplesCacheFolder() -> URL {
        cacheFolder()
            .appendingPathComponent("Samples")
    }
}
