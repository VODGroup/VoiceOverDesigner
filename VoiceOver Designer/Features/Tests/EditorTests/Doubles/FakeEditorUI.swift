@testable import Editor
import CoreGraphics

class FakeEditorUI: EditorPresenterUIProtocol {
    var image: CGImage?
    func image(at frame: CGRect, scale: CGFloat) async -> CGImage? {
        return image
    }
}
