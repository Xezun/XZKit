# XZKit/DataCryptor

针对 iOS 系统库 CommonCrypto/CommonCryptor 的二次封装，使其面向对象，更易使用。

## 特性

- 面向对象的接口，更易使用。
- 针对 Swift 优化的命名方式，在 Swift 中更自然。
- 同时提供快速便利方法和示例方法，轻松应对大、小数据的加密。

## 示例

1. 小型数据使用便利方法进行加密／解密。

```swift
// AES 加密
let data1 = "XZKit".data(using: .utf8)!
if let enData = try? DataCryptor.AES(data1, operation: .encrypt, key: "XZKit", vector: "XZKit") {
    print(enData.base64EncodedString())
    // 输出：rUYzP3YxACtDFWR0XrP1xQ==
}

// AES 解密
let data2 = Data.init(base64Encoded: "rUYzP3YxACtDFWR0XrP1xQ==")!
if let deData = try? DataCryptor.AES(data2, operation: .decrypt, key: "XZKit", vector: "XZKit") {
    print(String.init(data: deData, encoding: .utf8)!)
    // 输出：XZKit
}

// 不常用加密算法可使用此方法。
let result = try? DataCryptor.crypt(someData, algorithm: .CAST("aKey"), operation: .decrypt, mode: .CBC("aVector"), padding: .PKCS7)
```

2. 大型数据使用实例化对象进行加密／解密。

```
// 创建对象
let dataCryptor = DataCryptor.init(...)
// 创建接收数据的对象
var dataResult = Data()
// 分段读取大数据并计算，并将结果数据添加到 dataResult 中
dataCryptor.crypt(data, final: false)
// 所有数据读取完成后，改变最后一个参数，并再次调用上面的方法获取最后的数据。
```

