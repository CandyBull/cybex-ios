//
//  ETODetailActions.swift
//  CandyBull
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import HandyJSON

struct ETODetailContext: RouteContext, HandyJSON {
    init() {}

    var pid: Int = 0
}

// MARK: - State
struct ETODetailState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<ETOProjectViewModel?> = BehaviorRelay(value: nil)
    var userState: BehaviorRelay<ETOUserAuditModel?> = BehaviorRelay(value: nil)
    var refreshData: BehaviorRelay<ETOProjectViewModel?> = BehaviorRelay(value: nil)
}

// MARK: - Action

struct SetProjectDetailAction: ReSwift.Action {
    var data: ETOProjectModel
}

struct FetchUserStateAction: ReSwift.Action {
    var data: ETOUserAuditModel
}

struct RefrehProjectModelAction: ReSwift.Action {
    var data: ETOShortProjectStatusModel
}
