//
//  HotAssetView.swift
//  CandyBull
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

@IBDesignable
class HotAssetView: CybexBaseView {

    @IBOutlet weak var assetName: BaseLabel!
    @IBOutlet weak var amountLabel: BaseLabel!
    @IBOutlet weak var rmbLabel: BaseLabel!
    @IBOutlet weak var trendLabel: BaseLabel!

    enum Event: String {
        case hotAssetViewDidClicked
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        assetName.textAlignment = .center
        amountLabel.textAlignment = .center
        rmbLabel.textAlignment = .center
        trendLabel.textAlignment = .center
    }

    func setupSubViewEvent() {
        self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            self.next?.sendEventWith(Event.hotAssetViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
        }).disposed(by: disposeBag)
    }

    @objc override func didClicked() {
    }
}
