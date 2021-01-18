//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import XCTest
import UIKit
import Bin

final class ListPagerTests: XCTestCase {

    private enum PagingPresenceStatus {
        case inRange
        case outOfRange
    }

    private var scrollView: UIScrollView!
    private var screenFrame: CGRect {
        UIScreen.main.bounds
    }

    override func setUp() {
        super.setUp()
        scrollView = .init(frame: screenFrame)
    }

    func testVerticalSmallContentSizeHandler() {
        let pager = ListPager(pagingDirection: .vertical)
        pager.pagingStartOffset = scrollView.bounds.height
        scrollView.contentSize.height = pager.pagingStartOffset
        XCTAssertTrue(isPagingCalledIfContentSizeTooSmall(pager: pager, scrollView: scrollView),
                      "should be true since content size height is less or equal then bounds height")
        scrollView.contentSize.height = pager.pagingStartOffset * 2
        XCTAssertFalse(isPagingCalledIfContentSizeTooSmall(pager: pager, scrollView: scrollView),
                       "should be false since content size height is greater then bounds height")
    }

    func testHorizontalSmallContentSizeHandler() {
        let pager = ListPager(pagingDirection: .horizontal)
        pager.pagingStartOffset = scrollView.bounds.width
        scrollView.contentSize.width = pager.pagingStartOffset
        XCTAssertTrue(isPagingCalledIfContentSizeTooSmall(pager: pager, scrollView: scrollView),
                      "should be true since content size width is less or equal then bounds width")
        scrollView.contentSize.width = pager.pagingStartOffset * 2
        XCTAssertFalse(isPagingCalledIfContentSizeTooSmall(pager: pager, scrollView: scrollView),
                       "should be false since content size width is greater then bounds width")
    }

    func testHorizontalPagingReset() {
        let pager = ListPager(pagingDirection: .horizontal)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }
        pager.scrollView = scrollView
        scrollView.delegate = pager
        pager.pagingStartOffset = scrollView.bounds.width
        scrollView.contentSize.width = pager.pagingRestartOffset
        scrollView.contentOffset = .init(x: 1, y: 0)
        XCTAssertEqual(lastStatus, .inRange, "should be in range since in range")
        lastStatus = nil
        scrollView.contentOffset = .init(x: 2, y: 0)
        XCTAssertEqual(lastStatus, nil, "should not be set since were in range and didn't got out of range")
        pager.resetPagingState()
        lastStatus = nil
        scrollView.contentOffset = .init(x: 3, y: 0)
        XCTAssertEqual(lastStatus, .inRange, "should be in range since state were reset")
    }

    func testVerticalPagingReset() {
        let pager = ListPager(pagingDirection: .vertical)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }
        pager.scrollView = scrollView
        scrollView.delegate = pager
        pager.pagingStartOffset = scrollView.bounds.height
        scrollView.contentSize.height = pager.pagingRestartOffset
        scrollView.contentOffset = .init(x: 0, y: 1)
        XCTAssertEqual(lastStatus, .inRange, "should be in range since in range")
        lastStatus = nil
        scrollView.contentOffset = .init(x: 0, y: 2)
        XCTAssertEqual(lastStatus, nil, "should not be set since were in range and didn't got out of range")
        pager.resetPagingState()
        lastStatus = nil
        scrollView.contentOffset = .init(x: 0, y: 3)
        XCTAssertEqual(lastStatus, .inRange, "should be in range since state were reset")
    }

    func testVerticalPaging() {
        let pager = ListPager(pagingDirection: .vertical)
        scrollView.delegate = pager
        pager.scrollView = scrollView
        scrollView.contentSize = .init(width: scrollView.frame.width, height: screenFrame.height * 2)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }
        scrollView.contentOffset = .init(x: 0, y: 0)
        XCTAssertEqual(lastStatus, nil, "should be nil since not in paging borders")
        scrollView.contentOffset = .init(x: 0, y: 1)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since in range")
        lastStatus = nil
        scrollView.contentOffset = .init(x: 0, y: 2)
        XCTAssertEqual(lastStatus, nil, "should not be changed since still in range")
        scrollView.contentOffset = .init(x: 0, y: 1)
        XCTAssertEqual(lastStatus, .outOfRange, "should be outOfRange since out of range")
    }

    func testHorizontalPaging() {
        let pager = ListPager(pagingDirection: .horizontal)
        scrollView.delegate = pager
        pager.scrollView = scrollView
        scrollView.contentSize = .init(width: screenFrame.width * 2, height: scrollView.frame.height)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }
        scrollView.contentOffset = .init(x: 0, y: 0)
        XCTAssertEqual(lastStatus, nil, "should be nil since not in paging borders")
        scrollView.contentOffset = .init(x: 1, y: 0)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since in range")
        lastStatus = nil
        scrollView.contentOffset = .init(x: 2, y: 0)
        XCTAssertEqual(lastStatus, nil, "should not be changed since still in range")
        scrollView.contentOffset = .init(x: 1, y: 0)
        XCTAssertEqual(lastStatus, .outOfRange, "should be outOfRange since out of range")
    }

    func testVerticalPagingWithIncreasedContentHeight() {
        let pager = ListPager(pagingDirection: .vertical)
        scrollView.delegate = pager
        pager.scrollView = scrollView
        scrollView.contentSize = .init(width: scrollView.frame.width, height: screenFrame.height * 2)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }

        scrollView.contentOffset = .zero
        XCTAssertEqual(lastStatus, nil, "should be not changed since not scrolled")

        scrollView.contentOffset = .init(x: 0, y: screenFrame.height)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since in range")
        scrollView.contentSize.height += screenFrame.height
        lastStatus = nil
        scrollView.contentOffset = .init(x: 0, y: screenFrame.height + 1)
        XCTAssertEqual(lastStatus, .outOfRange, "should be outOfRange since content height changed")
        scrollView.contentOffset = .init(x: 0, y: screenFrame.height + 2)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since last were outOfRange and in range")
    }

    func testHorizontalPagingWithIncreasedContentHeight() {
        let pager = ListPager(pagingDirection: .horizontal)
        scrollView.delegate = pager
        pager.scrollView = scrollView
        scrollView.contentSize = .init(width: screenFrame.width * 2, height: scrollView.frame.height)
        var lastStatus: PagingPresenceStatus?
        pager.pagingInRangeEventHandler = {
            lastStatus = .inRange
        }
        pager.pagingOutOfRangeEventHandler = {
            lastStatus = .outOfRange
        }

        scrollView.contentOffset = .zero
        XCTAssertEqual(lastStatus, nil, "should be not changed since not scrolled")

        scrollView.contentOffset = .init(x: screenFrame.width, y: 0)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since in range")
        scrollView.contentSize.width += screenFrame.width
        lastStatus = nil
        scrollView.contentOffset = .init(x: screenFrame.width + 1, y: 0)
        XCTAssertEqual(lastStatus, .outOfRange, "should be outOfRange since content height changed")
        scrollView.contentOffset = .init(x: screenFrame.width + 2, y: 0)
        XCTAssertEqual(lastStatus, .inRange, "should be inRange since last were outOfRange and in range")
    }

    private func isPagingCalledIfContentSizeTooSmall(pager: ListPager, scrollView: UIScrollView) -> Bool {
        var isSucceed = false
        scrollView.delegate = pager
        pager.scrollView = scrollView
        pager.pagingOutOfRangeEventHandler = {
            isSucceed = false
        }
        pager.pagingInRangeEventHandler = {
            isSucceed = true
        }
        pager.performPagingIfContentSizeTooSmall()
        return isSucceed
    }
}
