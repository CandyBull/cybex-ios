//
//  ETORecordListViewView.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETORecordListViewView: BaseView {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    enum Event:String {
        case ETORecordListViewViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        nameLabel.text = "Hash future"
        actionLabel.text = "Join ETO"
        amountLabel.text = "10 CYB"
        timeLabel.text = "2018/12/28  12:09:50"
        statusLabel.text = "Failed to receive"
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETORecordListViewViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}