//
//  AddAddressViewController.swift
//  CandyBull
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwifterSwift

enum PopType: Int {
    case normal = 0
    case selectVC
}

class AddAddressViewController: BaseViewController {

    @IBOutlet weak var containerView: AddAddressView!
    var coordinator: (AddAddressCoordinatorProtocol & AddAddressStateManagerProtocol)?
    var addressType: AddressType = .withdraw
    var asset: String = ""
    var name: String = ""
    var withdrawAddress: WithdrawAddress?
    var transferAddress: TransferAddress?
    var popActionType: PopType = .normal
    var needTag: Bool = false
    
	override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        self.coordinator?.setAsset(self.asset)
    }

    func setupUI() {
        if addressType == .withdraw {
            self.containerView.asset.content.text = appData.assetInfo[self.asset]?.symbol.filterSystemPrefix


            self.title = R.string.localizable.address_title_add.key.localized()
            self.containerView.address.title = R.string.localizable.address_or_account.key
            if needTag {
                self.containerView.memo.isHidden = false
                self.containerView.memo.name.text = "Tag"
            }
            else {
                self.containerView.memo.isHidden = true
            }

            if self.withdrawAddress != nil {
                self.containerView.data = withdrawAddress
                if withdrawAddress?.address.isEmpty == false {
                    self.coordinator?.veritiedAddress(true)
                }
            }
        } else {
            self.title = R.string.localizable.account_title_add.key.localized()
            self.containerView.assetShadowView.isHidden = true
            self.containerView.memo.isHidden = true
            if self.transferAddress != nil {
                self.containerView.data = transferAddress
                if transferAddress?.address.isEmpty == false {
                    self.coordinator?.veritiedAddress(true)
                }
            }
        }
    }

    override func configureObserveState() {
        (self.containerView.address.content.rx.text.orEmpty <-> self.coordinator!.state.address).disposed(by: disposeBag)
        (self.containerView.mark.content.rx.text.orEmpty <-> self.coordinator!.state.note).disposed(by: disposeBag)
        (self.containerView.memo.content.rx.text.orEmpty <-> self.coordinator!.state.memo).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification,
                                               object: self.containerView.mark.content, queue: nil) { [weak self](_) in
            guard let self = self else { return }
            if let text = self.containerView.mark.content.text, text.trimmed.count != 0 {
                self.coordinator?.verityNote(true)
                if text.trimmed.count > 15 {
                    self.containerView.mark.content.text = text.trimmed.substring(from: 0, length: 15)
                    self.coordinator?.setNoteAction(self.containerView.mark.content.text!)
                }
            } else {
                self.coordinator?.verityNote(false)
            }
        }

        NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self.containerView.address.content, queue: nil) { [weak self](_) in
            guard let self = self else {return}

            if let text = self.containerView.address.content.text, text.trimmed.count > 0 {
                if self.needTag {
                    self.coordinator?.veritiedAddress(true)
                    return
                }
                self.containerView.addressState = .loading
                self.coordinator?.verityAddress(text.trimmed, type: self.addressType, name: self.name)
            } else {
                self.containerView.addressState = .normal
                self.coordinator?.veritiedAddress(false)
            }
        }

        self.coordinator?.state.addressVailed.asObservable().skip(1).subscribe(onNext: { [weak self](addressSuccess) in
            guard let self = self else {return}
            if !addressSuccess {
                if self.containerView.address.content.text.count != 0 {
                    self.containerView.addressState = .fail
                } else {
                    self.containerView.addressState = .normal
                }
            } else {
                self.containerView.addressState = .success
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        Observable.combineLatest(
            self.coordinator!.state.addressVailed.asObservable(),
            self.coordinator!.state.noteVailed.asObservable()
            ).subscribe(onNext: { [weak self](addressSuccess, noteSuccess) in
            guard let self = self else { return }
            guard addressSuccess, noteSuccess else {
                self.containerView.addBtn.isEnable = false
                return
            }
            self.containerView.addBtn.isEnable = true
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.containerView.addBtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self](_) in
            guard let self = self else { return }
            self.view.endEditing(true)

            if self.containerView.addBtn.isEnable == false || self.containerView.addressState != .success {
                return
            }
            let exit = self.addressType == .withdraw ?
                AddressManager.shared.containAddressOfWithDraw(self.containerView.address.content.text, currency: self.asset).0 :
                AddressManager.shared.containAddressOfTransfer(self.containerView.address.content.text).0
            if exit {
                if self.isVisible {
                    self.showToastBox(false,
                                      message: self.addressType == .withdraw ?
                                        R.string.localizable.address_exit.key.localized() :
                                        R.string.localizable.account_exit.key.localized())
                }
            } else {
                self.coordinator?.addAddress(self.addressType)
                self.showToastBox(true, message: R.string.localizable.address_add_success.key.localized())
                delay(milliseconds: 1000) {
                    ShowToastManager.shared.hide(0)
                    self.coordinator?.pop(self.popActionType)
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
