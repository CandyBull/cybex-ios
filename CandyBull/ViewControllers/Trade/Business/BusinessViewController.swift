//
//  BusinessViewController.swift
//  CandyBull
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import Localize_Swift
import SwifterSwift
import cybex_ios_core_cpp

class BusinessViewController: BaseViewController {
    var pair: Pair? {
        didSet {
            if oldValue != pair {
                self.coordinator?.resetState()
                fetchLatestPrice()
                refreshView()
            }
            if self.pricePrecision == 0 {
                fetchLatestPrice()
            }
        }
    }
    
    @IBOutlet weak var containerView: BusinessView!
    
    var type: ExchangeType = .buy
    var coordinator: (BusinessCoordinatorProtocol & BusinessStateManagerProtocol)?
    var pricePrecision: Int = 0
    var amountPrecision: Int = 0
    var totalPrecision: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEvent()
    }
    
    func fetchLatestPrice() {
        guard let pair = pair else { return }
        let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)
        pricePrecision = tradePrecision.book.lastPrice.int!
        amountPrecision = tradePrecision.book.amount.int!
        totalPrecision = tradePrecision.book.total.int!
    }
    
    func setupUI() {
        containerView.button.gradientLayer.colors = type == .buy ?
            [UIColor.paleOliveGreen.cgColor, UIColor.apple.cgColor] :
            [UIColor.pastelRed.cgColor, UIColor.reddish.cgColor]
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification),
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
                                                guard let self = self else { return }
                                                
                                                if ThemeManager.currentThemeIndex == 0 {
                                                    self.containerView.priceTextfield.textColor = .white
                                                    self.containerView.amountTextfield.textColor = .white
                                                } else {
                                                    self.containerView.priceTextfield.textColor = .darkTwo
                                                    self.containerView.amountTextfield.textColor = .darkTwo
                                                }
                                                
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](_) in
            guard let self = self else { return }
            
            self.containerView.amountTextfield.placeholder = R.string.localizable.withdraw_amount.key.localized()
            self.containerView.priceTextfield.placeholder = R.string.localizable.orderbook_price.key.localized()
            self.containerView.amountTextfield.setPlaceHolderTextColor(UIColor.steel50)
            self.containerView.priceTextfield.setPlaceHolderTextColor(UIColor.steel50)
            self.changeButtonState()
        }
    }
    
    func refreshView() {
        guard let pair = pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] else { return }
        
        self.containerView.quoteName.text = quoteInfo.symbol.filterSystemPrefix
        
        self.coordinator?.getFee(self.type == .buy ? baseInfo.id : quoteInfo.id)
        
        self.coordinator?.getBalance((self.type == .buy ? baseInfo.id : quoteInfo.id))
        
        changeButtonState()
    }
    
    @discardableResult func checkBalance() -> Bool {
        guard let pair = self.pair else {
            self.containerView.tipView.isHidden = true
            
            return false
        }
        
        guard let canPost = self.coordinator?.checkBalance(pair, isBuy: self.type == .buy) else {
            if let amount =  self.containerView.amountTextfield.text,
                amount.decimal() > 0,
                let price =  self.containerView.priceTextfield.text,
                price.decimal() > 0 {
                self.containerView.errorMessage.locali = R.string.localizable.withdraw_nomore.key
                self.containerView.tipView.isHidden = false
            } else {
                self.containerView.tipView.isHidden = true
            }
            return false
        }
        
        if !canPost {
            self.containerView.errorMessage.locali = R.string.localizable.withdraw_nomore.key
            self.containerView.tipView.isHidden = false
            return false
        } else {
            self.containerView.tipView.isHidden = true
            return true
        }
    }

    @discardableResult func formRules() -> Bool {
        if let pair = pair, let amount = self.containerView.amountTextfield.text,
            amount.decimal() > 0,
            let price =  self.containerView.priceTextfield.text,
            price.decimal() > 0 {
            let precision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)

            if precision.form.minOrderValue.decimal() <= amount.decimal() * price.decimal() {
                self.containerView.tipView.isHidden = true
                return true
            } else {
                self.containerView.errorMessage.text = R.string.localizable.min_order_value_remind.key.localizedFormat(precision.form.minOrderValue)
                self.containerView.tipView.isHidden = false
                return false
            }
        }

        return true
    }
    
    func changeButtonState() {
        if UserManager.shared.logined {
            guard let pair = pair, let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.containerView.button.locali = self.type == .buy ? R.string.localizable.openedBuy.key : R.string.localizable.openedSell.key
            if let title = self.containerView.button.button.titleLabel?.text {
                self.containerView.button.button.setTitle("\(title) \(quoteInfo.symbol.filterSystemPrefix)", for: .normal)
            }
        } else {
            self.containerView.button.locali = R.string.localizable.business_login_title.key
        }
    }
    
    func showOpenedOrderInfo() {
        guard let baseInfo = appData.assetInfo[(self.pair?.base)!],
            let quoteInfo = appData.assetInfo[(self.pair?.quote)!],
            let _ = appData.assetInfo[(self.coordinator?.state.feeID.value)!],
            self.coordinator?.state.feeAmount.value != 0,
            let curAmount = self.coordinator?.state.amount.value,
            let price = self.coordinator?.state.price.value
            else { return }
        
        let decimalAmount = curAmount.decimal()
        let decimalPrice = price.decimal()
        
        guard  decimalAmount != 0, decimalPrice != 0 else { return }


        let ensureTitle = self.type == .buy ?
            R.string.localizable.openedorder_buy_ensure.key.localized() :
            R.string.localizable.openedorder_sell_ensure.key.localized()

        let prirce = decimalPrice.formatCurrency(digitNum: self.pricePrecision) + " " + baseInfo.symbol.filterSystemPrefix
        let amount = decimalAmount.formatCurrency(digitNum: self.amountPrecision)  + " " + quoteInfo.symbol.filterSystemPrefix
        let total = (decimalPrice * decimalAmount).formatCurrency(digitNum: self.totalPrecision) + " " + baseInfo.symbol.filterSystemPrefix

        if UserManager.shared.checkExistCloudPassword(), UserManager.shared.loginType == .nfc {
            let titleLocali = UserManager.shared.unlockType == .cloudPassword ? R.string.localizable.enotes_use_type_0.key : R.string.localizable.enotes_use_type_1.key
            showConfirm(ensureTitle, attributes: UIHelper.getOpenedOrderInfo(price: prirce, amount: amount, total: total, fee: "", isBuy: self.type == .buy), rightTitleLocali: titleLocali, tag: titleLocali, setup: nil)
        } else {
            showConfirm(ensureTitle, attributes: UIHelper.getOpenedOrderInfo(price: prirce, amount: amount, total: total, fee: "", isBuy: self.type == .buy))
        }
    }
    
    override func configureObserveState() {
        
        (self.containerView.amountTextfield.rx.text.orEmpty <-> self.coordinator!.state.amount).disposed(by: disposeBag)
        (self.containerView.priceTextfield.rx.text.orEmpty <-> self.coordinator!.state.price).disposed(by: disposeBag)
        
        self.addObserverSubscribeAction()
        self.addNotificationSubscribeAction()
        self.addUserManagerObserverSubscribeAction()
        
        //balance
        self.coordinator?.state.balance.asObservable().skip(1).subscribe(onNext: {[weak self] (balance) in
            guard let self = self else { return }
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote], balance != 0 else {
                self.containerView.balance.text = "--"
                
                if let amount = self.containerView.amountTextfield.text,
                    amount.decimal() > 0,
                    let price =  self.containerView.priceTextfield.text,
                    price.decimal() > 0 {
                    self.containerView.errorMessage.locali = R.string.localizable.withdraw_nomore.key
                    self.containerView.tipView.isHidden = false
                }
                return
            }
            
            let info = self.type == .buy ? baseInfo : quoteInfo
            let symbol = info.symbol.filterSystemPrefix
            let realAmount = balance.formatCurrency(digitNum: info.precision)
            
            self.containerView.balance.text = "\(realAmount) \(symbol)"
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //fee
        Observable.combineLatest(coordinator!.state.feeID.asObservable(), coordinator!.state.feeAmount.asObservable()).subscribe(onNext: {[weak self] (feeId, feeAmount) in
            guard let self = self else { return }
            
            guard let info = appData.assetInfo[feeId] else {
                self.containerView.fee.text = "--"
                return
            }

            self.containerView.fee.text = feeAmount.formatCurrency(digitNum: info.precision) + " \(info.symbol.filterSystemPrefix)"
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //total
        Observable.combineLatest(coordinator!.state.feeID.asObservable(),
                                 self.coordinator!.state.amount,
                                 self.coordinator!.state.price,
                                 coordinator!.state.feeAmount.asObservable())
            .subscribe(onNext: {[weak self] (_, amount, price, fee) in
                guard let self = self else { return }
                guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base] else {
                    self.containerView.endMoney.text = "--"
                    return
                }
                guard price.decimal() != 0, amount.decimal() != 0, fee != 0 else {
                        self.containerView.endMoney.text = "--"
                        return
                }
                let total = price.decimal() * amount.decimal()
//                guard let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0 else {
//                    self.containerView.endMoney.text = "\(total.formatCurrency(digitNum: self.totalPrecision)) \(baseInfo.symbol.filterJade)"
//                    return
//                }
                self.containerView.endMoney.text = "\(total.formatCurrency(digitNum: self.totalPrecision)) \(baseInfo.symbol.filterSystemPrefix)"
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    func addUserManagerObserverSubscribeAction() {
        UserManager.shared.fullAccount.asObservable().subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base],
                let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.coordinator?.getBalance((self.type == .buy ? baseInfo.id : quoteInfo.id))
            self.coordinator?.getFee(self.type == .buy ? baseInfo.id : quoteInfo.id)
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        UserManager.shared.name.skip(1).asObservable().subscribe(onNext: {[weak self] (name) in
            guard let self = self else { return }
            self.changeButtonState()
            guard let _ = name else {
                self.coordinator?.resetState()
                return
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func addObserverSubscribeAction() {
        //RMB
        self.coordinator!.state.price.subscribe(onNext: {[weak self] (text) in
            guard let self = self else { return }
            if self.checkBalance() {
                self.formRules()
            }
            guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base],
                let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0,
                text.components(separatedBy: ".").count <= 2 && text != "." else {
                    self.containerView.value.text = self.handlerRMBLabel("0.0000")
                    return
            }

            var rmbPrice: Decimal = 0
            if let baseAsset = AssetConfiguration.CybexAsset(baseInfo.id) {
                rmbPrice = text.decimal() * AssetConfiguration.shared.rmbOf(asset: baseAsset)
            }
            self.containerView.value.text = self.handlerRMBLabel(rmbPrice.formatCurrency(digitNum: AppConfiguration.rmbPrecision))
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        self.coordinator!.state.amount.subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            
            if self.checkBalance() {
                self.formRules()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    func handlerRMBLabel(_ str: String) -> String {
        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable,
            let parent = self.parent?.parent as? TradeViewController, let context = parent.context, context.pageType == .game {
            return ""
        }

        return "≈¥" + str
    }
    
    func addNotificationSubscribeAction() {
        //precision
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self.containerView.priceTextfield, queue: nil) {[weak self] (_) in
            guard let self = self else { return }
            
            guard let text = self.containerView.priceTextfield.text, text != "", text.decimal() != 0 else {
                self.containerView.priceTextfield.text = ""
                self.coordinator?.switchPrice("")
                return
            }
            
            let texts = text.replacingOccurrences(of: ",", with: "").components(separatedBy: ".")
            if let price = texts.first, price.count > 8 {
                self.containerView.priceTextfield.text = price.substring(from: 0, length: 8)
                if texts.count > 1 {
                    self.containerView.priceTextfield.text = self.containerView.priceTextfield.text! + "." + texts.last!
                }
            }
            
            self.containerView.priceTextfield.text = self.containerView.priceTextfield.text!.formatCurrency(digitNum: self.pricePrecision)
            self.coordinator?.switchPrice(self.containerView.priceTextfield.text!)
            
            guard let amountText = self.containerView.amountTextfield.text, amountText != "", amountText.decimal() != 0 else {
                return
            }
            self.containerView.amountTextfield.text = amountText.decimal().formatCurrency(digitNum: self.amountPrecision)
            self.coordinator?.state.price.accept(self.containerView.priceTextfield.text!)
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self.containerView.amountTextfield, queue: nil) {[weak self] (_) in
            guard let self = self else { return }
            
            guard let text = self.containerView.amountTextfield.text, text != "", text.decimal() != 0 else {
                self.containerView.amountTextfield.text = ""
                return
            }
            
            let texts = text.replacingOccurrences(of: ",", with: "").components(separatedBy: ".")
            if let amount = texts.first, amount.count > 8 {
                self.containerView.amountTextfield.text = amount.substring(from: 0, length: 8)
                if texts.count > 1 {
                    self.containerView.amountTextfield.text = self.containerView.amountTextfield.text! + "." + texts.last!
                }
            }
            self.containerView.amountTextfield.text = self.containerView.amountTextfield.text!.formatCurrency(digitNum: self.amountPrecision)
            
            self.coordinator?.changeAmountAction(self.containerView.amountTextfield.text!)
            guard let priceText = self.containerView.priceTextfield.text, priceText != "", priceText.decimal() != 0 else {
                return
            }
            self.coordinator?.state.amount.accept(self.containerView.amountTextfield.text!)
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self.containerView.amountTextfield, queue: nil) {[weak self](_) in
            guard let self = self else {return}
            if !UserManager.shared.logined {
                self.containerView.amountTextfield.resignFirstResponder()
                appCoodinator.showLogin()
                return
            }
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self.containerView.priceTextfield, queue: nil) {[weak self](_) in
            guard let self = self else {return}
            
            if !UserManager.shared.logined {
                self.containerView.priceTextfield.resignFirstResponder()
                appCoodinator.showLogin()
                return
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self.containerView.priceTextfield!)
        NotificationCenter.default.removeObserver(self.containerView.amountTextfield!)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
    }
}

extension BusinessViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }

    func resetView() {
        
    }
}

extension BusinessViewController {
    @objc func amountPercent(_ data: [String: Any]) {
        if let percent = data["percent"] as? String {
            guard let pair = self.pair,
                let baseInfo = appData.assetInfo[pair.base],
                let quoteInfo = appData.assetInfo[pair.quote] else { return }
            self.coordinator?.changePercent(percent.decimal() / 100.0,
                                            isBuy: self.type == .buy,
                                            assetID: self.type == .buy ? baseInfo.id : quoteInfo.id,
                                            pricision: self.amountPrecision)
        }
    }
    
    @objc func buttonDidClicked(_ data: [String: Any]) {
        self.containerView.priceTextfield.endEditing(true)
        self.containerView.amountTextfield.endEditing(true)
        if self.coordinator!.parentIsLoading(self.parent) {
            return
        }
        
        if !UserManager.shared.logined {
            appCoodinator.showLogin()
            return
        }

        if let price = self.containerView.priceTextfield.text,
        price.decimal() > 0, checkBalance() && formRules(), let exVC = self.parent as? ExchangeViewController {
            if self.type == .buy {
                if exVC.lastPrice > 0 && price.decimal() > exVC.lastPrice * 1.2 {
                    showPureContentConfirm(content: R.string.localizable.price_offset_remind.key, tag: R.string.localizable.price_offset_remind.key)
                    return
                }
            } else if self.type == .sell {
                if exVC.lastPrice > 0 && price.decimal() < exVC.lastPrice * 0.8 {
                    showPureContentConfirm(content: R.string.localizable.price_offset_remind.key, tag: R.string.localizable.price_offset_remind.key)
                    return
                }
            }
            self.showOpenedOrderInfo()
        }
    }
    
    @objc func adjustPrice(_ data: [String: Bool]) {
        if self.pricePrecision == 0 {
            return
        }
        self.coordinator?.adjustPrice(data["plus"]!, pricePricision: self.pricePrecision)
    }

    override func returnEnsureActionWithData(_ tag: String) {
        if tag == R.string.localizable.price_offset_remind.key {
            self.showOpenedOrderInfo()
            return
        }
        if UserManager.shared.loginType == .nfc, UserManager.shared.unlockType == .nfc {
            if #available(iOS 11.0, *) {
                NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                    BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)
                    self.coordinator?.parentStartLoading(self.parent)
                    self.postOrder()
                }
                NFCManager.shared.start()
            }
        } else if UserManager.shared.isLocked {
            showPasswordBox()
        } else {
            self.coordinator?.parentStartLoading(self.parent)
            postOrder()
        }
    }

    func postOrder() {
        guard let pair = self.pair else { return }
        self.coordinator?.postLimitOrder(pair, isBuy: self.type == .buy, callback: {[weak self] (success) in
            guard let self = self else { return }
            self.coordinator?.parentEndLoading(self.parent)
            if success {
                self.coordinator?.resetState()
                self.refreshView()
            }
            self.showToastBox(success, message: success ? R.string.localizable.order_create_success.key.localized() : R.string.localizable.order_create_fail.key.localized())
        })
    }

    override func didClickedRightAction(_ tag: String) {
        if tag == R.string.localizable.enotes_use_type_0.key { //enotes
            if #available(iOS 11.0, *) {
                NFCManager.shared.didReceivedMessage.delegate(on: self) { (self, card) in
                    BitShareCoordinator.setDerivedOperationExtensions(card.base58PubKey, derived_private_key: card.base58OnePriKey, derived_public_key: card.base58OnePubKey, nonce: Int32(card.oneTimeNonce), signature: card.compactSign)

                    self.coordinator?.parentStartLoading(self.parent)
                    self.postOrder()
                }
                NFCManager.shared.start()
            }
        } else {
            showPasswordBox()
        }
    }
    
    override func passwordDetecting() {
        self.coordinator?.parentStartLoading(self.parent)
    }
    
    override func passwordPassed(_ passed: Bool) {
        if passed {
            postOrder()
        } else {
            self.coordinator?.parentEndLoading(self.parent)
            self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
        }
    }
}
