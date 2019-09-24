//
//  ImageShareActions.swift
//  CandyBull
//
//  Created peng zhu on 2018/8/30.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct ImageShareState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

   var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

// MARK: - Action
