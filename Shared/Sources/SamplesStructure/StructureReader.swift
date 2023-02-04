import Foundation
import Samples

@available(macOS 13.0, *)
struct StructureReader {
    let fileManager = FileManager.default
    
    func run(currentFolder: URL) throws -> SamplesStructure {
        let languages = try fileManager.folders(at: currentFolder)
        print("Languages: \(languages)")
        
        var result: [String: [Project]] = [:]
        for language in languages {
            let projects = try projects(language: language, path: currentFolder)
            result[language] = projects
        }
        
        return SamplesStructure(languages: result)
    }
    
    private func projects(language: String, path: URL) throws -> [Project] {
        print(language)
        let langFolder = path.appendingPathComponent(language)
        let projects = try fileManager.folders(at: langFolder)
        
        var result: [Project] = []
        for project in projects {
            print("     \(project)")
            let documentFolder = langFolder.appendingPathComponent(project)

            let documents = try documents(language: language,
                                          project: project,
                                          projectFolder: documentFolder)
            
            let projectRef = Project(name: project, documents: documents)
            result.append(projectRef)
            print("     \(projectRef)")
        }
        
        return result
    }

    private func documents(
        language: String,
        project: String,
        projectFolder: URL
    ) throws -> [DocumentPath] {
        let documents = try fileManager.vodesign(at: projectFolder)
        
        var result: [DocumentPath] = []
        for document in documents {
            let documents = documentPath(language: language,
                                         project: project,
                                         documentWithExtension: document)
            result.append(documents)
        }
        
        return result
    }
    
    private func documentPath(
        language: String,
        project: String,
        documentWithExtension: String
    ) -> DocumentPath {
        let documentName = documentWithExtension.components(separatedBy: ".")
            .dropLast().joined(separator: ".")
        
        return DocumentPath(
            relativePath: URL(filePath: language).appendingPathComponent(project).path,
            name: documentName,
            files: [],
            fileSize: 0, version: 1)
    }
}
