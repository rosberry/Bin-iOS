//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UITextField

extension UITextField {

    // Initialization of UITextField with specific input traits pattern
    convenience init(inputTraitsPattern: TextInputTraits.Pattern, returnKeyType: UIReturnKeyType? = nil) {
        self.init(frame: .zero)
        let inputTraits = TextInputTraits(pattern: inputTraitsPattern)
        if let returnKeyType = returnKeyType {
            inputTraits.returnKeyType = returnKeyType
        }
        self.setTextInputTraits(inputTraits)
    }

    // Sets up passed input traits to UItextField
    func setTextInputTraits(_ textInputTraits: TextInputTraits) {
        keyboardType = textInputTraits.keyboardType
        autocorrectionType = textInputTraits.autocorrectionType
        autocapitalizationType = textInputTraits.autocapitalizationType
        spellCheckingType = textInputTraits.spellCheckingType
        isSecureTextEntry = textInputTraits.isSecureTextEntry
        keyboardAppearance = textInputTraits.keyboardAppearance
        returnKeyType = textInputTraits.returnKeyType
        enablesReturnKeyAutomatically = textInputTraits.enablesReturnKeyAutomatically
    }

    // Sets up input traits to UITextField according to passed pattern
    func setTextInputTraits(with pattern: TextInputTraits.Pattern) {
        let traits = TextInputTraits(pattern: pattern)
        setTextInputTraits(traits)
    }
}
