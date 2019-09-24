//
//  UserDefaults.swift
//  CandyBull
//
//  Created by koofrank on 2018/4/2.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var theme : DefaultsKey<Int> { .init("com.candybull.dex.theme", defaultValue: 0) }
    var language : DefaultsKey<String> { .init("com.candybull.dex.language", defaultValue: "") }
    var refreshTime : DefaultsKey<Double> {.init("com.candybull.dex.refreshTime", defaultValue: 0)}
    var frequencyType : DefaultsKey<Int> {.init("com.candybull.dex.frequency_type", defaultValue: 0)}
    var loginType : DefaultsKey<Int>{.init("com.candybull.dex.logintype", defaultValue: 0)}
    var locktime : DefaultsKey<Int>{.init("com.candybull.dex.locktime", defaultValue: UserManager.LockTime.low.rawValue)}
    var unlockType : DefaultsKey<Int>{.init("com.candybull.dex.unlockType", defaultValue: 0)}
    var pinCodes : DefaultsKey<[String: Any]>{.init("com.candybull.dex.pincodes", defaultValue: [:])}

    var username : DefaultsKey<String>{.init("com.candybull.dex.username", defaultValue: "")}
    var keys : DefaultsKey<String>{.init("com.candybull.dex.keys", defaultValue: "")}
    var enotesKeys : DefaultsKey<String>{.init("com.candybull.dex.enotesKeys", defaultValue: "")}
    var account : DefaultsKey<String>{.init("com.candybull.dex.account", defaultValue: "")}

    var transferAddressList : DefaultsKey<[TransferAddress]>{.init("com.candybull.dex.TransferAddressList", defaultValue: [])}
    var withdrawAddressList : DefaultsKey<[WithdrawAddress]>{.init("com.candybull.dex.WithdrawAddressList", defaultValue: [])}

    var environment : DefaultsKey<String>{.init("com.candybull.dex.environment", defaultValue: "product")}
    var showContestTip : DefaultsKey<Bool>{.init("com.candybull.dex.showContestTip", defaultValue: false)}

    var isRealName : DefaultsKey<Bool>{.init("com.candybull.dex.isRealName", defaultValue: false)}

        var hasCode : DefaultsKey<Bool>{.init("com.candybull.dex.hasCode", defaultValue: false)}
}
