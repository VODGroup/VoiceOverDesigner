import Foundation
import Combine

public protocol VODesignDocumentProtocol {
    
    // MARK: - Data
    var controls: [any AccessibilityView] { get set }
    var image: Image? { get set }
    
    // MARK: - Services
    /// An undo manager that records operations on document
    /// - Renamed as `NSDocument` and `UIDocument` have different `UndoManager` signature
    var undo: UndoManager? { get }
}
