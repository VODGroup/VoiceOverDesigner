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
}
