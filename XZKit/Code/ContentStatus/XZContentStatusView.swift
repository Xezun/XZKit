//
//  ContentStatusView.swift
//  AFNetworking
//
//  Created by mlibai on 2017/12/2.
//

import UIKit

/// 呈现视图内容状态的视图。
@objc(XZContentStatusView)
open class ContentStatusView: TextImageControl {
    
    /// 状态视图所属的视图。
    public unowned let view: UIView
    
    /// 新创建的视图与 view 相同大小且背景色一致。
    ///
    /// - Parameter view: 新构造的视图所属的视图。
    public required init(for view: UIView) {
        self.view = view
        super.init(frame: view.bounds)
        super.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.backgroundColor = view.backgroundColor
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

