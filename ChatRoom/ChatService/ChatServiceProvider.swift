//
//  ChatServiceProvider.swift
//  ChatRoom
//
//  Created by koofrank on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ChatServiceProvider {
    enum SendType: Int {
        case login = 1
        case message
    }

    enum ResponseType: Int {
        case response = 0
        case message = 2
    }

    private var deviceID: String
    private var channel: String
    public var onlineUpdated = Delegate<Int, Void>()
    public var messageReceived = Delegate<[ChatMessage], Void>()

    var online: Int = 0

    init(_ deviceID: String, channel: String) {
        self.deviceID = deviceID
        self.channel = channel
    }


    func switchChanel(_ channel: String) {
        self.channel = channel

        self.online = 0
    }

    func login(_ messageRow: Int = 300) -> String {
        var data: [String: Any] = [:]

        data["channel"] = self.channel
        data["deviceID"] = deviceID
        data["messageSize"] = "\(messageRow)"

        let postData = ["type": SendType.login.rawValue,
                "data": data
            ] as [String : Any]

        return JSON(postData).rawString() ?? ""
    }

    public func message(_ name: String, msg: String, sign: String) -> String {
        var data: [String: Any] = [:]

        data["userName"] = name
        data["message"] = msg
        data["sign"] = sign

        let postData = ["type": SendType.message.rawValue,
                "data": data
            ] as [String : Any]

        return JSON(postData).rawString() ?? ""
    }

    // MARK: -- parse response

    @discardableResult
    func parse(_ str: String) -> [ChatMessage] {
        let multiData = str.components(separatedBy: "\n").map({ JSON(parseJSON: $0) })
        var messages: [ChatMessage] = []

        for data in multiData {
            updateOnline(data)

            guard let type = ResponseType(rawValue: data["type"].intValue), type == .message else {
                continue
            }

            let message = ChatMessage.mapModels(from: data["data"]["messages"].rawString() ?? "")

            messages.append(contentsOf: message)
        }

        self.messageReceived.call(messages)
        
        return messages
    }

    func updateOnline(_ json: JSON) {
        guard let num = json["online"].int else {
            return
        }

        self.online = num
        self.onlineUpdated.call(num)
    }
}