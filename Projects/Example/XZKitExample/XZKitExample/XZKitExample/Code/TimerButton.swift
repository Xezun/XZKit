//
//  TimerButton.swift
//  XZKit
//
//  Created by mlibai on 2017/8/8.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit

extension UIControl.Event {
    
    /// 倒计时结束，与 .valueChanged 相同。
    public static let timeout = UIControl.Event.valueChanged
    
}

/// 显示一个倒计时的 Button，当倒计时完成时，会触发 UIControlEvents.timeout（或 valueChanged）事件。
open class TimerButton: UIButton, TimeKeepable {
    
    public func timeKeeper(_ timeKeeper: TimeKeeper, didKeep timeInterval: TimeInterval) {
        self.progressView.progress = CGFloat(currentTime / duration)
    }
    
    public var currentTime: TimeInterval {
        get {
            return (self as TimeKeepable).currentTime
        }
        set {
            (self as TimeKeepable).currentTime = newValue
            self.progressView.progress = CGFloat(currentTime / duration)
        }
    }

    public var duration: TimeInterval {
        get {
            return (self as TimeKeepable).duration
        }
        set {
            (self as TimeKeepable).duration = newValue
            self.progressView.progress = CGFloat(currentTime / duration)
        }
    }
    
    let displayTimer = TimeKeeper.init()
    let progressView = ProgressView.init()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }

    private func didInitialize() {
        progressView.frame = bounds
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(progressView, at: 0)

        progressView.isUserInteractionEnabled = false
    }

}

