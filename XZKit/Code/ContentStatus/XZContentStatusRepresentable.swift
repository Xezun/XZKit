//
//  ContentStatusRepresentable.swift
//  XZKit
//
//  Created by Xezun on 2017/7/21.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

import UIKit

// TODO: - 将状态视图绑定到视图上，对内存不友好，需要优化。

/// 本协议用于视图。
public protocol ContentStatusRepresentable: NSObjectProtocol {
    
    /// 状态视图的类型。
    /// - Note: 尝试过使用 associatedtype 来自定义状态视图的类型，但是在框架引用到实际项目中时，产生找不到自定义的状态类型的编译错误。
    static var contentStatusViewClass: ContentStatusView.Type { get }
    
    /// 设置/获取当前视图的内容状态。
    /// - Note: 每个状态都对应不同的状态视图。
    /// - Note: 为 `.default` 状态配置状态视图，也会生效。
    /// - Note: 状态视图的背景色，与其被创建时的当前视图背景色相同。
    /// - Note: 状态视图为懒加载，只有手动调用或一般调用设置方法时会自动创建。
    /// - Note: 默认情况下，状态视图的大小与当前视图保持一致。
    var contentStatus: ContentStatus { get set }
    
    /// 构造指定状态下的状态视图的方法，懒加载。
    ///
    /// - Parameter contentStatus: 指定的状态。
    /// - Returns: 呈现指定状态的视图。
    func contentStatusView(for contentStatus: ContentStatus) -> ContentStatusView
    
    /// 获取指定内容状态下的已经创建状态视图。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 呈现指定状态的视图。
    func contentStatusViewIfLoaded(for contentStatus: ContentStatus) -> ContentStatusView?
    
}

extension ContentStatusRepresentable {
    
    public static var contentStatusViewClass: ContentStatusView.Type {
        return ContentStatusView.self
    }
    
    public var contentStatus: ContentStatus {
        get {
            if let contentStatus = objc_getAssociatedObject(self, &AssociationKey.contentStatus) as? ContentStatus {
                return contentStatus
            }
            return ContentStatus.default
        }
        set {
            self.contentStatusViewIfLoaded(for: self.contentStatus)?.isHidden = true
            objc_setAssociatedObject(self, &AssociationKey.contentStatus, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            // 如果配置有指定状态下的状态视图，才显示。
            self.contentStatusViewIfLoaded(for: self.contentStatus)?.isHidden = false
        }
    }
    
    public func contentStatusViewIfLoaded(for contentStatus: ContentStatus) -> ContentStatusView? {
        return self.contentStatusViews[contentStatus]
    }
    
    /// 所有已创建的状态视图。
    /// - Note: 该属性可写，方便开发者自定义。
    public var contentStatusViews: [ContentStatus: ContentStatusView] {
        get {
            if let contentStatusViews = objc_getAssociatedObject(self, &AssociationKey.contentStatusViews) as? [ContentStatus: ContentStatusView] {
                return contentStatusViews
            }
            let contentStatusViews = [ContentStatus: ContentStatusView]()
            objc_setAssociatedObject(self, &AssociationKey.contentStatusViews, contentStatusViews, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return contentStatusViews
        }
        set {
            objc_setAssociatedObject(self, &AssociationKey.contentStatusViews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


// MARK: - 状态视图的访问接口。

extension ContentStatusRepresentable where Self: UIView {
    
    public func contentStatusView(for contentStatus: ContentStatus) -> ContentStatusView {
        if let contentStatusView = contentStatusViews[contentStatus] {
            return contentStatusView
        }
        let contentStatusView = Self.contentStatusViewClass.init(for: self)
        self.setContentStatusView(contentStatusView, for: contentStatus)
        return contentStatusView
    }
    
    /// 当前正在展示的状态视图。
    public var currentContentStatusView: ContentStatusView? {
        return self.contentStatusViewIfLoaded(for: self.contentStatus)
    }
    
    /// 设置指定状态下的状态视图。
    ///
    /// - Parameters:
    ///   - contentStatusView: 状态视图。
    ///   - contentStatus: 状态。
    public func setContentStatusView(_ contentStatusView: ContentStatusView?, for contentStatus: ContentStatus) {
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

// MARK: - 视图内容状态、触控状态相关的样式。

extension ContentStatusRepresentable where Self: UIView {
    
    /// 设置指定内容状态下，状态视图显示的标题文本。
    ///
    /// - Parameters:
    ///   - title: 标题文本。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitle(_ title: String?, for contentStatus: ContentStatus, for state: UIControl.State = .normal) {
        contentStatusView(for: contentStatus).setText(title, for: state)
    }
    
    /// 获取指定内容状态下，已设置的标题文本。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文字。
    public func title(for contentStatus: ContentStatus, for state: UIControl.State = .normal) -> String? {
        return contentStatusViewIfLoaded(for: contentStatus)?.text(for: state);
    }
    
    /// 设置指定内容状态下，状态视图的标题文本颜色。
    ///
    /// - Parameters:
    ///   - titleColor: 标题文本颜色。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitleColor(_ titleColor: UIColor?, for contentStatus: ContentStatus, for state: UIControl.State = .normal) {
        contentStatusView(for: contentStatus).setTextColor(titleColor, for: state)
    }
    
    /// 获取指定状态下已设置的标题文字颜色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文本颜色。
    public func titleColor(for contentStatus: ContentStatus, for state: UIControl.State = .normal) -> UIColor? {
        return contentStatusViewIfLoaded(for: contentStatus)?.textColor(for: state)
    }
    
    /// 设置指定状态下的标题文本阴影颜色。
    ///
    /// - Parameters:
    ///   - titleShadowColor: 标题文本阴影颜色。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setTitleShadowColor(_ titleShadowColor: UIColor?, for contentStatus: ContentStatus, for state: UIControl.State) {
        contentStatusView(for: contentStatus).setTextShadowColor(titleShadowColor, for: state)
    }
    
    /// 获取指定状态下已设置的标题文本阴影颜色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题文本阴影颜色。
    public func titleShadowColor(for contentStatus: ContentStatus, for state: UIControl.State) -> UIColor? {
        return contentStatusViewIfLoaded(for: contentStatus)?.textShadowColor(for: state)
    }
    
    /// 设置指定状态下的标题富文本。
    ///
    /// - Parameters:
    ///   - attributedTitle: 标题富文本。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setAttributedTitle(_ attributedTitle: NSAttributedString?, for contentStatus: ContentStatus, for state: UIControl.State) {
        contentStatusView(for: contentStatus).setAttributedText(attributedTitle, for: state)
    }
    
    /// 获取指定状态下已设置的标题富文本。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 标题富文本。
    public func attributedTitle(for contentStatus: ContentStatus, for state: UIControl.State) -> NSAttributedString? {
        return contentStatusViewIfLoaded(for: contentStatus)?.attributedText(for: state)
    }
    
    
    /// 设置指定内容状态下，状态视图显示的图片。
    ///
    /// - Parameters:
    ///   - image: 待显示的图片。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setImage(_ image: UIImage?, for contentStatus: ContentStatus, for state: UIControl.State = .normal) {
        contentStatusView(for: contentStatus).setImage(image, for: state)
    }
    
    /// 获取已设置的状态图像。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 已设置的图片。
    public func image(for contentStatus: ContentStatus, for state: UIControl.State = .normal) -> UIImage? {
        return contentStatusViewIfLoaded(for: contentStatus)?.image(for: state)
    }
    
    
    /// 设置在某一状态下要显示的背景图片。
    ///
    /// - Parameters:
    ///   - backgroundImage: 背景图片。
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    public func setBackgroundImage(_ backgroundImage: UIImage?, for contentStatus: ContentStatus, for state: UIControl.State = .normal) {
        contentStatusView(for: contentStatus).setBackgroundImage(backgroundImage, for: state)
    }
    
    /// 获取已设置的状态背景图片。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    ///   - state: 触控状态，默认 normal 。
    /// - Returns: 已设置的背景图片。
    public func backgroundImage(for contentStatus: ContentStatus, for state: UIControl.State = .normal) -> UIImage? {
        return contentStatusViewIfLoaded(for: contentStatus)?.backgroundImage(for: state)
    }
    
    
    // MARK: - 事件绑定与移除
    
    /// 给指定状态下的内容视图添加触控事件。
    ///
    /// - Parameters:
    ///   - target: 事件接受者。
    ///   - action: 事件对应的方法。
    ///   - contentStatus: 指定的内容状态。
    ///   - controlEvents: 指定的触控事件。
    public func addTarget(_ target: Any?, action: Selector, for contentStatus: ContentStatus, for controlEvents: UIControl.Event = .touchUpInside) {
        contentStatusView(for: contentStatus).addTarget(target, action: action, for: controlEvents)
    }
    
    /// 移除指定状态下的内容视图的触控事件。
    ///
    /// - Parameters:
    ///   - target: 事件接收者。
    ///   - action: 事件方法。
    ///   - contentStatus: 指定的内容状态。
    ///   - controlEvents: 指定的触控事件。
    public func removeTarget(_ target: Any?, action: Selector?, for contentStatus: ContentStatus, for controlEvents: UIControl.Event = .touchUpInside) {
        contentStatusViewIfLoaded(for: contentStatus)?.removeTarget(target, action: action, for: controlEvents)
    }
    
    
    // MARK: - 无触控状态的样式。
    
    /// 设置指定内容状态下，状态视图的背景色。
    /// - Note: 背景色默认与当前视图一致，但如果状态视图创建后更改了当前视图背景色，状态视图不会自动改变背景色。
    ///
    /// - Parameters:
    ///   - backgroundColor: 状态视图的背景色。
    ///   - contentStatus: 指定的内容状态。
    public func setBackgroundColor(_ backgroundColor: UIColor?, for contentStatus: ContentStatus) {
        contentStatusView(for: contentStatus).backgroundColor = backgroundColor
    }
    
    /// 获取指定状态下已设置的状态视图的背景色。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    /// - Returns: 状态视图的背景色。
    public func backgroundColor(for contentStatus: ContentStatus) -> UIColor? {
        return contentStatusViewIfLoaded(for: contentStatus)?.backgroundColor
    }
    
    /// 设置指定内容状态下，状态视图的标题文本字体。
    ///
    /// - Parameters:
    ///   - titleFont: 标题文本字体。
    ///   - contentStatus: 指定的内容状态。
    public func setTitleFont(_ titleFont: UIFont?, for contentStatus: ContentStatus) {
        contentStatusView(for: contentStatus).textLabel.font = titleFont
    }
    
    /// 获取指定状态下已设置的标题文字字体。
    ///
    /// - Parameters:
    ///   - contentStatus: 指定的内容状态。
    /// - Returns: 标题文本字体。
    public func titleFont(for contentStatus: ContentStatus) -> UIFont? {
        return contentStatusViewIfLoaded(for: contentStatus)?.textLabel.font
    }
    
    /// 设置指定状态下的状态视图的内边距。
    ///
    /// - Parameters:
    ///   - contentInsets: 要指定的内边距。
    ///   - contentStatus: 指定的内容状态。
    public func setContentInsets(_ contentInsets: EdgeInsets, for contentStatus: ContentStatus) {
        contentStatusView(for: contentStatus).contentInsets = contentInsets
    }
    
    
    /// 获取指定状态下，状态视图的内边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 状态视图的内边距。
    public func contentInsets(for contentStatus: ContentStatus) -> EdgeInsets {
        return contentStatusView(for: contentStatus).contentInsets
    }
    
    /// 设置指定内容状态下，标题文本的外边距。
    ///
    /// - Parameters:
    ///   - titleEdgeInsets: 标题文本的外边距。
    ///   - contentStatus: 指定的内容状态。
    public func setTitleInsets(_ titleEdgeInsets: EdgeInsets, for contentStatus: ContentStatus) {
        contentStatusView(for: contentStatus).textInsets = titleEdgeInsets
    }
    
    /// 获取已设置的指定内容状态下的标题文本外边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 标题文本的外边距。
    public func titleInsets(for contentStatus: ContentStatus) -> EdgeInsets {
        return contentStatusView(for: contentStatus).textInsets
    }
    
    /// 设置指定内容状态下，图片的外边距。
    ///
    /// - Parameters:
    ///   - imageEdgeInsets: 图片外边距。
    ///   - contentStatus: 指定的内容状态。
    public func setImageInsets(_ imageEdgeInsets: EdgeInsets, for contentStatus: ContentStatus) {
        contentStatusView(for: contentStatus).imageInsets = imageEdgeInsets
    }
    
    /// 获取指定内容状态下，图片的外边距。
    ///
    /// - Parameter contentStatus: 指定的内容状态。
    /// - Returns: 图片的外边距。
    public func imageInsets(for contentStatus: ContentStatus) -> EdgeInsets {
        return contentStatusView(for: contentStatus).imageInsets
    }
    
}


private struct AssociationKey {
    static var contentStatus: Int       = 0
    static var contentStatusViews: Int  = 1
}










