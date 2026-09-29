# XZDataCryptor

基于原生 CommonCrypto 框架进行的二次封装，将 AES、DES、CAST 等对称加密函数，封装成易于使用的面向对象的版本。

## Example

在示例项目中，提供了完整的使用示例，也可用来体验 XZDataCryptor 提供的对称加密功能。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

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
// 密钥/向量支持三种编码形式，对应三组构造方法与属性：
//   Data            -> AES(key:vector:)
//   十六进制字符串  -> AES(hexEncodingKey:vector:)
//   Base64 字符串   -> AES(base64EncodingKey:vector:)
let algorithm = XZDataCryptor.Algorithm.AES(key: keyData, vector: vectorData)
let hexAlgorithm = XZDataCryptor.Algorithm.AES(hexEncodingKey: "0123...", vector: "fedcba...")
let base64Algorithm = XZDataCryptor.Algorithm.AES(base64EncodingKey: "ASNFZ4mr...", vector: "CN26f4mr...")
```

2. AES/DES 加密

```swift
// 默认使用 CBC 模式、PKCS7 填充
let result = try? XZDataCryptor.AES(data, operation: .encrypt, key: keyData, vector: vectorData)
let result = try? XZDataCryptor.DES(data, operation: .decrypt, key: keyData, vector: vectorData)
// 使用 ECB 模式
let result = try? XZDataCryptor.AES(data, operation: .encrypt, key: keyData, vector: nil, mode: .ECB, padding: .PKCS7)
let result = try? XZDataCryptor.DES(data, operation: .decrypt, key: keyData, vector: nil, mode: .ECB, padding: .PKCS7)
```

3. 其它加密算法

```swift
let result = try? XZDataCryptor.encrypt(data, algorithm: .CAST(key: keyData, vector: vectorData), mode: .CBC, padding: .PKCS7)
let result = try? XZDataCryptor.decrypt(data, algorithm: .CAST(key: keyData, vector: vectorData), mode: .CBC, padding: .PKCS7)
```

4. 分段加密

```swift
let datas: [Data] // 分段的数据

let algorithm = XZDataCryptor.Algorithm.AES(key: keyData, vector: vectorData) // 这里可以是其他算法

var result = Data()
do {
    // 密钥与向量的长度由 Algorithm 保证合法，这里只可能是内存不足或算法与模式的组合不受支持
    let cryptor = try XZDataCryptor(algorithm: algorithm, operation: .encrypt, mode: .CBC, padding: .PKCS7)
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

## 密钥与初始化向量

`XZDataCryptor.Algorithm` 负责保证 **任何输入都能得到合法的密钥与初始化向量**：

- 密钥与向量支持三种编码形式输入：`Data`、十六进制字符串（`hexEncodingKey`/`hexEncodingVector`）、Base64 字符串（`base64EncodingKey`/`base64EncodingVector`），每个算法都有对应的构造方法；非法的 hex/Base64 字符串按 `nil` 处理；
- 长度以 **UTF-8 字节数** 为准，而非 `NSString` 的字符数，因此中文、Emoji 等多字节字符作为密钥同样有效；
- 过长按字节截断（可能切断多字节字符），不足则在末尾补 `\0`；
- 传入 `nil` 或空串也是合法的，会得到一把全 `\0` 的密钥（向量同理）。

因此 `XZDataCryptor` 不会因密钥、向量的长度问题而构造失败，只可能因内存不足或算法与模式的组合不受支持而报错。例如 `XZDataCryptorMode.RC4` 仅供 RC4 算法使用，其他算法搭配该模式时会被视为 ECB 模式处理。

一次性便利方法（`encrypt:algorithm:mode:padding:`、`AES:operation:key:vector:mode:padding:`、`DES:…` 等）基于 `CCCrypt`，**只支持 ECB、CBC（noPadding/PKCS7Padding）、RC4 模式**；传入 CFB/CTR/OFB/CFB8 会返回 `kCCUnimplemented` 错误而不是静默降级，这些模式请使用 `XZDataCryptor` 实例进行流式加解密。

`reset(key:vector:)` 会重建上下文，新的密钥与初始化向量都会生效（CommonCrypto 的 `CCCryptorReset` 无法更换密钥），尚未凑满一块而被缓冲的数据会被丢弃。

加解密出错时，`NSError` 的 domain 为 `XZDataCryptorErrorDomain`，`code` 为 CommonCrypto 的 `CCCryptorStatus` 值。

## 测试

单元测试位于 `Example/ExampleTests/XZDataCryptor/XZDataCryptorTests.m`，覆盖密钥/向量规范化、各算法与模式的构造、分块与一次性加密的一致性、重置语义与错误域。

## Author

Xezun, developer@xezun.com

## License

XZDataCryptor is available under the MIT license. See the LICENSE file for more info.
