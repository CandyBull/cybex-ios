//
//  MarketReducers.swift
//  CandyBull
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift

func marketReducer(action: ReSwift.Action, state: MarketState?) -> MarketState {
    let state = state ?? MarketState()
    var klineDatas = state.detailData.value ?? [:]

    switch action {
    case let action as KLineFetched:
        if klineDatas.has(key: action.pair) {
            var klineData = klineDatas[action.pair]!
            klineData[action.stick] = action.assets
            klineDatas[action.pair] = klineData
        } else {
            klineDatas[action.pair] = [action.stick: action.assets]
        }

        state.detailData.accept(klineDatas)
  
    default:
        break
    }
    return state
}
