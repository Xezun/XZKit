//
//  XZStandardNavigationBar.swift
//  XZKit
//
//  Created by 徐臻 on 2026/2/7.
//

import UIKit

/// 定制化导航栏可选基类。
@MainActor @objc open class XZStandardNavigationBar: UIView, XZNavigationBar {
    
    open override var isHidden: Bool {
        didSet {
            self.synchronizeAppearance(for: .isHidden)
        }
    }
    
    /// 控制背景透明，默认 true 。
    open var isTranslucent = true {
        didSet {
            self.synchronizeAppearance(for: .isTranslucent)
        }
    }
    
    /// 默认 false 。
    open var prefersLargeTitles = false {
        didSet {
            self.synchronizeAppearance(for: .prefersLargeTitles)
            setNeedsLayout()
        }
    }
    
    /// 导航栏的背景视图。
    public let backgroundImageView: UIImageView
    
    /// 导航栏阴影视图。
    public let shadowImageView: UIImageView
    
    public override init(frame: CGRect) {
        backgroundImageView = UIImageView.init(frame: CGRect(x: 0, y: -20, width: frame.width, height: 64));
        backgroundImageView.backgroundColor  = UIColor.white
        
        shadowImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: 1.0 / UIScreen.main.scale))
        shadowImageView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        shadowImageView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44));
        
        self.addSubview(backgroundImageView)
        self.addSubview(shadowImageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let backgroundImageView = aDecoder.decodeObject(forKey: CodingKey.backgroundImageView.rawValue) as? UIImageView else { return nil }
        guard let shadowImageView     = aDecoder.decodeObject(forKey: CodingKey.shadowImageView.rawValue) as? UIImageView else { return nil }
        self.backgroundImageView      = backgroundImageView
        self.shadowImageView          = shadowImageView
        self.isTranslucent            = aDecoder.decodeBool(forKey: CodingKey.isTranslucent.rawValue)
        self.prefersLargeTitles       = aDecoder.decodeBool(forKey: CodingKey.prefersLargeTitles.rawValue)
        super.init(coder: aDecoder)
        self.addSubview(backgroundImageView)
        self.addSubview(shadowImageView)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(isTranslucent,       forKey: CodingKey.isTranslucent.rawValue)
        aCoder.encode(backgroundImageView, forKey: CodingKey.backgroundImageView.rawValue)
        aCoder.encode(shadowImageView,     forKey: CodingKey.shadowImageView.rawValue)
        aCoder.encode(prefersLargeTitles,  forKey: CodingKey.prefersLargeTitles.rawValue)
    }

    /// 此属性直接修改的是导航栏背景视图的背景色。
    open var barTintColor: UIColor? {
        get { return backgroundImageView.backgroundColor }
        set { backgroundImageView.backgroundColor = newValue }
    }

    /// 导航栏背景图片，默认情况下，背景图片将拉伸填充整个背景。
    open var backgroundImage: UIImage? {
        get { return backgroundImageView.image }
        set { backgroundImageView.image = newValue }
    }

    /// 导航栏阴影图片。
    open var shadowImage: UIImage? {
        get { return shadowImageView.image }
        set { shadowImageView.image = newValue }
    }

    /// 导航栏阴影颜色，如果设置了阴影图片，则此属性可能不生效。
    /// - Note: 与系统默认一致，默认 0.3 半透明黑色。
    open var shadowColor: UIColor? {
        get { return shadowImageView.backgroundColor }
        set { shadowImageView.backgroundColor = newValue }
    }
    
    deinit {
        
    }
    
    private func navigationController() -> UINavigationController? {
        var responder = self.next;
        repeat {
            if let navigationController = responder as? UINavigationController {
                return navigationController
            }
            if let viewController = responder as? UIViewController {
                return viewController.navigationController
            }
            responder = responder?.next
        } while (responder != nil)
        return nil
    }
    
    private func statusBarFrame() -> CGRect {
        if let statusBarManager = self.window?.windowScene?.statusBarManager {
            return statusBarManager.statusBarFrame
        }
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: 0);
    }
    
    private func layoutContext(_ bounds: CGRect, _ prefersLargeTitles: Bool) -> (height: CGFloat, minY: CGFloat) {
        if self.traitCollection.userInterfaceIdiom == .pad {
            if #available(iOS 18.0, *) {
                return (54.0, bounds.maxY - 54.0)
            }
            return (44.0, bounds.maxY - 44.0)
        }
        
        if #available(iOS 26.0, *) {
            return (min(44.0, bounds.height), prefersLargeTitles ? 0 : bounds.maxY - 44.0 )
        }
        
        if #available(iOS 13.0, *) {
            if self.frame.minY <= 0 {
                return (56.0, prefersLargeTitles ? 0.0 : bounds.maxY - 56.0)
            }
            return (44.0, prefersLargeTitles ? 0 : bounds.maxY - 44.0)
        }
        
        return (44.0, 0)
    }

    /// 导航栏将按照当前视图布局方向布局 titleView、infoView、backView、shadowImageView、backgroundImageView 。
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let safeBounds = bounds.inset(by: self.safeAreaInsets)
        
        // titleView\backView\infoView 只在初次赋值时，检测是否有大小并尝试自动调整。
        // 切在导航栏整个生命周期中，不主动调整它们的大小，只是按照规则将它们放在左中右。
        // 它们的大小完全由开发者控制，以避免强制调整而造成的不符合预期的情况。
        // 比如，当 title 比较宽的时候，如果自动缩短了 back/info 的长度，那么当 title 变短的时候，back/info 却不能变长，
        // 所以将它们的大小完全交给开发者处理。
        //【一般情形】
        // 普通高度：44
        // 横屏高度：32
        // 大标题高度：44 + 52 = 96
        // 【导航控制器以堆叠样式被 present 呈现时】
        // 普通高度：56
        // 大标题高度：56 + 52 = 108
        // 理论上，这种情形，应该使用 safeArea 而不是直接增加 navBar 高度，但遗憾的是 Apple 似乎采取了一个懒惰的方法，即直接修改导航栏高度。
        // 在 iOS 26 中，Apple 修复了这个问题。
        let isLeftToRight = (self.effectiveUserInterfaceLayoutDirection == .leftToRight)
        
        // 普通模式，导航栏布局在底部；大标题模式，导航栏布局在顶部。
        let layoutContext = self.layoutContext(bounds, prefersLargeTitles)
        
        if let largeTitleView = self.largeTitleView {
            largeTitleView.isHidden = prefersLargeTitles ? bounds.size.height <= 64.0 : true
            let height = prefersLargeTitles ? (bounds.size.height - layoutContext.height) : 0
            largeTitleView.frame = CGRect(x: bounds.minX, y: bounds.maxY - height, width: bounds.width, height: height)
        }
        
        if let titleView = self.titleView {
            titleView.isHidden = prefersLargeTitles ? bounds.height > 64.0 : false;
            let titleFrame = titleView.frame
            let x = (bounds.width - titleFrame.width) * 0.5
            let y = layoutContext.minY + (layoutContext.height - titleFrame.height) * 0.5
            titleView.frame = CGRect.init(x: x, y: y, width: titleFrame.width, height: titleFrame.height)
        }

        if let infoView = self.infoView {
            let infoFrame = infoView.frame
            let x = (isLeftToRight ? safeBounds.maxX - infoFrame.width : safeBounds.minX)
            let y = layoutContext.minY + (layoutContext.height - infoFrame.height) * 0.5
            infoView.frame = CGRect.init(x: x, y: y, width: infoFrame.width, height: infoFrame.height)
        }

        if let backView = self.backView {
            let backFrame = backView.frame
            let x = (isLeftToRight ? safeBounds.minX : safeBounds.maxX - backFrame.width)
            let y = layoutContext.minY + (layoutContext.height - backFrame.height) * 0.5
            backView.frame = CGRect.init(x: x, y: y, width: backFrame.width, height: backFrame.height)
        }
        
        shadowImageView.frame = CGRect.init(
            x: bounds.minX,
            y: bounds.maxY,
            width: bounds.width,
            height: shadowImageView.image?.size.height ?? 1.0 / UIScreen.main.scale
        )

        let frameMinY = self.frame.minY
        if frameMinY >= 0 {
            backgroundImageView.frame = CGRect.init(x: bounds.minY, y: -frameMinY, width: bounds.width, height: bounds.height + frameMinY)
        }
    }

    /// 在导航栏上居中显示的标题视图。
    /// - Note: 标题视图显示在导航栏中央。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    open var titleView: UIView? {
        get {
            return _titleView
        }
        set {
            _titleView?.removeFromSuperview()
            
            if let titleView = newValue {
                if titleView.frame.isEmpty {
                    titleView.sizeToFit()
                }
                self.addSubview(titleView)
            }
            
            _titleView = newValue
        }
    }
    private var _titleView: UIView?
    
    /// 大标题视图。
    ///
    /// 导航栏高度为 44.0 点，当开启大标题视图时，导航栏高度增加，增加的区域就是大标题视图的区域。
    open var largeTitleView: UIView? {
        get {
            return _largeTitleView
        }
        set {
            _largeTitleView?.removeFromSuperview()
            if let largeTitleView = newValue {
                if largeTitleView.frame.isEmpty {
                    largeTitleView.sizeToFit()
                }
                if let titleView = titleView {
                    insertSubview(largeTitleView, belowSubview: titleView)
                } else {
                    addSubview(largeTitleView)
                }
            }
            _largeTitleView = newValue
        }
    }
    private var _largeTitleView: UIView?

    /// 在导航栏上的返回视图。
    /// - Note: 自适应布局方向，在水平方向上，leading 对齐。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    /// - Note: 不会与标题视图重叠，优先显示标题视图。
    open var backView: UIView? {
        get {
            return _backView
        }
        set {
            _backView?.removeFromSuperview()
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
            _backView = newValue
        }
    }
    private var _backView: UIView?

    /// 导航栏上信息视图。
    /// - Note: 自适应布局方向，在水平方向上，trailing 对象。
    /// - Note: 如果设置值时，视图没有大小，则会自动尝试调用 sizeToFit() 方法。
    /// - Note: 不会与标题视图重叠，优先显示标题视图。
    open var infoView: UIView? {
        get {
            return _infoView
        }
        set {
            _infoView?.removeFromSuperview()
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
            _infoView = newValue
        }
    }
    private var _infoView: UIView?
    
    private enum CodingKey: String {
        case isTranslucent       = "XZStandardNavigationBar.isTranslucent"
        case backgroundImageView = "XZStandardNavigationBar.backgroundImageView"
        case shadowImageView     = "XZStandardNavigationBar.shadowImageView"
        case prefersLargeTitles  = "XZStandardNavigationBar.prefersLargeTitles"
    }
}


