//
//  XZKit+HexEncoding.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation

extension Data {
    
    /// 返回数据的十六进制字符串形式，默认小写字母。
    public var hexEncodedString: String {
        return hexEncodedString(with: .lowercase)
    }
    
    /// 按指定大小写，返回数据的十六进制字符串形式。
    ///
    /// - Parameter characterCase: 字符大小写方式。
    /// - Returns: 十六进制的字符串。
    public func hexEncodedString(with characterCase: XZCharacterCase) -> String {
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

extension String {
    
    /// 将二进制数据，以十六进制编码的形式转换为字符串。
    /// - Parameters:
    ///   - data: 二进制数据
    ///   - characterCase: 十六进制字符的大小写
    public init(_ data: Data, hexEncoding characterCase: XZCharacterCase) {
        self = data.hexEncodedString(with: characterCase);
    }
    
    /// 将当前字符串进行十六进制编码。
    /// - Parameters:
    ///   - characterCase: 十六进制字符的大小写，默认小写
    ///   - encoding: 当前字符串的编码格式，默认 utf8
    /// - Returns: 十六进制编码的字符串
    public func addingHexEncoding(with characterCase: XZCharacterCase, using encoding: Encoding = .utf8) -> String? {
        return self.data(using: encoding)?.hexEncodedString(with: characterCase)
    }
    
    /// 将当前字符串进行十六进制编码，小写字母。
    /// - Parameter encoding: 当前字符串的编码格式，默认 utf8
    /// - Returns: 十六进制编码的字符串
    public func addingHexEncoding(using encoding: Encoding) -> String? {
        return self.addingHexEncoding(with: .lowercase, using: encoding)
    }
    
    /// 当前字符串的十六进制编码，小写字母。
    public var addingHexEncoding: String? {
        return self.addingHexEncoding(with: .lowercase)
    }
    
    /// 对当前（十六进制编码的）字符串执行解码，并使用指定编码格式还原字符串。
    /// - Parameter encoding: 原始字符串使用的字符编码
    /// - Returns: 原始字符串
    public func removingHexEncoding(using encoding: Encoding) -> String? {
        guard let data = Data.init(hexEncoded: self) else { return nil }
        return String.init(data: data, encoding: .utf8)
    }
    
    /// 将当前（十六进制编码的）字符串执行解码，并用 .utf8 编码还原字符串。
    public var removingHexEncoding: String? {
        return self.removingHexEncoding(using: .utf8)
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
