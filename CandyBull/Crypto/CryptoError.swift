//
//  CryptoError.swift
//  CandyBull
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation

/// - algorithmsFailed: An error occurred while performing an algorithm related operation like creating
///                     keys or verifying signed data.
/// - JWTFailed: An error occurred while performing a JWT related operation.
/// - JWKFailed: An error occurred while performing a JWK related operation.
/// - generalError: An error occurred while performing another crypto related operation.
public enum CryptoError: Error {

    /// The possible underlying reasons an `.algorithmsFailed` error occurs.
    ///
    /// - invalidDERKey: The DER data does not contain a valid RSA key. Code 3016_1001.
    /// - invalidX509Header: The x509 header is found in the key, but the data is invalid. Code 3016_1002.
    /// - createKeyFailed: An error occurred while creating a security key. Code 3016_1003.
    /// - invalidPEMKey: The PEM key is invalid. Code 3016_1004.
    /// - encryptingError: An error occurred while encrypting plain data. Code 3016_1005.
    /// - decryptingError: An error occurred while decrypting encrypted data. Code 3016_1006.
    /// - signingError: An error occurred while signing plain data. Code 3016_1007.
    /// - verifyingError:  An error occurred while verifying data. Code 3016_1008.
    public enum AlgorithmsErrorReason {

        /// The DER data does not contain a valid RSA key. Code 3016_1001.
        case invalidDERKey(data: Data, reason: String)

        /// The x509 header is found in the key, but the data is invalid. Code 3016_1002.
        case invalidX509Header(data: Data, index: Int, reason: String)

        /// An error occurred while creating a security key. Code 3016_1003.
        case createKeyFailed(data: Data, reason: String)

        /// The PEM key is invalid. Code 3016_1004.
        case invalidPEMKey(string: String, reason: String)

        /// An error occurred while encrypting plain data. Code 3016_1005.
        case encryptingError(Error?)

        /// An error occurred while decrypting encrypted data. Code 3016_1006.
        case decryptingError(Error?)

        /// An error occurred while signing plain data. Code 3016_1007.
        case signingError(Error?)

        /// An error occurred while verifying data. Code 3016_1008.
        case verifyingError(Error?, statusCode: Int?)
    }

    public enum JWTErrorReason {

        /// The input text is not a valid JWT encoded string. Code 3016_2001.
        case malformedJWTFormat(string: String)

        case unsupportedHeaderAlgorithm(name: String)

        /// Verification for a certain key in the JWT payload does not pass. Code 3016_2003.
        case claimVerifyingFailed(key: String, got: String, description: String)
    }

    public enum JWKErrorReason {

        case unsupportedKeyType(String)
    }

    /// The possible underlying reasons a `.generalError` occurs.
    ///
    /// - base64ConversionFailed: The string cannot be converted to the base64 data format. Code 3016_4001.
    /// - dataConversionFailed: The data cannot be converted to a string with the given encoding. Code
    ///                         3016_4002.
    /// - stringConversionFailed: The string cannot be converted to data with the given encoding. Code
    ///                           3016_4003.
    /// - operationNotSupported: The operation is not supported by the current OS. Code 3016_4004.
    /// - decodingFailed: The data cannot be decoded to the target type. Code 3016_4005.
    public enum GeneralErrorReason {

        /// The string cannot be converted to the base64 data format. Code 3016_4001.
        case base64ConversionFailed(string: String)

        /// The data cannot be converted to a string with the given encoding. Code 3016_4002.
        case dataConversionFailed(data: Data, encoding: String.Encoding)

        /// The string cannot be converted to data with the given encoding. Code 3016_4003.
        case stringConversionFailed(string: String, encoding: String.Encoding)

        /// The operation is not supported by the current OS. Code 3016_4004.
        case operationNotSupported(reason: String)

        /// The data cannot be decoded to the target type. Code 3016_4005.
        case decodingFailed(string: String, type: Any.Type)
    }

    case algorithmsFailed(reason: AlgorithmsErrorReason)
    case JWTFailed(reason: JWTErrorReason)
    case JWKFailed(reason: JWKErrorReason)
    case generalError(reason: GeneralErrorReason)
}

extension CryptoError.AlgorithmsErrorReason {

    var errorDescription: String? {
        switch self {
        case .invalidDERKey(_, let reason):
            return "DER data does not contain a valid key. \(reason)"
        case .invalidX509Header(_, let index, let reason):
            return "x509 header is found in the key, but the expected data at index: \(index) is wrong. \(reason)"
        case .createKeyFailed(_, let reason):
            return "Error happens while creating security key. \(reason)"
        case .invalidPEMKey(_, let reason):
            return "The PEM key is invalid. \(reason)"
        case .encryptingError(let error):
            return "Error happens while encrypting some plain data. Error: \(String(describing: error))"
        case .decryptingError(let error):
            return "Error happens while decrypting some plain data. Error: \(String(describing: error))"
        case .signingError(let error):
            return "Error happens while signing some plain data. Error: \(String(describing: error))"
        case .verifyingError(let error, let code):
            return "Error happens while verifying some plain data. " +
            "Error: \(String(describing: error)), code: \(String(describing: code))"
        }
    }

    var errorCode: Int {
        switch self {
        case .invalidDERKey:     return 3016_1001
        case .invalidX509Header: return 3016_1002
        case .createKeyFailed:   return 3016_1003
        case .invalidPEMKey:     return 3016_1004
        case .encryptingError:   return 3016_1005
        case .decryptingError:   return 3016_1006
        case .signingError:      return 3016_1007
        case .verifyingError:    return 3016_1008
        }
    }

    var errorUserInfo: [String: Any] {
        var userInfo = [CybexErrorUserInfoKey: Any]()
        switch self {
        case .invalidDERKey(let data, _):
            userInfo[.data] = data
        case .invalidX509Header(let data, let index, _):
            userInfo[.data] = data
            userInfo[.index] = index
        case .createKeyFailed(let data, _):
            userInfo[.data] = data
        case .invalidPEMKey(let data, _):
            userInfo[.data] = data
        case .encryptingError(let error):
            userInfo[.underlyingError] = error
        case .decryptingError(let error):
            userInfo[.underlyingError] = error
        case .signingError(let error):
            userInfo[.underlyingError] = error
        case .verifyingError(let error, let code):
            userInfo[.underlyingError] = error
            if let code = code {
                userInfo[.statusCode] = code
            }
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.JWTErrorReason {

    var errorDescription: String? {
        switch self {
        case .malformedJWTFormat(let string):
            return "The input text is not a valid JWT encoded string: \(string)"
        case .unsupportedHeaderAlgorithm(let name):
            return "The algorithm (\(name)) defined in JWT header is not supported."
        case .claimVerifyingFailed(let key, let got, let description):
            return "Verification failed for key: \(key). Got: \(got), \(description)"
        }
    }

    var errorCode: Int {
        switch self {

        case .malformedJWTFormat:         return 3016_2001
        case .unsupportedHeaderAlgorithm: return 3016_2002
        case .claimVerifyingFailed:       return 3016_2003
        }
    }

    var errorUserInfo: [String: Any] {
        var userInfo = [CybexErrorUserInfoKey: Any]()
        switch self {
        case .malformedJWTFormat(let string):
            userInfo[.text] = string
        case .unsupportedHeaderAlgorithm(let name):
            userInfo[.raw] = name
        case .claimVerifyingFailed(let key, let got, _):
            userInfo[.key] = key
            userInfo[.got] = got
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.JWKErrorReason {

    var errorDescription: String? {
        switch self {
        case .unsupportedKeyType(let keyType):
            return "The key type (\(keyType)) is not supported."
        }
    }

    var errorCode: Int {
        switch self {
        case .unsupportedKeyType: return 3016_3001
        }
    }

    var errorUserInfo: [String: Any] {
        var userInfo = [CybexErrorUserInfoKey: Any]()
        switch self {
        case .unsupportedKeyType(let keyType):
            userInfo[.raw] = keyType
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.GeneralErrorReason {

    var errorDescription: String? {
        switch self {
        case .base64ConversionFailed(let string):
            return "String cannot be converted to base64 data format: \(string)"
        case .dataConversionFailed(let data, let encoding):
            return "Cannot convert data to string under a given encoding. Data: \(data), encoding: \(encoding)"
        case .stringConversionFailed(let string, let encoding):
            return "Cannot convert string to data under a given encoding. String: \(string), encoding: \(encoding)"
        case .operationNotSupported(let reason):
            return "The operation is not supported in current OS. \(reason)"
        case .decodingFailed(let string, let type):
            return "Cannot decode string: \(string) to \(type)."
        }
    }

    var errorCode: Int {
        switch self {

        case .base64ConversionFailed: return 3016_4001
        case .dataConversionFailed:   return 3016_4002
        case .stringConversionFailed: return 3016_4003
        case .operationNotSupported:  return 3016_4004
        case .decodingFailed:         return 3016_4005
        }
    }

    var errorUserInfo: [String: Any] {
        var userInfo = [CybexErrorUserInfoKey: Any]()
        switch self {
        case .base64ConversionFailed(let string):
            userInfo[.text] = string
        case .dataConversionFailed(let data, let encoding):
            userInfo[.data] = data
            userInfo[.encoding] = encoding
        case .stringConversionFailed(let string, let encoding):
            userInfo[.text] = string
            userInfo[.encoding] = encoding
        case .operationNotSupported:
            break
        case .decodingFailed(let string, let type):
            userInfo[.raw] = string
            userInfo[.type] = type
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

// MARK: - Error description
extension CryptoError: LocalizedError {
    /// Describes the cause of an error in human-readable text.
    public var errorDescription: String? {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorDescription
        case .JWTFailed(reason: let reason): return reason.errorDescription
        case .JWKFailed(reason: let reason): return reason.errorDescription
        case .generalError(reason: let reason): return reason.errorDescription
        }
    }
}

// MARK: - NSError compatibility
extension CryptoError: CustomNSError {

    /// :nodoc:
    public var errorUserInfo: [String : Any] {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorUserInfo
        case .JWTFailed(reason: let reason): return reason.errorUserInfo
        case .JWKFailed(reason: let reason): return reason.errorUserInfo
        case .generalError(reason: let reason): return reason.errorUserInfo
        }
    }

    /// :nodoc:
    public var errorCode: Int {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorCode
        case .JWTFailed(reason: let reason): return reason.errorCode
        case .JWKFailed(reason: let reason): return reason.errorCode
        case .generalError(reason: let reason): return reason.errorCode
        }
    }

    /// :nodoc:
    public static var errorDomain: String {
        return "CybexError.CryptoError"
    }
}
