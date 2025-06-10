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
public macro module<T>(_ value: T) -> XZMocoaModule = #externalMacro(module: "XZMocoaMacros", type: "MocoaModuleMacro")


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
public macro mocoa(_ role: Role) = #externalMacro(module: "XZMocoaMacros", type: "MocoaMacro")

// MARK: - @key

/// 不带参数，使用属性名作为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key() = #externalMacro(module: "XZMocoaMacros", type: "MocoaKeyMacro")

/// 单个参数且不带标签，参数为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: String) = #externalMacro(module: "XZMocoaMacros", type: "MocoaKeyMacro")

/// 单个参数，带 value 标签，使用属性名作为键并，value 参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(value: Any) = #externalMacro(module: "XZMocoaMacros", type: "MocoaKeyMacro")

/// 两个参数：第一个参数为键名，第二个参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: String, _ value: Any) = #externalMacro(module: "XZMocoaMacros", type: "MocoaKeyMacro")

@attached(peer, names: arbitrary)
public macro bind(_ name: XZMocoaKey...) = #externalMacro(module: "XZMocoaMacros", type: "MocoaBindMacro")

//@freestanding(expression)
//public macro bind(text textLabel: UILabel, _ viewModel: XZMocoaViewModel, _ key: XZMocoaKey = .text, _ value: Any? = nil) = #externalMacro(module: "XZMocoaMacros", type: "MocoaBindLabelMacro")
//
//@freestanding(expression)
//public macro bind(text textView: UITextView, _ viewModel: XZMocoaViewModel, _ key: XZMocoaKey = .text, _ value: Any? = nil) = #externalMacro(module: "XZMocoaMacros", type: "MocoaBindTextViewMacro")
//
//@freestanding(expression)
//public macro bind(image imageView: UIImageView, _ viewModel: XZMocoaViewModel, _ key: XZMocoaKey = .image, _ value: Any? = nil) = #externalMacro(module: "XZMocoaMacros", type: "MocoaBindImageViewMacro")

//@InitializerDeclSyntax
//func registerModule() {
//    
//}
//
//@attached(memberAttribute)
//public macro func mocoaKey() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

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



