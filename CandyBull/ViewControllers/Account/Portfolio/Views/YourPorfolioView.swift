//
//  YourPorfolioView.swift
//  CandyBull
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class YourPorfolioView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var price: UILabel!

    @IBOutlet weak var cybAmount: UILabel!

    @IBOutlet weak var rmbPrice: UILabel!

    @IBOutlet weak var bottomView: UIStackView!

    // 如果是CYB 就不显示的下层view
    @IBOutlet weak var highLowView: UIView!
    @IBOutlet weak var priceCyb: UILabel!
    @IBOutlet weak var highLowIcon: UIImageView!
    @IBOutlet weak var highLowLabel: UILabel!

    var data: Any? {
        didSet {
            if let portfolioData = data as? MyPortfolioData {
                bottomView.isHidden = true

                self.icon.kf.setImage(with: URL(string: portfolioData.icon))

                name.text      = portfolioData.name
                amount.text    = portfolioData.limitAmount
                if portfolioData.rbmPrice == "-" {
                    rmbPrice.text = handlerRMBLabel("0.0000")
                } else {
                    rmbPrice.text  = handlerRMBLabel(portfolioData.rbmPrice)
                }
                cybAmount.text = portfolioData.realAmount
            }
        }
    }

    func handlerRMBLabel(_ str: String) -> String {

        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable, str == "0.0000" {
            let ids = MarketConfiguration.shared.gameMarketPairs.flatMap { $0.assets }.removingDuplicates()
            if ids.contains(name.text!.assetID) {
                return ""
            }
        }
        
        return "≈¥" + str
    }

    fileprivate func setup() {
        bottomView.isHidden = true
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
