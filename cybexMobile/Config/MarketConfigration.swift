//
//  MarketConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RxCocoa
import SwiftyJSON

enum ExchangeType: Int {
    case buy = 0
    case sell
}

enum Indicator: String {
    case none
    case macd = "MACD"
    case ema = "EMA"
    case ma = "MA"
    case boll = "BOLL"

    static let all: [Indicator] = [.ma, .ema, .macd, .boll]
}

enum Candlesticks: Int, Hashable {
    case fiveMinute = 300
    case oneHour = 3600
    case oneDay = 86400

    static func ==(lhs: Candlesticks, rhs: Candlesticks) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    var hashValue: Int {
        return self.rawValue
    }

    static let all: [Candlesticks] = [.fiveMinute, .oneHour, .oneDay]
}

class MarketConfiguration {
    static let shared = MarketConfiguration()

    var marketPairs: BehaviorRelay<[Pair]> = BehaviorRelay(value: []) //首页过滤白名单后的所有交易对
    var gameMarketPairs: [Pair] = [
        Pair(base: AssetConfiguration.CybexAsset.ArenaUSDT.id, quote: AssetConfiguration.CybexAsset.ArenaETH.id),
        Pair(base: AssetConfiguration.CybexAsset.ArenaUSDT.id, quote: AssetConfiguration.CybexAsset.ArenaEOS.id),
        Pair(base: AssetConfiguration.CybexAsset.ArenaUSDT.id, quote: AssetConfiguration.CybexAsset.ArenaBTC.id)
    ]
    var importMarketLists: BehaviorRelay<[ImportantMarketPair]> = BehaviorRelay(value: [])

    private init() {
        
    }
    
    // 修改后页面的base列表
    static var marketBaseAssets: [AssetConfiguration.CybexAsset] {
        switch AppEnv.current {
        case .product:
            return [AssetConfiguration.CybexAsset.USDT,
                    AssetConfiguration.CybexAsset.ETH,
                    AssetConfiguration.CybexAsset.CoreToken,
                    AssetConfiguration.CybexAsset.BTC]
        case .test:
            return [AssetConfiguration.CybexAsset.USDT,
                    AssetConfiguration.CybexAsset.ETH,
                    AssetConfiguration.CybexAsset.CoreToken,
                    AssetConfiguration.CybexAsset.BTC]
        case .uat:
            return [AssetConfiguration.CybexAsset.USDT,
                    AssetConfiguration.CybexAsset.ETH,
                    AssetConfiguration.CybexAsset.CoreToken,
                    AssetConfiguration.CybexAsset.BTC]
        }
    }


    //交易大赛base
    static var gameMarketBaseAssets: [AssetConfiguration.CybexAsset] {
        switch AppEnv.current {
        case .product:
            return [AssetConfiguration.CybexAsset.ArenaUSDT]
        case .test:
            return [AssetConfiguration.CybexAsset.ArenaUSDT]
        case .uat:
            return [AssetConfiguration.CybexAsset.ArenaUSDT]
        }
    }
}

extension MarketConfiguration {
    func fetchMarketPairList() {
        var pairs: [Pair] = []
        var count = 0

        for base in MarketConfiguration.marketBaseAssets.map({ $0.id }) {
            AppService.request(target: AppAPI.marketlist(base: base), success: { (json) in
                let result = json.arrayValue.compactMap({ Pair(base: base, quote: $0.stringValue) })

                let piecePair = result.filter({ (pair) -> Bool in
                    return AssetConfiguration.shared.whiteListOfIds.value.contains([pair.base, pair.quote])
                })

                count += 1
                pairs += piecePair
                if count == MarketConfiguration.marketBaseAssets.count {
                    MarketConfiguration.shared.marketPairs.accept(pairs)
                }
            }, error: { (_) in

            }, failure: { (_) in

            })
        }
    }

    func fetchTopStickMarkets() {
        AppService.request(target: AppAPI.stickTopMarketPair, success: { (json) in
            let marketLists = JSON(json).arrayValue.compactMap({ (item) in
                ImportantMarketPair(base: item["base"].stringValue, quotes: (item["quotes"].arrayObject as? [String])!)
            })

            self.importMarketLists.accept(marketLists)
        }, error: { (_) in

        }, failure: { (_) in

        })
    }
}
