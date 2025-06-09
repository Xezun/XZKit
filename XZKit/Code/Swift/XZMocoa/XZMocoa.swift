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
extension XZMocoaViewModel.Key: @retroactive ExpressibleByStringLiteral {
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


@freestanding(expression)
public macro mocoa<T>(_ value: T) -> XZMocoaModule = #externalMacro(module: "XZMocoaMacros", type: "MocoaMacro")

@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa() = #externalMacro(module: "XZMocoaMacros", type: "MocoaMacro")

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

@attached(body)
public macro bind(_ name: String...) = #externalMacro(module: "XZMocoaMacros", type: "MocoaBindMacro")

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
extension XZMocoaViewModel.Key: ExpressibleByStringLiteral {
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



