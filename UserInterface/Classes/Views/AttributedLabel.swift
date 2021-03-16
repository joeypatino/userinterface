public protocol AttributedLabelDelegate: AnyObject {
    func attributedLabel(_ label: AttributedLabel, didTapLink link: URL)
}

/// Attributed label allows adding simple attributes to a label, instead of
/// constructing NSAttributedStrings throughout your code.
public class AttributedLabel: UIView {
    public weak var delegate: AttributedLabelDelegate?
    
    public var text: String? {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var font: UIFont = .systemFont(ofSize: UIFont.systemFontSize) {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var alignment: NSTextAlignment = .left {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var lineSpacing: CGFloat = 0.0 {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var kerning: CGFloat = 0.0 {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var textColor: UIColor = .darkText {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var insets: UIEdgeInsets = .zero {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public var linkAttributes: [NSAttributedString.Key:Any] = [.underlineStyle: NSUnderlineStyle(rawValue: 0).rawValue, .underlineColor: UIColor.clear]
    
    private var links: [String: [NSAttributedString.Key: Any]] = [:]
    private var links_all: [String: [NSAttributedString.Key: Any]] = [:]
    
    private var attributedString: NSAttributedString {
        let string = NSMutableAttributedString(string: text ?? "", attributes: attrs)
        
        /// apply links to all matching words
        for (a, attributes) in links_all {
            var attrs = linkAttributes
            for (key, value) in attributes {
                attrs[key] = value
            }
            if let rngs = text?.ranges(of: a), let t = text {
                rngs.forEach { string.addAttributes(attrs, range: NSRange($0, in: t)) }
            }
        }
        
        /// apply links to single words
        for (a, attributes) in links {
            var attrs = linkAttributes
            for (key, value) in attributes {
                attrs[key] = value
            }
            if let rng = (text as NSString?)?.range(of: a) { string.addAttributes(attrs, range: rng) }
        }
        return string
    }
    
    private var attrs: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        return [.font: font as Any, .foregroundColor: textColor, .kern: kerning, .paragraphStyle: paragraphStyle]
    }
        
    public override var bounds: CGRect {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    public override var intrinsicContentSize: CGSize {
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let rect = attributedString.boundingRect(with: size, options: drawingOptions, context: nil).integral
        let width = rect.width + insets.left + insets.right
        let height = rect.height + insets.top + insets.bottom
        return CGSize(width: width, height: height)
    }
    
    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = 0

        // Configure NSLayoutManager and add the text container
        let layoutManager = LayoutManager()
        layoutManager.addTextContainer(textContainer)

        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addAttribute(.font, value: font, range: NSMakeRange(0, attributedString.length))
        textStorage.addLayoutManager(layoutManager)
        
        // Calculate the offset of the text in the view
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: .zero)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
    }
    
    public func addLink(_ attrs: [NSAttributedString.Key: Any], to string: String) {
        links[string] = attrs
        invalidateIntrinsicContentSize(); setNeedsDisplay()
    }

    public func addLinks(_ attrs: [NSAttributedString.Key: Any], to string: String) {
        links_all[string] = attrs
        invalidateIntrinsicContentSize(); setNeedsDisplay()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = 0

        // Configure NSLayoutManager and add the text container
        let layoutManager = LayoutManager()
        layoutManager.addTextContainer(textContainer)

        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addAttributes(attrs, range: NSMakeRange(0, attributedString.length))
        textStorage.addLayoutManager(layoutManager)

        // get the tapped character location
        let locationOfTouchInLabel = location

        // account for text alignment and insets
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat
        switch alignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            alignmentOffset = 0
        }
        let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)

        // figure out which character was tapped
        let characterTapped = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // figure out how many characters are in the string up to and including the line tapped
        let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) - 1
        let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: (font.lineHeight * lineSpacing) * CGFloat(lineTapped))
        let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // ignore taps past the end of the current line
        if characterTapped < charsInLineTapped {
            let attrs = attributedString.attributes(at: characterTapped, effectiveRange: nil)
            if let link = attrs[.link] as? URL {
                delegate?.attributedLabel(self, didTapLink: link)
            }
        }
    }
}

/// NSLayoutManager to force the foreground attribute color for .link attributes
fileprivate final class LayoutManager: NSLayoutManager {
    @available(iOS 13.0, *)
    public override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in CGContext: CGContext) {
        defer { super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext); }
        guard let foregroundColor = attributes[.foregroundColor] as? UIColor else {  return }
        CGContext.setFillColor(foregroundColor.cgColor)
    }
    
    public override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, matrix textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in graphicsContext: CGContext) {
        defer { super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: attributes, in: graphicsContext) }
        guard let foregroundColor = attributes[.foregroundColor] as? UIColor else {  return }
        graphicsContext.setFillColor(foregroundColor.cgColor)
    }
}

fileprivate extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}
