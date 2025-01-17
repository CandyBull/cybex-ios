//
//  QuotesTitleView.swift
//  CandyBull
//
//  Created by DKM on 2018/5/17.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

@IBDesignable
class QuotesTitleView: UIView {
    enum Event: String {
        case tagDidSelected
    }

    enum ViewType: Int {
        case home
        case trade
        case game
    }

    @IBOutlet weak var line: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var titleViews: [UIView]!
    @IBOutlet weak var stackViewLeft: NSLayoutConstraint!

    @IBInspectable
    var viewType: Int = 0 {
        didSet {
            switch viewType {
            case 1:
                self.stackView.axis = .vertical
                self.stackView.spacing = 0
                stackViewLeft.constant = 0
                self.line.isHidden = true
                for titleView in self.titleViews {
                    titleView.viewWithTag(10)?.isHidden = true // 选中的线
                    if let label = titleView.viewWithTag(9) as? UILabel {
                        label.textAlignment = .left
                    }
                }
            case 2:
                self.stackView.axis = .vertical
                self.stackView.spacing = 0
                stackViewLeft.constant = 0
                self.line.isHidden = true

                for (idx, titleView) in self.titleViews.enumerated() {
                    if idx < MarketConfiguration.gameMarketBaseAssets.count {
                        titleView.viewWithTag(10)?.isHidden = true // 选中的线
                        if let label = titleView.viewWithTag(9) as? UILabel {
                            label.textAlignment = .left
                            label.text = MarketConfiguration.gameMarketBaseAssets[idx].id.symbol
                        }
                    }
                    else {
                        titleView.isHidden = true

                    }
                }

            default:
                self.stackView.axis = .horizontal
                stackViewLeft.constant = 22
            }

        }
    }

    @IBInspectable
    var normalColor: UIColor = UIColor.steel {
        didSet {
            for titleView in titleViews {
                titleView.viewWithTag(10)?.isHidden = true
                if let titleL = titleView.viewWithTag(9) as? UILabel {
                    titleL.theme1TitleColor = normalColor
                    titleL.theme2TitleColor = normalColor
                }
            }
        }
    }

    @IBInspectable
    var selectedColor: UIColor = UIColor.white {
        didSet {

        }
    }

    fileprivate func setup() {
        for titleView in titleViews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickViewAction))
            titleView.addGestureRecognizer(tapGesture)
        }
    }

    @objc func clickViewAction(_ sender: UITapGestureRecognizer) {
        guard let titleView = sender.view else {
            return
        }
        changeToHighStatus(titleView.tag)
    }

    func changeToHighStatus(_ index: Int, save: Bool = false) {
        for titleView in titleViews {
            if titleView.tag  == index {
                if self.stackView.axis == .vertical {
                    titleView.viewWithTag(10)?.isHidden = true
                    if let titleL =  titleView.viewWithTag(9) as? UILabel {
                        titleL.theme1TitleColor = .primary
                        titleL.theme2TitleColor = .primary
                        let selectedIndex = index - 1
                        self.next?.sendEventWith(Event.tagDidSelected.rawValue, userinfo: ["selectedIndex": selectedIndex, "save": save])
                    }
                } else {
                    titleView.viewWithTag(10)?.isHidden = false
                    if let titleL =  titleView.viewWithTag(9) as? UILabel {
                        titleL.theme1TitleColor = .white
                        titleL.theme2TitleColor = .darkTwo
                        let selectedIndex = index - 1

                        self.next?.sendEventWith(Event.tagDidSelected.rawValue, userinfo: ["selectedIndex": selectedIndex, "save": save])
                    }
                }
            } else {
                titleView.viewWithTag(10)?.isHidden = true
                if let titleL =  titleView.viewWithTag(9) as? UILabel {
                    titleL.theme1TitleColor = .steel
                    titleL.theme2TitleColor = .steel
                }
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
