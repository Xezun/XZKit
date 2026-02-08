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

/// 定制化的导航条外观变化时，需要向原生导航条同步的属性枚举。
public enum XZNavigtionBarAppearanceAttribute {
    case isHidden
    case isTranslucent
    case prefersLargeTitles
}

extension XZNavigationBar {
    
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
    
    /// 定制化导航条所属控制器的导航控制器。
    public var navigationController: UINavigationController? {
        var next = self.next
        
        repeat {
            if let navigationController = next as? UINavigationController {
                return navigationController
            }
            
            if let viewController = next as? UIViewController {
                return viewController.navigationController
            }
            
            next = next?.next
        } while next != nil
        
        return nil
    }
    
}
