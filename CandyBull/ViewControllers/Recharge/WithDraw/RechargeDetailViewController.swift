//
//  RechargeDetailViewController.swift
//  CandyBull
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift
import Guitar
import SwifterSwift

class RechargeDetailViewController: BaseViewController {
    
    @IBOutlet weak var contentView: RechargeView!
    
    var feeAssetId: String  = AssetConfiguration.CybexAsset.CoreToken.id
    var available: Decimal = 0.0 // 可用余额有精度
    var requireAmount: String = "" //至少需要的金额
    var isWithdraw: Bool = false // 提现是否开启
    var withdrawing: Bool = false // 正在提现

    var isTrueAddress: Bool = false {
        didSet {
            if isTrueAddress != oldValue {
                self.changeWithdrawState()
            }
        }
    }
    var isAvalibaleAmount: Bool = false {
        didSet {
            if isAvalibaleAmount != true {
                self.changeWithdrawState()
            }
        }
    }
    
    var trade: Trade? {
        didSet {
            if let trade = self.trade {
                self.balance = UserHelper.getBalanceWithAssetId(trade.id)
                self.precision = appData.assetInfo[trade.id]?.precision
                self.coordinator?.getFee(trade.id, address: "", tag: trade.tag)
            }
        }
    }
    var balance: Balance? {
        didSet {
            if let balance = balance {
                self.available = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance)
            }
        }
    }
    var coordinator: (RechargeDetailCoordinatorProtocol & RechargeDetailStateManagerProtocol)?
    var precision: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
            self.title = tradeInfo.symbol.filterSystemPrefix + R.string.localizable.recharge_title.key.localized()
            
            self.startLoading()
            self.coordinator?.fetchWithDrawInfoData(trade.name)
        }
        
        setupUI()
        setupData()
        setupEvent()

        checkPermisson()
    }
    
    func setupData() {
        guard let trade = self.trade else { return }
        self.coordinator?.fetchDepositWriteInfo(trade.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView.trade = self.trade
    }
    
    func setupUI() {
        self.contentView.trade = self.trade
        self.contentView.balance = self.balance
        
        self.configRightNavButton(R.image.icWithdrawNew24Px())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openWithdrawRecodeList((self.trade?.name)!)
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                    self.switchHiddenInfo(true)
//                    self.view.layoutIfNeeded()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                self.switchHiddenInfo(false)
//                self.view.layoutIfNeeded()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    func switchHiddenInfo(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.contentView.feeView.isHidden       = hidden
            self.contentView.introduceView.isHidden = hidden
            self.contentView.feeView.allsubviews().forEach { $0.isHidden = hidden }
            self.contentView.introduceView.allsubviews().forEach { $0.isHidden = hidden }
        }
    }
    
    func setupEndEditingEvent() {
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.amountView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if let text = self.contentView.amountView.content.text, text.isEmpty == false,
                    text.decimal() >= 0,
                    let balance = self.balance,
                    let balanceInfo = appData.assetInfo[balance.assetType] {

                    if let coordinator =  self.coordinator, let value = coordinator.state.data.value, let precision = value.precision {
                        self.precision = precision
                        self.contentView.amountView.content.text = CashHelper.checkMaxLength(text, maxLength: value.precision ?? balanceInfo.precision)
                    } else {
                        self.contentView.amountView.content.text = CashHelper.checkMaxLength(text, maxLength: balanceInfo.precision)
                    }
                    let amount = self.contentView.amountView.content.text!.decimal()
                    self.checkAmountIsAvailable(amount)
                } else {
                    if let text = self.contentView.amountView.content.text {
                        if text.isEmpty {
                            self.contentView.errorView.isHidden = true
                        }
                        self.contentView.amountView.content.text = text.substring(from: 0, length: text.count - 1)
                    }
                    self.isAvalibaleAmount = false
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.addressView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if let address = self.contentView.addressView.content.text, address.count > 0 {
                    let letterBegin = Guitar(pattern: "^([a-zA-Z0-9])")
                    if !letterBegin.test(string: address) {
                        self.isTrueAddress = false
                        self.contentView.errorView.isHidden = false
                        self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                        self.contentView.addressView.addressState = .fail
                        return
                    }

                    if let trade = self.trade {
                        self.contentView.addressView.addressState = .loading
                        RechargeDetailCoordinator.verifyAddress(trade.name, address: address, callback: { (success) in
                            if success {
                                self.isTrueAddress = true
                                self.contentView.addressView.addressState = .success
                                self.contentView.errorView.isHidden = true
                                self.coordinator?.getFee(trade.id, address: address, tag: trade.tag)

                                if let amount = self.contentView.amountView.content.text?.decimal(), amount != 0 {
                                    self.checkAmountIsAvailable(amount)
                                }
                            } else {
                                self.contentView.addressView.addressState = .fail
                                self.isTrueAddress = false
                                self.contentView.errorView.isHidden = false
                                self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                            }
                        })
                    }
                } else {
                    if self.isTrueAddress == false, self.contentView.errorView.isHidden == false, self.contentView.addressView.addressState == .fail {
                        self.contentView.errorView.isHidden = true
                    }
                    self.contentView.addressView.addressState = .normal
                    self.isTrueAddress = false
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.memoView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                guard let trade = self.trade, let _ = self.contentView.amountView.content.text, let address = self.contentView.addressView.content.text else { return }
                self.coordinator?.getFee(trade.id, address: address, tag: trade.tag)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func setupEvent() {
        self.contentView.amountView.btn.rx.controlEvent(UIControl.Event.touchUpInside)
            .asControlEvent()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                if let balance = self.balance, let precision = self.precision {
                    self.contentView.amountView.content.text = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).formatCurrency(digitNum: precision)
                    self.checkAmountIsAvailable(AssetHelper.getRealAmount(balance.assetType, amount: balance.balance))
                    self.setFinalAmount()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.contentView.addressView.btn.rx.controlEvent(UIControl.Event.touchUpInside)
            .asControlEvent()
            .subscribe(onNext: { [weak self](_) in
                guard let self = self else { return }
                
                if let address = self.contentView.addressView.content.text,
                    let memo = self.contentView.memoView.content.text,
                    let trade = self.trade {
                    if address.isEmpty == false {
                        if self.isTrueAddress == true {
                            let withdrawAddress = WithdrawAddress(id: AddressManager.shared.getUUID(), name: trade.name, address: address, currency: trade.id, memo: memo)
                            self.coordinator?.chooseOrAddAddress(withdrawAddress, needTag: trade.tag)
                        }
                    }
                    else {
                        let withdrawAddress = WithdrawAddress(id: AddressManager.shared.getUUID(), name: trade.name, address: address, currency: trade.id, memo: memo)
                        self.coordinator?.chooseOrAddAddress(withdrawAddress, needTag: trade.tag)
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        setupKeyboardEvent()
        
        self.contentView.withdraw.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self](_) in
            guard let self = self else { return }
            self.withDrawAction()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        setupEndEditingEvent()
        self.coordinator?.state.withdrawAddress.asObservable().subscribe(onNext: { [weak self](address) in
            guard let self = self, let trade = self.trade, let address = address else { return }
            self.contentView.addressView.content.text = address.address
            self.contentView.addressView.addressState = .success
            self.contentView.memoView.content.text = address.memo
            self.isTrueAddress = true
            self.coordinator?.getFee(trade.id, address: address.address, tag: trade.tag)

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    }
    
    func checkAmountIsAvailable(_ amount: Decimal) {
        if let data = self.coordinator?.state.data.value {
            self.contentView.errorView.isHidden = false
            self.contentView.withdraw.isEnable = false
            if amount < data.minValue.decimal {
                self.isAvalibaleAmount  = false
                self.contentView.errorL.locali = R.string.localizable.withdraw_min_value.key
            } else if amount > self.available || self.available < data.fee.decimal {
                self.isAvalibaleAmount  = false
                self.contentView.errorL.locali =  R.string.localizable.withdraw_nomore.key
            } else {
                self.isAvalibaleAmount = true
                self.contentView.errorView.isHidden = true
                self.setFinalAmount()
                self.changeWithdrawState()
                if let addressText = self.contentView.addressView.content.text, addressText.count != 0, !self.isTrueAddress {
                    self.contentView.errorView.isHidden = false
                    self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                }
            }
        }
    }
    
    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().skip(1).subscribe(onNext: {[weak self] (withdrawInfo) in
            guard let self = self, let data = withdrawInfo else { return }
            self.endLoading()

            if let precision = data.precision {
                self.precision = precision
            }
            
            if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id], let precision = self.precision, let balance = self.balance {
                self.contentView.insideFee.text = data.fee.formatCurrency(digitNum: precision) + " " + tradeInfo.symbol.filterSystemPrefix
                self.contentView.avaliableView.content.text = AssetHelper.getRealAmount(
                    balance.assetType,
                    amount: balance.balance).formatCurrency(digitNum: tradeInfo.precision) + " " + tradeInfo.symbol.filterSystemPrefix
            }
            self.setFinalAmount()
            delay(milliseconds: 300) {
                self.changeWithdrawState()
            }
            self.contentView.amountView.textplaceholder = R.string.localizable.recharge_min.key.localized() + String(describing: data.minValue)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.fee.asObservable().subscribe(onNext: { [weak self](result) in
            guard let self = self else { return }
            self.endLoading()
            if let data = result, data.success, let feeInfo = appData.assetInfo[data.0.assetId] {
                let fee = data.0
                if let trade = self.trade, let precision = self.precision, feeInfo.id == trade.id {
                    self.contentView.gateAwayFee.text = fee.amount.formatCurrency(digitNum: precision) + " " + feeInfo.symbol.filterSystemPrefix
                } else {
                    self.contentView.gateAwayFee.text = fee.amount.formatCurrency(digitNum: feeInfo.precision) + " " + feeInfo.symbol.filterSystemPrefix
                }
                self.feeAssetId = fee.assetId
                self.setFinalAmount()
                delay(milliseconds: 300) {
                    self.changeWithdrawState()
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.withdrawMsgInfo.asObservable().subscribe(onNext: { [weak self](data) in
            guard let self = self else { return }
            self.contentView.projectData = data
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        (self.contentView.memoView.content.rx.text.orEmpty <-> self.coordinator!.state.memo).disposed(by: disposeBag)
    }
    
    func setFinalAmount() {
        guard let text = self.contentView.amountView.content.text, let amount = Decimal(string: text) else { return }
        guard let (finalAmount, requireAmount) = self.coordinator?.getFinalAmount(feeId: self.feeAssetId, amount: amount, available: self.available) else { return }
        self.requireAmount = requireAmount
        guard finalAmount >= 0,
            let balance = self.balance,
            let balanceInfo = appData.assetInfo[balance.assetType],
            let precision = self.precision else { return }
        self.contentView.finalAmount.text = finalAmount.formatCurrency(digitNum: precision) + " " + balanceInfo.symbol.filterSystemPrefix
    }
}

extension RechargeDetailViewController {
    /*
     1 所有的状态判断都在这个方法
     2 显示不同的状态提示框
     3 币种可提现  解锁钱包  权限  输入额度  地址
     */
    func changeWithdrawState() {
        if self.isTrueAddress, self.isAvalibaleAmount {
            if let _ = self.coordinator?.state.fee.value, let _ = self.coordinator?.state.data.value {
                self.contentView.withdraw.isEnable = true
            }
        } else {
            self.contentView.withdraw.isEnable = false
        }
    }

    func checkPermisson() -> Bool {
        if !UserManager.shared.permission.withdraw, UserManager.shared.unlockType == .cloudPassword {
            self.showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
            return false
        }

        if self.isWithdraw == false, let trade = self.trade {
            self.showToastBox(false, message: Localize.currentLanguage() == "en" ? trade.enMsg : trade.cnMsg)
            return false
        }

        return true
    }
    
    func withDrawAction() {
        if withdrawing {
            return
        }

        withdrawing = true
        self.view.endEditing(true)

        delay(milliseconds: 300) {
            self.withdrawing = false

            if self.checkPermisson() {
                if self.contentView.addressView.addressState != .success {
                    return
                }
                if !self.contentView.withdraw.isEnable {
                    return
                }

                self.confirm()
            }
        }

    }

    func confirm() {
        if self.contentView.withdraw.isEnable, let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
            let data = UIHelper.getWithdrawDetailInfo(addressInfo: self.contentView.addressView.content.text!,
                                                      amountInfo: self.contentView.amountView.content.text! + " " + tradeInfo.symbol.filterSystemPrefix,
                                                      withdrawFeeInfo: self.contentView.insideFee.text!,
                                                      gatewayFeeInfo: self.contentView.gateAwayFee.text!,
                                                      receiveAmountInfo: self.contentView.finalAmount.text!,
                                                      tag: trade.tag,
                                                      memoInfo: self.contentView.memoView.content.text!)
            showConfirm(R.string.localizable.withdraw_ensure_title.key.localized(), attributes: data)
        }
    }

    func withdraw() {
        guard let address = self.contentView.addressView.content.text, let trade = self.trade, let gatewayFee = self.coordinator?.state.fee.value
            else { return }
        startLoading()
        self.coordinator?.withDraw(assetId: trade.id,
                                   amount: self.requireAmount,
                                   address: address,
                                   feeId: self.feeAssetId,
                                   feeAmount: gatewayFee.0.amount,
                                   tag: trade.tag,
                                   callback: {[weak self] (data) in
                                    guard let self = self else { return }
                                    self.endLoading()
                                    main {
                                        ShowToastManager.shared.hide()
                                        if self.isVisible {
                                            if String(describing: data) == "<null>"{

                                                if AddressManager.shared.containAddressOfWithDraw(address, currency: trade.id).0 == false {
                                                    self.showConfirmImage(R.image.icCheckCircleGreen.name,
                                                                          title: R.string.localizable.withdraw_success_title.key.localized(),
                                                                          content: R.string.localizable.withdraw_success_content.key.localized(), tag: R.string.localizable.withdraw_success_content.key.localized())
                                                } else {
                                                    self.showToastBox(true, message: R.string.localizable.recharge_withdraw_success.key.localized())
                                                    delay(milliseconds: 100) {
                                                        self.coordinator?.pop()
                                                    }
                                                }
                                            } else {
                                                self.showToastBox(false, message: R.string.localizable.recharge_withdraw_failed.key.localized())
                                            }
                                        }
                                    }
        })
    }
    
    override func passwordDetecting() {
        startLoading()
    }
    
    override func passwordPassed(_ passed: Bool) {
        endLoading()
        if passed {
            ShowToastManager.shared.hide()
            withdraw()
        } else {
            if self.isVisible {
                self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
            }
        }
    }
    
    override func cancelImageAction(_ tag: String) {
        if tag == R.string.localizable.withdraw_success_content.key.localized() {
            self.coordinator?.pop()
        }
    }
}

extension RechargeDetailViewController {
    // 提现操作
    override func returnEnsureActionWithData(_ tag: String) {
        if tag == R.string.localizable.enotes_feature_hint.key.localized() { // 添加云账户
            pushCloudPasswordViewController(nil)
            return
        }
        if UserManager.shared.loginType == .nfc, UserManager.shared.unlockType == .nfc {
            if !UserManager.shared.checkExistCloudPassword() {
                showPureContentConfirm(R.string.localizable.confirm_hint_title.key.localized(), ensureButtonLocali: R.string.localizable.enotes_feature_add.key, content: R.string.localizable.enotes_feature_hint.key, tag: R.string.localizable.enotes_feature_hint.key.localized())
            } else {
                showPasswordBox()
            }
        } else if UserManager.shared.isLocked {
            showPasswordBox()
        } else {
            withdraw()
        }
    }
    override func returnEnsureImageAction() {
        if let address = self.contentView.addressView.content.text,
            let memo = self.contentView.memoView.content.text,
            let trade = self.trade {
            let withdrawAddress = WithdrawAddress(id: AddressManager.shared.getUUID(), name: trade.name, address: address, currency: trade.id, memo: memo)
            self.coordinator?.openAddAddressWithAddress(withdrawAddress, needTag: trade.tag)
        }
    }
}
