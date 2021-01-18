//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

extension UIResponder {

    private weak static var currentFirstResponder: UIResponder?

    public static var current: UIResponder? {
        currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }

    @objc private func findFirstResponder() {
        UIResponder.currentFirstResponder = self
    }
}
