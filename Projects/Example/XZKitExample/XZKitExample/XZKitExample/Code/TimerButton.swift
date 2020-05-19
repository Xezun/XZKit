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
        self.progressView.setProgress(CGFloat(currentTime / duration), animated: timekeeper.timeInterval > 0.5)
        
        if currentTime - duration > -0.01 {
            sendActions(for: .valueChanged)
        }
        
        XZLog("%.3f / %.3f", currentTime, duration)
    }
    
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

