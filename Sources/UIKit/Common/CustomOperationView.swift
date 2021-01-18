//
// Copyright (c) 2020 Zazzi. All rights reserved.
//

import UIKit

class CustomOperationView<View: UIView>: OperationContainerView {

    final let view: View

    init(view: View, loadingView: LoadingView) {
        self.view = view
        super.init(primaryView: self.view, loadingBackgroundView: .init(), statusView: .init(), loadingView: loadingView)
    }

    final override func sizeThatFits(_ size: CGSize) -> CGSize {
        view.sizeThatFits(size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
