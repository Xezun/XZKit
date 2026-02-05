//
//  XZNavigationBar.swift
//  XZNavigationController
//
//  Created by Xezun on 2024/7/7.
//

import UIKit

/// 控制器定制导航条须实现的属性，这些属性是为了与原生导航条保持一致所必须的。
///
/// 本组件并非原生组件的完全替代品，而是原生组件的功能增强，因此必须实现一些方法或属性，以与原生保持的一致性。
///
/// 实现机制是使用定制导航条不可透明，若透明，因为原生的导航条在
///
/// 组件提供了``XZStandardNavigationBar``基类，我们可以继承它，也可以使用其它遵循了``XZNavigationBar``协议的视图控件。
///
/// ### 关于系统导航条
///
/// 1. 如果 `isTranslucent == false` ，那么导航条背景色 alpha 会被设置为 1.0，但是大标题模式背景色却是白色的。
/// 2. 如果 `isTranslucent == true` ，设置透明色，则导航条可以透明。
///
/// ### 如何设置原生导航条透明
///
/// ```swift
/// navigationBar.backgroundColor = UIColor.clear
/// navigationBar.isHidden        = false
/// navigationBar.barTintColor    = UIColor(white: 1.0, alpha: 0)
/// navigationBar.shadowImage     = UIImage()
/// navigationBar.isTranslucent   = true
/// navigationBar.setBackgroundImage(UIImage(), for: .default)
/// ```
///
/// 自定义导航条，可以通过 `navigationBar` 属性获取原生导航条。
///
/// 当原生导航条的状态发生改变时，会自动将状态同步给自定义导航条。
/// 因此，为了避免**循环调用**，当自定义导航条向原生导航条同步状态时，需要调用以下方法，而不能直接同步。
///
/// ```swift
/// // self is the custom navigation bar
/// self.synchronizeAppearance(for: .isHidden)
/// self.synchronizeAppearance(for: .isTranslucent)
/// self.synchronizeAppearance(for: .prefersLargeTitles)
/// ```
///
/// - Attention: 由于转场需要，自定义导航条并不总是在原生导航条之上，所以自定义导航条需要单独设置 tintColor 的值，以避免转场过程中，导航条颜色不一致的问题。
@MainActor public protocol XZNavigationBar: UIView {
    /// 导航条是否半透明。
    var isTranslucent: Bool { get set }
    /// 导航条是否显示大标题模式。
    var prefersLargeTitles: Bool { get set }
}

public enum XZNavigtionBarAppearanceAttribute {
    case isHidden
    case isTranslucent
    case prefersLargeTitles
}

extension XZNavigationBar {
    
    /// 原生导航条。
    ///
    /// 此属性为 nil 时，表示自定义导航条未展示，或者处于转场的过程中。
    public internal(set) var uiNavigationBar: UINavigationBar? {
        get {
            return (objc_getAssociatedObject(self, &_navigationBar) as? WeakWrapper)?.value
        }
        set {
            if let wrapper = objc_getAssociatedObject(self, &_navigationBar) as? WeakWrapper {
                wrapper.value = newValue
            } else {
                let value = WeakWrapper.init(value: newValue)
                objc_setAssociatedObject(self, &_navigationBar, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// 将状态同步给原生导航条。
    public func synchronizeAppearance(for attribute: XZNavigtionBarAppearanceAttribute) {
        guard let navigationBar = self.uiNavigationBar else { return }

        switch attribute {
        case .isHidden:
            xz_objc_msgSendSuper_void(navigationBar, type(of: navigationBar), #selector(setter: UINavigationBar.isHidden), self.isHidden)
        case .isTranslucent:
            xz_objc_msgSendSuper_void(navigationBar, type(of: navigationBar), #selector(setter: UINavigationBar.isTranslucent), self.isTranslucent)
        case .prefersLargeTitles:
            xz_objc_msgSendSuper_void(navigationBar, type(of: navigationBar), #selector(setter: UINavigationBar.prefersLargeTitles), self.prefersLargeTitles)
        }
    }
    
    public var navigationController: UINavigationController? {
        var next: UIResponder? = self.next
        while next != nil {
            if let nav = next as? UINavigationController {
                return nav
            }
            if let vc = next as? UIViewController {
                return vc.navigationController
            }
            next = next?.next
        }
        return nil
    }
    
}


/// 自定义导航条可选基类。
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
        }
    }
    
    /// 导航条的背景视图。
    public let backgroundImageView: UIImageView
    
    /// 导航条阴影视图。
    public let shadowImageView: UIImageView
    
    public override init(frame: CGRect) {
        backgroundImageView = UIImageView.init(frame: CGRect(x: 0, y: -20, width: frame.width, height: 64));
        backgroundImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        
        let bounds = self.bounds
        let safeBounds = bounds.inset(by: self.safeAreaInsets)

        // titleView\backView\infoView 只在初次赋值时，检测是否有大小并尝试自动调整。
        // 切在导航条整个生命周期中，不主动调整它们的大小，只是按照规则将它们放在左中右。
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
        // 理论上，这种情形，应该使用 safeArea 而不是直接增加 navBar 高度，。
        
        let navHeight = prefersLargeTitles ? min(44.0, bounds.height) : bounds.height;
        
        if let titleView = self.titleView {
            titleView.isHidden = bounds.height > 64.0
            let frame = titleView.frame
            let x = (bounds.width - frame.width) * 0.5
            let y = (navHeight - frame.height) * 0.5
            titleView.frame = CGRect.init(x: x, y: y, width: frame.width, height: frame.height)
        }
        
        if let largeTitleView = self.largeTitleView {
            largeTitleView.isHidden = !(bounds.height > 64.0 && prefersLargeTitles)
            largeTitleView.frame = CGRect(x: bounds.minX, y: navHeight, width: bounds.width, height: bounds.height - navHeight)
        }

        let isLeftToRight = (self.effectiveUserInterfaceLayoutDirection == .leftToRight)

        if let infoView = self.infoView {
            let oFrame = infoView.frame
            let x = (isLeftToRight ? safeBounds.maxX - oFrame.width : safeBounds.minX)
            let y = (navHeight - oFrame.height) * 0.5
            infoView.frame = CGRect.init(x: x, y: y, width: oFrame.width, height: oFrame.height)
        }

        if let backView = self.backView {
            let oFrame = backView.frame
            let x = (isLeftToRight ? safeBounds.minX : safeBounds.maxX - oFrame.width)
            let y = (navHeight - oFrame.height) * 0.5
            backView.frame = CGRect.init(x: x, y: y, width: oFrame.width, height: oFrame.height)
        }

        shadowImageView.frame = CGRect.init(
            x: bounds.minX,
            y: bounds.maxY,
            width: bounds.width,
            height: shadowImageView.image?.size.height ?? 1.0 / UIScreen.main.scale
        )

        if let navigationBar = self.uiNavigationBar {
            let minY = navigationBar.frame.minY;
            backgroundImageView.frame = CGRect.init(x: bounds.minX, y: -minY, width: bounds.width, height: bounds.height + minY)
        } else {
            let minY = self.frame.minY;
            backgroundImageView.frame = CGRect.init(x: bounds.minY, y: -minY, width: bounds.width, height: bounds.height + minY)
        }
    }

    /// 在导航条上居中显示的标题视图。
    /// - Note: 标题视图显示在导航条中央。
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
    /// - Note: 正常的导航条高度为 44.0，当显示大标题视图时，导航条高度增加，增加的区域就是大标题视图的区域。
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

    /// 在导航条上的返回视图。
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

    /// 导航条上信息视图。
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
        case isTranslucent       = "XZNavigationBar.isTranslucent"
        case backgroundImageView = "XZNavigationBar.backgroundImageView"
        case shadowImageView     = "XZNavigationBar.shadowImageView"
        case prefersLargeTitles  = "XZNavigationBar.prefersLargeTitles"
    }
}



/// 避免循环引用。
@MainActor private class WeakWrapper {
    
    weak var value: UINavigationBar?
    
    init(value: UINavigationBar? = nil) {
        self.value = value
    }
    
}

@MainActor private var _navigationBar = 0
