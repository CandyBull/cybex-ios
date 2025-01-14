//
//  AccountViewController.swift
//  CandyBull
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import ReSwift
import SwiftTheme
import RxSwift
import CryptoSwift
import SwiftRichString
import SwifterSwift
import Localize_Swift
import PromiseKit
import SwiftyJSON

class AccountViewController: BaseViewController {

    var coordinator: (AccountCoordinatorProtocol & AccountStateManagerProtocol)?

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var accountContentView: AccountContentView!

    var dataArray: [AccountViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let height = UIScreen.main.bounds.height
        if height == 812 {
            bgImageView.image = R.image.account_bg_x()
        } else {
            bgImageView.image = R.image.accountBg()
        }
        self.accountContentView.headerView.coinAge.text = R.string.localizable.coin_age.key.localizedFormat("");

        setupUI()
        setupEvent()

        if  UserManager.shared.logined {
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        delay(milliseconds: 100) {
            self.setupUI()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setupIconImg() {
        if UserManager.shared.logined == false {
            accountContentView.headerView.icon = R.image.accountAvatar()
            accountContentView.headerView.coinAgeContainer.isHidden = true
        } else {
            getCoinAge()
            accountContentView.headerView.coinAgeContainer.isHidden = true
            if let hash = UserManager.shared.avatarString {
                let generator = IconGenerator(size: 168, hash: Data(hex: hash))
                if let render = generator.render() {
                    let image = UIImage(cgImage: render)
                    accountContentView.headerView.icon = image
                }
            }
        }
    }

    func setupTitle() {
        if let name = UserManager.shared.name.value {
            accountContentView.headerView.title = R.string.localizable.hello.key.localized() + name
        } else {
            accountContentView.headerView.title = R.string.localizable.accountLogin.key.localized()
        }
    }

    // UI的初始化设置
    func setupUI() {
        self.navigationItem.title = ""
        setupTitle()
        setupIconImg()
        self.configRightNavButton(R.image.icSettings24Px())

        let imgArray = [R.image.icBalance(), R.image.w(), R.image.ic_address_28_px(), R.image.icOrder28Px(), R.image.icLockAsset(), R.image.icHashLocksAssets24Px()]

        let nameArray = [R.string.localizable.my_property.key.localized(),
                         R.string.localizable.deposit_withdraw.key.localized(),
                         R.string.localizable.address_manager.key.localized(),
                         R.string.localizable.order_value.key.localized(),
                         R.string.localizable.lockupAssetsTitle.key.localized(),
                         R.string.localizable.hashlockupAssetsTitle.key.localized()
                         ]

        dataArray.removeAll()
        for index in 0..<nameArray.count {
            var model = AccountViewModel()
            model.leftImage = imgArray[index]
            model.name = nameArray[index]
            dataArray.append(model)
        }
        accountContentView.data = dataArray
    }

    func setupEvent() {

    }

    func getCoinAge() {
        guard let id = UserManager.shared.fullAccount.value?.account?.id else { return }
        //:[{"id":"10.1.17","asset":"1.3.0","account":"1.2.28","score":155842895}]
    
        CybexDatabaseApiService.request(target: DatabaseApi.getAccountTokenAge(id: id)).map { (json) -> Decimal in
            if let object = json.array?.first {
                let score = object["score"].stringValue
                let assetId = object["asset"].stringValue
                if let precision = AssetHelper.getPrecision(assetId) {
                    return score.decimal() / pow(10, precision)
                }
                return 0
            }
            return 0
            }.done { (score) in
                if let rate = AppConfiguration.shared.enableSetting.value?.ageRate {
                    let age = score * (1 - rate.decimal)
                    self.accountContentView.headerView.coinAge.text = R.string.localizable.coin_age.key.localizedFormat("\(age.floor.intValue)");
                }
        }.cauterize()
    }

    // 跳转到设置界面
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openSetting()
    }

    override func configureObserveState() {
        UserManager.shared.fullAccount.asObservable()
            .skip(1)
            .throttle(10, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if self.isVisible {
                    self.setupTitle()
                    self.setupIconImg()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension AccountViewController {

    @objc func login(_ data: [String: Any]) {
        if !UserManager.shared.logined {
            appCoodinator.showLogin()
        }
    }

    @objc func coinAgeDesc(_ data: [String: Any]) {
        self.coordinator?.showHelper(R.string.localizable.coin_age_desc.key.localized())
    }

    @objc func clickCellView(_ sender: [String: Any]) {
        guard let index = sender["index"] as? Int else {
            return
        }
        switch index {
        case 0:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {

                self.coordinator?.openYourProtfolio()
            }
        case 1:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {
                self.coordinator?.openRecharge()
            }
        case 2:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {
                self.coordinator?.openAddressManager()
            }
        case 3:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {
                self.coordinator?.openOpenedOrders()
            }
        case 4:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {
                openLockupAssets([:])
            }

        case 5:
            if !UserManager.shared.logined {
                appCoodinator.showLogin()
            } else {
                self.coordinator?.openHashLockupAssets()
            }
        default:
           break
        }
    }

    @objc func openLockupAssets(_ data: [String: Any]) {
        self.coordinator?.openLockupAssets()
    }
}
