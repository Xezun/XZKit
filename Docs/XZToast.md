# XZToast

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZToast)
[![Version](https://img.shields.io/cocoapods/v/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![License](https://img.shields.io/cocoapods/l/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![Platform](https://img.shields.io/cocoapods/p/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![SwiftPM](https://img.shields.io/badge/Swift-Package%20Manager-brightgreen.svg)](https://www.swift.org/package-manager)

## 安装

#### 1、使用 Swift Package Manager 集成

`Xcode` -> `File` -> `Add Package Dependencies...` -> `Search or Enter Package URL` 

```txt
https://github.com/Xezun/XZKit.git
```

#### 2、使用 [CocoaPods](http://cocoapods.org) 集成

```ruby
pod "XZToast"
```

## 如何使用

### 1、展示

XZToast 基于控制器展示，所以需要如下代码的执行环境都是在控制器的方法中。

```objc
[self xz_showToast:[XZToast messageToast:@"提示消息"] duration:3.0 position:(XZToastPositionBottom) exclusive:NO completion:^(BOOL finished) {
    // do something
}];
```

方法名针对 Swift 进行了优化，不用写`xz_`前缀，且对于文本类型的提示消息，可以直接通过字符串字面量，比如下面两种写法的作用相同。

```swift
// 使用字面量
showToast("提示消息", duration: 3.0, position: .bottom, exclusive: false) { _ in
    // do something
}

// 使用便利构造方法
showToast(.message("提示消息"), duration: 3.0, position: .bottom, exclusive: false) { _ in
    // do something
}
```

方法参数说明：

- toast: 待展示的 XZToast 对象
- duration: 展示时长，默认 1.0 秒
- position: 展示位置，默认 middle 中间
- exclusive: 是否独占，默认否；独占的提示消息展示时，会阻止展示新的 toast 消息
- completion: 结束展示的回调

### 2、隐藏

隐藏指定提示消息。

```swift
hideToast(toast, completion: {
	// do something  
})
```

方法`hideToast`两个参数都是可选的，如果要隐藏所有提示消息，只需要把`toast`参数传 nil 即可。

此外还可以通过 `showToast` 方法的返回值，执行 `hide` 方法来隐藏指定提示消息。

```swift
let toast = showToast(.message("提示消息"))
toast?.hide({
    // do something
})
```

方法 `showToast` 的返回值，是管理提示消息的`ToastTask`对象，而非参数中`toast`对象。

### 3、效果


- 支持上、中、下位置

```swift
showToast("请稍后", duration: 3.0, position: .top)
showToast("请稍后", duration: 3.0, position: .middle)
showToast("请稍后", duration: 3.0, position: .bottom)
```

<table>
<tr>
<td><img src="https://i-blog.csdnimg.cn/direct/0e492bcfb594418293378748d748d549.png#pic_center" /></td>
<td><img src="https://i-blog.csdnimg.cn/direct/c86ae72071314f76baa35a4a461dc44b.png#pic_center" /></td>
<td><img src="https://i-blog.csdnimg.cn/direct/3bfdef26f7164e7fadfdbcb72f61044a.jpeg#pic_center" /></td>
</tr>
</table>


- 内置多种样式

```swift
showToast(.success("操作成功"))
showToast(.failure("操作失败"))
showToast(.waiting("即将开始"))
showToast(.warning("即将到期"))
showToast(.loading("正在加载"))
showToast(.loading("正在加载", progress: 0.5))

// 准备加载
loadingToast = showToast(.loading("加载中"));
// 加载中，更新进度
do {
    loadingToast?.progress = 0.5
}
// 加载完成
loadingToast?.hide()
```

<table>
	<tr>
		<td><img src="https://i-blog.csdnimg.cn/direct/fc508429bcc0402597734701db47caa8.png#pic_center" width="375" height="667" /></td>
		<td><img src="https://i-blog.csdnimg.cn/direct/9ee70d6edc4a48c3bd9ac5bea9ce4198.png#pic_center" width="375" height="667" /></td>
		<td><img src="https://i-blog.csdnimg.cn/direct/8194c6e6f2d74d1d8813b889134bb6a2.png#pic_center" width="375" height="667" /></td>
	</tr>
	<tr>
		<td><img src="https://i-blog.csdnimg.cn/direct/17f34b7542dc4ffc87f272e9369488e2.png#pic_center" width="375" height="667" /></td>
		<td><img src="https://i-blog.csdnimg.cn/direct/06de920aa11049389638b575cfbd34e5.png#pic_center" width="375" height="667" /></td>
		<td><img src="https://i-blog.csdnimg.cn/direct/2e553fdc5e82435e99aa7a603b52c9b7.png#pic_center" width="375" height="667" /></td>
	</tr>
</table>


- 支持样式配置

通过控制器的拓展属性`toastConfiguration`可以配置该控制器所展示的提示消息的样式，而通过`XZToast`的类属性和类方法，则可以配置提示消息的默认样式。

- `maximumNumberOfToasts`: 数量控制
- `textColor`: 文本颜色
- `font`: 文本字体
- `backgroundColor`: 背景颜色
- `shadowColor`: 投影颜色
- `color`: 进度颜色
- `trackColor`: 进度轨道颜色
- `setOffset(_:for:)`: 设置偏移值
- `setNeedsLayoutToasts/layoutToastsIfNeeded`: 刷新消息布局 


```swift
// 默认样式，生效范围：所有控制器
XZToast.font                  = .systemFont(ofSize: 15)
XZToast.textColor             = .red
XZToast.shadowColor           = .red
XZToast.backgroundColor       = .white
XZToast.maximumNumberOfToasts = 3
XZToast.setOffset(-2, for: .bottom)

// 指定样式，生效范围：当前控制器
let config = self.toastConfiguration
config.font                  = .systemFont(ofSize: 15)
config.textColor             = .red
config.shadowColor           = .red
config.backgroundColor       = .white
config.maximumNumberOfToasts = 3
config.setOffset(-50, for: .bottom)
```

- 支持数量控制

```swift
toastConfiguration.maximumNumberOfToasts = 3
```

<img src="./images/message-middle-max3.png" width="375" height="667" />

- 支持“单例”模式

```objc
showToast(.shared(.success, text: "操作成功"))
showToast(.shared(.failure, text: "操作失败"))
showToast(.shared(.waiting, text: "即将开始"))
showToast(.shared(.warning, text: "即将到期"))
```
<img src="./images/shared-middle.gif" width="375" height="667" />


- 支持自定义视图

```objc
let button = UIButton.init(type: .system)
button.backgroundColor = UIColor.orange
button.setTitleColor(.white, for: .normal)
button.setTitle("点击这里", for: .normal);
button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
showToast(.view(button), duration: 0)
```
