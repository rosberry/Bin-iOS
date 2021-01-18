//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

/**

*/

final public class PatternTimer {

    /// Timer action handler
    public typealias Handler = (TimeInterval) -> Void

    /// Timer pattern behavior rule
    public enum PatternRule {
        /// Complete one full cycle and stop the timer
        case once
        /// Repeat full cycle indefinitely
        case repeatAll
        /// Repeat last *n* elements of a pattern indefinitely
        case repeatLast(Int)
        /// Reverse pattern after reaching the end & repeat indefinitely
        case pingPong
    }

    private var timer: Timer?
    private var patternIndex: Int = 0 {
        didSet {
            updatePatternIndex()
        }
    }

    public private(set) var time: TimeInterval = 0.0
    private var accumulatedDelta: TimeInterval = 0.0
    private var timerInterval: TimeInterval?

    public private(set) var pattern: [UInt] = []
    public private(set) var timeScale: UInt = 1
    public private(set) var rule: PatternRule = .once
    private let handler: Handler

    // MARK: - Init

    /**
     Initialized the timer.

     - Parameters:
        - pattern: a list of base intervals
        - timeScale: a timescale used to transform base intervals to time intervals (base / timeScale)
        - rule: a rule which should be applied to a pattern. See `PatternRule`
        - handler: a handler to execute when timer fires
     */
    public init(pattern: [UInt], timeScale: UInt = 1, rule: PatternRule = .once, handler: @escaping Handler) {
        self.handler = handler
        setup(with: pattern, timeScale: timeScale, rule: rule)
    }

    // MARK: - Public

    /**
     Reconfigure the timer.
     If reconfiguration is performed on an active timer, it'll be stopped.

     - Parameters:
        - pattern: a list of base intervals
        - timeScale: a timescale used to transform base intervals to time intervals (base / timeScale)
        - rule: a rule which should be applied to a pattern. See `PatternRule`
    */
    public func setup(with pattern: [UInt], timeScale: UInt = 1, rule: PatternRule = .once) {
        self.pattern = pattern
        self.timeScale = timeScale
        self.rule = rule

        timerInterval = findInterval(for: pattern, timeScale: timeScale)
        stop()
    }

    /// Starts the timer.
    public func start() {
        guard let interval = timerInterval else {
            return
        }

        let timer = Timer(timeInterval: interval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)

        self.timer?.invalidate()
        self.timer = timer
    }

    /// Stops the timer.
    public func stop() {
        timer?.invalidate()
        timer = nil

        rewind()
    }

    /// Rewinds the timer without stopping it.
    public func rewind() {
        patternIndex = 0
        time = 0.0
        accumulatedDelta = 0.0
    }

    // MARK: - Actions

    @objc private func timerFired() {
        guard let timer = timer else {
            return
        }

        accumulatedDelta += timer.timeInterval
        time += timer.timeInterval

        let value = TimeInterval(pattern[patternIndex]) / TimeInterval(timeScale)
        if accumulatedDelta >= value {
            handler(time)

            accumulatedDelta -= value
            patternIndex += 1
        }
    }

    // MARK: - Helpers

    private func findInterval(for pattern: [UInt], timeScale: UInt) -> TimeInterval? {
        guard pattern.isEmpty == false else {
            return nil
        }

        var result = pattern[0]
        for value in pattern[1...] {
            result = gcd(result, value)
        }

        return TimeInterval(result) / TimeInterval(timeScale)
    }

    // swiftlint:disable identifier_name
    private func gcd(_ a: UInt, _ b: UInt) -> UInt {
        var a = a
        var b = b

        while b != 0 {
            (a, b) = (b, a % b)
        }

        return a
    }
    // swiftlint:enable identifier_name

    private func updatePatternIndex() {
        guard patternIndex >= pattern.count else {
            return
        }

        switch rule {
        case .once:
            stop()
            rewind()
        case .repeatAll:
            patternIndex = 0
        case .repeatLast(let count):
            patternIndex = max(pattern.count - count, 0)
        case .pingPong:
            patternIndex = 0
            pattern.reverse()
        }
    }
}
