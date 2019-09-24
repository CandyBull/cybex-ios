//
//  JWA.swift
//  CandyBull
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import Foundation

struct JWA {
    enum Algorithm: String, Decodable {

        case RS256
        case RS384
        case RS512

        case ES256
        case ES384
        case ES512

        var algorithm: CryptoAlgorithm {
            switch self {
            case .RS256: return RSA.Algorithm.sha256
            case .RS384: return RSA.Algorithm.sha384
            case .RS512: return RSA.Algorithm.sha512

            case .ES256: return ECDSA.Algorithm.sha256
            case .ES384: return ECDSA.Algorithm.sha384
            case .ES512: return ECDSA.Algorithm.sha512
            }
        }
    }
}

extension JWA {
    // A wrapper (container) for parameters for a certain key type.
    // If we need to support other types of signing key, we should add it here.
    enum KeyParameters: Decodable {

        enum CodingKeys: String, CodingKey {
            case keyType = "kty"
        }

        case rsa(RSAParameters)
        case ec(ECDSAParameters)

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let keyType = try container.decode(JWK.KeyType.self, forKey: .keyType)
            switch keyType {
            case .rsa:
                self = .rsa(try RSAParameters(from: decoder))
            case .ec:
                self = .ec(try ECDSAParameters(from: decoder))
            }
        }

        var asRSA: RSAParameters? {
            if case .rsa(let parameters) = self { return parameters }
            return nil
        }

        var asEC: ECDSAParameters? {
            if case .ec(let parameters) = self { return parameters }
            return nil
        }
    }
}

extension JWA {

    struct RSAParameters: Decodable {

        enum Algorithm: String, Decodable {
            case RS256
            case RS384
            case RS512
        }

        let modulus: String
        let exponent: String
        let algorithm: Algorithm

        enum CodingKeys: String, CodingKey {
            case modulus = "n"
            case exponent = "e"
            case algorithm = "alg"
        }

        // Get public key DER data from modulus and exponent.
        // It follows the ASN.1 encoding to create data under distinguished encoding rules.
        func getKeyData() throws -> Data {

            guard let decodedModulusData = modulus.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: modulus))
            }
            guard let decodedExponentData = exponent.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: exponent))
            }

            var modulusBytes = [UInt8](decodedModulusData)

            // Make sure the modulusBytes starts with 0x00. If not, append it.
            if let firstByte = modulusBytes.first, firstByte != 0x00 {
                modulusBytes.insert(0x00, at: 0)
            }

            let modulusEncoded = modulusBytes.encode(as: .integer)

            let exponentBytes = [UInt8](decodedExponentData)
            let exponentEncoded = exponentBytes.encode(as: .integer)

            let sequenceEncoded = (modulusEncoded + exponentEncoded).encode(as: .sequence)

            return Data(sequenceEncoded)
        }
    }
}

extension JWA {
    // RFC 5349 https://tools.ietf.org/html/rfc5349
    // X.509 SPKI
    struct ECDSAParameters: Decodable {

        let x: String
        let y: String
        let curve: ECDSA.Curve

        enum CodingKeys: String, CodingKey {
            case x, y, curve = "crv"
        }

        func getKeyData() throws -> Data {
            guard let decodedXData = x.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: x))
            }
            guard let decodedYData = y.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: y))
            }


            // Make sure X and Y Coordinate not started with 0x00. Some SSL implementation would append 0x00 when to
            // prevent a big number to be recognized as minus. However, SecKey would expect a non-0x00 started value.
            // https://stackoverflow.com/questions/4407779/biginteger-to-byte
            let xBytes: [UInt8]
            if decodedXData.count == curve.coordinateOctetLength {
                xBytes = [UInt8](decodedXData)
            } else {
                xBytes = [UInt8](decodedXData).dropFirst { $0 == 0x00 }
            }

            let yBytes: [UInt8]
            if decodedYData.count == curve.coordinateOctetLength {
                yBytes = [UInt8](decodedYData)
            } else {
                yBytes = [UInt8](decodedYData).dropFirst { $0 == 0x00 }
            }

            let uncompressedIndicator: [UInt8] = [ASN1Type.uncompressIndicator.byte]

            return Data(uncompressedIndicator + xBytes + yBytes)
        }
    }
}

// MARK: Array Extension for Encoding
// Inspired by: https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
extension Array where Element == UInt8 {

    func encode(as type: ASN1Type) -> [UInt8] {
        var tlvTriplet: [UInt8] = []
        tlvTriplet.append(type.byte)
        tlvTriplet.append(contentsOf: lengthField(of: self))
        tlvTriplet.append(contentsOf: self)

        return tlvTriplet
    }

}

extension Array where Element: Equatable {
    /// Returns an array containing all but the first element, if `condition` meets. Otherwise, returns self.
    ///
    /// - Parameter condition: The condition to check when try to drop the first element.
    /// - Returns: The array without the first element if `condition` returns `true`; self otherwise.
    func dropFirst(_ condition: (Element) -> Bool) -> Array {
        if count == 0 { return self }
        if condition(self[startIndex]) {
            return Array(dropFirst())
        }
        return self
    }
}

// MARK: Freestanding Helper Function
private func lengthField(of valueField: [UInt8]) -> [UInt8] {
    var count = valueField.count

    if count < 128 {
        return [ UInt8(count) ]
    }

    // The number of bytes needed to encode count.

    let k = log2(Double(count))
    let lengthBytesCount = Int(k / 8 + 1)

    // The first byte in the length field encoding the number of remaining bytes.
    let firstLengthFieldByte = UInt8(128 + lengthBytesCount)

    var lengthField: [UInt8] = []
    for _ in 0..<lengthBytesCount {
        // Take the last 8 bits of count.
        let lengthByte = UInt8(count & 0xff)
        // Add them to the length field.
        lengthField.insert(lengthByte, at: 0)
        // Delete the last 8 bits of count.
        count = count >> 8
    }

    // Include the first byte.
    lengthField.insert(firstLengthFieldByte, at: 0)

    return lengthField
}
