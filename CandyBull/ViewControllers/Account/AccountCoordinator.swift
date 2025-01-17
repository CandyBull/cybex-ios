//
//  AccountCoordinator.swift
//  CandyBull
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift
import PromiseKit
import SwiftyJSON
import Presentr

protocol AccountCoordinatorProtocol {
    func openOpenedOrders()
    func openLockupAssets()
    func openHashLockupAssets()
    func openAddressManager()
    func openYourProtfolio()
    func openSetting()
    func openRecharge()
}

protocol AccountStateManagerProtocol {
    var state: AccountState { get }

    func showHelper(_ attrText: String)
}

class AccountCoordinator: NavCoordinator {
    var store = Store<AccountState>(
        reducer: gAccountReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: AccountState {
        return store.state
    }

    let presenter: Presentr = {
        let width = ModalSize.custom(size: 272)
        let height = ModalSize.custom(size: 340)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let customPresenter = Presentr(presentationType: customType)
        customPresenter.roundCorners = true
        return customPresenter
    }()

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.account.accountViewController()!
        vc.localizedText = R.string.localizable.accountTitle.key.localizedContainer()
        let coordinator = AccountCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }
}

extension AccountCoordinator: AccountCoordinatorProtocol {
    func openOpenedOrders() {
        // 跳转到其他页面的时候
        // 1 创建跳转的页面
        // 2 创建跳转页面的路由coordinator。而且根路由要转换成当前VC
        // 3 路由赋值 然后跳转
        // 解释： 路由的赋值是相当于NavinationC的跳转路由栈的队列

        let vc = R.storyboard.account.orderPageTabViewController()!
//        let coordinator = OpenedOrdersCoordinator(rootVC: self.rootVC)
//        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func showHelper(_ attrText: String) {
        let vc = R.storyboard.main.noticeBoardViewController()!
        vc.attrText = attrText
        vc.titleKey = R.string.localizable.coin_age_title.key
        vc.confirmKey = R.string.localizable.coin_age_desc_get.key

        vc.didConfirm.delegate(on: self) { (self, _) in
            self.dismiss()
        }
        self.rootVC.topViewController?.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }

    func dismiss() {
        appCoodinator.rootVC.dismiss(animated: true, completion: nil)
    }

    func openAddressManager() {
        let vc = R.storyboard.account.addressHomeViewController()!
        let coordinator = AddressHomeCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    // MARK: 锁定期资产
    func openLockupAssets() {
        let vc = R.storyboard.account.lockupAssetsViewController()!
        let coordinator = LockupAssetsCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openHashLockupAssets() {
        let vc = HashLockupAssetsViewController.instantiate()
        self.rootVC.pushViewController(vc, animated: true)
    }

    // MARK: 可用资产
    func openYourProtfolio() {
        let vc = R.storyboard.account.yourProtfolioViewController()!
        let coordinator = YourPortfolioCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    // MARK: 设置
    func openSetting() {

        //    let vc = R.storyboard.business.businessViewController()!
        //    let coordinator = BusinessCoordinator(rootVC: self.rootVC)
        //    vc.coordinator = coordinator
        //    self.rootVC.pushViewController(vc, animated: true)

        let vc = R.storyboard.main.settingViewController()!
        let coordinator = SettingCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    // MARK: 交易
    func openRecharge() {
        let vc = R.storyboard.account.rechargeViewController()!
        let coordinator = RechargeCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension AccountCoordinator: AccountStateManagerProtocol {
 
}
