# XZDataCryptor

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZDataCryptor)
[![Version](https://img.shields.io/cocoapods/v/XZDataCryptor.svg?style=flat)](https://cocoapods.org/pods/XZDataCryptor)
[![License](https://img.shields.io/cocoapods/l/XZDataCryptor.svg?style=flat)](https://cocoapods.org/pods/XZDataCryptor)
[![Platform](https://img.shields.io/cocoapods/p/XZDataCryptor.svg?style=flat)](https://cocoapods.org/pods/XZDataCryptor)

基于原生 CommonCrypto 框架进行的二次封装，将 AES、DES、CAST 等对称加密函数，封装成易于使用的面向对象的版本。

## Example

在示例项目中，提供了完整的使用示例，也可用来体验 XZDataCryptor 提供的对称加密功能。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZDataCryptor is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZDataCryptor'
```

## 功能特性

XZDataCryptor 使用 OC 编写，但是也为 Swift 进行了 API 命名优化，更易方便使用。

1、支持的加密算法

- AES 根据密钥长度自动使用 AES128/AES192/AES256
- DES
- 3DES
- CAST
- RC2
- RC4
- Blowfish

```swift
let algorithm = XZDataCryptor.Algorithm.AES(key: "key", vector: "vector")
```

2. AES/DES 加密

```swift
// 默认使用 CBC 模式、PKCS7 填充
let result = try? XZDataCryptor.AES(data, operation: .encrypt, key: "key", vector: "vector")
let result = try? XZDataCryptor.DES(data, operation: .decrypt, key: "key", vector: "vector")
// 使用 ECB 模式
let result = try? XZDataCryptor.AES(data, operation: .encrypt, key: "key", vector: nil, mode: .ECB, padding: .PKCS7)
let result = try? XZDataCryptor.DES(data, operation: .decrypt, key: "key", vector: nil, mode: .ECB, padding: .PKCS7)
```

3. 其它加密算法

```swift
let result = try? XZDataCryptor.encrypt(data, algorithm: .CAST(key: "key", vector: "vector"), mode: .CBC, padding: .PKCS7)
let result = try? XZDataCryptor.decrypt(data, algorithm: .CAST(key: "key", vector: "vector"), mode: .CBC, padding: .PKCS7)
```

4. 分段加密

```swift
let datas: [Data] // 分段的数据

let algorithm = XZDataCryptor.Algorithm.AES(key: "key", vector: "vector") // 这里可以是其他算法
let cryptor = XZDataCryptor.init(operation: .encrypt, algorithm: algorithm, mode: .CBC, padding: .PKCS7)

var result = Data()
do {
    for data in datas {
        let tmp = try cryptor.crypt(data) 
        result += tmp
    }
    result += try cryptor.final()
} catch {
    print("Error: \(error)")
}
print("\(result.base64EncodedString())")
```

## Author

Xezun, developer@xezun.com

## License

XZDataCryptor is available under the MIT license. See the LICENSE file for more info.
