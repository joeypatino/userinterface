public final class ScrollingStackView: UIScrollView {
    // MARK: - Properties
    private let stackView = UIStackView()
    
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            stackViewWidthConstraint.isActive = newValue == .vertical
            stackViewHeightConstraint.isActive = newValue == .horizontal
        }
    }
    public var distribution: UIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }
    public var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    public var stackContentInsets: UIEdgeInsets = .zero {
        didSet {
            contentInset = stackContentInsets
            stackViewWidthConstraint.constant = -stackContentInsets.horizontalLength
            stackViewHeightConstraint.constant = -stackContentInsets.verticalLength
            stackView.layoutIfNeeded()
        }
    }
    public var isLayoutMarginsRelativeArrangement: Bool {
        get { stackView.isLayoutMarginsRelativeArrangement }
        set { stackView.isLayoutMarginsRelativeArrangement = newValue }
    }
    public var arrangedSubviews: [UIView] {
        stackView.arrangedSubviews
    }
    private lazy var stackViewWidthConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)
    private lazy var stackViewHeightConstraint = stackView.heightAnchor.constraint(equalTo: heightAnchor)

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Tasks
    private func commonInit() {
        setupStackView()
    }

    private func setupStackView() {
        stackView.embed(in: self)
        stackView.distribution = .equalSpacing
        sendSubviewToBack(stackView)
        axis = .vertical
    }

    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    public func removeAllArrangedSubviews() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        stackView.setCustomSpacing(spacing, after: arrangedSubview)
    }

    public func customSpacing(after arrangedSubview: UIView) -> CGFloat {
        stackView.customSpacing(after: arrangedSubview)
    }
}

internal extension UIEdgeInsets {
    var horizontalLength: CGFloat {
        return left + right
    }

    var verticalLength: CGFloat {
        return top + bottom
    }
}

public protocol StackViewConformable {
    var axis: NSLayoutConstraint.Axis { get }
    func addArrangedSubview(_ view: UIView)
}

extension ScrollingStackView: StackViewConformable {}
extension UIStackView: StackViewConformable {}

public extension StackViewConformable {
    func addArrangedSubview(_ view: UIView, alignment: UIStackView.Alignment) {
        let leading = CGFloat(0)
        let trailing = CGFloat(0)
        
        func vSpacer(_ height: CGFloat) -> UIView {
            let spacer = UIView()
            spacer.verticalHugging = 249
            spacer.heightAnchor.equalToConstant(height)
            return spacer
        }
        func hSpacer(_ width: CGFloat) -> UIView {
            let spacer = UIView()
            spacer.horizontalHugging = 249
            spacer.widthAnchor.equalToConstant(width)
            return spacer
        }

        let stack = UIStackView()
        switch axis {
        case .horizontal:
            stack.axis = .horizontal
            stack.alignment = alignment
            stack.addArrangedSubview(hSpacer(leading))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(hSpacer(trailing))
        case .vertical:
            stack.axis = .vertical
            stack.alignment = alignment
            stack.addArrangedSubview(vSpacer(leading))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(vSpacer(trailing))
        @unknown default:
            break
        }
        addArrangedSubview(stack)
    }
    
    func addArrangedSubview(_ view: UIView, leadingMargin leading: CGFloat = 0, trailingMargin trailing: CGFloat = 0) {
        guard leading != 0 && trailing != 0 else { addArrangedSubview(view); return }
        func vSpacer(_ height: CGFloat) -> UIView {
            let spacer = UIView()
            spacer.heightAnchor.equalToConstant(height)
            return spacer
        }
        func hSpacer(_ width: CGFloat) -> UIView {
            let spacer = UIView()
            spacer.widthAnchor.equalToConstant(width)
            return spacer
        }
        
        let stack = UIStackView()
        switch axis {
        case .horizontal:
            stack.axis = .vertical
            stack.addArrangedSubview(vSpacer(leading))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(vSpacer(trailing))
        case .vertical:
            stack.axis = .horizontal
            stack.addArrangedSubview(hSpacer(leading))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(hSpacer(trailing))
        @unknown default:
            break
        }
        addArrangedSubview(stack)
    }
}

public extension UIStackView {
    static func verticalStack(_ arrangedViews: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedViews)
        stack.axis = .vertical
        return stack
    }
    
    static func horizontalStack(_ arrangedViews: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedViews)
        stack.axis = .horizontal
        return stack
    }
}
