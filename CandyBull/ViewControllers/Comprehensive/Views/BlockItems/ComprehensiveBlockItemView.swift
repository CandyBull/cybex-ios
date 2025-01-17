//
//  ComprehensiveBlockItemView.swift
//  CandyBull
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

@IBDesignable
class ComprehensiveBlockItemView: CybexBaseView {

    @IBOutlet weak var blockTitle: BaseLabel!
    @IBOutlet weak var blockContentLabel: BaseLabel!

    enum Event: String {
        case comprehensiveBlockItemViewDidClicked
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.comprehensiveBlockItemViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
