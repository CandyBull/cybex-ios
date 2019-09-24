//
//  TradeActions.swift
//  CandyBull
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa
import RxSwift
import HandyJSON

struct TradeContext: RouteContext, HandyJSON {
    enum TradeType: Int {
        case normal
        case game
    }

    var pageType: TradeType = .normal
    init() {}
}

// MARK: - State
struct TradeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
