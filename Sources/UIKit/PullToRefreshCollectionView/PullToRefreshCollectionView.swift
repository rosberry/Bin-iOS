//
// Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

public class PullToRefreshCollectionView: UICollectionView {

    /// The proxy of `UIScrollViewDelegate` which you should use instead of default delegate
    /// because `PullToRefreshCollectionView` should be scroll view delegate of its self
    public weak var scrollDelegate: UIScrollViewDelegate?

    /// Handler which calls when refresh event triggered
    public var refreshHandler: (() -> Void)?

    /// Handler which calls when refresh view becomes hidden
    /// Its may be useful if you need to stop animate of refresh view after its hides
    public var refresherHidesHandler: (() -> Void)?

    /// View which will be displayed instead of default refresher
    public var refreshView: UIView? {
        willSet {
            refreshView?.removeFromSuperview()
        }
        didSet {
            if let view = refreshView {
                refreshControl?.addSubview(view)
            }
            else {
                refreshView?.removeFromSuperview()
            }
        }
    }

    public var isRefreshing: Bool {
        refreshControl?.isRefreshing ?? false
    }

    private enum Constants {
        static let defaultRefreshControlVerticalInset: CGFloat = 16
    }

    private var refreshControlHeight: CGFloat {
        (refreshView?.frame.height ?? 0) + Constants.defaultRefreshControlVerticalInset * 2
    }
    private var refreshViewYOffset: CGFloat = 0

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self

        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshControlTriggeredBySystem), for: .valueChanged)

        self.refreshControl = refreshControl
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutRefreshView()
    }

    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }

    private func layoutRefreshView() {
        let refreshViewX = bounds.width / 2 - (refreshView?.frame.width ?? 0) / 2
        let refreshViewY = (refreshControl?.frame.height ?? 0) / 2 - (refreshView?.frame.height ?? 0) / 2
        refreshView?.frame.origin = .init(x: refreshViewX, y: refreshViewY - refreshViewYOffset)
    }

    private func refreshControlTriggered() {
        refreshControl?.beginRefreshing()
        refreshHandler?()
    }

    @objc private func refreshControlTriggeredBySystem() {
        refreshControl?.endRefreshing()
    }
}

extension PullToRefreshCollectionView: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        if !isRefreshing {
            let topInset = scrollView.contentInset.top
            let normalizedRefreshOffset = 1 - offsetY.normalized(from: -topInset,
                                                                 through: -refreshControlHeight - topInset).clamped(in: 0...1)
            refreshViewYOffset = refreshControlHeight * normalizedRefreshOffset
        }

        layoutRefreshView()

        if !isRefreshing && offsetY >= -scrollView.contentInset.top {
            refresherHidesHandler?()
        }

        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < (-refreshControlHeight - scrollView.contentInset.top)) && !isRefreshing {
            refreshControlTriggered()
        }
        scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                        withVelocity velocity: CGPoint,
                                        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollDelegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let shouldScroll = scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return shouldScroll
        }
        return true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
}
