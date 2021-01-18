//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit
import VisualEffectView

public final class CustomBlurEffectView: UIView {

    public var blurAlpha: CGFloat {
        didSet {
            update()
        }
    }
    public var blurColor: UIColor {
        didSet {
            update()
        }
    }
    public var blurRadius: CGFloat {
        didSet {
            update()
        }
    }

    private lazy var backgroundView: VisualEffectView = .init()

    public required init(blurAlpha: CGFloat = 1, blurColor: UIColor = .white, blurRadius: CGFloat = 10) {
        self.blurAlpha = blurAlpha
        self.blurColor = blurColor
        self.blurRadius = blurRadius
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(backgroundView)
        update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
    }

    private func update() {
        backgroundView.blurRadius = blurRadius
        backgroundView.colorTint = blurColor
        backgroundView.colorTintAlpha = blurAlpha
    }
}
