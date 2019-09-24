//
//  BusinessTitleCell.swift
//  CandyBull
//
//  Created by DKM on 2018/6/21.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class BusinessTitleCell: BaseTableViewCell {

    @IBOutlet weak var businessTitleCellView: BusinessTitleItemView!

    override func setup(_ data: Any?) {
        self.businessTitleCellView.selectedIndex = indexPath!.row
        self.businessTitleCellView.data = data
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
