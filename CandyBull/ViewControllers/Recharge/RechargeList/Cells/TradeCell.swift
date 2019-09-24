//
//  TradeCell.swift
//  CandyBull
//
//  Created by DKM on 2018/6/5.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class TradeCell: BaseTableViewCell {
    @IBOutlet weak var tradeCellView: TradeItemView!
    override func setup(_ data: Any?) {
        tradeCellView.data = data
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
