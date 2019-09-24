//
//  WithdrawAddressHomeActions.swift
//  CandyBull
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct WithdrawAddressHomeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    typealias WithdrawAddressHomeData = (viewModel: WithdrawAddressHomeViewModel, addressData: [WithdrawAddress])

    var data: BehaviorRelay<[WithdrawAddressHomeViewModel]> = BehaviorRelay(value: [])
    var selectedViewModel: BehaviorRelay<WithdrawAddressHomeData?> = BehaviorRelay(value: nil)
    var addressData: BehaviorRelay<[String: [WithdrawAddress]]> = BehaviorRelay(value: [:])
}

struct WithdrawAddressHomeViewModel {
    var imageURLString: String = ""
    var count: BehaviorRelay<String> = BehaviorRelay(value: "")
    var name: String = ""
    var model: Trade = Trade()
}

struct WithdrawAddressHomeSelectedAction: ReSwift.Action {
    var index: Int
}

struct WithdrawAddressHomeAddressDataAction: ReSwift.Action {
    var data: [String: [WithdrawAddress]]
}
