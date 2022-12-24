import UIKit

class SideTransitionPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let safeArea = containerView!.safeAreaInsets
        let margin = UIEdgeInsets(top: safeArea.top, left: 20, bottom: safeArea.bottom, right: 20)
        let parentFrame = containerView!.frame
        
        let size = CGSize(width: 375, height: parentFrame.height - margin.verticals)
        let originX = parentFrame.width - size.width - margin.right
        let origin = CGPoint(x: originX, y: margin.top)
        
        return CGRect(origin: origin, size: size)
            .insetBy(dx: 0, dy: 20)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        // Animates on device rotatation
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        dismissingView.frame = containerView!.frame
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        containerView!.addSubview(presentedView!)
        
        let layer = presentedView!.layer
        styleLikePopover(for: layer)
        
        addDismissingView(to: containerView!)
    }
    
    // MARK: - Popover
    private func styleLikePopover(for layer: CALayer) {
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 50
        layer.shadowOffset = .zero
//        layer.shadowPath = // TODO: Round corners?
    
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
    }
    
    // MARK: - Dismissing
    private var dismissingView: UIView = UIView()
    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true)
    }
    
    private func addDismissingView(to container: UIView) {
        container.addSubview(dismissingView)
        let dismissingTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismiss))
        dismissingView.addGestureRecognizer(dismissingTap)
    }
}

extension UIEdgeInsets {
    var horizontals: CGFloat {
        left + right
    }
    
    var verticals: CGFloat {
        top + bottom
    }
}
