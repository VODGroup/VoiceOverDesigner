import Document
import Combine

public struct RecognitionResult {
    public init(control: any AccessibilityView, text: [String]) {
        self.control = control
        
        var alternatives = text
        if alternatives.count > 1 {
            let combined = alternatives.joined(separator: " ")
            alternatives.append(combined)
        }
        
        self.text = alternatives
    }
    
    public let control: any AccessibilityView
    public let text: [String]
}
