import Foundation

@available(macOS 12, *)
@available(iOS 15, *)
private let multilineMarkdown = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)

@available(macOS 12, *)
@available(iOS 15, *)
extension NSMutableAttributedString {
    
    func append(markdown: String) {
        if markdown.isEmpty {
            return // Do nothing, otherwise it will crash
        }
        
        append(try! NSAttributedString(markdown: markdown,
                                       options: multilineMarkdown))
    }
    
    static func += (lhs: NSMutableAttributedString, rhs: String) {
        lhs.append(markdown: rhs)
    }
    
    static func += (lhs: NSMutableAttributedString, rhs: NSAttributedString) {
        lhs.append(rhs)
    }
    
    var isEmpty: Bool {
        length == 0
    }
}

extension String {
    @available(macOS 12, *)
    @available(iOS 15, *)
    func markdown(color: Color? = nil) -> NSAttributedString {
        if self.isEmpty {
            return NSAttributedString()// Do nothing, otherwise it will crash
        }

        let result = try! NSMutableAttributedString(markdown: self)
        
        if let color = color {
            let withoutMarkdownRange = result.string.fullRange
            result.addAttribute(.foregroundColor,
                                value: color,
                                range: withoutMarkdownRange)
        }
        return result
    }
}

extension String {
    var bold: String {
        "**\(self.trimmingWhitespaces())**"
    }
    
    var italic: String {
        "*\(self.trimmingWhitespaces())*"
    }
    
    func trimmingWhitespaces() -> Self {
        trimmingCharacters(in: .whitespaces)
    }
}
