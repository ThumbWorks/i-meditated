//
//  Coordinator.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/15/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit

protocol Coordinator {
    var mainViewController: UIViewController { get }
    var childCoordinators: [Coordinator] { get set }
    mutating func push(childCoordinator coordinator: Coordinator)
    mutating func popChildCoordinator()
}

extension Coordinator {
    mutating func push(childCoordinator coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
    }
    mutating func popChildCoordinator() {
        _ = self.childCoordinators.popLast()
    }
}
