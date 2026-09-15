# XZTicker

基于 `DispatchSourceTimer` 的计时器组件，提供累计计时能力。

## 特性 Features

- **任意对象计时**：遵循 `XZTickable` 协议即可为任意对象添加计时功能
- **精确计时**：基于系统级的 `DispatchSourceTimer`，精度更高
- **累计计时**：与定时器不同，主要提供计时（累计时长）的能力
- **灵活控制**：支持暂停/恢复、误差允许值设置
- **自动管理**：使用关联对象自动管理计时器实例

## 核心概念 Core Concepts

### 协议 Protocols

#### `XZTicking`
定义计时器的基本属性和方法：

```swift
public protocol XZTicking: AnyObject {
    var duration: TimeInterval { get set }         // 计时时长
    var currentTime: TimeInterval { get set }      // 当前已计时长
    var isPaused: Bool { get }                     // 是否暂停
    var timeInterval: TimeInterval { get set }     // 计时频率
    var timeLeeway: DispatchTimeInterval { get set } // 误差允许值
    
    func pause()                                   // 暂停
    func resume()                                  // 恢复
}
```

#### `XZTickerDelegate`
计时器代理协议，接收计时事件：

```swift
public protocol XZTickerDelegate: AnyObject {
    func ticker(_ ticker: XZTicker, didTick timeInterval: TimeInterval)
}
```

#### `XZTickable`
组合协议，继承后即可获得完整的计时能力：

```swift
public protocol XZTickable: XZTicking, XZTickerDelegate {}
```

## 使用方法 Usage

### 基础用法

让类遵循 `XZTickable` 协议即可自动获得计时能力：

```swift
class MyView: UIView, XZTickable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 设置计时参数
        duration = 10.0           // 总时长 10 秒
        timeInterval = 1.0        // 每秒触发一次
        timeLeeway = .milliseconds(100)
        
        // 启动计时器
        resume()
    }
    
    // 接收计时事件
    func ticker(_ ticker: XZTicker, didTick timeInterval: TimeInterval) {
        print("已计时：\(currentTime)")
        
        if currentTime >= duration {
            // 计时完成
        }
    }
}
```

### 独立计时器

直接使用 `XZTicker` 类：

```swift
let ticker = XZTicker(queue: .main)
ticker.delegate = self
ticker.duration = 30.0
ticker.timeInterval = 5.0
ticker.resume()
```

### 自定义队列

```swift
// 使用后台队列
let backgroundTicker = XZTicker(queue: .global())
```

## 扩展功能 Extensions

### `DispatchTimeInterval` 字面量转换

支持使用浮点数直接创建时间间隔：

```swift
// 等价于 .seconds(1)
let interval1: DispatchTimeInterval = 1.0

// 等价于 .milliseconds(500)
let interval2: DispatchTimeInterval = 0.5

// 等价于 .microseconds(100)
let interval3: DispatchTimeInterval = 0.0001
```

### `TimeInterval` 相互转换

```swift
// 从 DispatchTimeInterval 转换
let ti = TimeInterval(.seconds(5))  // 5.0

// 转换为 DispatchTimeInterval
let di = DispatchTimeInterval(2.5)   // .milliseconds(500)
```

## 注意事项 Notes

1. **默认暂停状态**：新创建的计时器处于暂停状态，需调用 `resume()` 启动
2. **单次计时**：如果 `duration < timeInterval`，计时器只会触发一次
3. **timeInterval 必须大于 0**：否则无法累计计时
4. **内存管理**：计时器使用弱引用代理，避免循环引用

## 相关文档 Related Documentation

- [DispatchSourceTimer 官方文档](https://developer.apple.com/documentation/dispatch/dispatch_source_make_timersource)

## 版本信息 Version Info

- 最小支持：iOS 15.0+
- Swift 版本：5.9+

## License

XZTicker is available under the Apache 2.0 license. See the LICENSE file for more info.
