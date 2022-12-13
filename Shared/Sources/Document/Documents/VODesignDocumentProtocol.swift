import Foundation
import Combine

public protocol VODesignDocumentProtocol {
    var controls: [any AccessibilityView] { get set }
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
    var image: Image? { get set }
    
    var controlsPublisher: PassthroughSubject<[any AccessibilityView], Never> { get }
}
