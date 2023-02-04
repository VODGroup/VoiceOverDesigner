import Foundation

extension FileManager {
    func folders(at path: URL) throws -> [String] {
        let allFiles = try contentsOfDirectory(atPath: path.path)
        let folders = allFiles.filter { file in
            !file.contains(".")
        }
        return folders
    }
    
    func vodesign(at path: URL) throws -> [String] {
        let allFiles = try contentsOfDirectory(atPath: path.path)
        let folders = allFiles.filter { file in
            file.contains(".vodesign")
        }
        return folders
    }
    
    func relativePathIncludingSubfolders(path: URL) throws -> [String] {
        let subdirectories = try folders(at: path)
        
        let allFiles = subdirectories.reduce([String]()) { result, subdirectory in
            let subdirectoryPath = path.appendingPathComponent(subdirectory)
            let files = (try? contentsOfDirectory(atPath: subdirectoryPath.path)) ?? []
            let paths = files.map { file in
                subdirectory + "/" + file
            }
            return result + paths
        }
        
        return allFiles
    }
    
    func directorySize(url: URL) -> Int64 {
        let contents: [URL]
        do {
            contents = try contentsOfDirectory(at: url,
                                               includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
        } catch {
            return 0
        }

        var size: Int64 = 0

        for url in contents {
            let isDirectoryResourceValue: URLResourceValues
            do {
                isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
            } catch {
                continue
            }
        
            if isDirectoryResourceValue.isDirectory == true {
                size += directorySize(url: url)
            } else {
                let fileSizeResourceValue: URLResourceValues
                do {
                    fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                } catch {
                    continue
                }
            
                size += Int64(fileSizeResourceValue.fileSize ?? 0)
            }
        }
        return size
    }
}
