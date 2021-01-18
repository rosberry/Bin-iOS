//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

public class OperationContainerView: UIView {

    public enum State {
        case primary
        case loading
        case status(text: NSAttributedString?)
    }

    enum Constants {
        static let inset: CGFloat = 16
    }

    public let animationDuration: CFTimeInterval = 0.3
    public var statusVisibilityDuration: TimeInterval?

    private(set) var state: State = .primary

    // MARK: Subviews

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    public let loadingView: LoadingView
    public let primaryView: UIView
    public let loadingBackgroundView: UIView
    public let statusView: UIView

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(primaryView: UIView,
                loadingBackgroundView: UIView,
                statusView: UIView,
                loadingView: LoadingView) {
        self.primaryView = primaryView
        self.loadingBackgroundView = loadingBackgroundView
        self.statusView = statusView
        self.loadingView = loadingView

        super.init(frame: .zero)

        statusView.alpha = 0
        loadingBackgroundView.alpha = 0

        statusView.add(statusLabel)
        loadingBackgroundView.add(loadingView)
        add(statusView,
            loadingBackgroundView,
            primaryView)

        clipsToBounds = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        primaryView.frame = bounds
        statusView.frame = bounds
        loadingBackgroundView.frame = bounds

        let size = CGSize(width: bounds.width - 2 * Constants.inset, height: .greatestFiniteMagnitude)
        statusLabel.configureFrame { maker in
            maker.sizeThatFits(size: size).center()
        }

        loadingView.configureFrame { maker in
            maker.sizeToFit().center()
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = UIScreen.main.bounds.width
        let minHeight: CGFloat = 60

        switch state {
            case .primary, .loading:
                return .init(width: width, height: minHeight)
            case .status:
                let fitSize = CGSize(width: size.width - 2 * Constants.inset, height: .greatestFiniteMagnitude)
                let labelHeight = statusLabel.textRect(forBounds: .init(origin: .zero, size: fitSize), limitedToNumberOfLines: 0).height

                return .init(width: width, height: max(minHeight, labelHeight + 2 * 12))
        }
    }

    // MARK: Actions

    public func enter(state: State, animated: Bool) {
        self.state = state

        switch state {
            case .primary:
                showPrimaryView(animated: animated)
            case .loading:
                loadingBackgroundView.alpha = 1
                perform(animated: animated, actions: {
                    self.loadingView.update(loading: true)
                    self.statusLabel.alpha = 0
                    self.primaryView.alpha = 0
                    self.statusView.alpha = 0
                }, completion: nil)
            case let .status(text):
                self.statusLabel.attributedText = text
                setNeedsLayout()
                layoutIfNeeded()
                statusView.alpha = 1
                perform(animated: animated, actions: {
                    self.loadingView.update(loading: false)
                    self.loadingBackgroundView.alpha = 0
                    self.primaryView.alpha = 0
                    self.statusLabel.alpha = 1
                }, completion: nil)
                if let statusDuration = statusVisibilityDuration {
                    DispatchQueue.main.asyncAfter(deadline: .now() + statusDuration, execute: { [weak self] in
                        guard let self = self,
                            case State.status = self.state else {
                            return
                        }
                        self.enter(state: .primary, animated: animated)
                    })
            }
        }
    }

    private func showPrimaryView(animated: Bool) {
        perform(animated: animated, actions: {
            self.loadingView.update(loading: false)
            self.statusView.alpha = 0
            self.primaryView.alpha = 1
            self.statusLabel.alpha = 0
        }, completion: {
            self.loadingBackgroundView.alpha = 0
        })
    }

    private func perform(animated: Bool, actions: @escaping () -> Void, completion: (() -> Void)?) {
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                actions()
            }, completion: { _ in
                completion?()
            })
        }
        else {
            actions()
            completion?()
        }
    }
}
