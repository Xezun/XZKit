//
//  NavigationBar.swift
//  Example
//
//  Created by Xu Zhen on 2018/9/26.
//  Copyright © 2018 mlibai. All rights reserved.
//

import UIKit
import XZKit

// 拓展 NavigationGestureDrivable 提供默认行为。

extension NavigationGestureDrivable {
    
    public func viewControllerForPushGestureNavigation(_ navigationController: UINavigationController) -> UIViewController? {
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, edgeInsetsForGestureNavigation operation: UINavigationController.Operation) -> UIEdgeInsets? {
        return nil
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, edgesInsetsForGestureNavigation operation: UINavigationController.Operation) -> UIEdgeInsets? {
        return nil
    }
}

// 为控制器拓展 NavigationBarCustomizable 使控制器有自定义的导航条 navigationBar 。

extension NavigationBarCustomizable where Self: UIViewController {
    
    var navigationBar: NavigationBar {
        if let navigationBar = objc_getAssociatedObject(self, &AssociationKey.navigationBar) as? NavigationBar {
            return navigationBar
        }
        let navigationBar = NavigationBar.init(frame: UIScreen.main.bounds)
        objc_setAssociatedObject(self, &AssociationKey.navigationBar, navigationBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return navigationBar
    }
    
    public var navigationBarIfLoaded: (UIView & NavigationBaring)? {
        return objc_getAssociatedObject(self, &AssociationKey.navigationBar) as? NavigationBar
    }
    
}

private struct AssociationKey {
    static var navigationBar = 0
}

// 自定义导航条。

class NavigationBar: XZKit.NavigationBar {
    
    override var prefersLargeTitles: Bool {
        didSet {
            if prefersLargeTitles {
                guard self.largeTitleView == nil else { return }
                let largeTitleView = LargeTitleView.init(frame: bounds)
                largeTitleView.textLabel.text = title
                self.largeTitleView = largeTitleView
            } else {
                self.largeTitleView = nil
            }
        }
    }

    /// 标题文字。
    /// - Note: 显示标题文字的视图为 TitledImageView ，如果使用了其它自定义标题视图，则此属性将不起作用。
    open var title: String? {
        get {
            return (titleView as? TextImageView)?.text
        }
        set {
            if let titleView = self.titleView {
                guard let textImageView = titleView as? TextImageView else { return }
                textImageView.text = newValue
                textImageView.sizeToFit()
                self.setNeedsLayout()
            } else {
                let textImageView = TextImageView.init(frame: .zero)
                textImageView.text = newValue
                textImageView.sizeToFit()
                self.titleView = textImageView
            }
            guard prefersLargeTitles else {
                return
            }
            if let largeTitleView = self.largeTitleView {
                guard let largeTitleView = largeTitleView as? LargeTitleView else { return }
                largeTitleView.textLabel.text = newValue
            } else {
                let largeTitleView = LargeTitleView.init(frame: bounds)
                largeTitleView.textLabel.text = newValue
                self.largeTitleView = largeTitleView
            }
        }
    }
    
    /// 标题图片。
    /// - 如果同时设置了标题文字和标题图片，文字和图片为上下显示的。
    /// - 显示标题图片的视图为 TitledImageView ，如果使用了其它自定义标题视图，则此属性将不起作用。
    open var titleImage: UIImage? {
        get {
            return (titleView as? TextImageView)?.image
        }
        set {
            if let titleView = self.titleView {
                guard let textImageView = titleView as? TextImageView else { return }
                textImageView.image = newValue
                textImageView.sizeToFit()
                self.setNeedsLayout()
            } else {
                let textImageView = TextImageView.init(frame: .zero)
                textImageView.image = newValue
                self.titleView = textImageView
            }
        }
    }
    
    /// 标题文本颜色。
    open var titleTextColor: UIColor? {
        get {
            return (titleView as? TextImageView)?.textLabelIfLoaded?.textColor
        }
        set {
            if let titleView = self.titleView {
                guard let textImageView = titleView as? TextImageView else { return }
                textImageView.textLabel.textColor = newValue
            } else {
                let textImageView = TextImageView.init(frame: .zero)
                textImageView.textLabel.textColor = newValue
                self.titleView = textImageView
            }
        }
    }
    
    /// 标题文本字体。
    open var titleTextFont: UIFont? {
        get {
            return (titleView as? TextImageView)?.textLabelIfLoaded?.font
        }
        set {
            if let titleView = self.titleView {
                guard let textImageView = titleView as? TextImageView else { return }
                textImageView.textLabel.font = newValue
                textImageView.sizeToFit()
                setNeedsLayout()
            } else {
                let textImageView = TextImageView.init(frame: .zero)
                textImageView.textLabel.font = newValue
                self.titleView = textImageView
            }
        }
    }
    
    /// 返回按钮，懒加载。
    /// - 返回按钮会默认添加返回事件。
    /// - 如果当前 backView 已自定义，那么此属性为 nil 。
    open var backButton: UIButton? {
        if let backView = self.backView {
            return backView as? UIButton
        }
        let backButton = NavigationBar.Button(type: .system)
        backButton.titleLabel!.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        backButton.addTarget(self, action: #selector(XZKit_backButtonAction(_:)), for: .touchUpInside)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        self.backView = backButton
        return backButton
    }
    
    @objc private func XZKit_backButtonAction(_ button: UIButton) {
        var responder = self.next
        while let next = responder {
            if let navigationController = next as? UINavigationController {
                navigationController.popViewController(animated: true)
                break
            } else {
                responder = responder?.next
            }
        }
    }
    
    /// 信息按钮，懒加载。
    /// - 默认情况下，如果 infoView 未自定义时，将创建 UIButton 作为 infoView 。
    /// - 如果 infoView 已自定义，那么此属性可能为 nil 。
    open var infoButton: UIButton? {
        if let infoView = self.infoView  {
            return infoView as? UIButton
        }
        let infoButton = NavigationBar.Button(type: .system)
        infoButton.titleLabel!.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        infoButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.infoView = infoButton
        return infoButton
    }
    
    @objc(XZNavigationBarButton)
    public final class Button: UIButton {

    }
    
    @objc(XZNavigationBarLargeTitleView)
    public class LargeTitleView: UIView {
        
        public let textLabel = UILabel.init()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            didInitialize()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            didInitialize()
        }
        
        private func didInitialize() {
            clipsToBounds = true
            
            textLabel.font = UIFont.systemFont(ofSize: 24.0)
            textLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            addSubview(textLabel)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            textLabel.sizeToFit()
            textLabel.frame = CGRect.init(x: bounds.minX + 8.0, y: bounds.maxY - 52.0, width: bounds.width - 16.0, height: 52.0)
        }
        
        
        
    }
}

