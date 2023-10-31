import Foundation
import AppKit

public class ScrollViewController: NSViewController {
    
    var child: NSViewController?
    
    func embed(_ child: NSViewController) {
        self.child = child
        addChild(child)
        view().addSubviewAndConstraints(child.view)
    }
    
    func view() -> ScrollContainerView {
        view as! ScrollContainerView
    }
    
    public static func fromStoryboard() -> ScrollViewController {
        let storyboard = NSStoryboard(name: "ElementSettingsViewController", bundle: .module)
        return storyboard.instantiateController(withIdentifier: "ScrollView") as! ScrollViewController
    }
}

public class ScrollContainerView: NSView {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var contentView: NSView!
    
    func addSubviewAndConstraints(_ subview: NSView) {
        scrollView.documentView = subview
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: scrollView.topAnchor),
            subview.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            subview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
        ])
    }
}

final class ClipView: NSClipView {
    override var isFlipped: Bool { true }
}

extension NSView {
    func pinToBounds(_ subview: NSView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
}
