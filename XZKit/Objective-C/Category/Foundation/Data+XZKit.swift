//
//  Data.swift
//  XZKit
//
//  Created by Xezun on 2018/2/8.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

extension Data {
    
    /// 返回数据的十六进制字符串形式，默认大写字母。
    public var hexEncodedString: String {
        return hexEncodedString(with: .uppercase)
    }
    
    /// 按指定大小写，返回数据的十六进制字符串形式。
    ///
    /// - Parameter characterCase: 字符大小写方式。
    /// - Returns: 十六进制的字符串。
    public func hexEncodedString(with characterCase: CharacterCase) -> String {
        switch characterCase {
        case .lowercase:
            let Table: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
            return self.reduce(into: String(), { (result, item) in
                result.append(Table[Int(item >> 4)]);
                result.append(Table[Int(item & 0x0f)]);
            });
        default:
            let Table: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
            return self.reduce(into: String(), { (result, item) in
                result.append(Table[Int(item >> 4)]);
                result.append(Table[Int(item & 0x0f)]);
            });
        }
    }
    
    /// 十六进制数字字符串构造 Data 对象。
    /// - Note: 使用 NSData 的构造方法。
    ///
    /// - Parameter string: 十六进制字符串表示的二进制数据。
    public init?(hexEncoded string: String) {
        guard string.count > 2 else {
            return nil
        }
        var bytes = [UInt8]()
        // 遍历的过程中必须能步进两次。
        let maxIndex = string.index(string.endIndex, offsetBy: -2);
        var index = string.startIndex;
        while index <= maxIndex {
            guard let bit1 = UInt8(hexEncoded: string[index]) else {
                break
            }
            index = string.index(after: index);
            guard let bit2 = UInt8(hexEncoded: string[index]) else {
                break
            }
            bytes.append(bit1 * 16 + bit2);
            index = string.index(after: index)
        }
        self.init(bytes)
    }
    
}

extension Data {
    
    /// 加密当前数据。
    public func encrypting(using algorithm: DataCryptor.Algorithm, mode: DataCryptor.Mode, padding: DataCryptor.Padding) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: algorithm, operation: .encrypt, mode: mode, padding: padding)
    }
    
    /// 解密当前的加密数据。
    public func decrypting(using algorithm: DataCryptor.Algorithm, mode: DataCryptor.Mode, padding: DataCryptor.Padding) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: algorithm, operation: .decrypt, mode: mode, padding: padding)
    }
    
    /// 对当前数据进行 AES 加密/解密。
    public func AES(_ operation: DataCryptor.Operation, key: String, mode: DataCryptor.Mode, padding: DataCryptor.Padding) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: .AES(key: key), operation: operation, mode: mode, padding: padding)
    }
    
    /// 对当前数据进行 AES 加密/解密，且使用 CBC、PKCS7 模式。
    public func AES(_ operation: DataCryptor.Operation, key: String, vector: String?) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: .AES(key: key), operation: operation, mode: .CBC(vector: vector), padding: .PKCS7)
    }
    
    /// 对当前数据进行 DES 加密/解密。
    public func DES(_ operation: DataCryptor.Operation, key: String, mode: DataCryptor.Mode, padding: DataCryptor.Padding) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: .DES(key: key), operation: operation, mode: mode, padding: padding)
    }
    
    /// 对当前数据进行 DES 加密/解密，且使用 CBC、PKCS7 模式。
    public func DES(_ operation: DataCryptor.Operation, key: String, vector: String?) throws -> Data {
        return try DataCryptor.crypto(self, algorithm: .DES(key: key), operation: operation, mode: .CBC(vector: vector), padding: .PKCS7)
    }
    
}

extension UInt8 {
    
    /// 将十六进制字符转换成 UInt8 数值（二进制）表示。
    /// - Note: 非十六进制字符返回 nil 。
    ///
    /// - Parameter character: 十六进制字符。
    public init?(hexEncoded character: Character) {
        switch character {
        case "0": self = 0
        case "1": self = 1
        case "2": self = 2
        case "3": self = 3
        case "4": self = 4
        case "5": self = 5
        case "6": self = 6
        case "7": self = 7
        case "8": self = 8
        case "9": self = 9
        case "a": self = 10
        case "b": self = 11
        case "c": self = 12
        case "d": self = 13
        case "e": self = 14
        case "f": self = 15
        case "A": self = 10
        case "B": self = 11
        case "C": self = 12
        case "D": self = 13
        case "E": self = 14
        case "F": self = 15
        default:  return nil
        }
    }
    
}


