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
    
    /// 计时的时间间隔。
    /// - Note: 计时器开始后设置无效。
    open var timeInterval: TimeInterval = 0.0
    
    /// 计时器最大运行时长。
    open var duration: TimeInterval = TimeInterval.greatestFiniteMagnitude
    
    /// 当前时间，已计时时长。设置此属性不会触发代理方法。
    open var currentTime: TimeInterval = 0
    
    /// 计时器是否暂停，默认 true 。
    open var isPaused: Bool = true {
        didSet {
            if oldValue == isPaused {
                return
            }
            if isPaused {
                dispatchTimerAction()
                dispatchTimer.suspend()
                return
            }
            
            // 启动计时器时，重置已完成的计时器。
            if currentTime >= duration {
                currentTime = 0
            }
            
            timestamp = CACurrentMediaTime()
            
            let a = Int(currentTime * 1000)
            let b = Int(timeInterval * 1000)
            let c = TimeInterval(b - a % b) * 0.001
            
            dispatchTimer.schedule(wallDeadline: .now() + c, repeating: .milliseconds(Int(timeInterval * 1000)), leeway: .seconds(0))
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
        // 计算时长。displayLink.duration * TimeInterval(displayLink.frameInterval)
        let timestamp = CACurrentMediaTime()   // 当前时间
        let timedelta = (timestamp - self.timestamp) // 与上次的时间差
        
        // 下一个计时开始时间
        self.timestamp = timestamp
        
        let newTime = self.currentTime + timedelta
        
        // 超过总时长，暂停倒计时。
        if newTime - self.duration > -0.001 {
            self.isPaused = true
            self.currentTime = self.duration
        } else {
            self.currentTime = newTime
        }
        
        self.delegate?.timekeeper(self, didTime: timeInterval)
    }
    
}

/// 实现本协议的对象自动获得计时的能力。
public protocol Timekeeping: AnyObject {
    
    /// 计时器嘀嗒一次的时长，计时间隔。
    var timeInterval: TimeInterval { get set }
    
    /// 是否暂停计时。
    var isPaused: Bool { get set }
    
    /// 计时总时长。
    var duration: TimeInterval { get set }
    
    /// 当前时间，即已计时时长。
    var currentTime: TimeInterval { get set }
    
}

extension Timekeepable {
    
    /// 计时周期时长，计时间隔。
    public var timeInterval: TimeInterval {
        get {
            return timekeeper.timeInterval
        }
        set {
            timekeeper.timeInterval = newValue
        }
    }
    
    /// 是否暂停计时。
    public var isPaused: Bool {
        get {
            return timekeeper.isPaused
        }
        set {
            timekeeper.isPaused = newValue
        }
    }
    
    /// 计时总时长。
    public var duration: TimeInterval {
        get {
            return timekeeper.duration
        }
        set {
            timekeeper.duration = newValue
        }
    }
    
    /// 当前时间，即已计时时长。
    public var currentTime: TimeInterval {
        get {
            return timekeeper.currentTime
        }
        set {
            timekeeper.currentTime = newValue
        }
    }
    
    /// 用于处理计时的 DisplayTimer 对象。
    public var timekeeper: Timekeeper {
        if let displayTimer = objc_getAssociatedObject(self, &AssociationKey.timekeeper) as? Timekeeper {
            return displayTimer
        }
        let displayTimer = Timekeeper.init(queue: .main)
        displayTimer.delegate = self
        objc_setAssociatedObject(self, &AssociationKey.timekeeper, displayTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return displayTimer
    }
    
}

private struct AssociationKey {
    static var timekeeper = 0
}







