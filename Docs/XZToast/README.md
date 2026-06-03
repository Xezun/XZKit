# XZToast

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZToast)
[![Version](https://img.shields.io/cocoapods/v/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![License](https://img.shields.io/cocoapods/l/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![Platform](https://img.shields.io/cocoapods/p/XZToast.svg?style=flat)](https://cocoapods.org/pods/XZToast)
[![SwiftPM](https://img.shields.io/badge/Swift-Package%20Manager-brightgreen.svg)](https://www.swift.org/package-manager)

## 一、安装

#### 1、使用 Swift Package Manager 集成

`Xcode` -> `File` -> `Add Package Dependencies...` -> `Search or Enter Package URL` 

```txt
https://github.com/Xezun/XZKit.git
```

#### 2、使用 [CocoaPods](http://cocoapods.org) 集成

```ruby
pod "XZToast"
# or
pod "XZKit/XZToast"
```

## 二、如何使用

`XZToast`为`UIView`和`UIViewController`拓展了`showToast()`和`hideToast()`方法。

> 本文中示例代码中的`self`为视图或视图控制器。
>
> 在 ObjC 中使用该方法需要添加`xz_`前缀。

```swift
public func showToast(_ toast: XZToast, duration: TimeInterval, position: XZToast.Position, exclusive: Bool, completion: XZToast.Completion?) -> XZToast.Task 
```

| 参数       | 说明               | 默认值                                                     |
| ---------- | ------------------ | ---------------------------------------------------------- |
| toast      | 带展示的提示消息   | 无，必填参数                                               |
| duration   | 展示时长           | 1.0，可通过`XZToast`或`toastManager`设置，0 表示不限制时长 |
| position   | 展示位置           | 导航控制器：bottom，页签控制器：top，普通控制器：middle    |
| exclusive  | 是否独占           | 独占的消息不会提前取消，也不与其它提示消息同时显示         |
| completion | 消息展示完成的回调 | 无。回调参数`finished`为`false`表示消息是被提前结束的      |

```swift
public func hideToast(_ toast: XZToast?, completion: (()->Void)?)
```
> 在 ObjC 中使用该方法需要添加`xz_`前缀。

| 参数       | 说明             | 默认值               |
| ---------- | ---------------- | -------------------- |
| toast      | 待隐藏提示消息   | nil 表示隐藏所有消息 |
| completion | 消息隐藏后的回调 | nil                  |

### 1、纯文本的消息

在 Swift 中，可以直接使用字符串字面量创建纯文本消息，比如下面的两种写法是等价的。

```swift
self.showToast("文本消息")
self.showToast(.message("文本消息"))
```

### 2、带图片的消息

`XZToast`内置了一些带图标的消息，方便直接使用。

#### 2.1 成功类型

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-success.PNG?raw=true" width="130" border="0">

```swift
// 使用内置或全局设置的成功图标。
self.showToast(.success("登录成功"))
// 使用自定义的成功图标。
self.showToast(.success("操作成功", image: UIImage(named: "icon_success")))
// 如果 image 参数为 nil 则不会带图标。
self.showToast(.init(style: .success, text: "操作成功", image: nil))
```

#### 2.2 失败类型

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-failure.PNG?raw=true" width="156" border="0">

```swift
self.showToast(.failure("登录失败"))
```

#### 2.3 加载类型

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-loading.PNG?raw=true" width="146" border="0">

默认使用`UIActivityIndicatorView`表示加载效果。

```swift
self.showToast(.loading("正在处理中"))
```

支持设置进度。

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-progress.PNG?raw=true" width="180" border="0">

```swift
self.showToast(.loading("已加载 15.80%", progress: 0.1))
```

若要保持加载消息独占且不被中断，需要设置`duration`和`exclusive`参数。

```swift
self.showToast(.loading("加载中"), duration: 0, exclusive: true)
```

#### 2.4 警告类型

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-warning.PNG?raw=true" width="155" border="0">

```swift
self.showToast(.warning("您无权访问权限"))
```

#### 2.5 等待类型

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-waiting.PNG?raw=true" width="161" border="0">

```swift
self.showToast(.waiting("请30秒后再试"))
```

### 3、自定义消息视图

#### 3.1 定义视图

如果`XZToast`内置的消息视图不能满足需求，可通过`XZToastView`协议来自定义消息视图。

```swift
class CustomToastView: UIView, XZToastView {
    
    func toast(_ toast: __XZToast, willShowIn viewController: UIViewController) {
        // 使用 toast 配置视图
        // 如果要实现转场效果，应在此方法中，对视图进行一些转场前的配置。
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 配置视图的最终状态。
        // 此方法会在 UIView.animate 方法中执行，因此会添加动画效果。
    }
    
    func toast(_ toast: __XZToast, didShowIn viewController: UIViewController) {
        // 转场后的操作，比如清理转场用到的临时视图。
    }
  
  	// 在此方法中，计算和返回视图的大小。
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}
```

#### 3.2 使用视图

使用`XZToast`的`NS_DESIGNATED_INITIALIZER`方法即可使用自定义的消息视图。

```swift
self.showToast(.init(style: .message, view: CustomToastView.init()))
```

另外，任意视图都可以作为`XZToast`的消息视图。

```swift
let button = UIButton.init(type: .system)
button.setTitle("刷新页面", for: .normal)
button.backgroundColor = .orange
button.addTarget(self, action: #selector(reloadData()), for: .touchUpInside)
self.showToast(.init(style: .message, view: button))
```

#### 3.3 将自定义视图设置为默认

可通过`XZToast`设置全局的默认消息视图，或者使用`toastManager`仅设置当前控制器的默认消息视图。

```swift
// 全局生效
XZToast.viewClass = CustomToastView.self
// 仅对 self 当前控制器生效       
self.toastManager.viewClass = CustomToastView.self
```

### 4、设置全局样式

通过`XZToast`提供的类属性或类方法，可配置`XZToast`的全局默认样式；通过视图或视图控制器`toastManager`属性，可配置页面的默认样式。

| 样式                | 说明         | 默认值                                   |
| ------------------- | ------------ | ---------------------------------------- |
| `textColor`         | 文本颜色     | `UIColor.whiteColor`                     |
| `font`              | 字体         | SystemFont, 17.0, Regular, monospaced    |
| `backgroundColor`   | 背景色       | `(white: 0.1, alpha: 0.95)`              |
| `shadowColor`       | 投影色       | `UIColor.blackColor`                     |
| `color`             | 图标色       | `UIColor.whiteColor`                     |
| `tintColor`         | 图标渲染色   | `UIColor.systemBlueColor`                |
| `duration`          | 默认显示时长 | `1.0`                                    |
| `setOffset(_:for:)` | 位置偏移     | `top: +20.0, middle: 0, bottom: -40.0`   |
| `setImage(_:for:)`  | 默认图标     | checkmark, xmark, exclamationmark, timer |

### 5、可同时显示的消息数量

`XZToast`支持用列表的形式，同时展示多个提示消息。

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-queue.PNG?raw=true" width="245" border="0">

```swift
// 全局默认仅同时展示一个
XZToast.maximumNumberOfToasts = 1
// 允许当前控制器可同时展示3个消息视图
self.toastManager.maximumNumberOfToasts = 3
```

### 6、刷新消息视图

某些时候可能需要刷新消息视图，特别是使用自定义消息视图时。

```swift
class CustomToastView: UIView, XZToastView {
    var text: String? {
        didSet {
            textLabel.text = text
            self.toastManager.setNeedsLayoutToasts()
        }
    }
}
```

> 控制器内的视图，可以直接通过`toastManager`属性获取到管理它的对象。自定义消息视图，在显示时，也会被添加到控制器视图树中。

## 三、特色

#### 1、列队管理

`XZToast`使用列队管理消息，每个消息都有完整的生命周期，可以避免消息重叠和消息淹没的问题。

> 每个消息最少有`0.7`秒的展示时间，如果是重要的消息，可通过独占模式，保证消息能够被展示指定时间。

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast-queue.PNG?raw=true" width="245" border="0">

#### 2、动画效果

`XZToast`精心设计了每个消息的出场、转场、退场效果，以适应当下对视觉效果越来越严格的要求。

<img src="https://github.com/Xezun/static-resources/blob/master/XZKit/Documentation/XZToast/XZToast.gif?raw=true" width="375" border="0">

#### 3、复用机制

消息可以复用，比如，某个页面使用了比较复杂的自定义视图的消息时，可以在当前页面保存该消息，以避免每次展示都需要创建。

```swift
let toast = XZToast.init(style: .success, view: CustomToastView.init())
    
@objc func buttonAction(_ sender: AnyObject) {
    self.showToast(toast)
}
```

同一时间段内，连续展示的消息视图，默认会被复用。比如在下面的例子中，三个消息会共用同一个消息视图。

> 注意，通过`XZToast.init(style:view:)`方法的`view`参数传入的视图，为独立视图，不可复用。

```swift
self.showToast(.loading("请在 3 秒内点击“同意”按钮"), duration: 3.0) { finished in
    if finished {
        self.showToast(.failure("操作超时"))
        self.button.isHidden = true
    }
}

@objc func buttonAction(_ sender: AnyObject) {
    self.showToast(.success("操作成功"))
}
```

复用机制不缓存消息视图，所以当消息完成生命周期时，如果没有新的消息需要展示，或者消息视图无法被复用，那么该消息视图就会被释放。

## 四、其它

#### 1、统一管理消息。

在业务中，如果我们期望统一管理消息，比如由导航控制器统一管理。

```
override var toastManager: XZToastManager {
    return navigationController!.toastManager
}
```

#### 2、精确隐藏消息。

在复用`XZToast`对象时，如果使用`hideToast`方法，会隐藏掉所有由同一对象发起的消息。此时，需要使用`showToast`方法返回的`XZToastTask`来实现精确隐藏消息。

```swift
let toastTask = self.showToast(.message("请稍后"))
toastTask.hide()
```

#### 3、动态更新消息。

`XZToast`默认提供了`text`、`image`、`progress`属性，可以直接用来更新数据。

> 内置消息视图，支持所有消息类型。消息样式`XZToast.Style`只在初始化时，起提供默认值的作用，所有类型的消息都支持上述三个属性。

```swift
let toast = self.showToast(.loading("请稍后")).toast
// 若要更新数据，直接设置属性即可。
toast.text     = "加载进度 50.0%"
toast.progress = 0.5
```

自定义消息视图，若要实现上述效果，需要实现`XZToastView`协议中的上述三个属性，监听属性的变化并更新视图，比如在内置视图中，属性`text`更新时。

```objc
- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self.xz_toastManager setNeedsLayoutToasts];
}
```

