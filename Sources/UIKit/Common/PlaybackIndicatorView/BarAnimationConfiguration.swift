//
// Copyright (c) 2019 Rosberry. All rights reserved.
//

import Foundation
import CoreGraphics

final class BarAnimationConfiguration {
    let duration: CFTimeInterval
    var timeOffset: CFTimeInterval
    var isReversed: Bool = false
    var height: CGFloat = 0

    init(duration: CFTimeInterval, timeOffset: CFTimeInterval = 0) {
        self.duration = duration
        self.timeOffset = timeOffset
    }
}
