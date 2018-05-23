//
//  HomePairView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import EZSwiftExtensions
import RxGesture
import Kingfisher

@IBDesignable
class HomePairView: UIView {
  
  enum event:String {
    case cellClicked
  }
  
  
  @IBOutlet weak var asset2: UILabel!
  
  @IBOutlet weak var volume: UILabel!
  
  @IBOutlet weak var price: UILabel!
  
  @IBOutlet weak var bulking: UILabel!
  
  @IBOutlet weak var asset1: UILabel!
  @IBOutlet weak var rbmL: UILabel!
  @IBOutlet weak var high_lowContain: UIView!
  
    @IBOutlet weak var icon: UIImageView!
    
    var base:String!
  var quote:String!
  var data: Any? {
    didSet {
      guard let markets = data as? HomeBucket else { return }
      
      self.asset2.text =  markets.quote_info.symbol.filterJade
      self.asset1.text = "/" + markets.base_info.symbol.filterJade
      if markets.bucket.count == 0 {
        self.volume.text = "V: -"
        self.price.text = "-"
        self.bulking.text = "-"
        self.bulking.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.high_lowContain.backgroundColor = .coolGrey
        self.rbmL.text  = "-"
        return
      }
      
      DispatchQueue.global().async {
        let matrix = BucketMatrix(markets)
        
        DispatchQueue.main.async {
          //
          
          self.icon.kf.setImage(with: URL(string: matrix.icon))

          if let _ = matrix.base_volume.toDouble(){
            self.volume.text = markets.quote_info.symbol.filterJade + ": " + matrix.quote_volume.formatCurrency(digitNum: 2)
            
          }else{
            let subString = matrix.quote_volume.substring(from: 0, length: matrix.quote_volume.length - 1)
            
            self.volume.text = markets.quote_info.symbol.filterJade + ": " + (subString?.formatCurrency(digitNum: 2))! + matrix.quote_volume.substring(from: matrix.quote_volume.length - 1, length: 1)!
          }
          
          self.price.text = matrix.price
          self.bulking.text = ((matrix.incre == .greater ? "+" : "") + matrix.change).formatCurrency(digitNum: 2) + "%"
          self.high_lowContain.backgroundColor = matrix.incre.color()
        
          let (eth,_) = changeToETHAndCYB(markets.quote_info.id)
          self.rbmL.text  = "≈¥" + (eth.toDouble()! * app_data.eth_rmb_price).toString.formatCurrency(digitNum: 2)
        }
      }
    }
  }
  
  
  fileprivate func setup() {
    self.isUserInteractionEnabled = true
    self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      
      self.next?.sendEventWith(event.cellClicked.rawValue, userinfo: ["index": self.store["index"] ?? []])
      
    }).disposed(by: disposeBag)
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
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
    loadViewFromNib()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadViewFromNib()
    setup()
  }
  
  fileprivate func loadViewFromNib() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
  
}
