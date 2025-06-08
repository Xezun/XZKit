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

@attached(member, names: named(Key))
public macro mocoa() = #externalMacro(module: "XZMocoaMacros", type: "MocoaMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro mocoaKey() = #externalMacro(module: "XZMocoaMacros", type: "MocoaKeyMacro")

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



