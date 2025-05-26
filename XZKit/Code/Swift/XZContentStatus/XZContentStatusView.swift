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
        contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        imageInsets   = .init(top: -5, leading: 0, bottom: +5, trailing: 0)
        textInsets    = .init(top: +5, leading: 0, bottom: -5, trailing: 0)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        style = .bottom
        contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        imageInsets   = .init(top: -5, leading: 0, bottom: +5, trailing: 0)
        textInsets    = .init(top: +5, leading: 0, bottom: -5, trailing: 0)
    }
    
}
