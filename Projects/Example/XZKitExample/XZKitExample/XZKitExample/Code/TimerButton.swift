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
open class TimerButton: UIButton, Timekeepable {
    
    public func timekeeper(_ timekeeper: Timekeeper, didTime timeInterval: TimeInterval) {
        if timekeeper.isPaused {
            progress = 1.0
            sendActions(for: .timeout)
        } else {
            self.progressView.setProgress(CGFloat(timekeeper.currentTime / timekeeper.duration), animated: false)
        }
        
        XZLog("%.3f: %.3f / %.3f", timeInterval, timekeeper.currentTime, timekeeper.duration)
    }
    
    var progress: CGFloat {
        get { return progressView.progress }
        set { progressView.progress = newValue }
    }
    
    var minimumTrackTintColor: UIColor? {
        get { return progressView.minimumTrackTintColor }
        set { progressView.minimumTrackTintColor = newValue }
    }
    
    var maximumTrackTintColor: UIColor? {
        get { return progressView.maximumTrackTintColor }
        set { progressView.maximumTrackTintColor = newValue }
    }
    
    var trackWidth: CGFloat {
        get { return progressView.trackWidth }
        set { progressView.trackWidth = newValue }
    }
    
    private let progressView = ProgressView.init()

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

