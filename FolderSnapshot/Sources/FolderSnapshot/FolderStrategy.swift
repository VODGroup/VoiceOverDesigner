import Foundation
import SnapshotTesting

extension Snapshotting where Value == URL, Format == String {
  /// A snapshot strategy for comparing any structure based on a sanitized text dump.
  public static var folderStructure: Snapshotting {
    return SimplySnapshotting.lines.pullback { snap($0) }
  }
}

private func snap(_ value: URL, name: String? = nil, indent: Int = 0, isFolder: Bool = false) -> String {
    let fileManager = FileManager.default
    
    let contents = try! fileManager.contentsOfDirectory(at: value, includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey])
    
    let folders = contents.filter { url in
        let resourceValues = try! (url as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
        let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as! Bool
        return isDirectory
    }
    
    let files = contents.filter { url in
        let resourceValues = try! (url as NSURL).resourceValues(forKeys: [URLResourceKey.isRegularFileKey])
        let isFile = resourceValues[URLResourceKey.isRegularFileKey] as! Bool
        return isFile
    }
    
    let lines = folders.map { folder in
        description(of: folder, indent: indent, isFolder: true) + snap(folder, indent: indent + 2, isFolder: true)
    } + files.map({ file in
        description(of: file, indent: indent, isFolder: false)
    })
    
    // TODO: Add symbolic link

    return lines.joined()
}

func description(of url: URL, indent: Int = 0, isFolder: Bool = false) -> String {
    let indentation = String(repeating: " ", count: indent)
    let bullet = isFolder ? "▿" : "-"
    
    return "\(indentation)\(bullet) \(url.lastPathComponent)\n"
}
