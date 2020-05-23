//
//  XZTimekeeper.swift
//  XZKit
//
//  Created by mlibai on 2017/8/9.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

/// 遵循 Timekeepable 协议可获得计时器 timekeeper 属性，该计时器以自身作为代理。
public protocol Timekeepable: Timekeeping, TimekeeperDelegate {
    
}

/// Timekeeper 代理协议。
public protocol TimekeeperDelegate: AnyObject {
    
    /// 计时器每执行一次嘀嗒计时，都会触发此方法。
    /// - Parameters:
    ///   - timekeeper: 调用此方法的 Timekeeper 计时器。
    ///   - timeInterval: 计时器从启动或上一次调用本方法时，到现在的时长。
    func timekeeper(_ timekeeper: Timekeeper, didTime timeInterval: TimeInterval)
    
}

public protocol Timekeeping: AnyObject {
    
    /// 计时器最大计时时长，默认 0 ，超过该时长，计时器自动暂停。
    var duration: TimeInterval { get set }
    
    /// 当前时间：计时器当前已计时时长。
    var currentTime: TimeInterval { get set }
    
    /// 计时器是否暂停，默认 true 。
    /// 请通过 resume() 和 pause 方法来启动或暂停计时器。
    var isPaused: Bool { get }
    
    /// 计时频率（周期）。通过设置此属性，可以控制计时器向 delegate 汇报计时进度的频率。
    /// 默认值 .never 表示计时完成前，不发送代理事件。
    /// - Note: 计时器执行过程中，设置此属性无效。
    var timeInterval: DispatchTimeInterval { get set }
    
    /// 误差允许值。计时器尽量保证满足此误差，并不绝对。
    /// - Note: 计时器执行过程中，设置此属性无效。
    var timeLeeway: DispatchTimeInterval { get set }
    
    /// 暂停计时器。
    /// - Note: 暂停中的计时器调用此方法不执行任何操作。
    /// - Note: 暂停时，当前的计时状态会保存
    func pause()
    
    /// 未开始或暂停中的计时器开始或恢复执行。
    /// - Note: 执行中的计时器，调用此方法不执行任何操作。
    func resume()
}

/// 基于 DispatchSourceTimer 实现的计时器。
/// - Note: 与定时器不同，计时器主要提供计时（累计时长）的能力。
open class Timekeeper: Timekeeping {
    
    /// 代理。
    open weak var delegate: TimekeeperDelegate?
    
    open var duration: TimeInterval             = 0
    
    open var currentTime: TimeInterval          = 0
    
    open private(set) var isPaused: Bool        = true
    
    open var timeInterval: DispatchTimeInterval = .never
    
    open var timeLeeway: DispatchTimeInterval   = .seconds(0)
    
    /// 记录了上次的计时的绝对时间点，或者暂停前已执行的周期时长。
    private var timestamp: TimeInterval         = 0
    
    open func pause() {
        if isPaused {
            return
        }
        isPaused = true
        // 暂停时，记录时长。
        timestamp = (CACurrentMediaTime() - timestamp)
        currentTime += timestamp
        dispatchTimer.suspend()
    }
    
    open func resume() {
        guard isPaused else {
            return
        }
        isPaused = false
        
        // 重置已完成的计时器
        if currentTime >= duration {
            currentTime = 0
        }
        
        // 计算到下个重复周期
        let next = min(duration, TimeInterval(timeInterval)) - timestamp
        timestamp = CACurrentMediaTime()
        
        dispatchTimer.schedule(wallDeadline: .now() + next, repeating: timeInterval, leeway: timeLeeway)
        dispatchTimer.resume()
    }
    
    /// 创建一个计时器。
    /// - Note: 计时器默认处于暂停状态，需调用 resume() 方法启动。
    /// - Parameter queue: 计时器使用的队列（如发送代理事件）。
    public init(queue: DispatchQueue = .main) {
        dispatchTimer = DispatchSource.makeTimerSource(queue: queue)
        dispatchTimer.setEventHandler(handler: { [weak self] in
            self?.dispatchTimerAction()
        })
    }

    deinit {
        // DispatchSourceTimer 在初始化、暂停的情况下，不能执行 cancel 方法。
        if isPaused {
            dispatchTimer.setEventHandler(handler: nil)
            dispatchTimer.resume()
        }
        dispatchTimer.cancel()
    }
    
    /// 定时器。
    private let dispatchTimer: DispatchSourceTimer
    
    private func dispatchTimerAction() {
        // 计算时长。
        let now   = CACurrentMediaTime()  // 当前时间
        let delta = (now - timestamp)     // 与上次的时间差
        
        let newTime = currentTime + delta // 新的时间点
        let remain  = duration - newTime  // 剩余时长
        
        // 如果没有剩余时长，那么定时器暂停；如果不够一个间隔，则重新设置倒计时。
        if remain < 1.0e-9 {
            currentTime = duration
            timestamp   = 0
            isPaused    = true
            dispatchTimer.suspend()
        } else {
            if remain < TimeInterval(timeInterval) {
                dispatchTimer.schedule(deadline: .now() + remain, repeating: timeInterval, leeway: timeLeeway)
            }
            timestamp   = now
            currentTime = newTime
        }

        delegate?.timekeeper(self, didTime: delta)
    }
    
}

extension Timekeepable {
    
    public var duration: TimeInterval {
        get { return timekeeper.duration }
        set { timekeeper.duration = newValue }
    }
    
    public var timeInterval: DispatchTimeInterval {
        get { return timekeeper.timeInterval }
        set { timekeeper.timeInterval = newValue }
    }
    
    public var timeLeeway: DispatchTimeInterval {
        get { return timekeeper.timeLeeway }
        set { timekeeper.timeLeeway = newValue}
    }
    
    public var currentTime: TimeInterval {
        get { return timekeeper.currentTime }
        set { timekeeper.currentTime = currentTime }
    }
    
    public var isPaused: Bool {
        return timekeeper.isPaused
    }
    
    public func pause() {
        timekeeper.pause()
    }
    
    public func resume() {
        timekeeper.resume()
    }
    
    /// 用于处理计时的 DisplayTimer 对象，默认主线程。
    /// - Note: 该属性可写，可自定义（比如使用其它队列）所使用的 Timekeeper 对象。
    public var timekeeper: Timekeeper {
        get {
            if let timekeeper = objc_getAssociatedObject(self, &AssociationKey.timekeeper) as? Timekeeper {
                return timekeeper
            }
            let timekeeper = Timekeeper.init(queue: .main)
            timekeeper.delegate = self
            self.timekeeper = timekeeper
            return timekeeper
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.timekeeper, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension DispatchTimeInterval: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = TimeInterval
    
    public init(_ timeInterval: TimeInterval) {
        self.init(floatLiteral: timeInterval)
    }
    
    /// 根据当前 timeInterval （秒）小数点后面的位数选择合适的精度。
    /// - Note: Double占8个字节（64位）内存空间，最多可提供16位有效数字，小数点后默认保留6位。如全是整数，zd最多提供15位有效数字。
    /// - Note: 负数和大于 999_999_999_999_999 的值将构造为 .never 。
    /// - Parameter timeInterval: 以秒为单位的时间值。
    public init(floatLiteral timeInterval: TimeInterval) {
        if timeInterval < 0 || timeInterval > 999_999_999_999_999 {
            self = .never
            return
        }

        var t0 = timeInterval + 5.0e-10 // 四舍五入
        var t1 = floor(t0)
        var t2 = t0 - t1

        var tn = 0
        var tx = 1.0e-9 // 最小精度 1 纳秒。
        while t2 >= tx {
            t0 = t0 * 1000
            t1 = floor(t0)
            t2 = t0 - t1
            tn = tn + 1
            tx = tx * 1000 // 保持最小精度不变
        }

        let value = Int(floor(t0))

        switch tn {
        case 0:
            self = .seconds(value)
        case 1:
            self = .milliseconds(value)
        case 2:
            self = .microseconds(value)
        default:
            self = .nanoseconds(value)
        }
    }
    
    public static func - (lhs: DispatchTimeInterval, rhs: TimeInterval) -> TimeInterval {
        switch lhs {
        case .never:
            return TimeInterval(Int.max) - rhs
        case .seconds(let value):
            return TimeInterval(value) - rhs
        case .milliseconds(let value):
            return TimeInterval(value) * 1.0e-3 - rhs
        case .microseconds(let value):
            return TimeInterval(value) * 1.0e-6 - rhs
        case .nanoseconds(let value):
            return TimeInterval(value) * 1.0e-6 - rhs
        @unknown default:
            return 0
        }
    }
    
}

extension TimeInterval {
    
    public init(_ timeInterval: DispatchTimeInterval) {
        switch timeInterval {
        case .never:
            self = TimeInterval(UInt.max)
        case .seconds(let value):
            self = TimeInterval(value)
        case .milliseconds(let value):
            self = TimeInterval(value) * 1.0e-3
        case .microseconds(let value):
            self = TimeInterval(value) * 1.0e-6
        case .nanoseconds(let value):
            self = TimeInterval(value) * 1.0e-9
        default:
            self = 0
        }
    }
    
}

private struct AssociationKey {
    static var timekeeper = 0
}

