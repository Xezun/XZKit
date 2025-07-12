//
//  XZContentStatusView.swift
//  AFNetworking
//
//  Created by Xezun on 2017/12/2.
//

import UIKit

/// 呈现视图内容状态的视图。
@objc public class XZContentStatusView: XZTextImageButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        style = .bottomText
        contentInsets = .init(top: -5, leading: 0, bottom: -5, trailing: 0)
        imageInsets   = .init(top: -5, leading: 0, bottom: +5, trailing: 0)
        textInsets    = .init(top: +5, leading: 0, bottom: -5, trailing: 0)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        style = .bottomText
        contentInsets = .init(top: -5, leading: 0, bottom: -5, trailing: 0)
        imageInsets   = .init(top: -5, leading: 0, bottom: +5, trailing: 0)
        textInsets    = .init(top: +5, leading: 0, bottom: -5, trailing: 0)
    }
    
}
