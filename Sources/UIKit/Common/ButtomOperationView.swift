//
// Copyright (c) 2020 Zazzi. All rights reserved.
//

import UIKit

final class ButtonOperationView: CustomOperationView<UIButton> {

    var tapHandler: (() -> Void)?

    override init(view: UIButton, loadingView: LoadingView) {
        super.init(view: view, loadingView: loadingView)
        view.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonPressed() {
        tapHandler?()
    }
}
