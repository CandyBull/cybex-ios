//
//  ComprehensiveItemViewAdapter.swift
//  CandyBull
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

extension ComprehensiveItemView {
    func adapterModelToComprehensiveItemView(_ model: ComprehensiveItem) {
        icon.kf.setImage(with: URL(string: model.icon))
        titleLabel.text = model.title
        subTitleLabel.text = model.desc
    }
}
