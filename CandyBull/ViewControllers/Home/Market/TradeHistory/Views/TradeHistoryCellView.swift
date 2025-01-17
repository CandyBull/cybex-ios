//
//  TradeHistoryCellView.swift
//  CandyBull
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

@IBDesignable
class TradeHistoryCellView: UIView {

    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var assetQuote: UILabel!
    @IBOutlet weak var assetBase: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var data: Any? {
        didSet {
            guard let showData = data as? TradeHistoryViewModel else { return }
            self.price.textColor = showData.pay == true ? #colorLiteral(red: 0.4922918081, green: 0.7674361467, blue: 0.356476903, alpha: 1) : #colorLiteral(red: 0.7984321713, green: 0.3588138223, blue: 0.2628142834, alpha: 1)
            self.price.text = showData.price
            self.assetQuote.text = showData.quoteVolume
            self.assetBase.text = showData.baseVolume
            self.dateLabel.text = showData.time
        }
    }

    fileprivate func setup() {

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
