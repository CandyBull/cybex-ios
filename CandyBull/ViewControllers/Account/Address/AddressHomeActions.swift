//
//  AddressHomeActions.swift
//  CandyBull
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct AddressHomeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
