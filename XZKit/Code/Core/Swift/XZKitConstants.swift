//
//  XZKitConstants.swift
//  XZKit
//
//  Created by mlibai on 2018/4/12.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

/// 仅在 **XZKitDEBUG** 模式下，才在控制台输出指定信息。
/// - Note: 该方法只是控制控制台文本输出，并不会减少构建 message 参数的运算。
/// - Note: 在输出比较消耗资源的内容时，最好还是使用 DEBUG 宏来控制，保证在正式环境中输出内容不被编译。
/// - Note: 使用 format 的方式，以减少在正式环境构造字符串带来额外的资源消耗。
/// - Note: 可以 `%@` 作为任意数据类型的格式占位符，同时也兼容 Objective-C 占位符格式。
///
/// ```swift
/// XZLog("%@", false) // 输出：false
/// XZLog("%d", true)  // 输出：1
/// XZLog("%@ is %@ year(s) old.", "Xiao Ming", 12);
/// // 输出：Xiao Ming is 12 year(s) old.
/// XZLog("%@ is %.2f meter(s) in height.", "Xiao Ming", 1.512);
/// // 输出：Xiao Ming is 1.51 meter(s) in height.
/// ```
///
/// - Parameters:
///   - format: 输出格式。
///   - arguments: 参数。
///   - file: 文件名，可选。
///   - function: 函数名，可选。
///   - line: 行数，可选。
public func XZLog(_ format: String, file: String = #file, function: String = #function, line: Int = #line, _ arguments: Any? ...) {
    guard isDebugMode else {
        return
    }
    let date = Date().formatted(with: "yyyy-MM-dd HH:mm:ss.SSS")
    let comment = "§ \(file.split(separator: "/").last!)(\(line)) § \(function) § \(date) §"
    let line = String.init(repeating: "-", count: comment.count)
    print("\(line)\n\(comment)\n\(line)\n\(String.init(formats: format, arguments: arguments))\n")
}

extension TimeInterval {
    
    /// 格林尼治起始时间到现在的时间间隔。
    public static var since1970: TimeInterval {
        return __xz_timestamp();
    }
    
}




/// 该协议已废弃。
///
/// Swift 5.0 已支持限定协议的可继承的类型，例如。
/// ```swift
/// protocol Foo: UIView { }
/// ```
///
/// Swift 4.2 指定协议为指定的对象类型，
/// 但是当讲协议作为类型使用时，编译器不能识别该类型为对象，造成无法修改属性、无法使用值关联等问题。
/// 而指定协议为 AnyObject 类型，可以解决不能识别为对象的问题，编译器却不认为这是多余的声明。
/// 因此 ObjectProtocol 即为解决此问题而定义。
///
/// 例如下面的例子，无法修改对象的 name 属性，即使该属性被定义为可写，因为编译器不认为它是对象。
/// ```swift
/// protocol Foo where Self: UIView {
///     var name: String? { get set }
/// }
/// let foo: Foo = ... // Create a object which comforms to Foo.
/// foo.name = "Foo" // Error.
/// ```
/// 在下面的例子中，编译器认为协议继承 AnyObject 是多余的，而上面的例子明显又不符合要求。
/// ```swift
/// protocol Foo: AnyObject where Self: UIView { // Xcode warning here.
///     var name: String? { get set }
/// }
/// ```
/// 为了解决上述两个问题，继承 ObjectProtocol 协议，例如下面的代码则可以完美运行。
/// ```swift
/// protocol Foo: ObjectProtocol where Self: UIView {
///     var name: String? { get set }
/// }
/// let foo: Foo
/// foo.name = "Foo Object"
/// ```
@available(swift, deprecated: 5.0, message: "Swift 5.0 协议已支持直接“继承”指定的类型。")
public protocol ObjectProtocol: Swift.AnyObject {

}

/// 可解包多重可选值解包。
/// - Note: 解包用到了反射机制，在性能上不是最优的。
/// - Note: 在值类型确定的情况下，用指定类型的解包函数性能更好。
/// ```swift
/// let name: Any? = "John"
/// let data: Any = ["name": name]
/// if let dict = data as? [String: Any] {
///     if let name = dict["name"] {
///         print(name) // prints: Optional("John")
///     }
///     if let name = unwrap(dict["name"]) {
///         print(name) // prints: John
///     }
/// }
/// ```
///
/// - Parameters:
///   - value: 可选值。
///   - default: 默认值。
/// - Returns: 解包后的值或默认值。
@available(swift, deprecated: 5.0, message: "Swift 5.0 已经不会再有多次包装的可选类型。")
public func unwrap(_ value: Any?) -> Any? {
    guard let value = value else { return nil }
    let mirror = Mirror(reflecting: value)
    guard mirror.displayStyle == .optional else {
        return value
    }
    return unwrap(mirror.children.first?.value)
}

extension OptionSet where Self.RawValue: FixedWidthInteger {
    
    /// No options, rawValue is 0.
    /// - Note: 原始值为 0 的 OptionSet 。
    @available(swift, deprecated: 5.0, message: "请使用空数组 [] 代替。")
    public static var none: Self {
        return Self.init(rawValue: 0)
    }
    
}

