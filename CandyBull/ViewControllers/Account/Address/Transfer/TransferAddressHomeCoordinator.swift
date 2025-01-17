//
//  TransferAddressHomeCoordinator.swift
//  CandyBull
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress()
    func openActionVC(_ dismissCallback: CommonCallback?)
}

protocol TransferAddressHomeStateManagerProtocol {
    var state: TransferAddressHomeState { get }

    func refreshData()

    func select(_ address: TransferAddress?)
    func copy()
    func confirmdelete()
    func delete()
}

class TransferAddressHomeCoordinator: NavCoordinator {
    var store = Store<TransferAddressHomeState>(
        reducer: transferAddressHomeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override func register() {
        Broadcaster.register(TransferAddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(TransferAddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension TransferAddressHomeCoordinator: TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress() {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.addressType = .transfer
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func openActionVC(_ dismissCallback: CommonCallback?) {
        let actionController = PeriscopeActionController()
        actionController.tapMaskCallback = dismissCallback

        actionController.addAction(Action(R.string.localizable.copy.key.localized(), style: .destructive, handler: {[weak self] _ in
            guard let self = self else {return}
            self.copy()
            dismissCallback?()
        }))

        actionController.addAction(Action(R.string.localizable.delete.key.localized(), style: .destructive, handler: {[weak self] _ in
            guard let self = self else {return}
            self.confirmdelete()
            dismissCallback?()
        }))

        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: {[weak self] _ in
            guard let self = self else {return}

            self.select(nil)
            dismissCallback?()
        }))

        self.rootVC.topViewController?.present(actionController, animated: true, completion: nil)
    }
}

extension TransferAddressHomeCoordinator: TransferAddressHomeStateManagerProtocol {
    var state: TransferAddressHomeState {
        return store.state
    }

    func refreshData() {
        let list = AddressManager.shared.getTransferAddressList()

        let names = list.map { (info) -> AddressName in
            return AddressName(name: info.name)
        }

        let sortedNames = AddressHelper.sortNameBasedonAddress(names)

        let data = list.sorted { (front, last) -> Bool in
            return sortedNames.firstIndex(of: front.name)! <= sortedNames.firstIndex(of: last.name)!
        }
        self.store.dispatch(TransferAddressHomeDataAction(data: data))
    }

    func select(_ address: TransferAddress?) {
        self.store.dispatch(TransferAddressSelectDataAction(data: address))
    }

    func copy() {
        if let addressData = self.state.selectedAddress.value {
            UIPasteboard.general.string = addressData.address

            self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.copied.key.localized())
        }
    }

    func confirmdelete() {
        if let addressData = self.state.selectedAddress.value {
            self.rootVC.topViewController?.showConfirm(R.string.localizable.address_delete_confirm.key.localized(), attributes: UIHelper.confirmDeleteTransferAddress(addressData), setup: { (labels) in
                for label in labels {
                    label.content.numberOfLines = 1
                    label.content.lineBreakMode = .byTruncatingMiddle
                }
            })
        }
    }

    func delete() {
        if let addressData = self.state.selectedAddress.value {
            AddressManager.shared.removeTransferAddress(addressData.id)

            DispatchQueue.main.async {
                self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.deleted.key.localized())
            }
        }

    }
}
