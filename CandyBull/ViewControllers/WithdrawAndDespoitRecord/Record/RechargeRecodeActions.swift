//
//  RechargeRecodeActions.swift
//  CandyBull
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct RechargeRecodeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var data: BehaviorRelay<TradeRecord?> = BehaviorRelay(value: nil)
    var asset: String = ""
    var explorers: BehaviorRelay<[BlockExplorer]?> = BehaviorRelay(value: nil)
}

struct FetchDepositRecordsAction: ReSwift.Action {
    var data: TradeRecord?
}

struct SetWithdrawListAssetAction: ReSwift.Action {
    var asset: String
}

struct FetchAssetUrlAction: ReSwift.Action {
    var data: [BlockExplorer]
}
