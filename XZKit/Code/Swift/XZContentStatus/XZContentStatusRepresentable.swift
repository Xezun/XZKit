//
//  XZContentStatusRepresentable.swift
//  XZKit
//
//  Created by Xezun on 2017/7/21.
//  Copyright © 2017年 Xezun Individual. All rights reserved.
//

import UIKit
import XZTextImageView
import ObjectiveC

/// 本协议用于视图或视图控制器。
@MainActor public protocol XZContentStatusRepresentable {
    
    /// 控件的内容状态。
    /// - 默认情况下，内容状态 `.default` 不展示状态视图，可通过此状态，配置状态视图的默认外观样式。
    /// - 状态视图的默认背景色，为其被创建时的当前视图背景色。
    /// - 默认情况下，状态视图的大小与当前视图保持一致。
    /// - Note: 描述状态的 title/attributedTitle、image 值不属于外观，不存在默认值。
    var contentStatus: XZContentStatus { get set }
    
    /// 获取配置呈现指定内容状态视图的配置对象。
    /// - Parameter contentStatus: 内容状态
    /// - Returns: 配置呈现内容状态视图的对象
    func configuration(for contentStatus: XZContentStatus) -> XZContentStatus.Configuration
    
}

extension XZContentStatus {
    
    /// 配置状态视图的对象。
    ///
    /// 默认配置状态是的方法
    @MainActor public class Configuration {
        
        fileprivate unowned let manager: XZContentStatusManager
        
        fileprivate init(manager: XZContentStatusManager) {
            self.manager = manager
        }
        
        /// 状态视图。如果设置了自定义状态视图，配置状态视图方法将不生效。
        public lazy var view: UIView = XZContentStatusView.init() {
            didSet {
                manager.updateAppearance()
            }
        }
        
    }
    
}

extension XZContentStatus.Configuration: XZTextImageView.StatedAppearance {
    
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        (view as? XZButton)?.addTarget(target, action: action, for: controlEvents)
    }
    
    public func text(for state: UIControl.State) -> String? {
        return (view as? XZButton)?.text(for: state)
    }
    
    public func setText(_ text: String?, for state: UIControl.State) {
        (view as? XZButton)?.setText(text, for: state)
    }
    
    public func attributedText(for state: UIControl.State) -> NSAttributedString? {
        return (view as? XZButton)?.attributedText(for: state)
    }
    
    public func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State) {
        (view as? XZButton)?.setAttributedText(attributedText, for: state)
    }
    
    public func font(for state: UIControl.State) -> UIFont? {
        return (view as? XZButton)?.font(for: state)
    }
    
    public func setFont(_ font: UIFont?, for state: UIControl.State) {
        (view as? XZButton)?.setFont(font, for: state)
    }
    
    public func textColor(for state: UIControl.State) -> UIColor? {
        return (view as? XZButton)?.textColor(for: state)
    }
    
    public func setTextColor(_ textColor: UIColor?, for state: UIControl.State) {
        (view as? XZButton)?.setTextColor(textColor, for: state)
    }
    
    public func textShadowColor(for state: UIControl.State) -> UIColor? {
        return (view as? XZButton)?.textShadowColor(for: state)
    }
    
    public func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State) {
        (view as? XZButton)?.setTextShadowColor(textShadowColor, for: state)
    }
    
    public func image(for state: UIControl.State) -> UIImage? {
        return (view as? XZButton)?.image(for: state)
    }
    
    public func setImage(_ image: UIImage?, for state: UIControl.State) {
        (view as? XZButton)?.setImage(image, for: state)
    }
    
    public func backgroundImage(for state: UIControl.State) -> UIImage? {
        return (view as? XZButton)?.backgroundImage(for: state)
    }
    
    public func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) {
        (view as? XZButton)?.setBackgroundImage(backgroundImage, for: state)
    }
    
    public var style: XZTextImageView.Style {
        get { return (view as? XZButton)?.style ?? .bottom }
        set { (view as? XZButton)?.style = newValue }
    }
    
    public var contentInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZButton)?.contentInsets ?? .zero }
        set { (view as? XZButton)?.contentInsets = newValue }
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZButton)?.textInsets ?? .zero }
        set { (view as? XZButton)?.textInsets = newValue }
    }
    
    public var imageInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZButton)?.imageInsets ?? .zero }
        set { (view as? XZButton)?.imageInsets = newValue }
    }
}

private var _manager = 0

extension XZContentStatusRepresentable where Self: UIView {
    
    public var contentStatus: XZContentStatus {
        get {
            return managerIfLoaded?.contentStatus ?? .default
        }
        set {
            if newValue == .default {
                managerIfLoaded?.contentStatus = newValue
            } else {
                manager.contentStatus = newValue
            }
        }
    }
    
    public func configuration(for contentStatus: XZContentStatus) -> XZContentStatus.Configuration {
        return manager.configuration(for: contentStatus)
    }
    
    private var managerIfLoaded: XZContentStatusManager? {
        get {
            return objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager
        }
        set {
            let oldValue = objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager
            if oldValue === newValue {
                return
            }
            objc_setAssociatedObject(self, &_manager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var manager: XZContentStatusManager {
        if let manager = objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager {
            return manager
        }
        let manager = XZViewContentStatusManager.init(self)
        managerIfLoaded = manager
        return manager
    }
}

extension XZContentStatusRepresentable where Self: UIViewController {
    
    public var contentStatus: XZContentStatus {
        get {
            return managerIfLoaded?.contentStatus ?? .default
        }
        set {
            if newValue == .default {
                managerIfLoaded?.contentStatus = newValue
            } else {
                manager.contentStatus = newValue
            }
        }
    }
    
    public func configuration(for contentStatus: XZContentStatus) -> XZContentStatus.Configuration {
        return manager.configuration(for: contentStatus)
    }
    
    private var managerIfLoaded: XZContentStatusManager? {
        get {
            return objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager
        }
        set {
            let oldValue = objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager
            if oldValue === newValue {
                return
            }
            objc_setAssociatedObject(self, &_manager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var manager: XZContentStatusManager {
        if let manager = objc_getAssociatedObject(self, &_manager) as? XZContentStatusManager {
            return manager
        }
        let manager = XZViewControllerContentStatusManager.init(self)
        managerIfLoaded = manager
        return manager
    }
}

@MainActor private class XZContentStatusManager: XZContentStatusRepresentable {
    
    var contentStatus: XZContentStatus = .default {
        didSet {
            guard oldValue != contentStatus else {
                return
            }
            
            if oldValue != .default {
                configuration(for: oldValue).view.removeFromSuperview()
            }
            
            updateAppearance()
        }
    }
    
    private var configurations = [XZContentStatus: XZContentStatus.Configuration]()
    
    func configuration(for contentStatus: XZContentStatus) -> XZContentStatus.Configuration {
        assert(contentStatus != .default, "Configuration for XZContentStatus.defalut is not available")
        if let configuration = configurations[contentStatus] {
            return configuration
        }
        let configuration = XZContentStatus.Configuration.init(manager: self)
        configurations[contentStatus] = configuration
        return configuration
    }
    
    func updateAppearance() {
        
    }
    
}

@MainActor private class XZViewContentStatusManager: XZContentStatusManager {
    
    unowned let view: UIView
    
    init(_ view: UIView) {
        self.view = view
        super.init()
    }
    
    override func updateAppearance() {
        let configuraion = configuration(for: contentStatus)
        configuraion.view.frame = view.bounds
        view.addSubview(configuraion.view)
    }
}

@MainActor private class XZViewControllerContentStatusManager: XZContentStatusManager {
    
    unowned let viewController: UIViewController
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    override func updateAppearance() {
        guard contentStatus != .default else {
            return
        }
        let configuraion = configuration(for: contentStatus)
        configuraion.view.frame = viewController.view.bounds
        viewController.view.addSubview(configuraion.view)
    }
}
