//
//  ComprehensiveItemsViewAdapter.swift
//  CandyBull
//
//  Created DKM on 2018/9/21.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

extension ComprehensiveItemsView {
    func adapterModelToComprehensiveItemsView(_ model: [ComprehensiveItem]) {
        self.data = model
        self.updateHeight()
    }
}
