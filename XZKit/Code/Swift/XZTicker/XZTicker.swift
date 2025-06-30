//
//  XZTicker.swift
//  XZKit
//
//  Created by Xezun on 2017/8/9.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

/// 任何对象继承 TimeTickable 协议即可获得基于 DispatchSourceTimer 计时能力。
/// - SeeAlso: TimeTiker
public protocol XZTickable: XZTicking, XZTickerDelegate {
    // XZTickerDelegate 是唯一需要实现的方法
}

/// 定义了 XZTicker 计时器所具有的属性和特征。
public protocol XZTicking: AnyObject {
    
    /// 计时时长：如果已计时时长，超过该时长，则计时器会停止。
    /// - Note: 默认值 0 。
    /// - Note: 如果 `duration < timeInterval` 那么计时器只会触发一次。
    var duration: TimeInterval { get set }
    
    /// 当前时间：计时器当前已计时时长。
    var currentTime: TimeInterval { get set }
    
    /// 计时器是否暂停，默认 true 。
    /// - Note: 请通过 resume() 和 pause() 方法来启动或暂停计时器。
    /// - Note: 当计时完成时，此属性会变为 true 。
    var isPaused: Bool { get }
    
    /// 计时频率（周期）。通过设置此属性，可以控制计时器向 delegate 汇报计时进度的频率。
    /// 默认值 .never 表示计时完成前，不发送代理事件。
    /// - Note: 对于已启动的 XZTicker 在再次 resume 前，改变此属性不会生效。
    /// - Note: 此属性必须大于 0 ，否则计时无法累计，也就不会结束。
    var timeInterval: TimeInterval { get set }
    
    /// 误差允许值。计时器尽量保证满足此误差，并不绝对。
    /// - Note: 对于已启动的 XZTicker 在再次 resume 前，改变此属性不会生效。
    var timeLeeway: DispatchTimeInterval { get set }
    
    /// 暂停计时器。
    /// - Note: 暂停中的计时器调用此方法不执行任何操作。
    /// - Note: 暂停时，当前的计时状态会保存
    func pause()
    
    /// 未开始或暂停中的计时器开始或恢复执行。
    /// - Note: 执行中的计时器，调用此方法不执行任何操作。
    func resume()
}


/// XZTicker 代理协议。
public protocol XZTickerDelegate: AnyObject {
    
    /// 计时器每执行一次嘀嗒计时，都会触发此方法。
    /// - Parameters:
    ///   - ticker: 调用此方法的 XZTicker 计时器。
    ///   - timeInterval: 计时器从启动或上一次调用本方法时，到现在的时长。
    func ticker(_ ticker: XZTicker, didTick timeInterval: TimeInterval)
    
}


/// 基于 DispatchSourceTimer 实现的计时器。
/// - Note: 与定时器不同，计时器主要提供计时（累计时长）的能力。
open class XZTicker: XZTicking {
    
    /// 代理。
    open weak var delegate: XZTickerDelegate?
    
    open private(set) var isPaused: Bool = true
    
    open var duration     = TimeInterval(0)
    open var currentTime  = TimeInterval(0)
    open var timeInterval = TimeInterval.infinity
    open var timeLeeway   = DispatchTimeInterval.milliseconds(0)
    
    open func pause() {
        if isPaused {
            return
        }
        isPaused = true
        dispatchTimer.suspend()
    }
    
    private struct Context {
        /// 重复间隔。
        let reptInterval: TimeInterval
        /// 计时器实际执行时的时间间隔
        var execInterval: TimeInterval = 0
    }
    
    /// 记录了计时器从设定到下一次触发之间的时间间隔
    private var context = Context(reptInterval: .infinity, execInterval: 0)
    
    open func resume() {
        guard isPaused else {
            assert(false, "TimeTiker is ticking already.")
            return
        }
        
        // 不检验 duration 则计时器至少会执行一次
        
        isPaused = false
        
        // 重置已完成的计时器
        if currentTime >= duration {
            currentTime = 0
        }
        
        // 第一次是立即开始的，第一个执行间隔为 0
        // 如果没有设计重复间隔（或不合法）则只执行一次
        if timeInterval <= 0 {
            context = Context(reptInterval: .infinity, execInterval: 0)
        } else {
            context = Context(reptInterval: timeInterval, execInterval: 0)
        }
        
        // 使用绝对时间
        dispatchTimer.schedule(wallDeadline: .now(), repeating: context.reptInterval, leeway: timeLeeway)
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
        let delta = context.execInterval
        
        let newTime = currentTime + delta // 新的时间点
        let remain = duration - newTime  // 剩余时长
        
        // 如果没有剩余时长，那么定时器暂停；如果不够一个间隔，则重新设置倒计时。
        if remain < 1.0e-9 {
            currentTime = max(0, duration)
            isPaused    = true
            dispatchTimer.suspend()
        } else {
            currentTime = newTime
            
            // 如果剩余时长，少于一个周期，则重新设定计时器下一次触发的时间
            if remain < context.reptInterval {
                context.execInterval = remain
                let deadline: DispatchTime = .now() + remain
                dispatchTimer.schedule(deadline: deadline, repeating: context.reptInterval, leeway: timeLeeway)
            } else {
                context.execInterval = context.reptInterval
            }
        }

        delegate?.ticker(self, didTick: delta)
    }
    
}

extension XZTickable {
    
    public var duration: TimeInterval {
        get { return ticker.duration }
        set { ticker.duration = newValue }
    }
    
    public var timeInterval: TimeInterval {
        get { return ticker.timeInterval }
        set { ticker.timeInterval = newValue }
    }
    
    public var timeLeeway: DispatchTimeInterval {
        get { return ticker.timeLeeway }
        set { ticker.timeLeeway = newValue}
    }
    
    public var currentTime: TimeInterval {
        get { return ticker.currentTime }
        set { ticker.currentTime = currentTime }
    }
    
    public var isPaused: Bool {
        return ticker.isPaused
    }
    
    public func pause() {
        ticker.pause()
    }
    
    public func resume() {
        ticker.resume()
    }
    
    /// 用于处理计时的 DisplayTimer 对象，默认主线程。
    /// - Note: 该属性可写，可自定义（比如使用其它队列）所使用的 XZTicker 对象。
    public var ticker: XZTicker {
        get {
            if let timeTicker = objc_getAssociatedObject(self, &AssociationKey.timeTicker) as? XZTicker {
                return timeTicker
            }
            let timeTicker = XZTicker.init(queue: .main)
            timeTicker.delegate = self
            self.ticker = timeTicker
            return timeTicker
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.timeTicker, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension DispatchTimeInterval: @retroactive ExpressibleByFloatLiteral {
    
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
            self = TimeInterval(Int.max)
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

private struct AssociationKey: Sendable {
    nonisolated(unsafe) static var timeTicker = 0
}

