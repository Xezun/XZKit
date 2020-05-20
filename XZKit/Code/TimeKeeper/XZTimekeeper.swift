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
    
    open var timeInterval: TimeInterval = 0
    
    open var timePrecision: TimePrecision = .milliseconds
    
    open var timeLeeway: TimeLeeway = .milliseconds(0)
    
    open var duration: TimeInterval = 0
    
    open var currentTime: TimeInterval = 0
    
    open var isPaused: Bool = true {
        didSet {
            if oldValue == isPaused {
                return
            }
            
            if isPaused {
                dispatchTimer.suspend()
                if currentTime < duration { // 计时器尚未结束，记录并发送当前状态
                    let delta = (CACurrentMediaTime() - timestamp)
                    currentTime += delta
                    delegate?.timekeeper(self, didTime: delta)
                }
                return
            }
            
            if currentTime >= duration {
                currentTime = 0 // 重置已完成的计时器
            }
            
            timestamp = CACurrentMediaTime()
            
            if timeInterval <= 0 {
                dispatchTimer.schedule(wallDeadline: .now() + duration, repeating: .never, leeway: timeLeeway)
            } else {
                let a = currentTime * timePrecision
                let b = timeInterval * timePrecision
                let c = min(TimeInterval(b - a % b) / timePrecision, duration - currentTime)
                
                let repeatInterval = DispatchTimeInterval(timeInterval: timeInterval, timePrecision: timePrecision)
                dispatchTimer.schedule(wallDeadline: .now() + c, repeating: repeatInterval, leeway: timeLeeway)
            }
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
    
    // CADisplayLink 开始时的计时。
    private var timestamp: TimeInterval = 0
    
    private func dispatchTimerAction() {
        // 计算时长。
        let now = CACurrentMediaTime()   // 当前时间
        let delta = (now - timestamp) // 与上次的时间差
        
        // 下一个计时开始时间
        timestamp = now
        
        let newTime = currentTime + delta
        
        // 超过总时长，暂停倒计时。
        if (newTime - duration) * timePrecision > -1 {
            currentTime = duration
            isPaused = true
        } else {
            currentTime = newTime
        }
        
        delegate?.timekeeper(self, didTime: delta)
    }
    
    private func didTimeout() {
        
    }
    
}

/// 定义了计时器的精确度级别。
public enum TimePrecision: Int {
    case seconds      = 1
    case milliseconds = 1_000
    case microseconds = 1_000_000
    case nanoseconds  = 1_000_000_000
}

public typealias TimeLeeway = DispatchTimeInterval

/// 定义了计时器。
public protocol Timekeeping: AnyObject {
    
    /// 计时间隔，单位秒。在达到最大计时期前，每隔一段时间计时一次，并发送代理事件。默认 0 不发送。
    var timeInterval: TimeInterval { get set }
    
    /// 精确度，属性 timeInterval 小数点后的有效位，默认毫秒。
    var timePrecision: TimePrecision { get set }
    
    /// 计时器允许的误差，默认 0 毫秒。计时器尽可能的保证每个计时间隔的时长，在误差范围内。
    var timeLeeway: TimeLeeway { get set }
    
    /// 是否暂停计时，设置 false 启动计时器。
    var isPaused: Bool { get set }
    
    /// 计时器默认的最大计时时长，默认 0。
    var duration: TimeInterval { get set }
    
    /// 当前时间，即已计时时长。
    var currentTime: TimeInterval { get set }
    
}

extension Timekeepable {
    
    public var timeInterval: TimeInterval {
        get {
            return timekeeper.timeInterval
        }
        set {
            timekeeper.timeInterval = newValue
        }
    }
    
    public var timePrecision: TimePrecision {
        get {
            return timekeeper.timePrecision
        }
        set {
            timekeeper.timePrecision = newValue
        }
    }
    
    public var timeLeeway: TimeLeeway  {
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
    
    public var duration: TimeInterval {
        get {
            return timekeeper.duration
        }
        set {
            timekeeper.duration = newValue
        }
    }
    
    public var currentTime: TimeInterval {
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

extension DispatchTimeInterval {
    
    public init(timeInterval: TimeInterval, timePrecision: TimePrecision) {
        let value = timeInterval * timePrecision
        switch timePrecision {
        case .seconds:
            self = .seconds(value)
        case .milliseconds:
            self = .milliseconds(value)
        case .microseconds:
            self = .microseconds(value)
        case .nanoseconds:
            self = .nanoseconds(value)
        }
    }
    
}

extension TimeInterval {
    
    public static func * (lhs: TimeInterval, rhs: TimePrecision) -> Int {
        return Int(lhs * TimeInterval(rhs.rawValue))
    }
    
    public static func / (lhs: TimeInterval, rhs: TimePrecision) -> TimeInterval {
        switch rhs {
        case .seconds:
            return lhs
        case .milliseconds:
            return lhs * 1e-3
        case .microseconds:
            return lhs * 1.0e-6
        case .nanoseconds:
            return lhs * 1.0e-9
        }
    }
    
}



