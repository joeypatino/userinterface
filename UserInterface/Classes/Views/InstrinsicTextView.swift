public class IntrinsicTextView: UITextView {
    public init() {
        super.init(frame: .zero, textContainer: nil)
        isScrollEnabled = false
        contentInset = .zero
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !(bounds.size.equalTo(intrinsicContentSize)) {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
