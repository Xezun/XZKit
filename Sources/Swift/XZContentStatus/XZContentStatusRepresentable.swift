//
//  XZContentStatusRepresentable.swift
//  XZKit
//
//  Created by Xezun on 2026/6/10.
//

import UIKit

/// UIView 或 UIViewController 声明遵循协议，即可自动获得 contentStatus 属性。
@MainActor public protocol XZContentStatusRepresentable: UIResponder {
    
    /// 当前视图或视图控制器的内容状态，值 nil 表示默认状态。
    var contentStatus: XZContentStatus? { get set }
    
    /// 当状态的属性 isInteractive 的值为 true 时，状态视图被点击时，此方法会被调用。
    /// ```swift
    /// func performContentUpdates(for contentStatus: XZContentStatus) -> XZContentStatus? {
    ///     // 重新加载页面数据
    ///     reloadData({ [weak self] error in
    ///         // 加载数据后，更新页面状态
    ///         self?.contentStatus = error ? .error : nil
    ///     })
    ///     // 页面进入加载状态
    ///     return .loading
    /// }
    /// ```
    /// - Parameter contentStatus: 此方法被调用时，页面的当前状态
    /// - Returns: 在此方法调用后，页面将要呈现状态
    func shouldPerformUpdates(for contentStatus: XZContentStatus) -> XZContentStatus?
    
}


extension XZContentStatusRepresentable {
    
    public var contentStatus: XZContentStatus? {
        get {
            return (objc_getAssociatedObject(self, &_wrapperView) as? XZContentStatus.WrapperView)?.statusValue
        }
        set {
            if let newValue = newValue {
                var wrapperView = objc_getAssociatedObject(self, &_wrapperView) as? XZContentStatus.WrapperView
                if wrapperView == nil {
                    if let view = self as? UIView {
                        wrapperView = XZContentStatus.WrapperView.init(for: self, view: view)
                    } else if let viewController = self as? UIViewController {
                        wrapperView = XZContentStatus.WrapperView.init(for: self, view: viewController.view)
                    } else {
                        fatalError("init(coder:) has not been implemented")
                    }
                    objc_setAssociatedObject(self, &_wrapperView, wrapperView!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                wrapperView!.statusValue = newValue
            } else if let wrapperView = objc_getAssociatedObject(self, &_wrapperView) as? XZContentStatus.WrapperView {
                wrapperView.removeFromSuperview()
                objc_setAssociatedObject(self, &_wrapperView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

nonisolated(unsafe) private var _wrapperView = 0
