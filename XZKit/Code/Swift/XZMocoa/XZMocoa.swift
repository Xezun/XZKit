//
//  XZMocoa.swift
//  XZKit
//
//  Created by 徐臻 on 2025/1/25.
//

#if SWIFT_PACKAGE
@_exported import XZMocoaObjC
extension XZMocoaKind: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaName: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaUpdatesKey: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaKey: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#else
extension XZMocoaKind: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaName: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaUpdatesKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#endif

public protocol XZMocoaView: UIResponder, __XZMocoaView {
    
}

extension UIResponder {
    /// 视图模型。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此属性。
    @NSManaged public var viewModel: XZMocoaViewModel?
    
    /// 视图模型改变前。
    @NSManaged public func viewModelWillChange()
    
    /// 视图模型改变之后。
    @NSManaged public func viewModelDidChange()
}

extension UIView {
    /// 当前视图所在的控制器。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此属性。
    @NSManaged public private(set) var viewController: UIViewController?
    
    /// 当前视图所在的导航控制器。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此属性。
    @NSManaged public private(set) var navigationController: UINavigationController?
    
    /// 当前视图所在的页签控制器。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此属性。
    @NSManaged public private(set) var tabBarController: UITabBarController?
    
    /// 能否执行 Segue 跳转。由控制器转发过来的 Segue 事件。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此方法。
    @NSManaged public func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    
    /// 执行 Segue 跳转前的准备工作，由控制器转发过来的 Segue 事件。
    ///
    /// 必须是遵循 XZMocoaView 协议的子类才可以访问此方法。
    @NSManaged public func prepare(for segue: UIStoryboardSegue, sender: Any?)
}
