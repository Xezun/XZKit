//
//  XZDisplayTimer.swift
//  XZKit
//
//  Created by mlibai on 2017/8/9.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

/// 实现本协议的对象自动获得计时的能力。
public protocol Timable: DisplayTimerDelegate {
    
}

extension Timable {
    
    /// 用于处理计时的 DisplayTimer 对象。
    public var displayTimer: DisplayTimer {
        if let displayTimer = objc_getAssociatedObject(self, &AssociationKey.displayTimer) as? DisplayTimer {
            return displayTimer
        }
        let displayTimer = DisplayTimer.init()
        displayTimer.delegate = self
        objc_setAssociatedObject(self, &AssociationKey.displayTimer, displayTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return displayTimer
    }
    
    /// 计时总时长。
    public var duration: TimeInterval {
        get {
            return displayTimer.duration
        }
        set {
            displayTimer.duration = newValue
        }
    }
    
    /// 当前已计时时长。
    public var currentTime: TimeInterval {
        get {
            return displayTimer.currentTime
        }
        set {
            displayTimer.currentTime = newValue
        }
    }
    
    /// 是否暂停。
    public var isPaused: Bool {
        get {
            return displayTimer.isPaused
        }
        set {
            displayTimer.isPaused = newValue
        }
    }
    
    /// 每次计时时间间隔。
    public var timeInterval: TimeInterval {
        get {
            return displayTimer.timeInterval
        }
        set {
            displayTimer.timeInterval = newValue
        }
    }
    
}

private struct AssociationKey {
    static var displayTimer = 0
}

/// 遵循本协议的对象，自动获得计时的能力。
public protocol DisplayTimerDelegate: AnyObject {
    /// 计时进度发生改变，此方法会被调用。
    /// - Note: 按 timeInterval 属性设定的时间间隔调用，非精确值。
    ///
    /// - Parameters:
    ///   - displayTimer: 调用此方法的 DisplayTimer 对象。
    ///   - time: 从 displayTimer 启动或上一次调用本方法到现在的时长。
    func displayTimer(_ displayTimer: XZKit.DisplayTimer, didTime timeInterval: TimeInterval)
}

/// 使用 CADisplayLink 实现的计时器。
open class DisplayTimer {

    /// 代理。
    open weak var delegate: DisplayTimerDelegate?
    
    /// 计时总时长。
    open var duration: TimeInterval = 0
    
    /// 当前已计时时长，设置此属性不会触发代理方法。
    open var currentTime: TimeInterval = 0
    
    /// 计时器是否暂停，默认 true 。
    open var isPaused: Bool {
        get {
            return displayLink.isPaused
        }
        set(isPaused) {
            timestamp = CACurrentMediaTime() // displayLink.timestamp
            displayLink.isPaused = isPaused
            // 如果启动计时器时，计时器处于上一次计时完成状态，则 currentTime 置零。
            if !isPaused, currentTime >= duration, currentTime > 0 {
                currentTime = 0
            }
        }
    }
    // CADisplayLink 开始时的计时。
    fileprivate var timestamp: TimeInterval = 0
    
    /// 更新计时的时间间隔，非精确值，误差与当前帧数相关。默认 0 ，与当前一帧率所需的时间相同。
    open var timeInterval: TimeInterval = 0 {
        didSet {
            if #available(iOS 10.0, *) {
                displayLink.preferredFramesPerSecond = Int(1.0 / timeInterval)
            } else {
                displayLink.frameInterval = Int(60.0 * timeInterval)
            }
        }
    }
    
    public init() {
        let displayLinkWrapper = DisplayLinkWrapper()
        let displayLink = CADisplayLink(target: displayLinkWrapper, selector: #selector(DisplayLinkWrapper.displayLinkAction(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.isPaused = true
        
        self.displayLink = displayLink
        self.displayLinkWrapper = displayLinkWrapper
        
        displayLinkWrapper.displayTimer = self
    }

    private let displayLinkWrapper: DisplayLinkWrapper
    private unowned let displayLink: CADisplayLink
    
    deinit {
        displayLink.invalidate();
    }

}


private class DisplayLinkWrapper: NSObject {
    
    weak var displayTimer: DisplayTimer?
    
    @objc func displayLinkAction(_ displayLink: CADisplayLink) {
        guard let displayTimer = self.displayTimer else {
            return
        }
        
        // 计算时长。displayLink.duration * TimeInterval(displayLink.frameInterval)
        let timestamp = displayLink.timestamp
        let timedelta = (timestamp - displayTimer.timestamp)
        displayTimer.timestamp = timestamp
        
        let newTime = displayTimer.currentTime + timedelta
        
        // 如果不到一个时间间隔，不发送事件。
        if newTime < displayTimer.timeInterval {
            return
        }
        
        displayTimer.currentTime = newTime
        
        // 超过总时长，暂停倒计时。
        if newTime >= displayTimer.duration {
            displayTimer.isPaused = true
        }
        
        displayTimer.delegate?.displayTimer(displayTimer, didTime: timedelta)
    }
}

