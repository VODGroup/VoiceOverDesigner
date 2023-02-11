import XCTest
@testable import VoiceOverLayout
import Document
import DocumentTestHelpers
import SnapshotTesting

class VoiceOverLayoutTests: XCTestCase {
    var scrollView: FakeScrollViewConverable!
    
    override func setUp() {
        super.setUp()
        
        scrollView = FakeScrollViewConverable()
    }
    
    func elements(controls: [any AccessibilityView]) -> [Any] {
        let sut = VoiceOverLayout(controls: controls, scrollView: scrollView)
        return sut.accessibilityElements(at: UIView())
    }
    
    // | -------------------- |
    // | Label 1     Label 2  |
    // | -------------------- |
    
    func test_whenContainerAtZero_shouldPlaceElementsToSameCoordinates() {
        let controls = [
            A11yContainer.testMake(
                elements: [
                    A11yDescription.testMake(
                        label: "Label 1",
                        frame: CGRect(x: 10, y: 10, width: 50, height: 50)),
                    A11yDescription.testMake(
                        label: "Label 2",
                        frame: CGRect(x: 70, y: 10, width: 50, height: 50))
                ],
                frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)),
                label: "Container"
            )
        ]
        
        let elements = elements(controls: controls)
        
        assertSnapshot(matching: elements, as: .dump, record: true)
    }
    
    func test_whenContainerNotAtZero_shouldPlaceElementsRelativeToParents() {
        let controls = [
            A11yContainer.testMake(
                elements: [
                    A11yDescription.testMake(
                        label: "Label 1",
                        frame: CGRect(x: 10, y: 10, width: 50, height: 50)),
                    A11yDescription.testMake(
                        label: "Label 2",
                        frame: CGRect(x: 70, y: 10, width: 50, height: 50))
                ],
                frame: CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: 200, height: 100)),
                label: "Container"
            )
        ]
        
        let elements = elements(controls: controls)
        
        assertSnapshot(matching: elements, as: .dump, record: true)
    }
    
    // MARK: Zoom
}

class FakeScrollViewConverable: ScrollViewConverable {
    var yOffset: CGFloat = 0
    var zoomScale: CGFloat = 1
    
    func frameInScreenCoordinates(_ frame: CGRect) -> CGRect {
        let new = scaledFrame(frame)
        let rect = new.offsetBy(dx: 0, dy: yOffset)
        return rect
    }
}

extension VoiceOverContainer: CustomReflectable {

    public var customMirror: Mirror {
        let elements = accessibilityElements as! [VoiceOverElement]
        let mirror = Mirror(
            self,
            children: [
                "Label": accessibilityLabel ?? "No label",
                "Frame": accessibilityFrame.shortDescription,
                "Elements": elements
            ],
            displayStyle: .optional)

        return mirror
    }
}

extension VoiceOverElement: CustomReflectable {
    
    public var customMirror: Mirror {
        return Mirror(
            self,
            children: [
                "Label": accessibilityLabel ?? "No label",
                "Frame": accessibilityFrame.shortDescription,
                "FrameInContainerSpace": accessibilityFrameInContainerSpace.shortDescription],
            displayStyle: .optional)
    }
}

extension CGRect {
    var shortDescription: String {
        [origin.x, origin.y, size.width, size.height]
            .map(Int.init)
            .map(String.init)
            .joined(separator: ", ")
    }
}
