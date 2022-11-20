import Foundation
import Combine

public protocol VODesignDocumentProtocol {
    var controls: [A11yDescription] { get set }
    var undoManager: UndoManager? { get }
    var image: Image? { get set }
    
    var controlsPublisher: PassthroughSubject<[A11yDescription], Never> { get }
}
