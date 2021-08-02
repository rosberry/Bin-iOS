//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

public class LoadingView: UIView {

    private enum Constants {
        static let rotationAnimationKey = "rotation-animation-key"
    }

    public private(set) var isAnimating: Bool

    public var hidesWhenStopped: Bool = true

    // MARK: - Subviews

    public private(set) lazy var imageView: UIImageView = .init()

    // MARK: - Lifecycle

    public init(image: UIImage) {
        isAnimating = false
        super.init(frame: .zero)
        imageView.image = image
        addSubview(imageView)
        isHidden = hidesWhenStopped
        sizeToFit()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appWillEnterForeground() {
        if isAnimating {
            startAnimating()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return imageView.sizeThatFits(size)
    }

    // MARK: - Animations

    public func update(loading: Bool, animated: Bool = false) {
        guard loading == false, isAnimating == false else {
            return
        }
        loading ? startAnimating(animated: animated) : stopAnimating(animated: animated)
    }

    public func startAnimating(animated: Bool = false) {
        isAnimating = true
        if hidesWhenStopped {
            setHidden(false, animated: animated)
        }
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Float.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        imageView.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
    }

    public func stopAnimating(animated: Bool = false) {
        isAnimating = false
        if hidesWhenStopped {
            setHidden(true, animated: animated) { _ in
                self.imageView.layer.removeAnimation(forKey: Constants.rotationAnimationKey)
            }
        }
        else {
            imageView.layer.removeAnimation(forKey: Constants.rotationAnimationKey)
        }
    }
}
