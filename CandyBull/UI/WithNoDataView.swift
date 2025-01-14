//
//  withNoDataView.swift
//  CandyBull
//
//  Created by DKM on 2018/7/1.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class WithNoDataView: UIView {

    @IBOutlet weak var notice: UILabel!

    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak var noticeContairner: NSLayoutConstraint!

    var noticeWord: String? {
        didSet {
            if let noticeWord = noticeWord {
                notice.text = noticeWord
            }
        }
    }

    var iconName: String? {
        didSet {
            if let iconName = iconName {
                icon.image = UIImage.init(named: iconName)
            }
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
