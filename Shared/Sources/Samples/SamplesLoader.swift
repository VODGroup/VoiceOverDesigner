import Foundation

public class SamplesLoader {
    
    public init() {}
    
    public func loadStructure() async throws -> SamplesStructure {
        let (data, _) = try await URLSession.shared
            .data(from: ProjectPath.structurePath())
        
        let structure = try structure(from: data)
        
        try? dataCache.save(data: data, to: structurePath)
        
        return structure
    }
    
    private func structure(from data: Data) throws -> SamplesStructure {
        try JSONDecoder()
            .decode(SamplesStructure.self, from: data)
    }
    
    public func prefetchedStructure() -> SamplesStructure? {
        guard let data = try? Data(contentsOf: structurePath) else {
            return nil
        }
        
        let structure = try? structure(from: data)
        
        return structure
    }
    
    private var structurePath: URL {
        FileManager.default
            .samplesCacheFolder()
            .appendingPathComponent("structure.json")
    }
    
    let dataCache = DataCache()
}
