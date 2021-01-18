//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

public class AlignButton: UIButton {

    enum LayoutDirection {
        case horizontal
        case vertical
    }
    enum LayoutHorizontalAlignment {
        case left
        case center
        case right
        case justified
    }
    enum LayoutVerticalAlignment {
        case top
        case center
        case bottom
        case justified
    }
    enum ImageAlignment {
        case beginning
        case end
    }

    // Positioning direction for title and image
    var layoutDirection: LayoutDirection = .horizontal

    // Horizontal positioning for title and image
    var layoutHorizontalAlignment: LayoutHorizontalAlignment = .center

    // Vertical positioning for title and image
    var layoutVerticalAlignment: LayoutVerticalAlignment = .center

    // Image position relative to title (.beginning - before title, .end - after title)
    var imageAlignment: ImageAlignment = .beginning

    // Spacing befween title and image
    var contentSpacing: CGFloat = 0

    private var imageSize: CGSize {
        if let imageView = imageView, let image = imageView.image {
            return image.size
        }
        return .zero
    }
    private var titleSize: CGSize {
        if let titleLabel = titleLabel, !titleLabel.text.isNilOrEmpty {
            return titleLabel.bounds.size
        }
        return .zero
    }
    private var leftViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return imageSize
        }
        return titleSize
    }
    private var rightViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return titleSize
        }
        return imageSize
    }
    private var contentWidth: CGFloat {
        return imageSize.width + titleSize.width + contentSpacing
    }
    private var contentHeight: CGFloat {
        return imageSize.height + titleSize.height + contentSpacing
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        switch layoutDirection {
        case .horizontal:
            layoutHorizontally()
        case .vertical:
            layoutVertically()
        }
    }

    // MARK: Horizontal

    private func layoutHorizontally() {
        let leftView = leftViewForHorizontalLayout()
        let rightView = rightViewForHorizontalLayout()

        switch layoutHorizontalAlignment {
        case .left:
            leftView?.configureFrame { maker in
                maker.left(inset: contentEdgeInsets.left)
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
            rightView?.configureFrame { maker in
                if let leftView = leftView, leftViewSize != .zero {
                    maker.left(to: leftView.nui_right, inset: contentSpacing)
                }
                else {
                    maker.left(inset: contentEdgeInsets.left)
                }
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
        case .center:
            leftView?.configureFrame { maker in
                maker.left(inset: (bounds.width - contentWidth) / 2)
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
            rightView?.configureFrame { maker in
                if let leftView = leftView, leftViewSize != .zero {
                    maker.left(to: leftView.nui_right, inset: contentSpacing)
                }
                else {
                    maker.centerX()
                }
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
        case .right:
            rightView?.configureFrame { maker in
                maker.right(inset: contentEdgeInsets.right)
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
            leftView?.configureFrame { maker in
                if let rightView = rightView {
                    maker.right(to: rightView.nui_left, inset: contentSpacing)
                }
                else {
                    maker.right(inset: contentEdgeInsets.right)
                }
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
        case .justified:
            leftView?.configureFrame { maker in
                maker.left(inset: contentEdgeInsets.left)
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
            rightView?.configureFrame { maker in
                maker.right(inset: contentEdgeInsets.right)
                arrangeViewVerticallyForHorizontalLayout(with: maker)
            }
        }
    }

    private func leftViewForHorizontalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return imageView?.image != nil ? imageView : nil
        }
        return (titleLabel?.text != nil || titleLabel?.attributedText != nil) ? titleLabel : nil
    }

    private func rightViewForHorizontalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return (titleLabel?.text != nil || titleLabel?.attributedText != nil) ? titleLabel : nil
        }
        return imageView?.image != nil ? imageView : nil
    }

    private func arrangeViewVerticallyForHorizontalLayout(with maker: Maker) {
        let contentHeight = max(imageSize.height, titleSize.height)
        switch layoutVerticalAlignment {
        case .top, .justified:
            maker.top(inset: (contentHeight - bounds.height) / 2 + contentEdgeInsets.top)
        case .center:
            maker.centerY()
        case .bottom:
            maker.bottom(inset: (contentHeight - bounds.height) / 2 + contentEdgeInsets.bottom)
        }
    }

    // MARK: Vertical

    private func layoutVertically() {
        let topView = topViewForVerticalLayout()
        let bottomView = bottomViewForVerticalLayout()

        switch layoutVerticalAlignment {
        case .top:
            topView?.configureFrame { maker in
                maker.top(inset: contentEdgeInsets.top)
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
            bottomView?.configureFrame { maker in
                if let topView = topView {
                    maker.top(to: topView.nui_bottom, inset: contentSpacing)
                }
                else {
                    maker.top(inset: contentEdgeInsets.top)
                }
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
        case .center:
            topView?.configureFrame { maker in
                maker.top(inset: (bounds.height - contentHeight) / 2)
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
            bottomView?.configureFrame { maker in
                if let topView = topView {
                    maker.top(to: topView.nui_bottom, inset: contentSpacing)
                }
                else {
                    maker.centerY()
                }
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
        case .bottom:
            bottomView?.configureFrame { maker in
                maker.bottom(inset: contentEdgeInsets.bottom)
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
            topView?.configureFrame { maker in
                if let bottomView = bottomView {
                    maker.bottom(to: bottomView.nui_top, inset: contentSpacing)
                }
                else {
                    maker.bottom(inset: contentEdgeInsets.bottom)
                }
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
        case .justified:
            topView?.configureFrame { maker in
                maker.top(inset: contentEdgeInsets.top)
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
            bottomView?.configureFrame { maker in
                maker.bottom(inset: contentEdgeInsets.bottom)
                arrangeViewHorizontallyForVerticalLayout(with: maker)
            }
        }
    }

    private func topViewForVerticalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return imageView?.image != nil ? imageView : nil
        }
        return (titleLabel?.text != nil || titleLabel?.attributedText != nil) ? titleLabel : nil
    }

    private func bottomViewForVerticalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return (titleLabel?.text != nil || titleLabel?.attributedText != nil) ? titleLabel : nil
        }
        return imageView?.image != nil ? imageView : nil
    }

    private func arrangeViewHorizontallyForVerticalLayout(with maker: Maker) {
        switch layoutHorizontalAlignment {
        case .left:
            maker.left(inset: (contentWidth - bounds.width) / 2 + contentEdgeInsets.left)
        case .center:
            maker.centerX()
        case .right, .justified:
            maker.right(inset: (contentWidth - bounds.width) / 2 + contentEdgeInsets.right)
        }
    }

    // MARK: - Size

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let imageSize = imageView?.sizeThatFits(size) ?? .zero
        let titleSize = titleLabel?.sizeThatFits(size) ?? .zero
        switch layoutDirection {
        case .horizontal:
            let width = imageSize.width + titleSize.width + contentSpacing + contentEdgeInsets.left + contentEdgeInsets.right
            return CGSize(width: width, height: max(imageSize.height, titleSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom)
        case .vertical:
            let height = imageSize.height + titleSize.height + contentSpacing + contentEdgeInsets.top + contentEdgeInsets.bottom
            return CGSize(width: max(imageSize.width, titleSize.width) + contentEdgeInsets.left + contentEdgeInsets.right, height: height)
        }
    }
}
