import Foundation

public extension VODesignDocumentProtocol {
    func container(for description: A11yDescription) -> A11yContainer? {
        controls.container(for: description)
    }
}
