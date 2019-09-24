//
//  YourPortfolioCell.swift
//  CandyBull
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import SwiftTheme

class YourPortfolioCell: BaseTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var yourPortfolioCellView: YourPorfolioView!

    override func setup(_ data: Any?, indexPath: IndexPath) {
        yourPortfolioCellView.data = data
    }
}
