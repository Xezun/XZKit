//
//  XZTimekeeper.swift
//  XZKit
//
//  Created by mlibai on 2017/8/9.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

/// 实现 Timekeepable 协议即可获得计时能力（主线程）。
public protocol Timekeepable: Timekeeping, TimekeeperDelegate {
    
}
/// Timekeeper 代理。
public protocol TimekeeperDelegate: AnyObject {
    
    /// 计时器每执行一次嘀嗒计时，都会触发此方法。
    /// - Parameters:
    ///   - timekeeper: 调用此方法的 Timekeeper 计时器。
    ///   - timeInterval: 计时器从启动或上一次调用本方法时，到现在的时长。
    func timekeeper(_ timekeeper: Timekeeper, didTime timeInterval: TimeInterval)
    
}

/// 基于 DispatchSourceTimer 实现的计时器。
open class Timekeeper: Timekeeping {
    
    /// 代理。
    open weak var delegate: TimekeeperDelegate?
    
    open var timeInterval: DispatchTimeInterval = 0.0
    
    open var timeLeeway: DispatchTimeInterval = 0.0
    
    open var duration: TimeInterval = 0
    
    /// 记录了上次的计时的绝对时间点，或者暂停前已执行的周期时长。
    private var timestamp: TimeInterval = 0
    
    open var currentTime: TimeInterval = 0
    
    open var isPaused: Bool = true {
        didSet {
            if oldValue == isPaused {
                return
            }
            
            if isPaused {
                dispatchTimer.suspend()
                if timestamp > 0 { // 计时器尚未结束，记录并发送当前状态
                    let delta = (CACurrentMediaTime() - timestamp)
                    currentTime += delta
                    timestamp = delta
                    delegate?.timekeeper(self, didTime: delta)
                }
                return
            }
            
            if currentTime >= duration {
                currentTime = 0 // 重置已完成的计时器
            }
            
            let delta = timeInterval - timestamp
            
            timestamp = CACurrentMediaTime()
            
            dispatchTimer.schedule(wallDeadline: .now() + delta, repeating: timeInterval, leeway: timeLeeway)
            dispatchTimer.resume()
        }
    }
    
    public init(queue: DispatchQueue = .main) {
        dispatchTimer = DispatchSource.makeTimerSource(queue: queue)
        dispatchTimer.setEventHandler(handler: { [weak self] in
            self?.dispatchTimerAction()
        })
    }

    deinit {
        dispatchTimer.cancel()
    }
    
    private let dispatchTimer: DispatchSourceTimer
    

    
    private func dispatchTimerAction() {
        // 计算时长。
        let now = CACurrentMediaTime()   // 当前时间
        let delta = (now - timestamp) // 与上次的时间差
        
        let newTime = currentTime + delta // 新的时间点
        let remain  = duration - newTime  // 剩余时长
        
        // 如果没有剩余时长，那么倒计时结束；如果不够一个间隔，则重新设置倒计时。
        if remain <= 0 {
            currentTime = duration
            timestamp = 0
            isPaused = true
        } else {
            if remain < TimeInterval(timeInterval) {
                dispatchTimer.schedule(deadline: .now() + remain, repeating: .never, leeway: timeLeeway)
            }
            timestamp = now
            currentTime = newTime
        }

        delegate?.timekeeper(self, didTime: delta)
    }
    
    private func didTimeout() {
        
    }
    
}

/// 定义了计时器。
public protocol Timekeeping: AnyObject {
    
    /// 计时间隔，单位秒。在达到最大计时期前，每隔一段时间计时一次，并发送代理事件。默认 0 不发送。
    var timeInterval: DispatchTimeInterval { get set }
    
    /// 计时器允许的误差，默认 0 毫秒。计时器尽可能的保证每个计时间隔的时长，在误差范围内。
    var timeLeeway: DispatchTimeInterval { get set }
    
    /// 是否暂停计时，设置 false 启动计时器。
    var isPaused: Bool { get set }
    
    /// 计时器默认的最大计时时长，默认 0。
    var duration: Foundation.TimeInterval { get set }
    
    /// 当前时间，即已计时时长。
    var currentTime: Foundation.TimeInterval { get set }
    
}

extension Timekeepable {
    
    public var timeInterval: DispatchTimeInterval {
        get {
            return timekeeper.timeInterval
        }
        set {
            timekeeper.timeInterval = newValue
        }
    }
    
    public var timeLeeway: DispatchTimeInterval  {
        get {
            return timekeeper.timeLeeway
        }
        set {
            timekeeper.timeLeeway = newValue
        }
    }
    
    public var isPaused: Bool {
        get {
            return timekeeper.isPaused
        }
        set {
            timekeeper.isPaused = newValue
        }
    }
    
    public var duration: Foundation.TimeInterval {
        get {
            return timekeeper.duration
        }
        set {
            timekeeper.duration = newValue
        }
    }
    
    public var currentTime: Foundation.TimeInterval {
        get {
            return timekeeper.currentTime
        }
        set {
            timekeeper.currentTime = newValue
        }
    }
    
    /// 用于处理计时的 DisplayTimer 对象，默认主线程。
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

private struct AssociationKey {
    static var timekeeper = 0
}

extension DispatchTimeInterval: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = TimeInterval
    
    public var accuracy: TimeInterval {
        switch self {
        case .never:
            return 0
        case .seconds:
            return 1.0
        case .milliseconds:
            return 1.0e-3
        case .microseconds:
            return 1.0e-6
        case .nanoseconds:
            return 1.0e-9
        default:
            return 0
        }
    }
    
    /// 自动根据当前 timeInterval （秒）小数点后面的位数选择合适的精度。
    /// - Parameter timeInterval: 以秒为单位的时间值。
    public init(floatLiteral timeInterval: TimeInterval) {
        if timeInterval <= 0 {
            self = .never
            return
        }
        
        var t0 = timeInterval
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

        let value = Int(round(t0))
        
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
            return 0
        case .seconds(let value):
            return Foundation.TimeInterval(value) - rhs
        case .milliseconds(let value):
            return Foundation.TimeInterval(value) * 1.0e-3 - rhs
        case .microseconds(let value):
            return Foundation.TimeInterval(value) * 1.0e-6 - rhs
        case .nanoseconds(let value):
            return Foundation.TimeInterval(value) * 1.0e-6 - rhs
        @unknown default:
            return 0
        }
    }
}

extension TimeInterval {
    
    public init(_ timeInterval: DispatchTimeInterval) {
        switch timeInterval {
        case .never:
            self = 0
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
