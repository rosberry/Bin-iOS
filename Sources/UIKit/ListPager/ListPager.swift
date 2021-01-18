//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import UIKit

/// Paging helper
/// Provides functionality, to implement paging via `scrollView.contentOffset`
public final class ListPager: NSObject {

    /// - horizontal: x-axis values of measures will be checked. Such as `CGSize.width`, `CGPoint.x`, etc
    /// - vertical: y-axis values of measures will be checked. Such as `CGSize.height`, `CGPoint.y`, etc
    public enum PagingDirection {
        case horizontal
        case vertical
    }

    /// **"inRange" distance**
    /// This value makes range that starts from scrollView bounds endpoint. When `scrollView.contentOffset` enters this range,
    /// the `pagingInRangeEventHandler` is called
    /// > **bounds endpoint** depends on PagingDirection
    public var pagingStartOffset: CGFloat = 0

    /// **"outOfRange" distance**
    /// This value makes range that starts from scrollView bounds endpoint. When `scrollView.contentOffset` leaves from this range,
    /// the `pagingOutOfRangeEventHandler` is called
    /// > **bounds endpoint** depends on PagingDirection
    public var pagingRestartOffset: CGFloat = 0

    /// Called when `scrollView.contentOffset` enters the `pagingStartOffset`
    public var pagingInRangeEventHandler: (() -> Void)?

    /// Called when `scrollView.contentOffset` enters the `pagingRestartOffset`
    public var pagingOutOfRangeEventHandler: (() -> Void)?

    /// ScrollView, which content size will be checked on `performPagingIfContentSizeTooSmall`
    public weak var scrollView: UIScrollView?

    /// Associated with this pager `LoadingStatus`
    /// > pager doesn't affect state of this variable
    public var loadingCellStatus: LoadingStatus = .loading

    /// Indicated that `scrollView.contentOffset` is in `pagingStartOffset` and doesn't leave `pagingRestartOffset`
    private(set) var isInPagingBorders: Bool = false

    private var smallContentSizePagingHandler: () -> Void = {}
    private var isPagingPossible: Bool = true
    private var lastContentSize: CGSize = .zero
    private var scrollViewDidScrollEventHandler: (UIScrollView) -> Void = { _ in }
    private var lastContentOffset: CGPoint = .zero

    /// - Parameters:
    ///   - pagingDirection: A value that should corresponds to scroll direction of `scrollView`
    public init(pagingDirection: PagingDirection) {
        super.init()
        let screenSize = UIScreen.main.bounds.size
        switch pagingDirection {
        case .vertical:
            pagingStartOffset = screenSize.height
            pagingRestartOffset = screenSize.height / 3
            scrollViewDidScrollEventHandler = { [weak self] view in
                self?.paging(scrollView: view, cgPointKeyPath: \.y, sizeKeyPath: \.height)
            }
            smallContentSizePagingHandler = { [weak self] in
                self?.performPagingIfContentSizeTooSmall(keyPath: \.height)
            }
        case .horizontal:
            pagingStartOffset = screenSize.width
            pagingRestartOffset = screenSize.width / 3
            scrollViewDidScrollEventHandler = { [weak self] view in
                self?.paging(scrollView: view, cgPointKeyPath: \.x, sizeKeyPath: \.width)
            }
            smallContentSizePagingHandler = { [weak self] in
                self?.performPagingIfContentSizeTooSmall(keyPath: \.width)
            }
        }
    }

    /// Checks if `scrollView.contentSize` value is less, then (bounds.height + pagingStartOffset).
    /// If so, then call `pagingInRangeEventHandler`
    public func performPagingIfContentSizeTooSmall() {
        smallContentSizePagingHandler()
    }

    /// Resets internal paging state
    /// > Notice, that if it has been called after inRangeEvent, then next `scrollView.contentOffset` change, that is still
    /// > in `pagingStartOffset` will also trigger `pagingInRangeEventHandler`
    public func resetPagingState() {
        isPagingPossible = true
    }

    // MARK: - Private

    private func performPagingIfContentSizeTooSmall(keyPath: KeyPath<CGSize, CGFloat>) {
        guard let scrollView = scrollView,
              scrollView.contentSize[keyPath: keyPath] > 0,
              scrollView.contentSize[keyPath: keyPath] - pagingStartOffset < scrollView.bounds.size[keyPath: keyPath] else {
            return
        }
        isInPagingBorders = true
        pagingInRangeEventHandler?()
    }

    private func paging(scrollView: UIScrollView, cgPointKeyPath: KeyPath<CGPoint, CGFloat>, sizeKeyPath: KeyPath<CGSize, CGFloat>) {
        guard scrollView.contentSize[keyPath: sizeKeyPath] > 0 else {
            return
        }
        let isScrollingRight = isContentOffsetFieldIncreased(in: scrollView, keyPath: cgPointKeyPath)
        let contentSize = scrollView.contentSize
        let isContentWidthIncreased = lastContentSize[keyPath: sizeKeyPath] < contentSize[keyPath: sizeKeyPath]
        lastContentSize = contentSize

        let alreadyScrolledContentWidth = scrollView.contentOffset[keyPath: cgPointKeyPath] + scrollView.bounds.size[keyPath: sizeKeyPath]
        let contentRightOffset = contentSize[keyPath: sizeKeyPath] - alreadyScrolledContentWidth
        let isScrolledOutOfRange = !isScrollingRight && contentRightOffset > pagingRestartOffset
        let isScrolledInRange = isScrollingRight && contentRightOffset < pagingStartOffset

        if !isPagingPossible, (isScrolledOutOfRange || isContentWidthIncreased) {
            handleOutOfRangeEvent()
        }
        else if isPagingPossible, isScrolledInRange {
            handleInRangeEvent()
        }
    }

    private func handleInRangeEvent() {
        isPagingPossible = false
        isInPagingBorders = true
        pagingInRangeEventHandler?()
    }

    private func handleOutOfRangeEvent() {
        isPagingPossible = true
        isInPagingBorders = false
        pagingOutOfRangeEventHandler?()
    }

    private func isContentOffsetFieldIncreased(in scrollView: UIScrollView,
                                               keyPath: KeyPath<CGPoint, CGFloat>) -> Bool {
        let isScrollingDown: Bool = lastContentOffset[keyPath: keyPath] < scrollView.contentOffset[keyPath: keyPath]
        lastContentOffset = scrollView.contentOffset
        return isScrollingDown
    }
}

extension ListPager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollEventHandler(scrollView)
    }
}
