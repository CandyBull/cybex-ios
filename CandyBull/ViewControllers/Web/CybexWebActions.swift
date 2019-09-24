//
//  CybexWebActions.swift
//  CandyBull
//
//  Created DKM on 2018/8/31.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct CybexWebState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

   var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

// MARK: - Action
