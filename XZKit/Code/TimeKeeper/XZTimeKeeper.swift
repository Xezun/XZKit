//
//  TimeKeeper.swift
//  XZKit
//
//  Created by mlibai on 2017/8/9.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

@available(*, unavailable, renamed: "TimeKeepable")
public typealias Timeable = TimeKeepable;

/// 实现本协议的对象自动获得计时的能力。
public protocol TimeKeepable: TimeKeeperDelegate {
    
}

extension TimeKeepable {
    
    /// 用于处理计时的 DisplayTimer 对象。
    public var timeKeeper: TimeKeeper {
        if let displayTimer = objc_getAssociatedObject(self, &AssociationKey.displayTimer) as? TimeKeeper {
            return displayTimer
        }
        let displayTimer = TimeKeeper.init()
        displayTimer.delegate = self
        objc_setAssociatedObject(self, &AssociationKey.displayTimer, displayTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return displayTimer
    }
    
    /// 计时总时长。
    public var duration: TimeInterval {
        get {
            return timeKeeper.duration
        }
        set {
            timeKeeper.duration = newValue
        }
    }
    
    /// 当前时间，即已计时时长。
    public var currentTime: TimeInterval {
        get {
            return timeKeeper.currentTime
        }
        set {
            timeKeeper.currentTime = newValue
        }
    }
    
    /// 是否暂停计时。
    public var isPaused: Bool {
        get {
            return timeKeeper.isPaused
        }
        set {
            timeKeeper.isPaused = newValue
        }
    }
    
    /// 计时周期时长，计时间隔。
    public var timeInterval: TimeInterval {
        get {
            return timeKeeper.timeInterval
        }
        set {
            timeKeeper.timeInterval = newValue
        }
    }
    
}

private struct AssociationKey {
    static var displayTimer = 0
}

/// TimeKeeper 代理。
public protocol TimeKeeperDelegate: AnyObject {
    
    /// 计时进度发生改变，此方法会被调用。
    /// - Note: 计时开始后，将按 TimeKeeper.timeInterval （非精确时间）时间间隔调用此方法直到结束。
    ///
    /// - Parameters:
    ///   - timeKeeper: 调用此方法的 TimeKeeper 对象。
    ///   - timeInterval: 从 timeInterval 启动或上一次调用本方法到现在的时长。
    func timeKeeper(_ timeKeeper: TimeKeeper, didKeep timeInterval: TimeInterval)
    
}

/// 基于 CADisplayLink 实现的计时器。
open class TimeKeeper {

    /// 代理。
    open weak var delegate: TimeKeeperDelegate?
    
    /// 计时的时间间隔。非精确值，误差与当前帧数相关。默认 0 ，与当前一帧率所需的时间相同。
    open var timeInterval: TimeInterval = 0 {
        didSet {
            if #available(iOS 10.0, *) {
                displayLink.preferredFramesPerSecond = Int(1.0 / timeInterval)
            } else {
                displayLink.frameInterval = Int(60.0 * timeInterval)
            }
        }
    }
    
    /// 计时器最大运行时长。
    open var duration: TimeInterval = 0
    
    /// 当前时间，已计时时长。设置此属性不会触发代理方法。
    open var currentTime: TimeInterval = 0
    
    /// 计时器是否暂停，默认 true 。
    open var isPaused: Bool {
        get {
            return displayLink.isPaused
        }
        set(isPaused) {
            timestamp = CACurrentMediaTime() // 重置开始时间
            displayLink.isPaused = isPaused  // 启动定时器
            if isPaused {
                return
            }
            // 启动计时器时，重置已完成的计时器。
            if currentTime >= duration, currentTime > 0 {
                currentTime = 0
            }
        }
    }
    
    // CADisplayLink 开始时的计时。
    fileprivate var timestamp: TimeInterval = 0
    
    public init() {
        let displayLinkWrapper = DisplayLinkWrapper()
        let displayLink = CADisplayLink(target: displayLinkWrapper, selector: #selector(DisplayLinkWrapper.displayLinkAction(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.isPaused = true
        
        self.displayLink = displayLink
        self.displayLinkWrapper = displayLinkWrapper
        
        displayLinkWrapper.timeKeeper = self
    }

    private let displayLinkWrapper: DisplayLinkWrapper
    private unowned let displayLink: CADisplayLink
    
    deinit {
        displayLink.invalidate();
    }

}

/// 为避免循环引用而用来接收 CADisplayLink 事件的类。
private class DisplayLinkWrapper: NSObject {
    
    weak var timeKeeper: TimeKeeper?
    
    @objc func displayLinkAction(_ displayLink: CADisplayLink) {
        guard let timeKeeper = self.timeKeeper else {
            return
        }
        
        // 计算时长。displayLink.duration * TimeInterval(displayLink.frameInterval)
        let timestamp = displayLink.timestamp   // 当前时间
        let timedelta = (timestamp - timeKeeper.timestamp) // 与上次的时间差
        // 如果不到一个时间间隔，不发送事件。
        if timedelta < timeKeeper.timeInterval {
            return
        }
        
        // 下一个计时开始时间
        timeKeeper.timestamp = timestamp
        
        let newTime = timeKeeper.currentTime + timedelta
        timeKeeper.currentTime = newTime
        
        // 超过总时长，暂停倒计时。
        if newTime >= timeKeeper.duration {
            timeKeeper.isPaused = true
        }
        
        timeKeeper.delegate?.timeKeeper(timeKeeper, didKeep: timedelta)
    }
}

