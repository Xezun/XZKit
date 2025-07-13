# XZKit

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZKit)
[![Version](https://img.shields.io/cocoapods/v/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)
[![License](https://img.shields.io/cocoapods/l/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)
[![Platform](https://img.shields.io/cocoapods/p/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)
[![SwiftPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://www.swift.org/package-manager)

## 环境需求 Requirements

iOS 13.0, Swift 6.0, Xcode 16.0.

## 安装集成 Installation

- 使用 Swift Package Manager 集成

`Xcode` -> `File` -> `Add Package Dependencies...` -> `Search or Enter Package URL`

```url
https://github.com/Xezun/XZKit.git
```

- 使用 [CocoaPods](http://cocoapods.org) 集成

```ruby
pod "XZKit"
```

## 组件 Components

### [XZMocoa](./Docs/XZMocoa.md) 

An MVVM library for Cocoa.

基于原生风格的轻量级 MVVM 开发框架。

```swift
import XZKit

@objc
class Model: NSObject {

    var isVIP = false
    var firstName: String?
    var lastName: String?
    var profile: String?

}

@mocoa
class View: UIView, XZMocoaView {

    @bind(.name)
    @bind(v: .textColor)
    var textLabel: UILabel!
    
    @bind(.detailText)
    var detailLabel: UILabel!
    
}

@mocoa
class ViewModel: XZMocoaViewModel {
    
    @key
    var name: String?
    
    @key(value: UIColor.black)
    var textColor: UIColor
    
    @key
    @bind("profile")
    var detailText: String?
    
    @bind
    func setName(firstName: String?, lastName: String?) {
        if let firstName = firstName {
            if let lastName = lastName {
                name = "\(firstName)·\(lastName)"
            } else {
                name = firstName
            }
        } else if let lastName = lastName {
            name = lastName
        } else {
            name = "Visitor"
        }
    }
    
    @bind
    func setTextColor(isVip: Bool) {
        textColor = isVip ? .red : .black
    }
    
}
```

### [XZDefines](./Docs/XZDefines.md) 

开发中常用的宏、定义、函数。

### [XZExtensions](./Docs/XZExtensions.md) 

原生框架UIKit、Foundation的拓展与增强

### [XZML](./Docs/XZML.md) 

富文本标记语言

### [XZObjcDescriptor](./Docs/XZObjcDescriptor.md) 

方便直观的获取 ObjectiveC 的数据类型、类、方法、属性、实例变量等元数据的描述信息。

### [XZJSON](./Docs/XZJSON.md) 

一款简洁、高效、拓展自定义性强的“数据-模型”转换工具类。

### [XZRefresh](./Docs/XZRefresh.md) 

最流畅的下拉刷新组件

### [XZPageView](./Docs/XZPageView.md) 

多页管理组件

### [XZPageControl](./Docs/XZPageControl.md)

翻页控制组件

### [XZSegmentedControl](./Docs/XZSegmentedControl.md) 

分段控制组件

### [XZGeometry](./Docs/XZGeometry.md) 

拓展的几何定义

### [XZTextImageView](./Docs/XZTextImageView)

展示图片和文字的组件

### [XZContentStatus](./Docs/XZContentStatus.md) 

内容状态呈现组件

### [XZToast](./Docs/XZToast.md) 

即时消息提示组件

### [XZURLQuery](./Docs/XZURLQuery.md) 

链接参数处理

### [XZLocale](./Docs/XZLocale.md) 

应用本地化支持

### [XZCollectionViewFlowLayout](./Docs/XZCollectionViewFlowLayout.md) 

支持多种对齐方式的 UICollectionView 流布局

### [XZNavigationController](./Docs/XZNavigationController.md) 

全屏手势导航、手势返回、自定义导航条

### [XZDataCryptor](./Docs/XZDataCryptor.md) 

对称加密

### [XZDataDigester](./Docs/XZDataDigester.md) 

数据摘要

### [XZKeychain](./Docs/XZKeychain.md) 

钥匙串访问

## 联系作者 Contacts

[xezun@icloud.com](mailto://xezun@icloud.com)

## License

XZKit is available under the MIT license. See the LICENSE file for more info.
