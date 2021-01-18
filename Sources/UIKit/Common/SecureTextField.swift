//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Base

final class SecureTextField: UITextField {

    var insets: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)

    var textDidChangeHandler: ((String) -> Void)?

    private weak var delegateProxy: UITextFieldDelegate?

    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                fillSecureText()
            }
        }
    }

    override var delegate: UITextFieldDelegate? {
        get {
            delegateProxy
        }
        set {
            delegateProxy = newValue
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if isSecureTextEntry {
            fillSecureText()
        }
        return success
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: -insets).contains(point)
    }

    // MARK: - Private

    private func setup() {
        super.delegate = self
    }

    private func fillSecureText() {
        guard let text = self.text else {
            return
        }
        self.text?.removeAll()
        self.text = text
    }
}

// MARK: - UITextFieldDelegate

extension SecureTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegateProxy?.textFieldShouldReturn?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegateProxy?.textFieldDidBeginEditing?(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let stringRange = Range(range, in: text) else {
            return true
        }
        let updatedString = text.replacingCharacters(in: stringRange, with: string)
        textField.text = updatedString
        if let textPosition = textField.position(from: textField.beginningOfDocument, offset: range.lowerBound + string.count) {
            let textRange = textField.textRange(from: textPosition, to: textPosition)
            textField.selectedTextRange = textRange
        }
        textDidChangeHandler?(updatedString)
        return delegateProxy?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegateProxy?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegateProxy?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegateProxy?.textFieldDidEndEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegateProxy?.textFieldDidEndEditing?(textField, reason: reason)
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if #available(iOS 13.0, *) {
            delegateProxy?.textFieldDidChangeSelection?(textField)
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegateProxy?.textFieldShouldClear?(textField) ?? true
    }
}
