//
// Copyright (c) 2019 Rosberry. All rights reserved.
//

import UIKit

final public class PlaybackIndicatorView: UIView {

    /// The minimum value of height for bar view
    /// Default value is 6
    public var minBarHeight: CGFloat = 6
    /// The value of width for bar view
    /// Default value is 4
    public var barWidth: CGFloat = 4
    /// The value of distance between bar views
    /// Default value is 2
    public var distanceBetweenBars: CGFloat = 2

    /// The background color of bar views
    /// Default value is `white`
    public var barViewsBackgroundColor: UIColor = .white {
        didSet {
            barViews.forEach { view in
                view.backgroundColor = barViewsBackgroundColor
            }
        }
    }

    public private(set) var isAnimating: Bool = false

    private var barAnimationConfigurations: [BarAnimationConfiguration] = []

    private var displayLink: CADisplayLink?
    private var lastTick: CFTimeInterval?

    // MARK: Subviews

    private var barViews: [UIView] = []

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(numberOfBars: Int = 3) {
        super.init(frame: .zero)

        (0..<numberOfBars).forEach { _ in
            let view = UIView()
            view.layer.anchorPoint = .init(x: 0.5, y: 1)
            view.backgroundColor = UIColor.white
            addSubview(view)
            barViews.append(view)
            barAnimationConfigurations.append(.init(duration: CFTimeInterval.random(in: (0.3..<0.6))))
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        stopTimer()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard !isAnimating else {
            return
        }

        (0..<barViews.count).forEach { index in
            let view = barViews[index]

            view.frame = .init(x: CGFloat(index) * (barWidth + distanceBetweenBars),
                               y: bounds.height - barAnimationConfigurations[index].height,
                               width: barWidth,
                               height: barAnimationConfigurations[index].height)
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let numberOfBars = CGFloat(barViews.count)
        let width = (barWidth * numberOfBars) + (distanceBetweenBars * (numberOfBars - 1))
        return .init(width: width, height: size.height)
    }

    public func startAnimating() {
        if isAnimating {
            stopTimer()
        }

        startTimer()
        isAnimating = true
    }

    public func stopAnimating() {
        guard isAnimating else {
            return
        }

        stopTimer()
        isAnimating = false
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .current, forMode: .common)
    }

    private func stopTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick() {
        guard let duration = displayLink?.duration else {
            return
        }

        for (configuration, view) in zip(barAnimationConfigurations, barViews) {
            let actualDelta = configuration.isReversed ? -duration : duration
            configuration.timeOffset += actualDelta

            let progress = (configuration.timeOffset / configuration.duration).clamped(min: 0, max: 1)
            view.bounds.size.height = minBarHeight + (bounds.height - minBarHeight) * CGFloat(sineEaseInOut(progress))
            configuration.height = view.bounds.size.height

            if configuration.timeOffset >= configuration.duration {
                configuration.isReversed = true
            }
            if configuration.timeOffset <= 0 {
                configuration.isReversed = false
            }
        }
    }

    // swiftlint:disable:next identifier_name
    private func sineEaseInOut(_ x: Double) -> Double {
        return 1 / 2 * (1 - cos(x * .pi))
    }

    // MARK: - Notifications

    @objc private func applicationDidBecomeActive() {
        if isAnimating {
            startAnimating()
        }
    }
}
