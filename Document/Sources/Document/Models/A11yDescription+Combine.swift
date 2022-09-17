import Combine

public typealias OptionalDescriptionSubject = CurrentValueSubject<A11yDescription?, Never>
public typealias TextRecognitionSubject = CurrentValueSubject<RecognitionResult?, Never>

public struct RecognitionResult {
    public init(control: A11yControl, text: [String]) {
        self.control = control
        self.text = text
    }
    
    let control: A11yControl
    let text: [String]
}
