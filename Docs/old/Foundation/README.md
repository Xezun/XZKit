# XZKit/Foundation

## 安装

```ruby
pod "XZKit/Foundation"
```

## 介绍

主要是一些全局函数和公共定义部分。

## 主要功能

### Swift

1. isDebugMode 常量：判断当前是否为 `-XZKitDEBUG` 模式。

```swift
// 配置 DEBUG 模式：*Edit Scheme* -> *Arguments Passed On Launch* -> *添加 -XZKitDEBUG 启动参数*。
```

2. unwrap(_:default:) 解包函数：Swift 有时候会遇到多层可选的变量。

### Objective-C

1. defer 宏: 定义一个在作用域结束时执行的代码块。

```
UIGraphicsBeginImageContext(CGSizeMake(100, 100));
defer(^{
    UIGraphicsEndImageContext();
});

/// 再也不需要担心忘记关闭上下文了。
```

2. XZKitDebugMode() 函数：同 Swift 中 `isDebugMode` 常量。

3. XZLog 宏：只在 `-XZKitDEBUG` 模式下才在控制台输出，与 `NSLog` 用法一样。


