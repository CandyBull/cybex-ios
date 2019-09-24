//
//  ETORecordCell.swift
//  CandyBull
//
//  Created by peng zhu on 2018/8/31.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class ETORecordCell: BaseTableViewCell {
    @IBOutlet weak var recordView: ETORecordListViewView!

    override func setup(_ data: Any?) {
        if let data = data as? ETOTradeHistoryModel {
            recordView.updateUI(data, handler: ETORecordListViewView.adapterModelToETORecordListViewView(recordView))
        }
    }
}
