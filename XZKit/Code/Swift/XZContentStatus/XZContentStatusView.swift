//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit
import XZTextImageView

/// 呈现视图内容状态的视图。
@objc public class XZContentStatusView: XZButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        style = .bottom
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        style = .bottom
    }
    
}
