//
//  AppConfigration.swift
//  CandyBull
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation
import RxCocoa
import Repeat
import RxSwift
import SwiftyUserDefaults
import SwiftyJSON

enum AppEnv: String, CaseIterable {
    case product
    case test
    case uat

    static var current: AppEnv {
        return AppEnv(rawValue: Defaults[\.environment]) ?? .product
    }

    var index: Int {
        for (i, env) in AppEnv.allCases.enumerated() {
            if self == env {
                return i
            }
        }

        return 0
    }
}

var appData: AppPropertyState {
    return appState.property
}
var appState: AppState {
    return AppConfiguration.shared.appCoordinator.state
}
var appCoodinator: AppCoordinator {
    return AppConfiguration.shared.appCoordinator
}

class AppConfiguration {
    static let shared = AppConfiguration()

    var enableSetting: BehaviorRelay<AppEnableSetting?> = BehaviorRelay(value: nil)
    var nodes: BehaviorRelay<NodesURLSettingModel?> = BehaviorRelay(value: nil)

    var rmbPrices: BehaviorRelay<[RMBPrices]> = BehaviorRelay(value: [])

    var appCoordinator: AppCoordinator!
    var timer: Disposable?

    static let rmbPrecision = 4
    static let percentPrecision = 2
    static let amountPrecision = 2

    static let debounceDisconnectTime = 10
    static let autoLockWalletInbackground = 60 * 5

    static let AppName = "CandyBull"

    private init() {
        let rootVC = BaseTabbarViewController()
        appCoordinator = AppCoordinator(rootVC: rootVC)

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.timer?.dispose()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.startFetchOuterPrice()
        }
    }

    static var ServerIconsBaseURLString = "https://app.candybull.io/icons/"
    static var GameBaseURLString = "https://gamecenter.candybull.io"

    static var HelpNightURL = "https://survey.candybull.io/cybexnight?lang="
    static var HelpLightURL = "https://survey.candybull.io/cybexday?lang="
}

extension AppConfiguration {
    func fetchAppEnableSettingRequest() {
        AppService.request(target: .setting, success: { (json) in
            var model = AppEnableSetting.deserialize(from: json.dictionaryObject)
//            model?.isETOEnabled = true
//            model?.contestEnabled = true
            self.enableSetting.accept(model)

            AppConfiguration.shared.appCoordinator.start()

            self.appCoordinator.topViewController()?.handlerUpdateVersion(nil)
        }, error: { (_) in

        }) { (_) in

        }
    }

    func startFetchOuterPrice() {
        timer?.dispose()

        self.fetchOuterPrice()
        timer = Observable<Int>.interval(3, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (n) in
            guard let self = self else { return }
            self.fetchOuterPrice()

            Log.print(n, flag: "timer----")
        })
    }

    private func fetchOuterPrice() {
        AppService.request(target: AppAPI.outerPrice, success: { (json) in
            let prices = json["prices"].arrayValue.compactMap( { RMBPrices.deserialize(from: $0.dictionaryObject) } )

            if prices.count > 0 {
                self.rmbPrices.accept(prices)
            }
        }, error: { (_) in
        }) { (_) in
        }
    }

    func isAppStoreVersion() -> Bool {
        if let bundleID = Bundle.main.bundleIdentifier, bundleID.contains("fir") {
            return false
        }

        return true
    }

    func fetchNodes() {
        AppService.request(target: AppAPI.nodesURL, success: { (json) in
            if let model = NodesURLSettingModel.deserialize(from: json.dictionaryObject) {
                self.nodes.accept(model)
            }
        }, error: { (_) in
            self.nodes.accept(nil)
        }) { (_) in
            self.nodes.accept(nil)
        }
    }

    func switchNetworkNode() {
        let node = nodes.value!

        if AppEnv.current == .product {
            let nodes = [node.nodes].flatMapped(with: String.self)
            CybexWebSocketService.Config.productURL = nodes.map({ URL(string: $0)! })

            let mdps = [node.mdp].flatMapped(with: String.self)
            MDPWebSocketService.Config.productURL = mdps.map({ URL(string: $0)! })

            let limitOrders = [node.limitOrder].flatMapped(with: String.self)
            OCOWebSocketService.Config.productURL = limitOrders.map({ URL(string: $0)! })

            ETOMGService.Config.productURL = URL(string: node.eto)!
//            ETOMGService.Config.productURL = URL(string: "https://etoapi-pre.candybull.io/api")!

            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                CybexWebSocketService.shared.connect()
            }

            Gateway2Service.Config.productURL = URL(string: node.gateway2)!
        }
        else if AppEnv.current == .uat {
            let nodes = [node.nodes].flatMapped(with: String.self)
            CybexWebSocketService.Config.uatURL = nodes.map({ URL(string: $0)! })

            let mdps = [node.mdp].flatMapped(with: String.self)
            MDPWebSocketService.Config.uatURL = mdps.map({ URL(string: $0)! })

            let limitOrders = [node.limitOrder].flatMapped(with: String.self)
            OCOWebSocketService.Config.uatURL = limitOrders.map({ URL(string: $0)! })

            ETOMGService.Config.uatURL = URL(string: node.eto)!
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                CybexWebSocketService.shared.connect()
            }


            Gateway2Service.Config.uatURL = URL(string: node.gateway2)!
        }
        else if AppEnv.current == .test {
            let nodes = [node.nodes].flatMapped(with: String.self)
            CybexWebSocketService.Config.devURL = nodes.map({ URL(string: $0)! })

            let mdps = [node.mdp].flatMapped(with: String.self)
            MDPWebSocketService.Config.devURL = mdps.map({ URL(string: $0)! })

            let limitOrders = [node.limitOrder].flatMapped(with: String.self)
            OCOWebSocketService.Config.devURL = limitOrders.map({ URL(string: $0)! })

            ETOMGService.Config.devURL = URL(string: node.eto)!
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                CybexWebSocketService.shared.connect()
            }

            Gateway2Service.Config.devURL = URL(string: node.gateway2)!
        }
    }
}

