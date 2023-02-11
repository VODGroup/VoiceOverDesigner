import XCTest
@testable import VoiceOverLayout
import Document
import DocumentTestHelpers
import SnapshotTesting

class VoiceOverLayoutTests: XCTestCase {
    var scrollView: FakeScrollViewConverable!
    var sut: VoiceOverLayout!
    
    override func setUp() {
        super.setUp()
        
        scrollView = FakeScrollViewConverable()
        
//        SnapshotTesting.isRecording = true
    }
    
    func elements(controls: [any AccessibilityView]) -> [Any] {
        sut = VoiceOverLayout(controls: controls, scrollView: scrollView)
        return sut.accessibilityElements(at: UIView())
    }
    
    // | -------------------- |
    // | Label 1     Label 2  |
    // | -------------------- |
    //
    // |        Label 3       |
    
    private func containerWith2Elements(origin: CGPoint) -> [any AccessibilityView] {
        [
            A11yContainer.testMake(
                elements: [
                    A11yDescription.testMake(
                        label: "Label 1",
                        frame: CGRect(x: 10, y: 10, width: 50, height: 50)),
                    A11yDescription.testMake(
                        label: "Label 2",
                        frame: CGRect(x: 70, y: 10, width: 50, height: 50))
                ],
                frame: CGRect(origin: origin, size: CGSize(width: 200, height: 100)),
                label: "Container"
            ),
            
            A11yDescription.testMake(
                label: "Label 3",
                frame: CGRect(x: 10, y: 70, width: 180, height: 50)),
        ]
    }
    
    func test_whenContainerAtZero_shouldPlaceElementsToSameCoordinates() {
        let controls = containerWith2Elements(origin: .zero)
        
        let elements = elements(controls: controls)
        
        assertSnapshot(matching: elements, as: .dump)
    }
    
    func test_whenContainerNotAtZero_shouldPlaceElementsRelativeToParents() {
        let controls = containerWith2Elements(origin: CGPoint(x: 10, y: 10))
        
        let elements = elements(controls: controls)
        
        assertSnapshot(matching: elements, as: .dump)
    }
    
    // MARK: Zoom
    
    func test_zoomIs3_whenLayout_shouldDownScaleContainerAndElements() {
        let controls = containerWith2Elements(origin: CGPoint(x: 10, y: 10))
        
        var accessibilityElements: [Any] = []
        XCTContext.runActivity(named: "When move should translate containers") { _ in
            scrollView.zoomScale = 0.5
            
            accessibilityElements = elements(controls: controls)
            
            // Note: only containers should be scaled, because elements scaled by iOS (don't know how)
            assertSnapshot(matching: accessibilityElements, as: .dump, named: "should scale")
        }
        
        XCTContext.runActivity(named: "When move should translate containers") { _ in
            scrollView.yOffset = 50
            sut.updateContainers(in: accessibilityElements)
            
            assertSnapshot(matching: accessibilityElements, as: .dump, named: "should scale and translate containers")
        }
    }
}

extension UIScrollView {
    func scroll(yOffset: CGFloat) {
        bounds = CGRect(origin: CGPoint(x: bounds.origin.x,
                                        y: bounds.origin.y + yOffset),
                        size: bounds.size)
    }
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
