//
//  ExchangeActions.swift
//  CandyBull
//
//  Created koofrank on 2018/6/23.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct ExchangeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
