//
//  Network.swift
//  CandyBull
//
//  Created by koofrank on 2019/3/29.
//  Copyright © 2019 CandyBull. All rights reserved.
//

import Foundation

protocol NetworkHTTPEnv {
    static var productURL: URL { get set }
    static var devURL: URL { get }
    static var uatURL: URL { get set }

    static var currentEnv: URL { get }
}

extension NetworkHTTPEnv {
    static var currentEnv: URL {
        switch AppEnv.current {
        case .product:
            return Self.productURL
        case .test:
            return Self.devURL
        case .uat:
            return Self.uatURL
        }
    }
}

protocol NetworkWebsocketNodeEnv {
    static var productURL: [URL] { get set }
    static var devURL: [URL] { get }
    static var uatURL: [URL] { get set }

    static var currentEnv: [URL] { get }
}

extension NetworkWebsocketNodeEnv {
    static var currentEnv: [URL] {
        switch AppEnv.current {
        case .product:
            return Self.productURL
        case .test:
            return Self.devURL
        case .uat:
            return Self.uatURL
        }
    }
}
