import Foundation

class DataCache {
    func downloadIfCacheIsEmpty(
        downloadUrl: URL,
        cacheUrl: URL
    ) async throws {
        guard !fileManager.fileExists(atPath: cacheUrl.path) else {
            return print("File is exists, skip loading: \(cacheUrl) ")
        }
        
        try await download(downloadUrl: downloadUrl, cacheUrl: cacheUrl)
    }
    
    func download(
        downloadUrl: URL,
        cacheUrl: URL
    ) async throws {
        let (data, response) = try await URLSession.shared.data(from: downloadUrl)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode == 200 else {
            print("Can't download \(downloadUrl)")
            return // no need to save other http responses
        }
        
        try save(data: data, to: cacheUrl)
    }
    
    
    func removeFile(at cacheURL: URL) throws {
        try fileManager.removeItem(at: cacheURL)
    }
    
    
    func hasFile(at cacheUrl: URL) -> Bool {
        fileManager.fileExists(atPath: cacheUrl.path)
    }
    
    private let fileManager = FileManager.default
    
    func save(data: Data, to file: URL) throws {
        print("Will write to \(file)")
        
        let folderPath = file.deletingLastPathComponent()
        
        try fileManager.createDirectory(
            at: folderPath,
            withIntermediateDirectories: true)
        
        try data.write(to: file)
    }
}
