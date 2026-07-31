//
//  XZMocoa.swift
//  XZKit
//
//  Created by Xezun on 2025/1/25.
//

#if SWIFT_PACKAGE
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
extension XZMocoaEvents.Name: @retroactive ExpressibleByStringLiteral {
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





extension XZMocoaKey {
    public static var `default`: XZMocoaKey {
        return "default";
    }
    public static var contentStatus: XZMocoaKey {
        return "contentStatus";
    }
    public static var status: XZMocoaKey {
        return "status";
    }
    public static var isChecked: XZMocoaKey {
        return "isChecked";
    }
    public static var isEnabled: XZMocoaKey {
        return "isEnabled";
    }
    public static var value: XZMocoaKey {
        return "value";
    }
    public static var name: XZMocoaKey {
        return "name";
    }
    public static var icon: XZMocoaKey {
        return "icon";
    }
    public static var isHidden: XZMocoaKey {
        return "isHidden";
    }
    public static var text: XZMocoaKey {
        return "text";
    }
    public static var font: XZMocoaKey {
        return "font";
    }
    public static var textColor: XZMocoaKey {
        return "textColor";
    }
    public static var shadowColor: XZMocoaKey {
        return "shadowColor";
    }
    public static var attributedText: XZMocoaKey {
        return "attributedText";
    }
    public static var highlightedTextColor: XZMocoaKey {
        return "highlightedTextColor";
    }
    public static var placeholder: XZMocoaKey {
        return "placeholder";
    }
    public static var image: XZMocoaKey {
        return "image";
    }
    public static var highlightedImage: XZMocoaKey {
        return "highlightedImage";
    }
    public static var isAnimating: XZMocoaKey {
        return "isAnimating";
    }
    public static var imageURL: XZMocoaKey {
        return "imageURL";
    }
    public static var title: XZMocoaKey {
        return "title";
    }
    public static var attributedTitle: XZMocoaKey {
        return "attributedTitle";
    }
    public static var subtitle: XZMocoaKey {
        return "subtitle";
    }
    public static var detailText: XZMocoaKey {
        return "detailText";
    }
    public static var startAnimating: XZMocoaKey {
        return "startAnimating";
    }
    public static var stopAnimating: XZMocoaKey {
        return "stopAnimating";
    }
    public static var isRefreshing: XZMocoaKey {
        return "isRefreshing";
    }
    public static var isRequesting: XZMocoaKey {
        return "isRequesting";
    }
    public static var isLoading: XZMocoaKey {
        return "isLoading";
    }
    public static var isOn: XZMocoaKey {
        return "isOn";
    }
    public static var isTranslucent: XZMocoaKey {
        return "isTranslucent";
    }
    public static var prefersLargeTitles: XZMocoaKey {
        return "prefersLargeTitles";
    }
}

extension XZMocoaKey {
    public var `default`: XZMocoaKey {
        return "default";
    }
    public var contentStatus: XZMocoaKey {
        return "contentStatus";
    }
    public var status: XZMocoaKey {
        return "status";
    }
    public var isChecked: XZMocoaKey {
        return "isChecked";
    }
    public var isEnabled: XZMocoaKey {
        return "isEnabled";
    }
    public var value: XZMocoaKey {
        return "value";
    }
    public var name: XZMocoaKey {
        return "name";
    }
    public var icon: XZMocoaKey {
        return "icon";
    }
    public var isHidden: XZMocoaKey {
        return "isHidden";
    }
    public var text: XZMocoaKey {
        return "text";
    }
    public var font: XZMocoaKey {
        return "font";
    }
    public var textColor: XZMocoaKey {
        return "textColor";
    }
    public var shadowColor: XZMocoaKey {
        return "shadowColor";
    }
    public var attributedText: XZMocoaKey {
        return "attributedText";
    }
    public var highlightedTextColor: XZMocoaKey {
        return "highlightedTextColor";
    }
    public var placeholder: XZMocoaKey {
        return "placeholder";
    }
    public var image: XZMocoaKey {
        return "image";
    }
    public var highlightedImage: XZMocoaKey {
        return "highlightedImage";
    }
    public var isAnimating: XZMocoaKey {
        return "isAnimating";
    }
    public var imageURL: XZMocoaKey {
        return "imageURL";
    }
    public var title: XZMocoaKey {
        return "title";
    }
    public var attributedTitle: XZMocoaKey {
        return "attributedTitle";
    }
    public var subtitle: XZMocoaKey {
        return "subtitle";
    }
    public var detailText: XZMocoaKey {
        return "detailText";
    }
    public var startAnimating: XZMocoaKey {
        return "startAnimating";
    }
    public var stopAnimating: XZMocoaKey {
        return "stopAnimating";
    }
    public var isRefreshing: XZMocoaKey {
        return "isRefreshing";
    }
    public var isRequesting: XZMocoaKey {
        return "isRequesting";
    }
    public var isLoading: XZMocoaKey {
        return "isLoading";
    }
    public var isOn: XZMocoaKey {
        return "isOn";
    }
    public var isTranslucent: XZMocoaKey {
        return "isTranslucent";
    }
    public var prefersLargeTitles: XZMocoaKey {
        return "prefersLargeTitles";
    }
}
