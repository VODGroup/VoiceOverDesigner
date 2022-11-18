import Document
import Combine

public typealias TextRecognitionSubject = CurrentValueSubject<RecognitionResult?, Never>

public struct RecognitionResult {
    public init(control: A11yControl, text: [String]) {
        self.control = control
        self.text = text
    }
    
    public let control: A11yControl
    public let text: [String]
}
