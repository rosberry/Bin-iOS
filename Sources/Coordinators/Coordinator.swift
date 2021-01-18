//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var delegate: CoordinatorDelegate? { get set }
    func append(child: Coordinator)
    func remove(child: Coordinator)
}

protocol CoordinatorDelegate: class {
    func childCoordinatorDidFinish(_ childCoordinator: Coordinator)
}

extension CoordinatorDelegate where Self: Coordinator {
    func childCoordinatorDidFinish(_ coordinator: Coordinator) {
        remove(child: coordinator)
        coordinator.delegate = nil
    }
}

// MARK: - BaseCoordinator

class BaseCoordinator<V: UIViewController>: Coordinator, CoordinatorDelegate {

    let rootViewController: V
    private var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?

    init(rootViewController: V) {
        self.rootViewController = rootViewController
    }

    func start() {

    }

    func append(child: Coordinator) {
        child.delegate = self
        childCoordinators.append(child)
    }

    func remove(child: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { coordinator in
            return coordinator === child
        }) {
            childCoordinators.remove(at: index)
        }
    }
}
