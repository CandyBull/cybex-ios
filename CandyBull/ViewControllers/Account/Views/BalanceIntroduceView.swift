//
//  BalanceIntroduceView.swift
//  CandyBull
//
//  Created by DKM on 2018/5/23.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class BalanceIntroduceView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    var foreView: UIView!

    @IBAction func ensureAction(_ sender: UIButton) {

        self.removeFromSuperview()
    }

    fileprivate func setup() {
        foreView.theme_backgroundColor = [UIColor.black.withAlphaComponent(0.5).hexString(true), UIColor.steel50.hexString(true)]
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
        foreView = view
    }
}
