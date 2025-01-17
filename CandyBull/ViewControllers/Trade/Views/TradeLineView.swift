//
//  TradeLineView.swift
//  CandyBull
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class TradeLineView: UIView {
    @IBOutlet weak var backColorView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var backViewLeading: NSLayoutConstraint!
    
    var pricePrecision: Int = 0
    var amountPrecision: Int = 0
    var isBuy: Bool?
    var data: Any? {
        didSet {
//            if let order = data as? (Any, Decimal), let data = order.0 as? OrderBook.Order {
//                price.text  = data.price
//                amount.text = data.volume
//                backViewLeading.constant = self.width * (1 - order.1).cgfloat()
//                backColorView.backgroundColor = self.isBuy == true ? UIColor.reddish15 : UIColor.turtleGreen15
//                price.textColor = self.isBuy == true ? UIColor.reddish : UIColor.turtleGreen
//                if UIScreen.main.bounds.width <= 320 {
//                    price.font  = UIFont.systemFont(ofSize: 11)
//                    amount.font = UIFont.systemFont(ofSize: 11)
//                }
//            }
        }
    }

    func setup() {

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

extension TradeLineView {
    func adapterModelToTradeLineView(_ model: OrderBookViewModel) {
        model.orderbook.asObservable().subscribe(onNext: { [weak self](orderbook) in
            guard let self = self, let data = orderbook else { return }
            if self.price.text != data.price.formatCurrency(digitNum: self.pricePrecision) {
                self.price.text  = data.price.formatCurrency(digitNum: self.pricePrecision)
            }
            if self.amount.text != data.volume.suffixNumber(digitNum: self.amountPrecision) {
                self.amount.text = data.volume.suffixNumber(digitNum: self.amountPrecision)
            }
            
            self.backColorView.backgroundColor = model.isBuy == true ? UIColor.reddish15 : UIColor.turtleGreen15
            self.price.textColor = model.isBuy == true ? UIColor.reddish : UIColor.turtleGreen
            if UIScreen.main.bounds.width <= 320 {
                self.price.font  = UIFont.systemFont(ofSize: 11)
                self.amount.font = UIFont.systemFont(ofSize: 11)
            }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.percent.asObservable().subscribe(onNext: { [weak self](decimal) in
            guard let `self` = self else { return }
            self.backViewLeading.constant = self.width * (1 - decimal).cgfloat()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }
}

