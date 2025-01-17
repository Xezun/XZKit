# XZKit

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZKit)
[![Version](https://img.shields.io/cocoapods/v/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)
[![License](https://img.shields.io/cocoapods/l/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)
[![Platform](https://img.shields.io/cocoapods/p/XZKit.svg?style=flat)](https://cocoapods.org/pods/XZKit)

## 环境需求

iOS 12.0, Swift 5.0, Xcode 16.0.

## 安装集成

推荐使用 [CocoaPods](http://cocoapods.org) 快速集成到项目中。

```ruby
pod "XZKit"
```

## 组件

1. [XZDefines - 开发中常用的宏、定义、函数](./Docs/XZDefines) 
1. [XZExtensions - 原生框架UIKit、Foundation的拓展与增强](./Docs/XZExtensions) 
1. [XZMocoa - 基于原生风格的轻量级 MVVM 开发框架](./Docs/XZMocoa) 
1. [XZML - 富文本标记语言](./Docs/XZML) 
1. [XZJSON - 基于 YYModel 的模型转换工具类](./Docs/XZJSON) 
1. [XZRefresh - 最流畅的下拉刷新组件](./Docs/XZRefresh)
1. [XZPageView - 多页管理组件](./Docs/XZPageView)
1. [XZPageControl - 翻页控制组件](./Docs/XZPageControl)
1. [XZSegmentedControl - 分段控制组件](./Docs/XZSegmentedControl)
1. [XZGeometry - 拓展的几何定义](./Docs/XZGeometry)
1. [XZTextImageView - 展示图片和文字的组件](./Docs/XZTextImageView)
1. [XZContentStatus - 内容状态呈现组件](./Docs/XZContentStatus)
1. [XZToast - 即时消息提示组件](./Docs/XZToast)
1. [XZURLQuery - 链接参数处理](./Docs/XZURLQuery)
1. [XZLocale - 应用本地化支持](./Docs/XZLocale)
1. [XZCollectionViewFlowLayout - 支持多种对齐方式的 UICollectionView 流布局](./Docs/XZCollectionViewFlowLayout)
1. [XZNavigationController - 全屏手势导航、手势返回、自定义导航条](./Docs/XZNavigationController)
1. [XZDataCryptor - 对称加密](./Docs/XZDataCryptor)
1. [XZDataDigester - 数据摘要](./Docs/XZDataDigester)
1. [XZKeychain - 钥匙串访问](./Docs/XZKeychain)

## 示例代码

所有组件都有单独的[示例代码](./Example)，下载到本地后，代码运行前需在 Pod 目录执行 `pod update` 安装相关依赖。

## 更新日志

- 2025.01.16

  重构及 Swift Package Manager 支持。

- 2019.04.16

  对  `XZKit/CarouselView` 进行了优化，添加了 `XZCarouselViewController` 方便做多控制器轮播；`XZCarouselView` 重构了重用机制，功能支持使用懒加载机制，未使用缩放、自定义动画功能时，更轻量级；重命名了部分方法名、属性名，统一命名规范。

- 2019.03.18

  轮播图支持全类型的 UIViewContentMode 模式了。

- 2019.03.14

  优化了轮播图、继续优化模块结构。

- 2019.02.27

  为了更方便的引用单个组件，准备重新优化 XZKit 结构，以避免组件间相互依赖关系太多。

- 2019.01.01

  优化了控制器重定向模块和导航控制器模块，解决了控制器重定向模块在执行重定向与控制器转场可能存在的冲突。

- 2018.09.17

  网络框架现在支持限制请求的总时长，避免在弱网情况下，即使设置响应超时，也可能无法有效控制请求时长，而导致的页面长时间处于加载状态。


## 联系作者

[xezun@icloud.com](mailto://xezun@icloud.com)

## License

XZKit is available under the MIT license. See the LICENSE file for more info.
