//
//  TimeGapView.swift
//  CandyBull
//
//  Created by koofrank on 2018/4/7.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

@IBDesignable
class TimeGapView: UIView {
  @IBOutlet var buttons: [UIView]!

  enum Event: String {
    case timeClicked = "timeClicked"
  }

  enum Tags: Int {
    case timeLabel = 1
    case line
  }

  var data: Any? {
    didSet {

    }
  }

  fileprivate func setup() {
    for (idx, button) in buttons.enumerated() {
      button.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
        guard let self = self else { return }

        self.switchButton(idx)
        self.next?.sendEventWith(Event.timeClicked.rawValue, userinfo: ["candlestick": Candlesticks.all[idx]])

      }).disposed(by: disposeBag)
    }
  }

  func switchButton(_ index: Int) {
    for (idx, button) in buttons.enumerated() {
        guard let timeLabel = button.viewWithTag(Tags.timeLabel.rawValue) as? UILabel else {
            continue
        }
      let line = button.viewWithTag(Tags.line.rawValue)
      if idx == index {
        timeLabel.textColor = .primary
        line?.isHidden = false
      } else {
        timeLabel.textColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
        line?.isHidden = true
      }
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
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
    guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

}
