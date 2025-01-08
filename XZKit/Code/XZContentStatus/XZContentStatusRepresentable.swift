//
//  XZContentStatusRepresentable.swift
//  XZKit
//
//  Created by Xezun on 2017/7/21.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

/// 本协议用于视图或视图控制器。
@MainActor public protocol XZContentStatusRepresentable: UIResponder {
    
    /// 设置/获取当前视图的内容状态。
    /// - Note: 每个状态都对应不同的状态视图。
    /// - Note: 为 `.default` 状态配置状态视图，也会生效。
    /// - Note: 状态视图的背景色，与其被创建时的当前视图背景色相同。
    /// - Note: 状态视图为懒加载，只有手动调用或一般调用设置方法时会自动创建。
    /// - Note: 默认情况下，状态视图的大小与当前视图保持一致。
    var contentStatus: XZContentStatus { get set }
    
}

extension XZContentStatusRepresentable {
    
    public var contentStatus: XZContentStatus {
        get {
            return contentStatusViewIfLoaded?.contentStatus ?? .default
        }
        set {
            contentStatusView.contentStatus = newValue
        }
    }
    
    fileprivate var contentStatusViewIfLoaded: XZContentStatusView1? {
        return objc_getAssociatedObject(self, &AssociationKey.storage) as? XZContentStatusView1
    }
    
    /// 所有已创建的状态视图。
    /// - Note: 该属性可写，方便开发者自定义。
    fileprivate var contentStatusView: XZContentStatusView1 {
        get {
            if let view = objc_getAssociatedObject(self, &AssociationKey.storage) as? XZContentStatusView1 {
                return view
            }
            let view = XZContentStatusView.init(for: self as! UIView)
            objc_setAssociatedObject(self, &AssociationKey.storage, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return view
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.contentStatusViews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - 视图内容状态、触控状态相关的样式。

extension XZContentStatusRepresentable {
    
    /// 设置指定内容状态下，状态视图显示的标题文本。
    ///
    /// - Parameters:
    ///   - title: 标题文本。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitle(_ title: String?, for contentStatus: XZContentStatus) {
        contentStatusView.setTitle(title, for: contentStatus)
    }
    
    /// 获取指定内容状态下，已设置的标题文本。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文字。
    public func title(for contentStatus: XZContentStatus) -> String? {
        return contentStatusViewIfLoaded?.title(for: contentStatus);
    }
    
    /// 设置指定内容状态下，状态视图的标题文本颜色。
    ///
    /// - Parameters:
    ///   - titleColor: 标题文本颜色。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitleColor(_ titleColor: UIColor?, for contentStatus: XZContentStatus) {
        contentStatusView.setTitleColor(titleColor, for: contentStatus)
    }
    
    /// 获取指定状态下已设置的标题文字颜色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文本颜色。
    public func titleColor(for contentStatus: XZContentStatus) -> UIColor? {
        return contentStatusViewIfLoaded?.titleColor(for: contentStatus)
    }
    
    /// 设置指定状态下的标题文本阴影颜色。
    ///
    /// - Parameters:
    ///   - titleShadowColor: 标题文本阴影颜色。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: XZContentStatus) {
        contentStatusView.setTitleShadowColor(titleShadowColor, for: contentStatus)
    }
    
    /// 获取指定状态下已设置的标题文本阴影颜色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文本阴影颜色。
    public func titleShadowColor(for contentStatus: XZContentStatus) -> UIColor? {
        return contentStatusViewIfLoaded?.titleShadowColor(for: contentStatus)
    }
    
    /// 设置指定状态下的标题富文本。
    ///
    /// - Parameters:
    ///   - attributedTitle: 标题富文本。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: XZContentStatus) {
        contentStatusView.setAttributedTitle(attributedTitle, for: contentStatus)
    }
    
    /// 获取指定状态下已设置的标题富文本。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题富文本。
    public func attributedTitle(for contentStatus: XZContentStatus) -> NSAttributedString? {
        return contentStatusViewIfLoaded?.attributedTitle(for: contentStatus)
    }
    
    
    /// 设置指定内容状态下，状态视图显示的图片。
    ///
    /// - Parameters:
    ///   - image: 待显示的图片。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setImage(_ image: UIImage?, for contentStatus: XZContentStatus) {
        contentStatusView.setImage(image, for: contentStatus)
    }
    
    /// 获取已设置的状态图像。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 已设置的图片。
    public func image(for contentStatus: XZContentStatus) -> UIImage? {
        return contentStatusViewIfLoaded?.image(for: contentStatus)
    }
    
    
    /// 设置在某一状态下要显示的背景图片。
    ///
    /// - Parameters:
    ///   - backgroundImage: 背景图片。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: XZContentStatus) {
        contentStatusView.setBackgroundImage(backgroundImage, for: contentStatus)
    }
    
    /// 获取已设置的状态背景图片。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 已设置的背景图片。
    public func backgroundImage(for contentStatus: XZContentStatus) -> UIImage? {
        return contentStatusViewIfLoaded?.backgroundImage(for: contentStatus)
    }
    
    
    // MARK: - 事件绑定与移除
    
    /// 给指定状态下的内容视图添加触控事件。
    ///
    /// - Parameters:
    ///   - target: 事件接受者。
    ///   - action: 事件对应的方法。
    ///   - contentStatus: 指定的内容状态。
    ///   - controlEvents: 指定的触控事件。
    public func addTarget(_ target: Any?, action: Selector, for state: UIControl.State) {
        contentStatusView.addTarget(target, action: action, for: state)
    }
    
    /// 移除指定状态下的内容视图的触控事件。
    ///
    /// - Parameters:
    ///   - target: 事件接收者。
    ///   - action: 事件方法。
    ///   - contentStatus: 指定的内容状态。
    ///   - controlEvents: 指定的触控事件。
    public func removeTarget(_ target: Any?, action: Selector?, for state: UIControl.State) {
        contentStatusViewIfLoaded?.removeTarget(target, action: action, for: state)
    }
    
    // MARK: - 无触控状态的样式。
    
    /// 设置指定内容状态下，状态视图的背景色。
    /// - Note: 背景色默认与当前视图一致，但如果状态视图创建后更改了当前视图背景色，状态视图不会自动改变背景色。
    ///
    /// - Parameters:
    ///   - backgroundColor: 状态视图的背景色。
    ///   - contentStatus: 指定的内容状态。
    public func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: XZContentStatus) {
        contentStatusView.setBackgroundColor(backgroundColor, for: contentStatus)
    }
    
    /// 获取指定状态下已设置的状态视图的背景色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    /// - Returns: 状态视图的背景色。
    public func backgroundColor(for contentStatus: XZContentStatus) -> UIColor? {
        return contentStatusViewIfLoaded?.backgroundColor(for: contentStatus)
    }
    
    /// 设置指定内容状态下，状态视图的标题文本字体。
    ///
    /// - Parameters:
    ///   - titleFont: 标题文本字体。
    ///   - contentStatus: 指定的内容状态。
    public func setTitleFont(_ titleFont: UIFont?, for contentStatus: XZContentStatus) {
        contentStatusView.setTitleFont(titleFont, for: contentStatus)
    }
    
    /// 获取指定状态下已设置的标题文字字体。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    /// - Returns: 标题文本字体。
    public func titleFont(for contentStatus: XZContentStatus) -> UIFont? {
        return contentStatusViewIfLoaded?.titleFont(for: contentStatus)
    }
    
    /// 设置指定状态下的状态视图的内边距。
    ///
    /// - Parameters:
    ///   - contentInsets: 要指定的内边距。
    ///   - contentStatus: 指定的内容状态。
    public func setContentInsets(_ contentInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        contentStatusView.setContentInsets(contentInsets, for: contentStatus)
    }
    
    /// 获取指定状态下，状态视图的内边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 状态视图的内边距。
    public func contentInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return contentStatusView.contentInsets(for: contentStatus)
    }
    
    /// 设置指定内容状态下，标题文本的外边距。
    ///
    /// - Parameters:
    ///   - titleEdgeInsets: 标题文本的外边距。
    ///   - contentStatus: 指定的内容状态。
    public func setTitleInsets(_ titleEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        contentStatusView.setTitleInsets(titleEdgeInsets, for: contentStatus)
    }
    
    /// 获取已设置的指定内容状态下的标题文本外边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 标题文本的外边距。
    public func titleInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return contentStatusView.titleInsets(for: contentStatus)
    }
    
    /// 设置指定内容状态下，图片的外边距。
    ///
    /// - Parameters:
    ///   - imageEdgeInsets: 图片外边距。
    ///   - contentStatus: 指定的内容状态。
    public func setImageInsets(_ imageEdgeInsets: NSDirectionalEdgeInsets, for contentStatus: XZContentStatus) {
        contentStatusView.setImageInsets(imageEdgeInsets, for: contentStatus)
    }
    
    /// 获取指定内容状态下，图片的外边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 图片的外边距。
    public func imageInsets(for contentStatus: XZContentStatus) -> NSDirectionalEdgeInsets {
        return contentStatusView.imageInsets(for: contentStatus)
    }
    
}

// MARK: - 状态视图的访问接口。

extension XZContentStatusRepresentable where Self: UIView {
    
    public func contentStatusView(for contentStatus: XZContentStatus) -> XZContentStatusView {
        if let contentStatusView = contentStatusViews[contentStatus] {
            return contentStatusView
        }
        let contentStatusView = XZContentStatusView.init(for: self)
        self.setContentStatusView(contentStatusView, for: contentStatus)
        return contentStatusView
    }
    
    /// 设置指定状态下的状态视图。
    ///
    /// - Parameters:
    ///   - contentStatusView: 状态视图。
    ///   - contentStatus: 状态。
    public func setContentStatusView(_ contentStatusView: XZContentStatusView?, for contentStatus: XZContentStatus) {
        // 移除旧视图
        if let oldStatusView = self.contentStatusViews[contentStatus] {
            oldStatusView.removeFromSuperview()
        }
        // 记录新值
        self.contentStatusViews[contentStatus] = contentStatusView
        // 添加新视图
        if let newStatusView = contentStatusView {
            newStatusView.isHidden = (contentStatus != self.contentStatus)
            self.addSubview(newStatusView)
        }
    }
    
}

extension XZContentStatusRepresentable where Self: UIViewController {
    
    public func contentStatusView(for contentStatus: XZContentStatus) -> XZContentStatusView {
        if let contentStatusView = contentStatusViews[contentStatus] {
            return contentStatusView
        }
        let contentStatusView = XZContentStatusView.init(for: self.view)
        self.setContentStatusView(contentStatusView, for: contentStatus)
        return contentStatusView
    }
    
    /// 设置指定状态下的状态视图。
    ///
    /// - Parameters:
    ///   - contentStatusView: 状态视图。
    ///   - contentStatus: 状态。
    public func setContentStatusView(_ contentStatusView: XZContentStatusView?, for contentStatus: XZContentStatus) {
        // 移除旧视图
        if let oldStatusView = self.contentStatusViews[contentStatus] {
            oldStatusView.removeFromSuperview()
        }
        // 记录新值
        self.contentStatusViews[contentStatus] = contentStatusView
        // 添加新视图
        if let newStatusView = contentStatusView {
            newStatusView.isHidden = (contentStatus != self.contentStatus)
            self.view.addSubview(newStatusView)
        }
    }
}

@MainActor private struct AssociationKey {
    static var contentStatus: Int       = 0
    static var contentStatusViews: Int  = 1
    static var storage = 2
}










