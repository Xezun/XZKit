//
//  XZContentStatusRepresentable.swift
//  XZKit
//
//  Created by Xezun on 2017/7/21.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit

/// 本协议用于视图或视图控制器。
@MainActor public protocol XZContentStatusRepresentable: XZContentStatusConfigurable {
    
    /// 呈现控件内容状态的视图。懒加载。
    var contentStatusView: XZContentStatusView { get set }
    
    /// 呈现控件内容状态的视图。非懒加载。
    var contentStatusViewIfLoaded: XZContentStatusView? { get }
    
}

extension XZContentStatusRepresentable {
    
    /// 控件的内容状态。
    /// - 默认情况下，内容状态 `.default` 不展示状态视图，可通过此状态，配置状态视图的默认外观样式。
    /// - 状态视图的默认背景色，为其被创建时的当前视图背景色。
    /// - 默认情况下，状态视图的大小与当前视图保持一致。
    /// - Note: 描述状态的 title/attributedTitle、image 值不属于外观，不存在默认值。
    public var contentStatus: XZContentStatus {
        get {
            return contentStatusViewIfLoaded?.contentStatus ?? .default
        }
        set {
            if newValue == .default {
                contentStatusViewIfLoaded?.contentStatus = newValue
            } else {
                contentStatusView.contentStatus = newValue
            }
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

extension XZContentStatusRepresentable where Self: UIView {
    
    public private(set) var contentStatusViewIfLoaded: XZContentStatusView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView
        }
        set {
            let oldValue = objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView
            if oldValue == newValue {
                return
            }
            oldValue?.removeFromSuperview()
            
            objc_setAssociatedObject(self, &AssociationKey.view, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard let newValue = newValue else { return }
            newValue.frame = self.bounds;
            newValue.contentStatus = oldValue?.contentStatus ?? .default
            self.addSubview(newValue)
        }
    }
    
    /// 所有已创建的状态视图。
    /// - Note: 该属性可写，方便开发者自定义。
    public var contentStatusView: XZContentStatusView {
        get {
            if let view = objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView {
                return view
            }
            let view = XZContentStatusView.init()
            contentStatusViewIfLoaded = view
            return view
        }
        set {
            contentStatusViewIfLoaded = newValue
        }
    }
}

extension XZContentStatusRepresentable where Self: UIViewController {
    
    public private(set) var contentStatusViewIfLoaded: XZContentStatusView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView
        }
        set {
            let oldValue = objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView
            if oldValue == newValue {
                return
            }
            oldValue?.removeFromSuperview()
            
            objc_setAssociatedObject(self, &AssociationKey.view, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard let newValue = newValue else { return }
            newValue.contentStatus = oldValue?.contentStatus ?? .default
            
            if let view = viewIfLoaded {
                newValue.frame = view.bounds;
                view.addSubview(newValue)
            } else {
                print("[XZContentStatus] 检测到控制器在 viewDidLoad 之前设置状态视图，请手动添加状态视图到控制器：\(self)")
            }
        }
    }
    
    /// 所有已创建的状态视图。
    /// - Note: 该属性可写，方便开发者自定义。
    public var contentStatusView: XZContentStatusView {
        get {
            if let view = objc_getAssociatedObject(self, &AssociationKey.view) as? XZContentStatusView {
                return view
            }
            let view = XZContentStatusView.init()
            contentStatusViewIfLoaded = view
            return view
        }
        set {
            contentStatusViewIfLoaded = newValue
        }
    }
}

@MainActor private struct AssociationKey {
    static var view: Int = 0
}










