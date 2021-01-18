//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import XCTest
import Bin

class PatternTimerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testColors() {
        let color1 = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        let rgb = color1.rgb
        XCTAssertEqual(rgb.r, 0.1)
        XCTAssertEqual(rgb.g, 0.2)
        XCTAssertEqual(rgb.b, 0.3)

        let color2 = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 1)
        let hsb = color2.hsb
        XCTAssertEqual(hsb.h, 0.1, accuracy: 0.1)
        XCTAssertEqual(hsb.s, 0.2, accuracy: 0.1)
        XCTAssertEqual(hsb.b, 0.3, accuracy: 0.1)
    }

    func testPatternTimer() {
        var accumulatedTime: TimeInterval = 0.0
        let completionExpectation = expectation(description: "accumulatedTimeExpectation")

        let pattern: [UInt] = [1, 2, 3]
        let total: TimeInterval = pattern.reduce(0) { (result: TimeInterval, input: UInt) -> TimeInterval in
            return result + TimeInterval(input)
        }

        let fireExpectation = expectation(description: "timerFireExpectation")
        fireExpectation.expectedFulfillmentCount = pattern.count

        let timer = PatternTimer(pattern: pattern) { (interval: TimeInterval) in
            fireExpectation.fulfill()

            accumulatedTime += interval
            if accumulatedTime >= total {
                completionExpectation.fulfill()
            }
        }

        let startTime = Date()

        timer.start()
        wait(for: [fireExpectation, completionExpectation], timeout: 10.0)

        let delta = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
        XCTAssertEqual(delta, total, accuracy: 0.5)
    }
}
