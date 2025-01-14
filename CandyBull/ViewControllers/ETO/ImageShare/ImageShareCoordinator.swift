//
//  ImageShareCoordinator.swift
//  CandyBull
//
//  Created peng zhu on 2018/8/30.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift


protocol ImageShareCoordinatorProtocol {
}

protocol ImageShareStateManagerProtocol {
    var state: ImageShareState { get }
}

class ImageShareCoordinator: NavCoordinator {
    var store = Store(
        reducer: imageShareReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ImageShareState {
        return store.state
    }

    override func register() {
        Broadcaster.register(ImageShareCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ImageShareStateManagerProtocol.self, observer: self)
    }
}

extension ImageShareCoordinator: ImageShareCoordinatorProtocol {

}

extension ImageShareCoordinator: ImageShareStateManagerProtocol {

}
