import Foundation

extension FileManager {
    func folders(at path: String) throws -> [String] {
        let allFiles = try contentsOfDirectory(atPath: path)
        let folders = allFiles.filter { file in
            !file.contains(".")
        }
        return folders
    }
    
    func vodesign(at path: String) throws -> [String] {
        let allFiles = try contentsOfDirectory(atPath: path)
        let folders = allFiles.filter { file in
            file.contains(".vodesign")
        }
        return folders
    }
}
