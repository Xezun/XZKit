//
//  XZTimekeeper.swift
//  XZKit
//
//  Created by mlibai on 2017/8/9.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit

/// 实现本协议的对象自动获得计时的能力。
public protocol Timekeepable: TimekeeperDelegate {
    
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
    private var timekeeper: Timekeeper {
        if let displayTimer = objc_getAssociatedObject(self, &AssociationKey.timekeeper) as? Timekeeper {
            return displayTimer
        }
        let displayTimer = Timekeeper.init()
        displayTimer.delegate = self
        objc_setAssociatedObject(self, &AssociationKey.timekeeper, displayTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return displayTimer
    }
    
}

private struct AssociationKey {
    static var timekeeper = 0
}

/// Timekeeper 代理。
public protocol TimekeeperDelegate: AnyObject {
    
    /// 计时器每执行一次嘀嗒计时，都会触发此方法。
    /// - Parameters:
    ///   - timekeeper: 调用此方法的 Timekeeper 计时器。
    ///   - timeInterval: 计时器从启动或上一次调用本方法时，到现在的时长。
    func timekeeper(_ timekeeper: Timekeeper, didTime timeInterval: TimeInterval)
    
}

/// 基于 CADisplayLink 实现的计时器。
open class Timekeeper {
    
    /// 代理。
    open weak var delegate: TimekeeperDelegate?
    
    /// 计时的时间间隔。非精确值，误差与当前帧数相关，最小值 Timekeeper.minimumTimeInterval ，默认 1.0 。
    open var timeInterval: TimeInterval = 1.0 {
        didSet {
            if #available(iOS 10.0, *) {
                displayLink.preferredFramesPerSecond = Int(1.0 / timeInterval)
            } else {
                displayLink.frameInterval = Int(60.0 * timeInterval)
            }
        }
    }
    
    /// 计时器最大运行时长。
    open var duration: TimeInterval = TimeInterval.greatestFiniteMagnitude
    
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
            if currentTime >= duration {
                currentTime = 0
            }
        }
    }
    
    /// 初始化一个计时器。
    /// - Parameters:
    ///   - runLoop: RunLoop
    ///   - mode: RunLoop.Mode
    public init(runLoop: RunLoop = .main, mode: RunLoop.Mode = .default) {
        let displayLinkProxy = DisplayLinkProxy()
        
        let displayLink = CADisplayLink(target: displayLinkProxy, selector: #selector(DisplayLinkProxy.displayLinkAction(_:)))
        displayLink.add(to: runLoop, forMode: mode)
        displayLink.isPaused = true
        
        self.displayLink = displayLink
        self.displayLinkProxy = displayLinkProxy
        
        displayLinkProxy.timekeeper = self
    }

    deinit {
        displayLink.invalidate();
    }
    
    private let displayLinkProxy: DisplayLinkProxy
    private unowned let displayLink: CADisplayLink
    
    // CADisplayLink 开始时的计时。
    private var timestamp: TimeInterval = 0
    
    private func displayLinkAction(_ displayLink: CADisplayLink) {
        // 计算时长。displayLink.duration * TimeInterval(displayLink.frameInterval)
        let timestamp = displayLink.timestamp   // 当前时间
        let timedelta = (timestamp - self.timestamp) // 与上次的时间差
        
        // 下一个计时开始时间
        self.timestamp = timestamp
        
        let newTime = self.currentTime + timedelta
        
        // 超过总时长，暂停倒计时。
        if newTime - self.duration > -Timekeeper.minimumTimeInterval {
            self.isPaused = true
            self.currentTime = self.duration
        } else {
            self.currentTime = newTime
        }
        
        self.delegate?.timekeeper(self, didTime: timeInterval)
    }

    /// 为避免循环引用而用来接收 CADisplayLink 事件的类。
    private class DisplayLinkProxy: NSObject {
        weak var timekeeper: Timekeeper?
        @objc func displayLinkAction(_ displayLink: CADisplayLink) {
            timekeeper?.displayLinkAction(displayLink)
        }
    }
    
    /// 计时器可设置的最小时间间隔。
    public static let minimumTimeInterval: TimeInterval = {
        if #available(iOS 10.3, *) {
            return 1.0 / TimeInterval(UIScreen.main.maximumFramesPerSecond)
        }
        return 1.0 / 60.0
    }()
}



