public enum AlertTransitionAnimatorType {
    case present
    case dismiss
}

public class AlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let type: AlertTransitionAnimatorType
    public init(type: AlertTransitionAnimatorType) {
        self.type = type
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return type == .present ? 0.4 : 0.25
    }
    
    @objc public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: { from.view.frame.origin.y = UIScreen.main.bounds.height }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

