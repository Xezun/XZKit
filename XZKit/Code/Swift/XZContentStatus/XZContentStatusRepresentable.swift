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

/// 支持呈现内容状态的页面需要遵循的协议。
///
/// 提供了默认实现，视图或视图控制器声明遵循协议，即可支持协议中提供的方法和属性。
@MainActor public protocol XZContentStatusRepresentable {
    
    /// 当前的内容状态。
    var contentStatus: XZContentStatus { get set }
    
    /// 获取配置内容状态视图的对象。
    /// > 不能为默认状态配置状态视图，所以不能通过此方法获取默认状态的配置对象。
    /// - Parameter contentStatus: 内容状态
    /// - Returns: 配置内容状态视图的对象
    func configuration(for contentStatus: XZContentStatus) -> XZContentStatus.Configuration
    
}

extension XZContentStatus {
    
    /// 配置状态视图的对象。
    @MainActor public class Configuration {
        
        fileprivate unowned let manager: XZContentStatusManager
        
        fileprivate init(manager: XZContentStatusManager) {
            self.manager = manager
        }
                
        /// 状态视图。
        ///
        /// 如果状态视图不是 XZTextImageButton 的子类，默认提供的配置方法将不会生效。
        public lazy var view: UIView = XZContentStatusView.init() {
            didSet {
                manager.updateAppearance()
            }
        }
        
    }
    
}

extension XZContentStatus.Configuration: XZTextImageView.StatedAppearance {
    
    /// 状态视图默认为 XZTextImageButton 视图，支持添加触摸事件。
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        (view as? UIControl)?.addTarget(target, action: action, for: controlEvents)
    }
    
    public func text(for state: UIControl.State) -> String? {
        return (view as? XZTextImageView.StatedAppearance)?.text(for: state)
    }
    
    public func setText(_ text: String?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setText(text, for: state)
    }
    
    public func attributedText(for state: UIControl.State) -> NSAttributedString? {
        return (view as? XZTextImageView.StatedAppearance)?.attributedText(for: state)
    }
    
    public func setAttributedText(_ attributedText: NSAttributedString?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setAttributedText(attributedText, for: state)
    }
    
    public func font(for state: UIControl.State) -> UIFont? {
        return (view as? XZTextImageView.StatedAppearance)?.font(for: state)
    }
    
    public func setFont(_ font: UIFont?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setFont(font, for: state)
    }
    
    public func textColor(for state: UIControl.State) -> UIColor? {
        return (view as? XZTextImageView.StatedAppearance)?.textColor(for: state)
    }
    
    public func setTextColor(_ textColor: UIColor?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setTextColor(textColor, for: state)
    }
    
    public func textShadowColor(for state: UIControl.State) -> UIColor? {
        return (view as? XZTextImageView.StatedAppearance)?.textShadowColor(for: state)
    }
    
    public func setTextShadowColor(_ textShadowColor: UIColor?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setTextShadowColor(textShadowColor, for: state)
    }
    
    public func image(for state: UIControl.State) -> UIImage? {
        return (view as? XZTextImageView.StatedAppearance)?.image(for: state)
    }
    
    public func setImage(_ image: UIImage?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setImage(image, for: state)
    }
    
    public func backgroundImage(for state: UIControl.State) -> UIImage? {
        return (view as? XZTextImageView.StatedAppearance)?.backgroundImage(for: state)
    }
    
    public func setBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) {
        (view as? XZTextImageView.StatedAppearance)?.setBackgroundImage(backgroundImage, for: state)
    }
    
    public var style: XZTextImageView.Style {
        get { return (view as? XZTextImageView.StatedAppearance)?.style ?? .bottomText }
        set { (view as? XZTextImageView.StatedAppearance)?.style = newValue }
    }
    
    public var contentInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZTextImageView.StatedAppearance)?.contentInsets ?? .zero }
        set { (view as? XZTextImageView.StatedAppearance)?.contentInsets = newValue }
    }
    
    public var textInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZTextImageView.StatedAppearance)?.textInsets ?? .zero }
        set { (view as? XZTextImageView.StatedAppearance)?.textInsets = newValue }
    }
    
    public var imageInsets: NSDirectionalEdgeInsets {
        get { return (view as? XZTextImageView.StatedAppearance)?.imageInsets ?? .zero }
        set { (view as? XZTextImageView.StatedAppearance)?.imageInsets = newValue }
    }
}

nonisolated(unsafe) private var _manager = 0

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
