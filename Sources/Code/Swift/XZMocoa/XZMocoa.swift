//
//  XZMocoa.swift
//  XZKit
//
//  Created by 徐臻 on 2025/1/25.
//

#if SWIFT_PACKAGE
@_exported import _XZKitObjC
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



