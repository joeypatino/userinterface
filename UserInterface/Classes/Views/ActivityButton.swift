public class ActivityButton: UIButton {
    private var originalButtonText: String?
    private var activityIndicator: UIActivityIndicatorView?
    public var isActive: Bool = false {
        didSet { isActive ? showLoading() : hideLoading() }
    }
    
    private func showLoading() {
        originalButtonText = self.titleLabel?.text
        setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    private func hideLoading() {
        setTitle(originalButtonText, for: .normal)
        activityIndicator?.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }
    
    private func showSpinning() {
        guard let activityIndicator = activityIndicator else { return }
        activityIndicator.center(in: self)
        activityIndicator.startAnimating()
    }
}
