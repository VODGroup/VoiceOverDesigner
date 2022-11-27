import Foundation
import Combine

public protocol VODesignDocumentProtocol {
    var controls: [any AccessibilityView] { get set }
    var undoManager: UndoManager? { get }
    var image: Image? { get set }
    
    var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> { get }
}
