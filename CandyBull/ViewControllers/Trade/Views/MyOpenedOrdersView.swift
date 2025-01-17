//
//  MyOpenedOrdersView.swift
//  CandyBull
//
//  Created by DKM on 2018/6/15.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit

class MyOpenedOrdersView: UIView {
    @IBOutlet weak var tableView: UITableView!
    var headerView: OpenedOrdersHeaderView!

    enum Event: String {
        case cancelOrder
        case cancelAllOrder
    }

    var data: Any? {
        didSet {
            if headerView == nil, data != nil {
                headerView = OpenedOrdersHeaderView(frame: CGRect(x: 0, y: 0, width: self.width, height: 42))
                headerView.cancelAllEvent.delegate(on: self) { (self, _) in
                    self.next?.sendEventWith(Event.cancelAllOrder.rawValue, userinfo: [:])
                }
                tableView.tableHeaderView = headerView
            }
            
            if let _ = data as? [LimitOrderStatus] {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate func setup() {
        let name = UINib.init(nibName: String.init(describing: OpenedOrdersCell.self), bundle: nil)
        self.tableView.register(name, forCellReuseIdentifier: String.init(describing: OpenedOrdersCell.self))
        self.tableView.tableFooterView = UIView()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

extension MyOpenedOrdersView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orders = data as? [LimitOrderStatus] else { return 0 }
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OpenedOrdersCell.self),
                                                    for: indexPath) as? OpenedOrdersCell,
            let orders = data as? [LimitOrderStatus] {
            cell.cellType = 0
            cell.setup(orders[indexPath.row], indexPath: indexPath)
            return cell
        }
        return OpenedOrdersCell()
    }
}

extension MyOpenedOrdersView {
    @objc func cancleOrderAction(_ data: [String: Any]) {
        if let index = data["selectedIndex"] as? Int {
            guard let orders = self.data as? [LimitOrderStatus] else { return  }
            
            let order = orders[index]
            self.next?.sendEventWith(Event.cancelOrder.rawValue, userinfo: ["order": order])
        }
    }
}
