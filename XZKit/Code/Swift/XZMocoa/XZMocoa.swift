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
extension XZMocoaViewModel.Updates.Key: @retroactive ExpressibleByStringLiteral {
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
extension XZMocoaOptions.Key: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

/// 通过 URL 构造 Mocoa 模块。
///
/// ```swift
/// #module("https://mocoa.xezun.com/main")
/// ```
@freestanding(expression)
public macro module<T>(_ value: T) -> XZMocoaModule = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaModuleMacro")


public enum Role {
    case m
    case v
    case vm
}

/// 为带 @key、@bind 的成员，添加 @objc 标记。
/// ```swift
/// @mocoa(.vm)
/// class ViewModel: XZMocoaViewModel {
///     @key name: String?
///     @bind func didChange(_ text: String?) {
///         name = text
///     }
/// }
/// @mocoa(.v)
/// class View: UIView, XZMocoaView {
///     @bind var textLabel: UILabel!
/// }
/// ```
@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa(_ role: Role) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaMacro")

// MARK: - @key

/// 不带参数，使用属性名作为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 单个参数且不带标签，参数为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 单个参数，带 value 标签，使用属性名作为键并，value 参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(value: Any) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 两个参数：第一个参数为键名，第二个参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: XZMocoaKey, _ value: Any) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 标记视图属性：绑定属性的默认值
/// ```swift
/// @mocoa(.v)
/// class View: UIView, XZMocoaView {
///
///     // 单向同步：将 viewModel.text 绑定给 textLabel.text
///     @bind
///     var textLabel: UILabel!
///
///     // 单向同步：将 viewModel.name  绑定给 textLabel.text
///     @bind(.name)
///     var textLabel: UILabel!
///
///     // 单向同步：将 viewModel.textColor 绑定给 textLabel.textColor
///     @bind(v: .textColor)
///     var textLabel: UILabel!
///
///     // 单向同步：将 viewModel.color 绑定给 textLabel.textColor
///     @bind(.color, .textColor)
///     var textLabel: UILabel!
///
///     // 单向同步：将 viewModel.imageURL 绑定给 -[imageView setImageWithURL:] 方法
///     @bind(.imageURL, selector: #selector(setImageWithURL:))
///     var imageView: UIImageView!
///
///     // 单向同步：将 viewModel.imageURL 绑定到此方法
///     @bind
///     func setAvatar(with imageURL: URL?) {
///         avatarImageView.sd_setImage(with: imageURL)
///     }
///
///     // 单向同步：将 viewModel.backgroundURL 绑定到此方法
///     @bind(.backgroundURL)
///     func setBackgroundImage(with imageURL: URL?) {
///         backgroundImageView.sd_setImage(with: imageURL)
///     }
///
/// }
/// ```
///
/// 标记视图模型：
/// ```swift
/// @mocoa(.vm)
/// class ViewModel: XZMocoaViewModel {
///
///     // 单向同步：将 model.name 绑定到 name 属性的 setter 方法
///     @bind
///     var name: String?
///
///     // 单向同步：将 model.desc 绑定到 description 属性的 setter 方法
///     @bind(.desc)
///     var description: String?
///
///     @bind
///     var didChange(min: Int, max: Int) {
///         // 将 model.min、model.max 绑定到当前方法
///     }
///
///     @bind(var1, var2)
///     var didChange(min: Int, max: Int) {
///         // 将 model.var1、model.var2 绑定到当前方法
///     }
/// }
/// ```
@attached(peer, names: arbitrary)
public macro bind() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

@attached(peer, names: arbitrary)
public macro bind(_ key: XZMocoaKey...) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

@attached(peer, names: arbitrary)
public macro bind(v vkey: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

@attached(peer, names: arbitrary)
public macro bind(_ vmKey: XZMocoaKey, v vkey: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

@attached(peer, names: arbitrary)
public macro bind(_ vmKey: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

@attached(body)
public macro rewrite() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindViewMacro")

@attached(accessor, names: named(didSet))
public macro observe() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindViewMacro")

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
extension XZMocoaViewModel.Updates.Key: ExpressibleByStringLiteral {
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
extension XZMocoaOptions.Key: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#endif



