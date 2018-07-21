//
//  AccountViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftTheme
import AwaitKit
import RxSwift
import CryptoSwift
import SwiftRichString
import SwifterSwift

class AccountViewController: BaseViewController {
  
  var coordinator: (AccountCoordinatorProtocol & AccountStateManagerProtocol)?
  
  @IBOutlet weak var accountContentView: AccountContentView!
  
  var dataArray: [AccountViewModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupEvent()
    if  UserManager.shared.isLoginIn {
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func setupIconImg() {
    if UserManager.shared.isLoginIn == true {
      accountContentView.headerView.icon = R.image.accountAvatar()
    } else {
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
    if let name = UserManager.shared.account.value?.name {
      accountContentView.headerView.title = R.string.localizable.business_login_title() + name
    } else {
      accountContentView.headerView.title = R.string.localizable.accountLogin()
    }
  }
  
  // UI的初始化设置
  func setupUI(){
    setupTitle()
    setupIconImg()
    self.configRightNavButton(R.image.icSettings24Px())
    
    let imgArray = [R.image.icBalance(),R.image.w(),R.image.icOrder28Px(),R.image.icLockAsset()]
    let nameArray = [R.string.localizable.my_property(),R.string.localizable.account_trade(),R.string.localizable.order_value(),R.string.localizable.lockupAssetsTitle()]
    for i in 0..<4 {
      var model = AccountViewModel()
      model.leftImage = imgArray[i]
      model.name = nameArray[i]
      dataArray.append(model)
    }
    accountContentView.data = dataArray
  }
  
  func setupEvent() {
    
  }
  
  // 跳转到设置界面
  override func rightAction(_ sender: UIButton) {
    self.coordinator?.openSetting()
  }
  
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
      return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    coordinator?.subscribe(loadingSubscriber) { sub in
      return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
}

extension AccountViewController{
  @objc func clickCellView(_ sender:[String:Any]) {
    let index = sender["index"] as! Int
    switch index {
    case 0:
      self.coordinator?.openYourProtfolio()
    case 1:
      self.coordinator?.openRecharge()
    case 2:
      self.coordinator?.openOpenedOrders()
    default:
      self.coordinator?.openLockupAssets()
    }
  }

  @objc func openLockupAssets(_ data:[String: Any]){
    guard !isLoading() else { return }
    
    if !UserManager.shared.isLocked {
      self.coordinator?.openLockupAssets()
    }
    else {
      self.showPasswordBox()
    }
  }
  
  override func passwordPassed(_ passed: Bool) {
    self.endLoading()
    
    if self.isVisible {
      if passed {
        self.coordinator?.openLockupAssets()
      }
      else {
        self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
      }
    }
    
  }
  
  override func passwordDetecting() {
    self.startLoading()
  }
}
