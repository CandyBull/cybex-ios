//
//  HotAssetsView.swift
//  CandyBull
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

@IBDesignable
class HotAssetsView: CybexBaseView {

    @IBOutlet weak var contentView: GridContentView!
    var itemViews: [HotAssetView]!

    enum Event: String {
        case hotAssetsViewDidClicked
    }

    override var data: Any? {
        didSet {
            if let data = data as? [Ticker], data.count != 0 {
                if self.itemViews == nil || self.itemViews.count == 0 {
                    self.contentView.reloadData()
                }
                for index in 0..<data.count {
                    self.itemViews[index].adapterModelToHotAssetView(data[index])
                    self.itemViews[index].isHidden = index >= data.count
                }
            }
        }
    }

    override func setup() {
        super.setup()
        contentView.datasource = self
        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.hotAssetsViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension HotAssetsView: GridContentViewDataSource {
    func itemsForView(_ view: GridContentView) -> [UIView] {
        if let data = self.data as? [Ticker] {
            let views = Array(0...2).map({ (index) -> HotAssetView in
                let item = HotAssetView(frame: .zero)
                item.theme1BgColor = .dark
                item.theme2BgColor = .paleGrey
                if index < data.count {
                    item.adapterModelToHotAssetView(data[index])
                    item.isHidden = false
                } else {
                    item.isHidden = true
                }
                return item
            })
            itemViews = views
            return views
        }

        return []
    }

    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 0
    }

    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 3
    }

    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 90
    }
}
