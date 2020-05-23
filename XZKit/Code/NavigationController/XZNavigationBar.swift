//
//  NavigationBar.swift
//  XZKit
//
//  Created by Xezun on 2018/1/4.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import UIKit

/// 自定义导航条可以继承 NavigationBar 也可以继承其它视图控件，实现 NavigationBaring 协议即可。
/// 自定义导航条所必须实现的协议。
/// - Note: 因为 tintColor 会自动从父视图继承，所以自定义导航条没有设置 tintColor 的话，那么最终可能会影响自定义导航条的外观，因为自定义导航条的父视图，在转场过程中会发生变化。
public protocol NavigationBaring: UIView {
    var isTranslucent: Bool { get set }
    var prefersLargeTitles: Bool { get set }
}


/// 自定义导航条。tintColor 有默认值，不从父类继承。
@objc(XZNavigationBar)
open class NavigationBar: UIView, NavigationBaring {
    
    /// 控制背景透明，默认 true 。
    open var isTranslucent: Bool
    /// 默认 false 。
    open var prefersLargeTitles: Bool
    /// 导航条的背景视图。
    public let backgroundImageView: UIImageView
    /// 导航条阴影视图。
    public let shadowImageView: UIImageView
    
    public override init(frame: CGRect) {
        self.backgroundImageView = UIImageView.init(frame: CGRect(x: 0, y: -20, width: frame.width, height: 64));
        self.backgroundImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundImageView.backgroundColor  = UIColor.white
        self.shadowImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: 1.0 / UIScreen.main.scale))
        self.shadowImageView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        self.shadowImageView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.isTranslucent      = true
        self.prefersLargeTitles = false
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44));
        // tintColor 有默认值，不会从父类继承。
        self.tintColor = UIColor(red: 0, green: 0.478431, blue: 1.0, alpha: 1.0)
        self.addSubview(backgroundImageView)
        self.addSubview(shadowImageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let backgroundImageView = aDecoder.decodeObject(forKey: CodingKey.backgroundImageView.rawValue) as? UIImageView else { return nil }
        guard let shadowImageView     = aDecoder.decodeObject(forKey: CodingKey.shadowImageView.rawValue) as? UIImageView else { return nil }
        self.backgroundImageView = backgroundImageView
        self.shadowImageView     = shadowImageView
        self.isTranslucent       = aDecoder.decodeBool(forKey: CodingKey.isTranslucent.rawValue)
        self.prefersLargeTitles  = aDecoder.decodeBool(forKey: CodingKey.prefersLargeTitles.rawValue)
        super.init(coder: aDecoder)
        self.addSubview(backgroundImageView)
        self.addSubview(shadowImageView)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(isTranslucent, forKey: CodingKey.isTranslucent.rawValue)
        aCoder.encode(backgroundImageView, forKey: CodingKey.backgroundImageView.rawValue)
        aCoder.encode(shadowImageView, forKey: CodingKey.shadowImageView.rawValue)
        aCoder.encode(prefersLargeTitles, forKey: CodingKey.prefersLargeTitles.rawValue)
    }

    /// 此属性直接修改的是导航条背景视图的背景色。
    open var barTintColor: UIColor? {
        get { return backgroundImageView.backgroundColor }
        set { backgroundImageView.backgroundColor = newValue }
    }

    /// 导航条背景图片，默认情况下，背景图片将拉伸填充整个背景。
    open var backgroundImage: UIImage? {
        get { return backgroundImageView.image }
        set { backgroundImageView.image = newValue }
    }

    /// 导航条阴影图片。
    open var shadowImage: UIImage? {
        get { return shadowImageView.image }
        set { shadowImageView.image = newValue }
    }

    /// 导航条阴影颜色，如果设置了阴影图片，则此属性可能不生效。
    /// - Note: 与系统默认一致，默认 0.3 半透明黑色。
    open var shadowColor: UIColor? {
        get { return shadowImageView.backgroundColor }
        set { shadowImageView.backgroundColor = newValue }
    }

    deinit {
        
    }

    /// 导航条将按照当前视图布局方向布局 titleView、infoView、backView、shadowImageView、backgroundImageView 。
    override open func layoutSubviews() {
        super.layoutSubviews()

        let BOUNDS = self.bounds

        // titleView\backView\infoView 只在初次赋值时，检测是否有大小并尝试自动调整。
        // 切在导航条整个生命周期中，不主动调整它们的大小，只是按照规则将它们放在左中右。
        // 它们的大小完全由开发者控制，以避免强制调整而造成的不符合预期的情况。
        // 比如，当 title 比较宽的时候，如果自动缩短了 back/info 的长度，那么当 title 变短的时候，back/info 却不能变长，
        // 所以将它们的大小完全交给开发者处理。
        // 普通高度：44 大标题高度： 96
        
        if let titleView = self.titleView {
            let frame = titleView.frame
            let x = (BOUNDS.width - frame.width) * 0.5
            let y = (44.0 - frame.height) * 0.5
            titleView.frame = CGRect.init(x: x, y: y, width: frame.width, height: frame.height)
            titleView.isHidden = BOUNDS.height >= 60.0
        }
        
        if let largeTitleView = self.largeTitleView {
            largeTitleView.isHidden = BOUNDS.height < 60
            largeTitleView.frame = CGRect(x: BOUNDS.minX, y: 44.0, width: BOUNDS.width, height: BOUNDS.height - 44.0)
        }

        let isLeftToRight = (self.userInterfaceLayoutDirection == .leftToRight)

        if let infoView = self.infoView {
            let oFrame = infoView.frame
            let x = (isLeftToRight ? BOUNDS.maxX - oFrame.width : 0)
            let y = (44.0 - oFrame.height) * 0.5
            infoView.frame = CGRect.init(x: x, y: y, width: oFrame.width, height: oFrame.height)
        }

        if let backView = self.backView {
            let oFrame = backView.frame
            let x = (isLeftToRight ? 0 : BOUNDS.maxX - oFrame.width)
            let y = (44.0 - oFrame.height) * 0.5
            backView.frame = CGRect.init(x: x, y: y, width: oFrame.width, height: oFrame.height)
        }

        shadowImageView.frame = CGRect.init(
            x: BOUNDS.minX,
            y: BOUNDS.maxY,
            width: BOUNDS.width,
            height: shadowImageView.image?.size.height ?? 1.0 / UIScreen.main.scale
        )

        guard let window = self.window else { return }
        let minY = min(0, window.convert(window.bounds.origin, to: self).y)
        backgroundImageView.frame = CGRect.init(x: BOUNDS.minX, y: minY, width: BOUNDS.width, height: BOUNDS.maxY - minY)
    }

    /// 在导航条上居中显示的标题视图。
    /// - Note: 标题视图显示在导航条中央。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    open var titleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.titleView) as? UIView
        }
        set {
            self.titleView?.removeFromSuperview()
            if let titleView = newValue {
                if titleView.frame.isEmpty {
                    titleView.sizeToFit()
                }
                self.addSubview(titleView)
            }
            objc_setAssociatedObject(self, &AssociationKey.titleView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 大标题视图。
    /// - Note: 正常的导航条高度为 44.0，当显示大标题视图时，导航条高度增加，增加的区域就是大标题视图的区域。
    open var largeTitleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.largeTitleView) as? UIView
        }
        set {
            self.largeTitleView?.removeFromSuperview()
            if let largeTitleView = newValue {
                if largeTitleView.frame.isEmpty {
                    largeTitleView.sizeToFit()
                }
                self.addSubview(largeTitleView)
            }
            objc_setAssociatedObject(self, &AssociationKey.largeTitleView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 在导航条上的返回视图。
    /// - Note: 自适应布局方向，在水平方向上，leading 对齐。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    /// - Note: 不会与标题视图重叠，优先显示标题视图。
    open var backView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.backView) as? UIView
        }
        set {
            self.backView?.removeFromSuperview()
            if let backView = newValue {
                if backView.frame.isEmpty {
                    backView.sizeToFit()
                }
                if let titleView = self.titleView {
                    self.insertSubview(backView, belowSubview: titleView)
                } else {
                    self.addSubview(backView)
                }
            }
            objc_setAssociatedObject(self, &AssociationKey.backView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 导航条上信息视图。
    /// - Note: 自适应布局方向，在水平方向上，trailing 对象。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    /// - Note: 不会与标题视图重叠，优先显示标题视图。
    open var infoView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociationKey.infoView) as? UIView
        }
        set {
            self.infoView?.removeFromSuperview()
            if let infoView = newValue {
                if infoView.frame.isEmpty {
                    infoView.sizeToFit()
                }
                if let titleView = self.titleView {
                    self.insertSubview(infoView, belowSubview: titleView)
                } else {
                    self.addSubview(infoView)
                }
            }
            objc_setAssociatedObject(self, &AssociationKey.infoView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

private struct AssociationKey {
    static var backView  = 0
    static var infoView  = 1
    static var titleView = 2
    static var largeTitleView = 3
}

private enum CodingKey: String {
    case isTranslucent       = "XZKit.NavigationBar.isTranslucent"
    case backgroundImageView = "XZKit.NavigationBar.backgroundImageView"
    case shadowImageView     = "XZKit.NavigationBar.shadowImageView"
    case prefersLargeTitles  = "XZKit.NavigationBar.prefersLargeTitles"
}
