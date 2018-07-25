//
//  TransferListCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class TransferListCellView: UIView {
  
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var state: UILabel!
  
  var data : Any? {
    didSet{
      if let data = data as? (TransferRecord,time:String) {
        
        let transferRecord = data.0
        self.time.text = data.time
        self.address.text = transferRecord.to
        if let transferAmount = transferRecord.amount ,let assetInfo = app_data.assetInfo[(transferRecord.amount?.asset_id)!] {
          self.amount.text = getRealAmount(transferAmount.asset_id, amount: transferAmount.amount).stringValue.formatCurrency(digitNum: assetInfo.precision) + " " + assetInfo.symbol.filterJade

          if transferRecord.from == UserManager.shared.name.value {
            self.state.text = R.string.localizable.transfer_send.key.localized()
            self.icon.image = R.image.ic_send()
            self.amount.text = "-" + self.amount.text!
          }else {
            self.state.text = R.string.localizable.transfer_done.key.localized()
            self.icon.image = R.image.ic_income()
            self.amount.text = "+" + self.amount.text!
          }
        }
      }
    }
  }
  
  func setup() {
    
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.frame.size.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width:UIViewNoIntrinsicMetric,height:dynamicHeight())
  }
  
  fileprivate func dynamicHeight() -> CGFloat {
    let lastView = self.subviews.last?.subviews.last
    return lastView!.bottom
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadFromXIB()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadFromXIB()
    setup()
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  private func loadFromXIB() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
  }
  
}
