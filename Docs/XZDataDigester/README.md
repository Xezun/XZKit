# XZDataDigester

## Example

To run the example project, clone the repo, and run `pod install` from the Pods directory first.


## Installation

XZDataDigester is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZDataDigester'
```

## 功能特性

支持 md2、md4、md5、sha1、sha224、sha256、sha384、sha512 摘要算法。

> 安全提示：md2、md4、md5 已不具备抗碰撞性，sha1 也已不推荐用于安全场景，它们仅适用于兼容历史数据的完整性校验；安全场景请选用 SHA-2 系列（sha224/sha256/sha384/sha512）。

> 错误处理：计算接口失败时返回 NO/nil，并通过 `error` 出参返回 `XZDataDigesterErrorDomain` 域的错误（EINVAL：非法参数或算法；ENOMEM：内存分配失败；ENOTSUP：不支持的时序操作，如 `-final` 之后未 `-reset` 就继续喂入数据）；Swift 侧导入为 `throws`。自 5.0 起枚举值、错误处理方式等存在破坏性变更，升级时请注意。

```swift
let md5 = try XZDataDigester.digest(data, algorithm: .MD5, hexEncoding: .uppercase)
let sha1 = try XZDataDigester.digest(data, algorithm: .SHA1, hexEncoding: .uppercase)
let sha256 = try XZDataDigester.digest(data, algorithm: .SHA256, hexEncoding: .uppercase)

// 对于 md5 或 sha1 有更简便的拓展方法
let md5 = string.md5
let sha1 = string.sha1
```

支持多数据合并计算摘要。

```swift
let digester = XZDataDigester(.MD5)!

let array = ["1", "2", "3"]
for item in array {
    try digester.digest(item)
}
let result = try digester.final()

let md5 = (result as NSData).hexEncodedString(.lowercase)
```

可以用来计算大文件的摘要。

```swift
let digester = XZDataDigester(.MD5)!

let file = ...
while !file.EOF {
    let data = file.read() // 每次读取一小部分数据，避免占用太多内存
    try digester.digest(data)
}
let result = try digester.final()

let md5 = (result as NSData).hexEncodedString(.lowercase)
```

## Author

Xezun, developer@xezun.com

## License

XZDataDigester is available under the MIT license. See the LICENSE file for more info.
