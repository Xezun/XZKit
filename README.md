# XZKit

[![Build](https://img.shields.io/badge/build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZKit)
[![Version](https://img.shields.io/badge/Version-4.2.8-blue.svg?style=flat)](http://cocoapods.org/pods/XZKit)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](http://cocoapods.org/pods/XZKit)
[![Platform](https://img.shields.io/badge/Platform-iOS-yellow.svg)](http://cocoapods.org/pods/XZKit)

## 环境需求

iOS 8.0, Swift 5.0, Xcode 10.0.

## 安装集成

推荐使用 [CocoaPods](http://cocoapods.org) 快速集成到项目中。

```ruby
use_frameworks!

pod "XZKit"
```

只使用其中某一个子模块，如只使用 CarouselView 模块。

```ruby
use_frameworks!

pod "XZKit/CarouselView"
```

*需要 CocoaPods 1.7.2 版本以上，请使用  `sudo gem install cocoapods` 命令更新 CocoaPods 版本。*

## 组件

### [轮播视图：CarouselView](./Documentation/CarouselView)

使用三图轮播机制设计的 `XZCarouselView` 控件，并且默认提供了无限轮播、自动轮播、手势缩放等功能；提供了获取轮播图滚动进度的接口，更方便做关联的渐变动画。
并且默认实现了图片轮播的控件 `XZImageCarouselView` 和类似微信朋友圈的大图查看的控件 `XZImageViewer` ，方便开发者直接使用。

<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/1.gif" alt="XZKit.CarouselView" width="240"></img>
<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/2.gif" alt="XZKit.CarouselView" width="240"></img>
<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/CarouselView/3.gif" alt="XZKit.CarouselView" width="240"></img>

### [自定义流布局：XZKit.UICollectionViewFlowLayout](./Documentation/UICollectionViewFlowLayout)

支持功能：水平滚动、垂直滚动、行对齐方式、垂直对齐方式、自适语言的应布局方向。

<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/UICollectionViewFlowLayout/UICollectionViewFlowLayout.gif" alt="XZKit.UICollectionViewFlowLayout" width="240"></img>
  

### [App 语言：AppLanguage](./Documentation/AppLanguage)

提供了更直观的设置 App 语言的接口，且支持应用内语言切换。

<img src="https://github.com/mlibai/static-resources/blob/master/XZKit/Documentation/AppLanguage/1.gif" alt="XZKit.AppLanguage" width="240"></img>

### [网络层协议：Networking](./Documentation/Networking)

  框架  `XZKit/Networking` 是一个轻量级网络框架，通过一套协议实现了多种常见的网络请求需求：
  - 请求的并发策略、优先级的控制，可以轻松控制请求的顺序，请求与其它请求之间的关系。
  - 请求失败时自动重试，且支持重试前延时。
  - 请求时间限制，与 HTTP 超时不相同，可以控制请求的总时长。
  - 当控制器销毁时，自动取消仍在进行的请求（控制器为请求的所有者时）。

### [进度条：ProgressView](./Documentation/ProgressView)

支持任意弧度的圆形进度条和任意角度的直线形进度条。

### [计时器：DisplayTimer](./Documentation/DisplayTimer)

使用 CADisplayLink 实现的计时器。

### [控制重定向：AppRedirection](./Documentation/AppRedirection)

提供了一套控制器消息传播机制，通过消息控制页面跳转。

### [缓存管理：CacheManager](./Documentation/CacheManager)

目前该模块只是提供将数据缓存到沙盒 Caches 目录的功能，更多的缓存机制有待开发。

### [内容状态：ContentStatus](./Documentation/ContentStatus)

方便的设置视图在内容为空，内容错误等状态时的提示视图。

### [数据加密：DataCryptor](./Documentation/DataCryptor)

对原生框架 <CommonCrypto/CommonCryptor.h> 的二次封装，支持 AES、DES、3DES、CAST、RC4、RC2、Blowfish 等算法的对称加密解密。

### [数据摘要：DataDigester](./Documentation/DataDigester)

对原生框架 <CommonCrypto/CommonDigest.h> 的二次封装，支持 MD2、MD4、MD5、SHA1、SHA224、SHA256、SHA384、SHA512 等数据摘要算法。

### [公共部分：Foundation](./Documentation/Foundation)

原生框架 Foundation 的拓展。

### [自定义导航条、全屏手势导航控制器：NavigationController](./Documentation/NavigationController)

### [文本图片视图：TextImageView](./Documentation/TextImageView)


### [公共部分：UIKit](./Documentation/UIKit)

### [公共部分：XZKitConstants](./Documentation/XZKitConstants)

## 示例代码

所有组件都有单独的[示例代码](./Projects/Example)，下载到本地后，代码运行前需在 Pod 目录执行 `pod update` 安装相关依赖。

## 更新日志

- 2020.05.10

解决了在 Objective-C 中使用 BOOL 类型作为枚举值，无法桥接为 Swift 类型，而导致无法编译的问题。

- 2019.04.28

  优化 Git 仓库体积，删除了所有历史提交记录及旧版本，删除体积较大的资源图片，效果图片分离到单独的 static-resources 仓库，尽量保持本仓库较小，减少 Cocoapods 拉取本库的用时。

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

[mlibai@163.com](mailto://mlibai@163.com)

## License

XZKit is available under the MIT license. See the LICENSE file for more info.
