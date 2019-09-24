//
//  RecodeCell.swift
//  CandyBull
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class RecodeCell: BaseTableViewCell {

    @IBOutlet var cellView: RecodeCellView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func setup(_ data: Any?, indexPath: IndexPath) {
        cellView.data = data
    }
}
