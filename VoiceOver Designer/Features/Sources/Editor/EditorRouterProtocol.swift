import AppKit
import Document

public protocol EditorRouterProtocol: AnyObject {
    func showSettings(for control: A11yControl, controlSuperview: NSView)
    func hideSettings()
}

public protocol EditorDelegate: AnyObject {
    func didSelect(control: A11yDescription?)
}
