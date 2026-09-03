# XZKit

XZKit 是一套面向 iOS 的模块化开发工具库，涵盖 MVVM 框架、UI 组件、数据处理、安全加密与基础扩展等能力。各组件相互独立、可按需引入，帮助开发者快速构建高质量应用。

![Version](https://img.shields.io/badge/Version-4.0.0-blue.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![iOS](https://img.shields.io/badge/iOS-15.0-red.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)

## 环境需求 Requirements

iOS 15.0, Swift 5.9, Xcode 16.0.

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

### 开发框架 Frameworks

- [![XZMocoa](https://img.shields.io/badge/XZ-Mocoa-blue.svg)](./Docs/XZMocoa) 一款轻量级的 MVVM 开发框架，降低组件化的改造成本。

### UI 组件 UI Components

- [![XZRefresh](https://img.shields.io/badge/XZ-Refresh-blue.svg)](./Docs/XZRefresh) 一款按 UIScrollView 自然滚动打造的最流畅下拉刷新组件，且支持自定义任意下拉刷新样式。
- [![XZToast](https://img.shields.io/badge/XZ-Toast-blue.svg)](./Docs/XZToast) 一款基于队列机制的消息组件，支持数量控制、视图自定义与复用的高性能组件。
- [![XZPageView](https://img.shields.io/badge/XZ-PageView-blue.svg)](./Docs/XZPageView) 一款支持水平、垂直翻页的分页管理组件。
- [![XZPageControl](https://img.shields.io/badge/XZ-PageControl-blue.svg)](./Docs/XZPageControl) 一款类似 `UIPageControl` 的翻页控制组件，支持自定义指示器样式。
- [![XZSegmentedControl](https://img.shields.io/badge/XZ-SegmentedControl-blue.svg)](./Docs/XZSegmentedControl) 一款支持水平、垂直布局、可滚动的分段控制组件，支持自定义元素视图与指示器，方便构建各种类型的菜单视图。
- [![XZProgressView](https://img.shields.io/badge/XZ-ProgressView-blue.svg)](./Docs/XZProgressView) 一款可自定义样式的进度视图组件。
- [![XZTextImageView](https://img.shields.io/badge/XZ-TextImageView-blue.svg)](./Docs/XZTextImageView) 一款图片文字组合的简单控件，可自定义文字与图片的位置关系。
- [![XZContentStatus](https://img.shields.io/badge/XZ-ContentStatus-blue.svg)](./Docs/XZContentStatus) 一款呈现页面状态的组件，比如数据为空、网络错误等。
- [![XZCollectionViewFlowLayout](https://img.shields.io/badge/XZ-CollectionViewFlowLayout-blue.svg)](./Docs/XZCollectionViewFlowLayout) 一款支持多种对齐方式的 UICollectionView 流布局实现方案。
- [![XZNavigationController](https://img.shields.io/badge/XZ-NavigationController-blue.svg)](./Docs/XZNavigationController) 一款支持自定义导航栏、全屏手势导航的增强组件。
- [![XZImage](https://img.shields.io/badge/XZ-Image-blue.svg)](./Sources/ObjC/XZImage) 一款支持边框、圆角、箭头、虚线等样式的图片绘制组件，可用于生成气泡、提示框等装饰性图片。

### 数据处理 Data Processing

- [![XZJSON](https://img.shields.io/badge/XZ-JSON-blue.svg)](./Docs/XZJSON) 一款高性能的“数据-模型”转换工具。
- [![XZML](https://img.shields.io/badge/XZ-ML-blue.svg)](./Docs/XZML) 一款轻量级的富文本标记语言，以满足业务中需要下发轻量级富文本的需求。
- [![XZURL](https://img.shields.io/badge/XZ-URLQuery-blue.svg)](./Docs/XZURL) 一款用来处理 URL 参数的工具类，以避免实际开发中处理 URL 的低级错误。
- [![XZLocale](https://img.shields.io/badge/XZ-Locale-blue.svg)](./Docs/XZLocale) 一款支持使用数字插值的本地化字符串处理方案，以便与其它平台保持一致，降低维护成本。

### 安全与隐私 Security & Privacy

- [![XZDataCryptor](https://img.shields.io/badge/XZ-DataCryptor-blue.svg)](./Docs/XZDataCryptor) 一款对原生 CommonCrypto 对称加密工具二次封装的组件。
- [![XZDataDigester](https://img.shields.io/badge/XZ-DataDigester-blue.svg)](./Docs/XZDataDigester) 一款对原生 CommonCrypto 数据摘要工具二次封装的组件。
- [![XZKeychain](https://img.shields.io/badge/XZ-Keychain-blue.svg)](./Docs/XZKeychain) 一款对原生 KeychainAccess 钥匙串访问工具二次封装的组件。

### 基础工具 Foundation & Tools

- [![XZLog](https://img.shields.io/badge/XZ-Log-blue.svg)](./Docs/XZLog) 一款便捷的日志工具，支持 Swift 宏与 Objective-C 的格式化日志输出。
- [![XZDefines](https://img.shields.io/badge/XZ-Defines-blue.svg)](./Docs/XZDefines) 开发中常用的宏、定义、函数。
- [![XZExtensions](https://img.shields.io/badge/XZ-Extensions-blue.svg)](./Docs/XZExtensions) 拓展与增强原生的 UIKit、Foundation 框架。
- [![XZObjc](https://img.shields.io/badge/XZ-Objc-blue.svg)](./Docs/XZObjc) 对 runtime 底层元数据的二次封装，方便直接取用。
- [![XZGeometry](https://img.shields.io/badge/XZ-Geometry-blue.svg)](./Docs/XZGeometry) 操作 CGRect 等几何结构体的便利函数拓展。
- [![XZTicker](https://img.shields.io/badge/XZ-Ticker-blue.svg)](./Sources/Swift/XZTicker) 一款基于 DispatchSourceTimer 的计时器组件，提供累计计时能力，遵循 XZTickable 协议即可为任意对象添加计时功能。

## 联系作者 Contacts

[xezun@icloud.com](mailto://xezun@icloud.com)

## License

XZKit is available under the Apache 2.0 license. See the LICENSE file for more info.
