//
//  YourPortfolioViewController.swift
//  CandyBull
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme

class YourPortfolioViewController: BaseViewController {
    struct Define {
        static let sectionHeaderHeight: CGFloat = 44.0
    }
    var data: [MyPortfolioData] = [MyPortfolioData]()

    var coordinator: (YourPortfolioCoordinatorProtocol & YourPortfolioStateManagerProtocol)?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgBgView: UIImageView!

    var lightModel = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightModel ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tradeTitltView = TradeNavTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
        tradeTitltView.title.localizedText =  R.string.localizable.my_property.key.localizedContainer()
        tradeTitltView.title.textColor = UIColor.white
        tradeTitltView.icon.isHidden = true
        self.navigationItem.titleView = tradeTitltView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let image = UIImage.init(color: UIColor.clear)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.isTranslucent = true
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let nav = self.navigationController as? BaseNavigationController {
            nav.updateNavUI()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if ThemeManager.currentThemeIndex == 0 {
            lightModel = true
        } else {
            lightModel = false
        }
    }

    func setupUI() {
        lightModel = true

        let height = UIScreen.main.bounds.height
        if height == 812 {
            imgBgView.image = R.image.imgMyBalanceBgX()
        } else {
            imgBgView.image = R.image.imgMyBalanceBg()
        }

        configLeftNavigationButton(R.image.ic_back_white_24_px())
        let cell = R.nib.yourPortfolioCell.name
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
    }

    func getMyPortfolioDatas() -> [MyPortfolioData] {
        var datas = [MyPortfolioData]()
        if let fullaccount = UserManager.shared.fullAccount.value {
            for balance in fullaccount.balances {
                if let foloiData = MyPortfolioData.init(balance: balance) {
                    if (foloiData.realAmount == "" || foloiData.realAmount.decimal() == 0) && foloiData.limitAmount.contains("--") {

                    } else {
                        datas.append(foloiData)
                    }
                }
            }
        }
        return datas
    }

    override func configureObserveState() {

        UserManager.shared.fullAccount.asObservable().skip(1).subscribe(onNext: {[weak self] (fullaccount) in
            guard let self = self else { return }
            self.data = self.getMyPortfolioDatas().filter({ (folioData) -> Bool in
                return folioData.realAmount != "0" && folioData.limitAmount != "0"
            })

            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: {[weak self] (_) in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.data = self.getMyPortfolioDatas().filter({ (folioData) -> Bool in
                        return folioData.realAmount != "0" && folioData.limitAmount != "0"
                    })

                    if self.data.count == 0 {

                        self.tableView.showNoData(R.string.localizable.balance_nodata.key.localized(), icon: R.image.imgWalletNoAssert.name)
                    } else {
                        self.tableView.hiddenNoData()
                    }
                    guard self.isVisible else { return }

                    self.tableView.reloadData()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

}

extension YourPortfolioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: YourPortfolioCell.self), for: indexPath) as? YourPortfolioCell else {
            return YourPortfolioCell()
        }

        cell.setup(self.data[indexPath.row], indexPath: indexPath)
        return cell
    }
}

extension YourPortfolioViewController {
    @objc func recharge(_ data: [String: Any]) {
        self.coordinator?.pushToRechargeVC()
    }
    @objc func withdrawdeposit(_ data: [String: Any]) {
        self.coordinator?.pushToWithdrawDepositVC()
    }
    @objc func transfer(_ data: [String: Any]) {
        self.coordinator?.pushToTransferVC(true)
    }

    @objc func ticketChecking(_ data: [String: Any]) {
        self.coordinator?.pushToDepolyTicketVC()
    }
}
