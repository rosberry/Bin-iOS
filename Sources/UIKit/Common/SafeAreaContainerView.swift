//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

public final class SafeAreaContainerView: UIView {

    public struct SafeAreaCareSide: OptionSet {
        public let rawValue: Int

        public static let top = SafeAreaCareSide(rawValue: 1)
        public static let left = SafeAreaCareSide(rawValue: 2)
        public static let right = SafeAreaCareSide(rawValue: 3)
        public static let bottom = SafeAreaCareSide(rawValue: 4)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public var insets: UIEdgeInsets = .zero
    public var safeAreaCareSide: SafeAreaCareSide = [.top, .left, .bottom, .right]
    public var totalInsets: UIEdgeInsets {
        return .init(top: inset(for: \.top, side: .top),
                     left: inset(for: \.left, side: .left),
                     bottom: inset(for: \.bottom, side: .bottom),
                     right: inset(for: \.right, side: .right))
    }

    // MARK: Life cycle

    public override func layoutSubviews() {
        super.layoutSubviews()

        let insets = totalInsets
        for subview in subviews {
            subview.configureFrame { maker in
                maker.edges(insets: insets)
            }
        }
    }

    // MARK: - Private

    private func inset(for keyPath: KeyPath<UIEdgeInsets, CGFloat>, side: SafeAreaCareSide) -> CGFloat {
        var inset = insets[keyPath: keyPath]
        if safeAreaCareSide.contains(side) {
            inset += safeAreaInsets[keyPath: keyPath]
        }
        return inset
    }
}
