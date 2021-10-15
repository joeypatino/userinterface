public extension UIView {
    var horizontalHugging: Float {
        get { return contentHuggingPriority(for: .horizontal).rawValue }
        set { setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }
    
    var verticalHugging: Float {
        get { return contentHuggingPriority(for: .vertical).rawValue }
        set { setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }
    
    var horizontalCompression: Float {
        get { return contentCompressionResistancePriority(for: .horizontal).rawValue }
        set { setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }
    
    var verticalCompression: Float {
        get { return contentCompressionResistancePriority(for: .vertical).rawValue }
        set { setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }
}

public extension UIView {
    typealias EmbedConstraints = (top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint)
    typealias Priorities = (top: Float , left: Float, bottom: Float, right: Float)
    
    static var PrioritiesRequired: Priorities = (top: 999 , left: 999, bottom: 999, right: 999)
    static var Priorities999: Priorities = (top: 999 , left: 999, bottom: 999, right: 999)
    
    @discardableResult
    func embed(in view: UIView, inset: UIEdgeInsets = .zero,
               usingSafeAreaLayoutGuides: Bool = false,
               priorities: Priorities = PrioritiesRequired) -> EmbedConstraints {
        view.addAutoLayoutSubview(self)
        if #available(iOS 11.0, *), usingSafeAreaLayoutGuides {
            let top = topAnchor.equalTo(view.safeAreaLayoutGuide.topAnchor, priority: priorities.top).constant(inset.top)
            let left = leadingAnchor.equalTo(view.safeAreaLayoutGuide.leadingAnchor, priority: priorities.left).constant(inset.left)
            let bottom = bottomAnchor.equalTo(view.safeAreaLayoutGuide.bottomAnchor, priority: priorities.bottom).constant(-inset.bottom)
            let right = trailingAnchor.equalTo(view.safeAreaLayoutGuide.trailingAnchor, priority: priorities.right).constant(-inset.right)
            return (top: top, left: left, bottom: bottom, right: right)
        } else {
            let top = topAnchor.equalTo(view.topAnchor, priority: priorities.top).constant(inset.top)
            let left = leadingAnchor.equalTo(view.leadingAnchor, priority: priorities.left).constant(inset.left)
            let bottom = bottomAnchor.equalTo(view.bottomAnchor, priority: priorities.bottom).constant(-inset.bottom)
            let right = trailingAnchor.equalTo(view.trailingAnchor, priority: priorities.right).constant(-inset.right)
            return (top: top, left: left, bottom: bottom, right: right)
        }
    }
    
    @discardableResult
    func center(in view: UIView, offset: CGPoint = .zero, inset: CGSize = .zero) -> (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint, width: NSLayoutConstraint, height: NSLayoutConstraint) {
        view.addAutoLayoutSubview(self)
        return (centerX: centerXAnchor.equalTo(view.centerXAnchor).constant(offset.x),
                centerY: centerYAnchor.equalTo(view.centerYAnchor).constant(offset.y),
                width: widthAnchor.equalTo(view.widthAnchor).constant(-inset.width),
                height: heightAnchor.equalTo(view.heightAnchor).constant(-inset.height))
    }
    
    func center(in view: UIView, inset: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let width = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -(inset.left + inset.right))
        width.isActive = true
        let height = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0, constant: -(inset.top + inset.bottom))
        height.isActive = true
        let centerX = centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerX.isActive = true
        let centerY = centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerY.isActive = true
    }
}

public extension UIView {
    func addAutoLayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    var requiredHeight: CGFloat {
        return systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }

    func requiredWidth(fittingHeight height: CGFloat) -> CGFloat {
        return systemLayoutSizeFitting(CGSize(width: 0, height: height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required).width
    }
    
    func requiredHeight(fittingWidth width: CGFloat) -> CGFloat {
        return systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
}

public extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
}

public extension UIView {
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

public extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size).image(actions: { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        })
    }
}

public extension UIView {
    struct UICornerMask: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        static var allCorners: UICornerMask = [.topLeftCorner, .topRightCorner, .bottomLeftCorner, .bottomRightCorner]
        static var topLeftCorner = UICornerMask(rawValue: 1 << 0)
        static var topRightCorner = UICornerMask(rawValue: 1 << 1)
        static var bottomLeftCorner = UICornerMask(rawValue: 1 << 2)
        static var bottomRightCorner = UICornerMask(rawValue: 1 << 3)
    }

    var maskedCorners: UICornerMask {
        get {
            let maskedCorners = layer.maskedCorners
            var corners: UICornerMask = []
            if maskedCorners.contains(.layerMaxXMaxYCorner) {
                corners.insert(.bottomRightCorner)
            }
            if maskedCorners.contains(.layerMinXMaxYCorner) {
                corners.insert(.bottomLeftCorner)
            }
            if maskedCorners.contains(.layerMaxXMinYCorner) {
                corners.insert(.topRightCorner)
            }
            if maskedCorners.contains(.layerMinXMinYCorner) {
                corners.insert(.topLeftCorner)
            }
            return corners
        }
        set {
            var corners: CACornerMask = []
            if newValue.contains(.bottomRightCorner) {
                corners.insert(.layerMaxXMaxYCorner)
            }
            if newValue.contains(.bottomLeftCorner) {
                corners.insert(.layerMinXMaxYCorner)
            }
            if newValue.contains(.topRightCorner) {
                corners.insert(.layerMaxXMinYCorner)
            }
            if newValue.contains(.topLeftCorner) {
                corners.insert(.layerMinXMinYCorner)
            }
            layer.maskedCorners = corners
        }
    }
}
