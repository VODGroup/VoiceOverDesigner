import XCTest
@testable import Editor
import Document

class RouterMock: EditorRouterProtocol {
    
    var isSettingsShown: Bool {
        didShowSettingsForControl != nil
    }
    
    var didShowSettingsForControl: A11yControl?
    func showSettings(
        for control: A11yControl,
        controlSuperview: NSView
    ) {
        didShowSettingsForControl = control
    }
    
    func hideSettings() {
        didShowSettingsForControl = nil
    }
}
