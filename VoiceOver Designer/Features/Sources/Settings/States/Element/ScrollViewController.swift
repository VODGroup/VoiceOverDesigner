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
        contentView.addSubview(subview)
        contentView.pinToBounds(subview)
    }
}

extension NSView {
    func pinToBounds(_ subview: NSView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
            subview.leftAnchor.constraint(equalTo: leftAnchor),
        ])
    }
}
