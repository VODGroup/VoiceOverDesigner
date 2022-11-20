@testable import Canvas
import CoreGraphics

class FakeCanvasUI: CanvasPresenterUIProtocol {
    var image: CGImage?
    func image(at frame: CGRect) async -> CGImage? {
        return image
    }
}
