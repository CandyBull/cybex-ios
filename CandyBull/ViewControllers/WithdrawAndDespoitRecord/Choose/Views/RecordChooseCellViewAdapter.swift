//
//  RecordChooseCellViewAdapter.swift
//  CandyBull
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation

extension RecordChooseCellView {
    func adapterModelToRecordChooseCellView(_ model: String) {
        self.nameLabel.text = model.filterSystemPrefix
    }
}
