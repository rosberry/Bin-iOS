//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

public protocol HSLViewDelegate: class {
    func hslView(_ hslView: HSLView, didSelectColor color: UIColor)
    func hslViewDidSelectAllColorItems(_ hslView: HSLView)
    func hslViewDidBeginColorSelection(_ hslView: HSLView)
    func hslViewDidEndColorSelection(_ hslView: HSLView)
}

public final class HSLView: UIView {

    public weak var delegate: HSLViewDelegate?

    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hueSaturationViewRecognizerTriggered))
        return gestureRecognizer
    }()

    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(hueSaturationViewRecognizerTriggered))
        return gestureRecognizer
    }()

    public var relativeGrayscaleWidth: CGFloat = 0.02
    public var borderColor: UIColor = .gray
    public var image: UIImage? = UIImage(named: "hslColorPicker")
    public var viewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)

    private var grayscaleRegionWidth: CGFloat {
        return  relativeGrayscaleWidth * hueSaturationImageView.frame.width
    }

    // MARK: - Subviews

    private lazy var hueSaturationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = borderColor.cgColor
        imageView.layer.cornerRadius = 4
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    public lazy var magnifierView = MagnifierView()

    private lazy var gestureRecognizersContainerView: UIView = .init()

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()

    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gestureRecognizersContainerView.frame = bounds
        hueSaturationImageView.configureFrame { maker in
            maker.edges(insets: viewInsets)
        }
    }

    // MARK: -

    func setMagnifierViewHidden() {
        magnifierView.isHidden = true
    }

    // MARK: - Actions

    @objc private func hueSaturationViewRecognizerTriggered(_ recognizer: UIGestureRecognizer) {
        func setColor() {
            var touchPosition = recognizer.location(in: self)
            touchPosition = point(touchPosition, thatFits: hueSaturationImageView.frame)

            magnifierView.center = touchPosition
            let color = UIColor(hue: hue(for: touchPosition),
                                saturation: saturation(for: touchPosition),
                                brightness: brightness(for: touchPosition),
                                alpha: 1.0)
            magnifierView.backgroundColor = color
            delegate?.hslView(self, didSelectColor: color)
        }
        magnifierView.isHidden = false
        delegate?.hslViewDidSelectAllColorItems(self)
        switch recognizer.state {
        case .began:
            setColor()
            delegate?.hslViewDidBeginColorSelection(self)
        case .changed:
            setColor()
        case .ended:
            setColor()
            delegate?.hslViewDidEndColorSelection(self)
        default:
            break
        }
    }

    // MARK: - Private

    private func setup() {
        add(hueSaturationImageView, gestureRecognizersContainerView, magnifierView)
        gestureRecognizersContainerView.addGestureRecognizer(tapGestureRecognizer)
        gestureRecognizersContainerView.addGestureRecognizer(panGestureRecognizer)
        magnifierView.isHidden = true
    }

    private func hue(for position: CGPoint) -> CGFloat {
        return (position.x - hueSaturationImageView.frame.origin.x) / (hueSaturationImageView.frame.width - grayscaleRegionWidth)
    }

    private func saturation(for position: CGPoint) -> CGFloat {
        if hueSaturationImageView.frame.width - (position.x - hueSaturationImageView.frame.origin.x) <= grayscaleRegionWidth {
            return 0.0
        }

        let pointY = (position.y - hueSaturationImageView.frame.origin.y) / hueSaturationImageView.frame.height
        if pointY < 0.5 {
            return 1.0 - (0.5 - pointY) * 2
        }
        else {
            return 1.0
        }
    }

    private func brightness(for position: CGPoint) -> CGFloat {
        if hueSaturationImageView.frame.width - (position.x - hueSaturationImageView.frame.origin.x) <= grayscaleRegionWidth {
            return 1.0 - (position.y - hueSaturationImageView.frame.origin.y) / hueSaturationImageView.frame.height
        }

        let pointY = (position.y - hueSaturationImageView.frame.origin.y) / hueSaturationImageView.frame.height
        if pointY > 0.5 {
            return 1.0 - (pointY - 0.5) * 2
        }
        else {
            return 1.0
        }
    }

    private func point(_ point: CGPoint, thatFits rect: CGRect) -> CGPoint {
        .init(x: min(max(point.x, rect.origin.x), rect.maxX),
              y: min(max(point.y, rect.origin.y), rect.maxY))
    }
}

extension HSLViewDelegate {
    func hslViewDidSelectAllColorItems(_ hslView: HSLView) {
        //
    }

    func hslViewDidBeginColorSelection(_ hslView: HSLView) {
        //
    }

    func hslViewDidEndColorSelection(_ hslView: HSLView) {
        //
    }
}
