import Foundation

@available(macOS 12, *)
@available(iOS 15, *)
extension NSMutableAttributedString {
    
    func append(markdown: String) {
        if markdown.isEmpty {
            return // Do nothing, otherwise it will crash
        }
        append(try! NSAttributedString(markdown: markdown))
    }
    
    static func += (lhs: NSMutableAttributedString, rhs: String) {
        lhs.append(markdown: rhs)
    }
    
    var isEmpty: Bool {
        length == 0
    }
}

extension String {
    var bold: String {
        "**\(self)**"
    }
    
    var italic: String {
        "*\(self)*"
    }
}
