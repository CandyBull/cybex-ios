//
//  IntrinsicTableViewView.swift
//  CandyBull
//
//  Created koofrank on 2019/1/4.
//  Copyright © 2019 CandyBull. All rights reserved.
//

import Foundation

class IntrinsicTableViewView: UITableView {
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
