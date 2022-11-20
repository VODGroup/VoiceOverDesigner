import UIKit

let additionalOffes: CGFloat = 50
let duration: TimeInterval = 0.5
let dumping: CGFloat = 0.9

func initialFrame(from transitionContext: UIViewControllerContextTransitioning) -> CGRect {
    let presentedController = transitionContext.viewController(forKey: .to)!
    let frame = transitionContext.finalFrame(for: presentedController)
    return frame
}

func translation(from transitionContext: UIViewControllerContextTransitioning) -> CGAffineTransform {
    let presentedController = transitionContext.viewController(forKey: .from)!
    let frame = transitionContext.finalFrame(for: presentedController)
    
    return CGAffineTransform(
        translationX: frame.width + additionalOffes,
        y: 0)
}

class SidePresentation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presented = transitionContext.view(forKey: .to)!
        presented.frame = initialFrame(from: transitionContext)
        presented.transform = translation(from: transitionContext)
        
        let animaton = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            dampingRatio: dumping)
        
        animaton.addAnimations {
            presented.transform = .identity
        }
        
        animaton.addCompletion { _ in
            transitionContext.completeTransition(true)
        }
        
        animaton.startAnimation()
    }
}

class SideDismissing: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presented = transitionContext.view(forKey: .from)!
        
        let animaton = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            dampingRatio: 1)
        
        animaton.addAnimations {
            presented.transform = translation(from: transitionContext)
        }
        
        animaton.addCompletion { _ in
            transitionContext.completeTransition(true)
        }
        
        animaton.startAnimation()
    }
}
