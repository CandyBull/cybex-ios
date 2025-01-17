//
//  LockupAssetsViewController.swift
//  CandyBull
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints

import SwiftyJSON

class LockupAssetsViewController: BaseViewController {
    
    struct Define {
        static let sectionHeaderHeight: CGFloat = 44.0
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedData: LockupAssteData!
    
    var data: [LockupAssteData] = []
    var coordinator: (LockupAssetsCoordinatorProtocol & LockupAssetsStateManagerProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        var keys: AccountKeys? {
            didSet {
                self.startLoading()
                if let keys = keys {
                    self.coordinator?.fetchLockupAssetsData(keys.addresses())
                }
            }
        }

        if UserManager.shared.unlockType == .nfc, let key = UserManager.shared.getCachedEnotesKeysExcludePrivate() {
            keys = key
        } else if UserManager.shared.unlockType == .cloudPassword, let key = UserManager.shared.getCachedKeysExcludePrivate() {
            keys = key
        }

    }
    
    func setupUI() {
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.localizedText = R.string.localizable.lockupAssetsTitle.key.localizedContainer()
        let cell = String.init(describing: LockupAssetsCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
    }
    
    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: {[weak self] (_ data) in
            guard let self = self else {return}
            self.endLoading()
            self.data = data.datas
            if self.emptyReloadData() {
                return
            }
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func emptyReloadData() -> Bool {
        if self.data.count == 0 {
            self.tableView.showNoData(R.string.localizable.balance_nodata.key.localized() , icon: R.image.imgWalletNoAssert.name)
            return true
        }
        else {
            self.tableView.hiddenNoData()
        }
        return false
    }
}

// MARK: UITableViewDataSource
extension LockupAssetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: LockupAssetsCell.self), for: indexPath) as? LockupAssetsCell else {
            return LockupAssetsCell()
        }
        cell.setup(self.data[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: Define.sectionHeaderHeight))
        
        return lockupAssetsSectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Define.sectionHeaderHeight
    }

    func claim() {
        let confirmData = UIHelper.claimLockupAsset(self.selectedData)
        if self.isVisible {
            showConfirm(R.string.localizable.lockup_asset_claim_ensure.key.localized(), attributes: confirmData)
        }
    }
    
}

extension LockupAssetsViewController {
    @objc func clickLockupAssetsViewEvent(_ data: [String: Any]) {
        guard let indexPathData = data["data"] as? LockupAssteData  else {
            return
        }
        self.selectedData = indexPathData

        if !UserManager.shared.isLocked {
            claim()
        } else {
            self.showPasswordBox()
        }
    }

    override func passwordPassed(_ passed: Bool) {
        self.endLoading()

        if self.isVisible {
            if passed {
                claim()
            } else {
                self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
            }
        }

    }

    override func passwordDetecting() {
        self.startLoading()
    }
    
    @objc override func returnEnsureAction() {
        self.coordinator?.applyLockupAsset(self.selectedData, cloudpasswordUnlock: UserManager.shared.unlockType == .cloudPassword, callback: { [weak self] success in
            guard let self = self else { return }
            if self.isVisible {
                if success == true {
                    self.showToastBox(true, message: R.string.localizable.lockup_asset_claim_success.key.localized())
                    self.data = self.data.removeAll(self.selectedData)
                    if self.emptyReloadData() {
                        return
                    }
                    self.tableView.reloadData()
                }
                else {
                    self.showToastBox(false, message: R.string.localizable.lockup_asset_claim_fail.key.localized())
                }
            }
        })
    }
}


