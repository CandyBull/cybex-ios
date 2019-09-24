//
//  ChatDirectionIconViewAdapter.swift
//  CandyBull
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation

extension ChatDirectionIconView {
    func adapterModelToChatDirectionIconView(_ model:String) {
        self.contentLabel.text = model
    }
}
