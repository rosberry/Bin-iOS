//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

public struct Shadow {

    public let color: UIColor
    public let offset: CGSize
    public let blur: CGFloat
    public let spread: CGFloat

    public init(color: UIColor, offset: CGSize, blur: CGFloat, spread: CGFloat) {
        self.color = color
        self.offset = offset
        self.blur = blur
        self.spread = spread
    }

    /// Applies shadow parameters to passed CALayer.
    ///
    /// - Parameter layer: the layer for shadow applying.
    public func apply(to layer: CALayer) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = offset
        layer.shadowRadius = blur
        let rect = layer.bounds.insetBy(dx: -spread, dy: -spread)
        layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: layer.cornerRadius).cgPath
    }

    /// Applies shadow parameters to passed CALayers.
    ///
    /// - Parameter layers: the layers for shadow applying.
    public func apply(to layers: [CALayer]) {
        layers.forEach(apply)
    }

    /// Applies shadow parameters to passed CALayers.
    ///
    /// - Parameter layers: the layers for shadow applying.
    public func apply(to layers: CALayer...) {
        apply(to: layers)
    }

    /// Applies shadow parameters to passed UIView's layer.
    ///
    /// - Parameter view: the view for shadow applying.
    public func apply(to view: UIView) {
        apply(to: view.layer)
    }

    /// Applies shadow parameters to passed UIViews' layers.
    ///
    /// - Parameter views: the views for shadow applying.
    public func apply(to views: [UIView]) {
        views.forEach(apply)
    }

    /// Applies shadow parameters to passed UIViews' layers.
    ///
    /// - Parameter views: the views for shadow applying.
    public func apply(to views: UIView...) {
        apply(to: views)
    }
}
