//
//  TradeHistoryCell.swift
//  CandyBull
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

class TradeHistoryCell: BaseTableViewCell {

    @IBOutlet weak var ownView: TradeHistoryCellView!

    override func setup(_ data: Any?) {
        self.ownView.data = data
    }
}
