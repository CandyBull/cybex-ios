//
//  TransferDetailActions.swift
//  CandyBull
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct TransferDetailState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
