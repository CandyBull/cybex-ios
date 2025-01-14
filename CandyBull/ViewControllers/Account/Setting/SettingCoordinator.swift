//
//  SettingCoordinator.swift
//  CandyBull
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyUserDefaults

protocol SettingCoordinatorProtocol {
    func openSettingDetail(type: SettingPage)
    func dismiss()
    func openHelpWebView()
}

protocol SettingStateManagerProtocol {
    var state: SettingState { get }

    func changeEnveronment()
}

class SettingCoordinator: NavCoordinator {
    var store = Store<SettingState>(
        reducer: gSettingReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: SettingState {
        return store.state
    }
}

extension SettingCoordinator: SettingCoordinatorProtocol {
    func dismiss() {
        self.rootVC.popToRootViewController(animated: true)
    }

    func openSettingDetail(type: SettingPage) {
        let vc = R.storyboard.main.settingDetailViewController()!
        vc.pageType = type
        let coordinator = SettingDetailCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openHelpWebView() {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension SettingCoordinator: SettingStateManagerProtocol {
    func changeEnveronment() {
        UserManager.shared.logout()

        AppConfiguration.shared.nodes.accept(nil)
        
        CybexWebSocketService.shared.disconnect()
        CybexConfiguration.shared.chainID.accept("")
        AppConfiguration.shared.enableSetting.accept(nil)
        AssetConfiguration.shared.whiteListOfIds.accept([])
        MarketConfiguration.shared.importMarketLists.accept([])
        AssetConfiguration.shared.quoteToProjectNames.accept([:])
        MarketConfiguration.shared.marketPairs.accept([])
        CybexWebSocketService.shared.canSendMessageReactive.accept(false)
        appData.tickerData.accept([])


        if let del = UIApplication.shared.delegate as? AppDelegate {
            del.checkSetting()
        }

    }
}
