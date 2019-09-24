//
//  CybexChainHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme
import SwiftyJSON
import SwiftyUserDefaults
import cybex_ios_core_cpp

typealias TransactionBaseType = (block_id: String, block_num: String)
typealias FeeResult = (success: Bool, amount: Decimal, assetID: String)

class CybexChainHelper {
    class func blockchainParams(callback: @escaping (TransactionBaseType) -> Void) {
        let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject], refLib: false) { (infos) in
            if let infos = infos as? TransactionBaseType {
                callback(infos)
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }

    class func blockchainParamsRefLib(callback: @escaping (TransactionBaseType) -> Void) {
        let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject], refLib: true) { (infos) in
            if var infos = infos as? TransactionBaseType {
                let nextBlockNum = infos.block_num.int! + 1
                let request = GetBlockHeaderRequest(blockNum: nextBlockNum.string) { result in
                    if let result = result as? String {
                        infos.block_id = result
                        callback(infos)
                    }
                }
                CybexWebSocketService.shared.send(request: request)
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }


    /// 计算手续费 优先使用cyb 没有则使用focusAssetId
    ///
    /// - Parameters:
    ///   - operation: transaction operation string
    ///   - operationID: operate id
    ///   - focusAssetId: alternative asset id
    ///   - completion:
    class func calculateFee(_ operation: String,
                            operationID: Int = OperationId.limitOrderCreate,
                            focusAssetId: String,
                            completion: @escaping (FeeResult) -> Void) {
        let cybBalance = UserHelper.getBalanceFromAssetID(AssetConfiguration.CybexAsset.CoreToken.id)
        let focusBalance = UserHelper.getBalanceFromAssetID(focusAssetId)

        calculateFeeOfAsset(AssetConfiguration.CybexAsset.CoreToken.id, operation: operation, operationID: operationID) { (result) in
            let amount = AssetHelper.getRealAmount(AssetConfiguration.CybexAsset.CoreToken.id, amount: result.string)

            if !UserManager.shared.logined || cybBalance >= result {
                completion((success: true, amount: amount, assetID: AssetConfiguration.CybexAsset.CoreToken.id))
                return
            }

            calculateFeeOfAsset(focusAssetId, operation: operation, operationID: operationID) { (focusResult) in
                let focusAmount = AssetHelper.getRealAmount(focusAssetId, amount: focusResult.string)

                if focusBalance >= focusResult {
                    completion((success: true, amount: focusAmount, assetID: focusAssetId))
                } else {
                    completion((success: true, amount: amount, assetID: AssetConfiguration.CybexAsset.CoreToken.id))
                }
            }
        }
    }

    class func calculateFeeOfAsset(_ assetID: String,
                               operation: String,
                               operationID: Int = OperationId.limitOrderCreate,
                               completion: @escaping (Decimal) -> Void) {
        let request = GetRequiredFees(response: { (data) in
            guard let fees = data as? [Fee], let amount = fees.first?.amount.decimal() else {
                completion(0)
                return
            }
            completion(amount)

        }, operationStr: operation, assetID: assetID, operationID: operationID)

        CybexWebSocketService.shared.send(request: request)
    }
}
