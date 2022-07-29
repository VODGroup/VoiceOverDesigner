import AppKit
import Document
import Settings

public protocol EditorRouterProtocol: AnyObject {
    func showSettings(for control: A11yControl, controlSuperview: NSView, delegate: SettingsDelegate)
}
