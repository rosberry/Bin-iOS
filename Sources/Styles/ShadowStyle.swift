//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

open class ShadowStyle {
    public var opacity: CGFloat = 0.0
    public var radius: CGFloat = 0.0
    public var offset: CGSize = .zero
    public var color: UIColor = .clear

    var shadow: NSShadow {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = radius
        shadow.shadowOffset = offset
        shadow.shadowColor = color.withAlphaComponent(opacity)
        return shadow
    }
}
