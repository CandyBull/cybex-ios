//
//  TransferListActions.swift
//  CandyBull
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa

// MARK: - State
struct TransferListState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var data: BehaviorRelay<[TransferRecordViewModel]?> = BehaviorRelay(value: nil)
}

struct ReduceTansferRecordsAction: ReSwift.Action {
    var data: [(TransferRecord, time: String)]
}
