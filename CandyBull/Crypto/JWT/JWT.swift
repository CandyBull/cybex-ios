//
//  JWT.swift
//  CandyBull
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation

public struct JWT: Equatable {

    /// :nodoc:
    public static func == (lhs: JWT, rhs: JWT) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    let header: Header

    /// The payload section of the JWT object.
    public let payload: Payload

    let signature: Data

    let rawValue: String
    let rawComponents: [String]

    init(text: String) throws {
        rawValue = text
        rawComponents = text.components(separatedBy: ".")
        guard rawComponents.count == 3 else {
            throw CryptoError.JWTFailed(reason: .malformedJWTFormat(string: text))
        }

        let decoder = Base64JSONDecoder()
        header = try decoder.decode(Header.self, from: rawComponents[0])

        let payloadValues = try decoder.decodeDictionary(rawComponents[1])
        payload = Payload(values: payloadValues)

        guard let sigData = rawComponents[2].base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: rawComponents[2]))
        }
        signature = sigData
    }

    init(data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .utf8))
        }
        try self.init(text: text)
    }

    func verify(with key: CryptoPublicKey) throws -> Bool {
        guard let alg = JWA.Algorithm(rawValue: header.algorithm) else {
            throw CryptoError.JWTFailed(reason: .unsupportedHeaderAlgorithm(name: header.algorithm))
        }

        let plainText = try Crypto.PlainData(string: plainSegment)
        let signData = Crypto.SignedData(raw: signature)

        let result = try plainText.verify(with: key, signature: signData, algorithm: alg.algorithm)
        return result
    }

    @discardableResult
    func verify(with key: JWK) throws -> Bool {
        let publicKey = try key.getPublicKey()
        return try verify(with: publicKey)
    }
}

extension JWT {
    var plainSegment: String {
        return "\(rawComponents[0]).\(rawComponents[1])"
    }
}

extension JWT {
    struct Header: Codable {
        let algorithm: String
        let tokenType: String?
        let keyID: String?

        enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case tokenType = "typ"
            case keyID = "kid"
        }
    }
}

extension JWT {

    /// Represents the payload section of a JWT object. Use the exposed properties to get claims from the
    /// payload. Use the `subscript` method to get any unexposed values.
    public struct Payload {
        let values: [String: Any]

        func verify<T: Equatable>(keyPath: KeyPath<JWT.Payload, T?>, expected: T) throws {
            try verify(keyPath: keyPath, failingReason: "expected: \(expected)") { value in
                return value == expected }
        }

        func verify(keyPath: KeyPath<JWT.Payload, Date?>, earlierThan date: Date) throws {
            try verify(keyPath: keyPath, failingReason: "expected should earlier than \(date)") { value in
                return value <= date
            }
        }

        func verify(keyPath: KeyPath<JWT.Payload, Date?>, laterThan date: Date) throws {
            try verify(keyPath: keyPath, failingReason: "expected should later than \(date)") { value in
                return value >= date
            }
        }

        func verify<T>(
            keyPath: KeyPath<JWT.Payload, T?>,
            failingReason: @autoclosure () -> String,
            condition: (T) -> Bool) throws
        {
            guard let value = self[keyPath: keyPath] else {
                throw CryptoError.JWTFailed(
                    reason: .claimVerifyingFailed(key: "\(keyPath)", got: "nil", description: "value not exist"))
            }
            guard condition(value) else {
                throw CryptoError.JWTFailed(
                    reason: .claimVerifyingFailed(key: "\(keyPath)", got: "\(value)", description: failingReason()))
            }
        }
    }
}

// MARK: - Named getters for claims
extension JWT.Payload {

    /// Gets values from the current payload.
    ///
    /// - Parameters:
    ///   - key: The string key of a claim.
    ///   - type: The expected type for `key`. The value for `key` will be converted to the specified type.
    ///           Use JSON compatible types only.
    public subscript<T>(key: String, type: T.Type) -> T? {
        return values[key] as? T
    }

    /// The issuer claim of the ID token. The issuer of ID tokens from the LINE Platform is always
    /// "https://access.line.me".
    public var issuer: String? { return self["iss", String.self] }

    /// The subject claim of the ID token. The subject of ID tokens from the LINE Platform is the user ID
    /// of the authorized user.
    public var subject: String? { return self["sub", String.self] }

    /// The audience claim of the ID token. The audience of ID tokens from the LINE Platform is the channel
    /// ID of your app.
    public var audience: String? { return self["aud", String.self] }

    /// The expiration time of the ID token.
    public var expiration: Date? {
        guard let timeInterval = self["exp", TimeInterval.self] else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    /// The issued time of the ID token.
    public var issueAt: Date? {
        guard let timeInterval = self["iat", TimeInterval.self] else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
}

// MARK: - LINE-specific claims
extension JWT.Payload {
    var nonce: String? { return self["nonce", String.self] }

    /// The user's display name. Not included if the `.profile` permission was not specified in the
    /// authorization request.
    public var name: String? { return self["name", String.self] }

    /// The user's profile image URL. Not included if the `.profile` permission was not specified in the
    /// authorization request.
    public var pictureURL: URL? {
        guard let string = self["picture", String.self] else {
            return nil
        }
        return URL(string: string)
    }

    /// The user's email address. Not included if the `.email` permission was not specified in the
    /// authorization request.
    public var email: String? { return self["email", String.self] }

}
