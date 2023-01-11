import Foundation

extension Array where Element == URL {
    func union(with urls: [URL]) -> [URL] {
        var result = self.withoutTrailingSlash()
        result.append(contentsOf: urls.withoutTrailingSlash())
        
        return NSOrderedSet(array: result).array as! [URL]
    }
    
    private func withoutTrailingSlash() -> [Element] {
        self.map { url in
            url.withoutTrailingSlash()
        }
    }
}

extension URL {
    func withoutTrailingSlash() -> URL {
        var string = absoluteString
        
        if string.hasSuffix("/") {
            string = String(string.dropLast(1))
        }
        
        return URL(string: string)!
    }
}
