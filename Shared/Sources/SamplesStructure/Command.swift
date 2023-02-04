import Foundation
import ArgumentParser
import Samples

@available(macOS 13.0, *)
@main
struct GenerateStructure: ParsableCommand {
    
    @Argument(help: "Path for samples folder")
    var path: String?

    mutating func run() throws {
        let fileManager = FileManager.default
        let currentFolder = path ?? fileManager.currentDirectoryPath
        print(currentFolder)
        
        let structure = try StructureReader().run(currentFolder: currentFolder)
        dump(structure)
        
        try write(structure, to: currentFolder)
    }
    
    func write(_ structure: SamplesStructure, to folder: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(structure)
        
        let file = URL(filePath: folder).appendingPathComponent("structure.json")
        print("Will write to file \(file)")
        try data.write(to: file)
    }
}
