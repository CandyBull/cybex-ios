//
//  ETORecordListActions.swift
//  CandyBull
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import DifferenceKit

// MARK: - State
struct ETORecordListState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<[ETOTradeHistoryModel]> = BehaviorRelay(value: [])
    var changeSet: BehaviorRelay<StagedChangeset<[ETOTradeHistoryModel]>> = BehaviorRelay(value: StagedChangeset<[ETOTradeHistoryModel]>())

    var page: BehaviorRelay<Int> = BehaviorRelay(value: 1)
}

// MARK: - Action

struct ETORecordListFetchedAction: ReSwift.Action {
    var data: JSON
    var add: Bool
}

struct ETONextPageAction: ReSwift.Action {
    var page: Int
}
