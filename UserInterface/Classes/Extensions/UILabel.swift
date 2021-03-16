public extension UILabel {
    convenience init(font: UIFont, color: UIColor, alignment: NSTextAlignment = .left) {
        self.init()
        self.font = font
        self.textColor = color
        self.textAlignment = alignment
    }
}
