//
//  QuotesTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/17.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

@IBDesignable
class QuotesTitleView: UIView {
  enum event : String{
    case tagDidSelected
  }
  
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet var titleViews: [UIView]!
  
  
  @IBInspectable
  var View_Type : Int = 0 {
    didSet{
      if View_Type != 1{
        self.stackView.axis = .horizontal
      }else{
        self.stackView.axis = .vertical
        self.stackView.spacing = 25
        for titleView in self.titleViews{
          titleView.viewWithTag(10)?.isHidden = true
        }
      }
    }
  }
  
  @IBInspectable
  var normal_Color : UIColor = UIColor.steel {
    didSet{
      for titleView in titleViews {
        titleView.viewWithTag(10)?.isHidden = true
        if let titleL =  titleView.viewWithTag(9) as? UILabel{
          titleL.theme1TitleColor = normal_Color
          titleL.theme2TitleColor = normal_Color
        }
      }
    }
  }
  
  @IBInspectable
  var selected_Color : UIColor = UIColor.white{
    didSet{
      
    }
  }
  
  
  fileprivate func setup() {
    for titleView in titleViews {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickViewAction))
      titleView.addGestureRecognizer(tapGesture)
    }
  }
  
  @objc func clickViewAction(_ sender : UITapGestureRecognizer){
    guard let titleView = sender.view else {
      return
    }
    changeToHighStatus(titleView.tag)
  }
  
  
  func changeToHighStatus(_ index : Int){
    for titleView in titleViews {
      if titleView.tag  == index{
        if self.stackView.axis == .vertical{
          titleView.viewWithTag(10)?.isHidden = true
        }else{
          titleView.viewWithTag(10)?.isHidden = false
        }
        if let titleL =  titleView.viewWithTag(9) as? UILabel{
          titleL.theme1TitleColor = .white
          titleL.theme2TitleColor = .darkTwo
          self.next?.sendEventWith(event.tagDidSelected.rawValue, userinfo: ["selectedIndex": index - 1])
        }
      }else{
        titleView.viewWithTag(10)?.isHidden = true
        if let titleL =  titleView.viewWithTag(9) as? UILabel{
          titleL.theme1TitleColor = .steel
          titleL.theme2TitleColor = .steel
        }
      }
    }
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
