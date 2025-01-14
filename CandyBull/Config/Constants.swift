//
//  Constants.swift
//  CandyBull
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension Notification.Name {
    static let NetWorkChanged = Notification.Name(rawValue: "NetWorkChanged") //授权网络状态切换
}

enum FundType: String {
    case WITHDRAW
    case DEPOSIT
    case ALL = ""
}

enum OperationId {
    static var transfer: Int {
        switch AppEnv.current {
        case .product:
            return 0
        case .test:
            return 0
        case .uat:
            return 0
        }
    }
    static var limitOrderCreate: Int {
        switch AppEnv.current {
        case .product:
            return 1
        case .test:
            return 1
        case .uat:
            return 1
        }
    }
    static var limitOrderCancel: Int {
        switch AppEnv.current {
        case .product:
            return 2
        case .test:
            return 2
        case .uat:
            return 2
        }
    }
    static var accountUpdate: Int {
        switch AppEnv.current {
        case .product:
            return 6
        case .test:
            return 6
        case .uat:
            return 6
        }
    }
    static var cancelAll: Int {
        switch AppEnv.current {
        case .product:
            return 52
        case .test:
            return 52
        case .uat:
            return 52
        }
    }
    static var participate_exchange: Int {
        switch AppEnv.current {
        case .product:
            return 63
        case .test:
            return 63
        case .uat:
            return 63
        }
    }
}

enum ObjectID {
    static var dynamicGlobalPropertyObject: String {
        switch AppEnv.current {
        case .product:
            return "2.1.0"
        case .test:
            return "2.1.0"
        case .uat:
            return "2.1.0"
        }
    }
    static var exchangeObject: String {
        switch AppEnv.current {
        case .product:
            return "1.20.0"
        case .test:
            return "1.20.0"
        case .uat:
            return "1.20.0"
        }
    }
}

enum HashAlgorithm: String, CaseIterable {
    case ripemd160
    case sha1
    case sha256

    func asInt() -> Int {
        return HashAlgorithm.allCases.firstIndex(of: self)!
    }

    init?(value: Int) {
        if value < HashAlgorithm.allCases.count {
            self = HashAlgorithm.allCases[value]
        } else {
            return nil
        }
    }
}


