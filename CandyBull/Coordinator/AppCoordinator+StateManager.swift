//
//  AppCoordinator+StateManager.swift
//  CandyBull
//
//  Created by koofrank on 2018/3/26.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import ReSwift
import Repeat
import SwifterSwift
import Reachability
import SwiftyJSON
import HandyJSON
import RxSwift

extension AppCoordinator {
    func fetchTickerData(_ pair: Pair, priority: Operation.QueuePriority) {
        let request = GetTickerRequest(baseName: pair.base, quoteName: pair.quote) { response in
            if let data = response as? Ticker {
                self.store.dispatch(TickerFetched(asset: data))

            }
        }
        CybexWebSocketService.shared.send(request: request, priority: priority)
    }

}

extension AppCoordinator {
    func fetchAllPairsMarkets(_ priority: Operation.QueuePriority = .normal) {
        for index in 0..<MarketConfiguration.marketBaseAssets.count {
            let base = MarketConfiguration.marketBaseAssets[index]
            let pairs = MarketConfiguration.shared.marketPairs.value.filter({return $0.base == base.id })

            self.fetchMarketFrom(pairs, priority: priority)
        }

        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable {
            self.fetchMarketFrom(MarketConfiguration.shared.gameMarketPairs, priority: priority)
        }

    }

    func fetchMarketFrom(_ pairs: [Pair], priority: Operation.QueuePriority = .normal) {
        for pair in pairs {
            if CybexWebSocketService.shared.overload() {
                return
            }
            fetchTickerData(pair, priority: priority)
        }
    }

    func repeatFetchMarket(_ priority: Operation.QueuePriority = .normal) {
        fetchMarketListTimer?.dispose()

        fetchMarketListTimer = Observable<Int>.interval(UserManager.shared.refreshTime, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (n) in
            guard let self = self else { return }

            if reachability.connection == .unavailable ||
                !CybexWebSocketService.shared.checkNetworConnected() {
                self.fetchMarketListTimer?.dispose()
                return
            }
            self.state.property.otherRequestRelyData.accept(1)
            self.fetchAllPairsMarkets(.veryLow)
        })
    }

    func getAssetInfos(_ ids: [String]) {
        let request = GetObjectsRequest(ids: ids, refLib: false) { response in
            if let assetinfo = response as? [AssetInfo] {
                self.store.dispatch(AssetInfoAction(info: assetinfo))
            }
        }
        CybexWebSocketService.shared.send(request: request, priority: .veryHigh)
    }

    func getLatestData() {
        if !AssetConfiguration.shared.whiteListOfIds.value.isEmpty {
            getAssetInfos(AssetConfiguration.shared.whiteListOfIds.value)
        }
        if !MarketConfiguration.shared.marketPairs.value.isEmpty {
            fetchAllPairsMarkets(.high)
        }

        repeatFetchMarket(.veryLow)
    }
}
