# XZKit

[![CI Status](https://img.shields.io/badge/build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZKit)
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

执行命令的过程中，会编译 Swift 宏插件，需要的时间可能比较长，请保持网络通畅。

## 组件 Components

### [XZDefines](./Docs/XZDefines) 

开发中常用的宏、定义、函数。

### [XZExtensions](./Docs/XZExtensions) 

拓展与增强原生的 UIKit、Foundation 框架。

### [XZMocoa](./Docs/XZMocoa) 
    
一款轻量级的 MVVM 开发框架，降低组件化的改造成本。

### [XZML](./Docs/XZML) 

一款轻量级的富文本标记语言，以满足业务中，需要下发轻量级的富文本的需求。

### [XZObjc](./Docs/XZObjc) 

对 runtime 底层元数据的二次封装，方便直接取用。

### [XZJSON](./Docs/XZJSON) 

一款高性能的“数据-模型”转换工具。

### [XZRefresh](./Docs/XZRefresh) 

一款按 UIScrollView 自然滚动打造的最流畅下拉刷新组件，且支持自定义任意下拉刷新样式。

### [XZPageView](./Docs/XZPageView) 

一款支持水平、垂直翻页的分页管理组件。

### [XZPageControl](./Docs/XZPageControl)

一款类似`UIPageControl`的翻页控制组件，支持自定义指示器样式。

### [XZSegmentedControl](./Docs/XZSegmentedControl) 

一款支持水平、垂直布局、可滚动的分段控制组件，支持自定义元素视图，支持定义指示器，方便各种类型的菜单视图。

### [XZGeometry](./Docs/XZGeometry) 

操作 CGRect 等几何结构体的便利函数拓展。

### [XZTextImageView](./Docs/XZTextImageView)

一款图片文字组合的简单控件，可自定义文字与图片的位置关系。

### [XZContentStatus](./Docs/XZContentStatus) 

一款呈现页面状态的组件，比如数据为空、网络错误等。

### [XZToast](./Docs/XZToast) 

一款可高度自定义的即时提醒组件，支持数量控制，使用列队展示避免重叠。

### [XZURLQuery](./Docs/XZURLQuery) 

一款用来处理 URL 参数处理的工具类，以避免实际开发中处理 URL 的低级错误。

### [XZLocale](./Docs/XZLocale) 

一款支持使用数字插值的本地化字符串处理方案，以便与其它平台保持一致，降低维护成本。

### [XZCollectionViewFlowLayout](./Docs/XZCollectionViewFlowLayout) 

一款支持多种对齐方式的 UICollectionView 流布局实现方案。

### [XZNavigationController](./Docs/XZNavigationController) 

一款支持定义导航栏、全屏手势导航的增强组件。

### [XZDataCryptor](./Docs/XZDataCryptor) 

一款对原生 CommonCrypto 对称加密工具二次封装的组件。

### [XZDataDigester](./Docs/XZDataDigester) 

一款对原生 CommonCrypto 数据摘要工具二次封装的组件。

### [XZKeychain](./Docs/XZKeychain) 

一款对原生 KeychainAccess 钥匙串访问工具二次封装的组件。

## 联系作者 Contacts

[xezun@icloud.com](mailto://xezun@icloud.com)

## License

XZKit is available under the MIT license. See the LICENSE file for more info.
