import UserInterface

class ViewController: UIViewController {
    private let showActionSheetWithIconsButton = PerformActionButton()
    private let showActionSheetButton = PerformActionButton()
    private let showKeyboardButton = PerformActionButton()
    
    private let textField = UITextField()
    private let infoLabel = AttributedLabel()
    private let scrollingStack = ScrollingStackView(backgroundColor: .lightGray)
    private var actionSheet: ActionSheetTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        scrollingStack.distribution = .fillEqually
        scrollingStack.axis = .horizontal
        scrollingStack.spacing = 8.0
        
        /// setup the attributed info label and add a tappable link to it
        infoLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        infoLabel.alignment = .center
        infoLabel.lineSpacing = 40.0
        infoLabel.delegate = self
        infoLabel.text =
"""
hello world!
this screen contains some random
examples of some user interface controls
check out the source code for details
this is a link in the label
In another world, this is link
"""
        infoLabel.addLink([.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.red, .link: URL(string: "http://www.awesome.com/world") as Any], to: "world")
        infoLabel.addLinks([.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.red, .link: URL(string: "http://www.awesome.com/link") as Any], to: "link")
        infoLabel.addLinks([.underlineStyle: NSUnderlineStyle.double.rawValue, .font: UIFont.systemFont(ofSize: 18.0, weight: .bold), .underlineColor: UIColor.blue, .link: URL(string: "http://www.awesome.com/some") as Any], to: "some")
        infoLabel.addLinks([.underlineStyle: NSUnderlineStyle.double.rawValue, .font: UIFont.systemFont(ofSize: 14.0, weight: .bold), .underlineColor: UIColor.green, .link: URL(string: "http://www.awesome.com/this") as Any], to: "this")
        
        /// setup the textfield
        textField.placeholder = "search field example..."
        textField.delegate = self
        textField.borderStyle = .roundedRect
        observerKeyboard()

        /// setup the buttons that trigger the ActionSheet
        showActionSheetButton.setAttributedTitle(title("action sheet"), for: .normal)
        showActionSheetButton.addTarget(self, action: #selector(showActionSheetAction), for: .touchUpInside)
        /// setup the buttons that trigger the ActionSheet
        showActionSheetWithIconsButton.setAttributedTitle(title("action sheet\nwith icons"), for: .normal)
        showActionSheetWithIconsButton.addTarget(self, action: #selector(showActionSheetWithIconsAction), for: .touchUpInside)
        /// setup the buttons that trigger the ActionSheet
        showKeyboardButton.setAttributedTitle(title("keyboard\nobserver"), for: .normal)
        showKeyboardButton.addTarget(self, action: #selector(showKeyboardAction), for: .touchUpInside)
    }
    
    private func layout() {
        /// add the stack view
        view.addAutoLayoutSubview(scrollingStack)
        scrollingStack.topAnchor.equalTo(view.safeAreaLayoutGuide.topAnchor)
        scrollingStack.leadingAnchor.equalTo(view.leadingAnchor)
        scrollingStack.trailingAnchor.equalTo(view.trailingAnchor)
        scrollingStack.heightAnchor.equalToConstant(80)

        /// add the action sheet trigger button
        scrollingStack.addArrangedSubview(showActionSheetButton)
        showActionSheetButton.heightAnchor.equalTo(scrollingStack.heightAnchor)
        /// add the action sheet trigger button
        scrollingStack.addArrangedSubview(showActionSheetWithIconsButton)
        showActionSheetWithIconsButton.heightAnchor.equalTo(scrollingStack.heightAnchor)
        /// add the keyboard trigger button
        scrollingStack.addArrangedSubview(showKeyboardButton)
        showKeyboardButton.heightAnchor.equalTo(scrollingStack.heightAnchor)

        /// add the info label
        view.addAutoLayoutSubview(infoLabel)
        infoLabel.centerXAnchor.equalTo(view.centerXAnchor)
        infoLabel.centerYAnchor.equalTo(view.centerYAnchor)
        
        view.addAutoLayoutSubview(textField)
        textField.bottomAnchor.equalTo(view.safeAreaLayoutGuide.bottomAnchor).constant(-8)
        textField.leadingAnchor.equalTo(view.leadingAnchor).constant(8)
        textField.trailingAnchor.equalTo(view.trailingAnchor).constant(-8)
    }
}

/// Support for AttributedLabel
extension ViewController: AttributedLabelDelegate {
    func attributedLabel(_ label: AttributedLabel, didTapLink link: URL) {
        say(link.absoluteString)
    }
}

/// Support for KeyboardObserver
extension ViewController: KeyboardObserver, UITextFieldDelegate {
    private func observerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardShow(_ notification: Notification) {
        dispatch(keyboardNotification: notification) { [weak self] frame, duration, options in
            guard let `self` = self else { return }
            let animations: () -> Void = {
                self.view.layoutIfNeeded()
            }
            self.view.transform = .init(translationX: 0, y: -frame.height)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations)
        }
    }

    @objc private func keyboardHide(_ notification: Notification) {
        dispatch(keyboardNotification: notification) { [weak self] frame, duration, options in
            guard let `self` = self else { return }
            let animations: () -> Void = {
                self.view.layoutIfNeeded()
            }
            self.view.transform = .identity
            let completion: (Bool) -> Void = { _ in  }
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
        }
    }
    
    /// Presents a the keyboard
    @objc private func showKeyboardAction(_ sender: UIButton) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// Support for ActionSheetViewController
extension ViewController {
    // helper function
    private func title(_ string: String) -> NSAttributedString {
        let style = NSParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12.0, weight: .medium), .paragraphStyle: style, .foregroundColor: UIColor.lightText]
        return NSAttributedString(string: string, attributes: attrs)
    }

    /// presents a regular UIAlertController
    private func say(_ message: String) {
        let viewController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(viewController, animated: true)
    }
    
    /// Presents an action sheet
    @objc private func showActionSheetAction(_ sender: UIButton) {
        actionSheet = ActionSheetTransitioningDelegate(presentingViewController: self)
        let viewController = ActionSheetViewController()
        viewController.addAction(ActionSheetAction(title: "Phone", action: { [weak self] in self?.say("Phone") }))
        viewController.addAction(ActionSheetAction(title: "iMessage", action: { [weak self] in self?.say("iMessage") }))
        viewController.addAction(ActionSheetAction(title: "Mail", action: { [weak self] in self?.say("Mail") }))
        viewController.delegate = self
        viewController.transitioningDelegate = actionSheet
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }
    
    /// Presents an action sheet, with icons
    @objc private func showActionSheetWithIconsAction(_ sender: UIButton) {
        actionSheet = ActionSheetTransitioningDelegate(presentingViewController: self)
        let viewController = ActionSheetViewController()
        viewController.addAction(ActionSheetAction(title: "Phone", icon: #imageLiteral(resourceName: "apple-phone"), action: { [weak self] in self?.say("Phone") }))
        viewController.addAction(ActionSheetAction(title: "iMessage", icon: #imageLiteral(resourceName: "imessage.pdf"), action: { [weak self] in self?.say("iMessage") }))
        viewController.addAction(ActionSheetAction(title: "Mail", icon: #imageLiteral(resourceName: "apple-mail.pdf"), action: { [weak self] in self?.say("Mail") }))
        viewController.delegate = self
        viewController.transitioningDelegate = actionSheet
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }
}

/// Support for ActionSheetViewController
extension ViewController: ActionSheetViewControllerDelegate {
    func viewControllerDone(_ viewController: ActionSheetViewController) {
        dismiss(animated: true) { [weak self] in
            self?.actionSheet = nil
        }
    }
    
    func viewControllerDidCancel(_ viewController: ActionSheetViewController) {
        dismiss(animated: true) { [weak self] in
            self?.actionSheet = nil
        }
    }
}

// Helper class
fileprivate class PerformActionButton: UIButton {
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        titleLabel?.numberOfLines = 0
        contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
