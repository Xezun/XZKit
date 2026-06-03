# XZDataDigester

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZDataDigester)
[![Version](https://img.shields.io/cocoapods/v/XZDataDigester.svg?style=flat)](https://cocoapods.org/pods/XZDataDigester)
[![License](https://img.shields.io/cocoapods/l/XZDataDigester.svg?style=flat)](https://cocoapods.org/pods/XZDataDigester)
[![Platform](https://img.shields.io/cocoapods/p/XZDataDigester.svg?style=flat)](https://cocoapods.org/pods/XZDataDigester)

## Example

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## Requirements

iOS 11.0, Xcode 14.0

## Installation

XZDataDigester is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZDataDigester'
```

## 功能特性

支持 md2、md4、md5、sha1、sha224、sha256、sha384、sha512 摘要算法。

```swift
let md5 = XZDataDigester.digest(data, algorithm: .MD5, hexEncoding: .uppercase)
let sha1 = XZDataDigester.digest(data, algorithm: .SHA1, hexEncoding: .uppercase)
let sha256 = XZDataDigester.digest(data, algorithm: .SHA256, hexEncoding: .uppercase)

// 对于 md5 或 sha1 有更简便的拓展方法
let md5 = string.md5
let sha1 = string.sha1
```

支持多数据合并计算摘要。

```swift
let digester = XZDataDigester.init(.MD5);

let array = ["1", "2", "3"]
for item in array {
    digester.add(item)
}
let result = digester.digest() as NSData

let md5 = result.hexEncodedString
```

可以用来计算大文件的摘要。

```swift
let digester = XZDataDigester.init(.MD5);

let file = ...
while !file.EOF {
    let data = file.read() // 每次读取一小部分数据，避免占用太多内存
    digester.add(data)
}
let result = digester.digest() as NSData

let md5 = result.hexEncodedString
```

## Author

Xezun, developer@xezun.com

## License

XZDataDigester is available under the MIT license. See the LICENSE file for more info.
