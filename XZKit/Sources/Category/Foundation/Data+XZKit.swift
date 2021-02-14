//
//  Data.swift
//  XZKit
//
//  Created by Xezun on 2018/2/8.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

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




