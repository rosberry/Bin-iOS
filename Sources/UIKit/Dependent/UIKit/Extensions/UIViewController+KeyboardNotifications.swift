//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

// Wrapper for keyboard notification data
final class KeyboardNotification {

    let duration: TimeInterval
    let animationCurve: UIView.AnimationOptions
    let endFrame: CGRect

    init?(nsNotification: NSNotification) {
        guard let userInfo = nsNotification.userInfo,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let animationCurveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
                return nil
        }
        self.endFrame = endFrame
        self.duration = duration
        self.animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
    }
}

protocol KeyboardNotificationObserver {

    func keyboardWillShow(with notification: KeyboardNotification)
    func keyboardDidShow(with notification: KeyboardNotification)
    func keyboardWillHide(with notification: KeyboardNotification)
    func keyboardDidHide(with notification: KeyboardNotification)
}

extension KeyboardNotificationObserver {

    func keyboardWillShow(with notification: KeyboardNotification) {}
    func keyboardDidShow(with notification: KeyboardNotification) {}
    func keyboardWillHide(with notification: KeyboardNotification) {}
    func keyboardDidHide(with notification: KeyboardNotification) {}
}

// Extension for handy subscriptions to keyboard notifications
extension UIViewController {

    func startObservingNotifications(_ name: NSNotification.Name, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }

    func endObservingNotifications(_ name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.removeObserver(self, name: name, object: object)
    }

    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    func startObservingKeyboardWillShowNotifications() {
        startObservingNotifications(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowNotification))
    }

    func startObservingKeyboardDidShowNotifications() {
        startObservingNotifications(UIResponder.keyboardDidShowNotification, selector: #selector(keyboardDidShowNotification))
    }

    func startObservingKeyboardWillHideNotifications() {
        startObservingNotifications(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHideNotification))
    }

    func startObservingKeyboardDidHideNotifications() {
        startObservingNotifications(UIResponder.keyboardDidHideNotification, selector: #selector(keyboardDidHideNotification))
    }

    func endObservingKeyboardWillShowNotifications() {
        endObservingNotifications(UIResponder.keyboardWillShowNotification)
    }

    func endObservingKeyboardDidShowNotifications() {
        endObservingNotifications(UIResponder.keyboardDidShowNotification)
    }

    func endObservingKeyboardWillHideNotifications() {
        endObservingNotifications(UIResponder.keyboardWillHideNotification)
    }

    func endObservingKeyboardDidHideNotifications() {
        endObservingNotifications(UIResponder.keyboardDidHideNotification)
    }

    @objc func keyboardDidShowNotification(_ notification: NSNotification) {
        guard let notification = KeyboardNotification(nsNotification: notification) else {
            return
        }
        if let observer = self as? KeyboardNotificationObserver {
            observer.keyboardDidShow(with: notification)
        }
    }

    @objc func keyboardWillShowNotification(_ notification: NSNotification) {
        guard let notification = KeyboardNotification(nsNotification: notification) else {
            return
        }
        if let observer = self as? KeyboardNotificationObserver {
            observer.keyboardWillShow(with: notification)
        }
    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        guard let notification = KeyboardNotification(nsNotification: notification) else {
            return
        }
        if let observer = self as? KeyboardNotificationObserver {
            observer.keyboardWillHide(with: notification)
        }
    }

    @objc func keyboardDidHideNotification(_ notification: NSNotification) {
        guard let notification = KeyboardNotification(nsNotification: notification) else {
            return
        }
        if let observer = self as? KeyboardNotificationObserver {
            observer.keyboardDidHide(with: notification)
        }
    }
}
