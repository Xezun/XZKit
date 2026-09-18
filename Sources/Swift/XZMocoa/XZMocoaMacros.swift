//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/6/13.
//

import Foundation
#if SWIFT_PACKAGE
import XZKitObjC


// KVC: @objc
// KVO: @objc + dynamic
//
// 宏 names 的作用：辅助编译器检查语法。
// - accessor 宏，若指定 names 为 arbitrary 则编译器会认为宏会生成 setter 和 getter 从而导致无法修饰只读属性。

/// 被宏 `@mocoa` 修饰的对象，在 Mocoa 中的角色。
public enum XZMocoaRole {
    /// 被修饰的对象为 Model 数据模型。
    case m
    /// 被修饰的对象为 View 视图。
    case v
    /// 被修饰的对象为 ViewModel 视图模型。
    case vm
}


// ------------------------------------------------------------
// MARK: - #module 宏
// ------------------------------------------------------------

/// 获取地址为 urlString 的 Mocoa 模块。
///
/// ```swift
/// #module("https://mocoa.xezun.com/main")
/// ```
@freestanding(expression)
public macro module(_ urlString: String) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "ModuleMacro")

/// 获取地址为 URL 的 Mocoa 模块。
@freestanding(expression)
public macro module(_ value: URL) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "ModuleMacro")


// ------------------------------------------------------------
// MARK: - @mocoa 宏
// ------------------------------------------------------------

/// 将 class 标记为 Mocoa 的 MVVM 角色。
///
/// - 标记为 Model 角色
///
/// ```swift
/// @mocoa(.m)
/// class Model: NSObject { }
/// ```
///
/// - 标记为 View 角色
/// ```
/// @mocoa(.v)
/// class View: UIView, XZMocoaView { }
/// ```
///
/// - 标记为 ViewModel 角色
/// ```swift
/// @mocoa(.vm)
/// class ViewModel: XZMocoaViewModel { }
/// ```
///
/// - SeeAlso: 如果 class 的命名符合规范，那么可省略 role 参数，参见无参数的 `@mocoa` 宏。
@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa(_ role: XZMocoaRole) = #externalMacro(module: "XZKitMacros", type: "MocoaMacro")

/// 将 class 标记为 Mocoa 的 MVVM 角色，并自动推断其角色类型。
///
/// 角色命名规范：
/// - ViewModel 角色：继承自 XZMocoaViewModel 或以 ViewModel 结尾
/// - Model 角色：继承自 XZMocoaModel 或以 Model 结尾
/// - View 角色：继承自 UIView、UIViewController、XZMocoaView 或以 View/Controller/Cell/Bar 结尾
///
/// ```swift
/// // 自动推断为 View 角色
/// @mocoa FooView: UIView { }
/// // 自动推断为 ViewModel 角色
/// @mocoa FooViewModel: XZMocoaViewModel { }
/// // 自动推断为 Model 角色
/// @mocoa FooModel: NSObject { }
/// ```
/// - SeeAlso: 更多使用规则见带参数的 `@mocoa(_:)` 宏。
@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa() = #externalMacro(module: "XZKitMacros", type: "MocoaMacro")


// ------------------------------------------------------------
// MARK: - @key 宏
// ------------------------------------------------------------

/// 标记 Model 属性为 KVO 键，或标记 ViewModel 的属性为 KTA 键。
///
/// 标记 Model 的属性，表明该属性支持 KVO 机制，其中宏参数为 KVO 的键，且键支持被 ViewModel 通过 @bind 宏绑定，通过 KVC 取值。
///
/// 标记 ViewModel 的属性，表明该属性支持 KTA 机制，其中宏参数为 KTA 的键，且键支持被 View 通过 @bind 宏绑定，通过 KVC 取值，以 KTA 事件值，传递给被绑定的方法。
///
/// > 属性所属的 class 需先用 `@mocoa` 标记。
///
/// ```swift
/// @key
/// var name: String?
/// // 宏展开后如下，其中 @objc 标记由 @mocoa 宏生成
/// @objc var name: String? {
///     didSet {
///         // 发送 KVO 或 KTA 事件的代码
///     }
/// }
/// ```
///
/// 若属性已实现 set 或 didSet 方法，那么宏不会再生成 didSet 方法，但是会检测是否包含发送 KVO 或 KTA 事件调用，如果不包含调用，会产生警告。
/// 如果事件不在 set 或 didSet 方法中触发，可在方法中添加注释以屏蔽警告。
///
/// ```swift
/// @key
/// var name: String? {
///     didSet {
///         // 下面这行含 didChangeValue 的注释可屏蔽 @key 宏产生的警告
///         // KVO 事件发送 didChangeValue(forKey:) 在其它方法中处理
///     }
/// }
/// ```
///
/// 宏参数为 XZMocoaKey 类型，支持支持使用字符串字面量，即`@key(.name)`等价于`@key("name")`。
///
/// - SeeAlso: 键名与属性名同名时，可不用指定 name 参数，详见不带参数的 ``key()`` 宏。
/// - Parameter name: KVO 键名或 KTA 键名
@attached(accessor, names: named(didSet))
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "KeyMacro")

/// 标记 Model 属性为 KVO 键，或标记 ViewModel 的属性为 KTA 键。
///
/// 使用属性名作为 KTA 或 KVO 的键名。
///
/// - SeeAlso: 更多使用规则，详见带参数的 ``key(_:)`` 宏。
@attached(accessor, names: named(didSet))
public macro key() = #externalMacro(module: "XZKitMacros", type: "KeyMacro")

// ------------------------------------------------------------
// MARK: @bind 宏
// ------------------------------------------------------------

/// 将指定键**单向绑定**到宏所修饰的属性或方法。
///
/// - 使用范围：视图、视图模型。
/// - 绑定键名：与“属性名”或“方法参数名”同名的键。
/// - 绑定目标：被宏修饰的属性或方法。
@attached(peer, names: prefixed(_))
public macro bind() = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将指定键**单次绑定**到宏所修饰的属性或方法。
///
/// - 使用范围：视图。
/// - 绑定键名：与“属性名”同名的键。
/// - 绑定目标：被宏修饰的属性或方法。
@attached(peer, names: prefixed(_))
public macro link() = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性或方法。
///
/// - 使用范围：视图、视图模型。
/// - 绑定键名：宏参数指定键名。
/// - 绑定目标：被宏修饰的属性或方法。
@attached(peer, names: prefixed(_))
public macro bind(_ key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单次绑定**到宏所修饰的属性或方法。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数指定键名。
/// - 绑定目标：被宏修饰的属性或方法。
@attached(peer, names: prefixed(_))
public macro link(_ key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key1、key2、keyN 键**单向绑定**到宏所修饰的方法。
///
/// - 使用范围：视图模型。
/// - 绑定键名：宏参数指定键名。
/// - 绑定目标：被宏修饰的方法。
@attached(peer, names: prefixed(_))
public macro bind(_ key1: XZMocoaKey, _ key2: XZMocoaKey, _ keyN: XZMocoaKey...) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏第一个参数指定键名。
/// - 绑定目标：被宏修饰属性的值对象的方法，方法名为宏第二个参数。
@attached(accessor, names: named(didSet))
public macro bind(_ key: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏第一个参数指定键名。
/// - 绑定目标：被宏修饰属性的值对象的方法，方法名为宏第二个参数。
@attached(accessor, names: named(didSet))
public macro link(_ key: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "BindMacro")


// MARK: - UIView

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isHidden 属性。
@attached(accessor, names: named(didSet))
public macro bind(isHidden key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isHidden 属性。
@attached(accessor, names: named(didSet))
public macro link(isHidden key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (alpha 属性。
@attached(accessor, names: named(didSet))
public macro bind(alpha key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (alpha 属性。
@attached(accessor, names: named(didSet))
public macro link(alpha key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (frame 属性。
@attached(accessor, names: named(didSet))
public macro bind(frame key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (frame 属性。
@attached(accessor, names: named(didSet))
public macro link(frame key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (bounds 属性。
@attached(accessor, names: named(didSet))
public macro bind(bounds key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (bounds 属性。
@attached(accessor, names: named(didSet))
public macro link(bounds key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (transform 属性。
@attached(accessor, names: named(didSet))
public macro bind(transform key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (transform 属性。
@attached(accessor, names: named(didSet))
public macro link(transform key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (tintColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(tintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (tintColor 属性。
@attached(accessor, names: named(didSet))
public macro link(tintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(backgroundColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundColor 属性。
@attached(accessor, names: named(didSet))
public macro link(backgroundColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UIControl

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isEnabled 属性。
@attached(accessor, names: named(didSet))
public macro bind(isEnabled key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isEnabled 属性。
@attached(accessor, names: named(didSet))
public macro link(isEnabled key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isSelected 属性。
@attached(accessor, names: named(didSet))
public macro bind(isSelected key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isSelected 属性。
@attached(accessor, names: named(didSet))
public macro link(isSelected key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isHighlighted 属性。
@attached(accessor, names: named(didSet))
public macro bind(isHighlighted key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isHighlighted 属性。
@attached(accessor, names: named(didSet))
public macro link(isHighlighted key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UILabel

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (text 属性。
@attached(accessor, names: named(didSet))
public macro bind(text key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (text 属性。
@attached(accessor, names: named(didSet))
public macro link(text key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedText 属性。
@attached(accessor, names: named(didSet))
public macro bind(attributedText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedText 属性。
@attached(accessor, names: named(didSet))
public macro link(attributedText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (font 属性。
@attached(accessor, names: named(didSet))
public macro bind(font key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (font 属性。
@attached(accessor, names: named(didSet))
public macro link(font key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (textColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(textColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (textColor 属性。
@attached(accessor, names: named(didSet))
public macro link(textColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (textAlignment 属性。
@attached(accessor, names: named(didSet))
public macro bind(textAlignment key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (textAlignment 属性。
@attached(accessor, names: named(didSet))
public macro link(textAlignment key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UIImageView

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (image 属性。
@attached(accessor, names: named(didSet))
public macro bind(image key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (image 属性。
@attached(accessor, names: named(didSet))
public macro link(image key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (animationImages 属性。
@attached(accessor, names: named(didSet))
public macro bind(animationImages key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (animationImages 属性。
@attached(accessor, names: named(didSet))
public macro link(animationImages key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UITextField

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (placeholder 属性。
@attached(accessor, names: named(didSet))
public macro bind(placeholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (placeholder 属性。
@attached(accessor, names: named(didSet))
public macro link(placeholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedPlaceholder 属性。
@attached(accessor, names: named(didSet))
public macro bind(attributedPlaceholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedPlaceholder 属性。
@attached(accessor, names: named(didSet))
public macro link(attributedPlaceholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UITextView

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isEditable 属性。
@attached(accessor, names: named(didSet))
public macro bind(isEditable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isEditable 属性。
@attached(accessor, names: named(didSet))
public macro link(isEditable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isSelectable 属性。
@attached(accessor, names: named(didSet))
public macro bind(isSelectable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isSelectable 属性。
@attached(accessor, names: named(didSet))
public macro link(isSelectable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UISlider

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (value 属性。
@attached(accessor, names: named(didSet))
public macro bind(value key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (value 属性。
@attached(accessor, names: named(didSet))
public macro link(value key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UISwitch

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isOn 属性。
@attached(accessor, names: named(didSet))
public macro bind(isOn key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isOn 属性。
@attached(accessor, names: named(didSet))
public macro link(isOn key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - UIButton

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (title 属性。
@attached(accessor, names: named(didSet))
public macro bind(title key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (title 属性。
@attached(accessor, names: named(didSet))
public macro link(title key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedTitle 属性。
@attached(accessor, names: named(didSet))
public macro bind(attributedTitle key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedTitle 属性。
@attached(accessor, names: named(didSet))
public macro link(attributedTitle key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (titleColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(titleColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (titleColor 属性。
@attached(accessor, names: named(didSet))
public macro link(titleColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (titleShadowColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(titleShadowColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (titleShadowColor 属性。
@attached(accessor, names: named(didSet))
public macro link(titleShadowColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (image 属性。
@attached(accessor, names: named(didSet))
public macro bind(image key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (image 属性。
@attached(accessor, names: named(didSet))
public macro link(image key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundImage 属性。
@attached(accessor, names: named(didSet))
public macro bind(backgroundImage key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundImage 属性。
@attached(accessor, names: named(didSet))
public macro link(backgroundImage key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// MARK: - Other

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (color 属性。
@attached(accessor, names: named(didSet))
public macro bind(color key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (color 属性。
@attached(accessor, names: named(didSet))
public macro link(color key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (name 属性。
@attached(accessor, names: named(didSet))
public macro bind(name key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (name 属性。
@attached(accessor, names: named(didSet))
public macro link(name key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (barTintColor 属性。
@attached(accessor, names: named(didSet))
public macro bind(barTintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (barTintColor 属性。
@attached(accessor, names: named(didSet))
public macro link(barTintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundImage 属性。
@attached(accessor, names: named(didSet))
public macro bind(backgroundImage key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (backgroundImage 属性。
@attached(accessor, names: named(didSet))
public macro link(backgroundImage key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isTranslucent 属性。
@attached(accessor, names: named(didSet))
public macro bind(isTranslucent key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (isTranslucent 属性。
@attached(accessor, names: named(didSet))
public macro link(isTranslucent key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (style 属性。
@attached(accessor, names: named(didSet))
public macro bind(style key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (style 属性。
@attached(accessor, names: named(didSet))
public macro link(style key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (state 属性。
@attached(accessor, names: named(didSet))
public macro bind(state key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (state 属性。
@attached(accessor, names: named(didSet))
public macro link(state key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (status 属性。
@attached(accessor, names: named(didSet))
public macro bind(status key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (status 属性。
@attached(accessor, names: named(didSet))
public macro link(status key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (title 属性。
@attached(accessor, names: named(didSet))
public macro bind(title key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (title 属性。
@attached(accessor, names: named(didSet))
public macro link(title key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedTitle 属性。
@attached(accessor, names: named(didSet))
public macro bind(attributedTitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (attributedTitle 属性。
@attached(accessor, names: named(didSet))
public macro link(attributedTitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (subtitle 属性。
@attached(accessor, names: named(didSet))
public macro bind(subtitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (subtitle 属性。
@attached(accessor, names: named(didSet))
public macro link(subtitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (detailText 属性。
@attached(accessor, names: named(didSet))
public macro bind(detailText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (detailText 属性。
@attached(accessor, names: named(didSet))
public macro link(detailText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (icon 属性。
@attached(accessor, names: named(didSet))
public macro bind(icon key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (icon 属性。
@attached(accessor, names: named(didSet))
public macro link(icon key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

/// 将 key 键**单向绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (viewModel 属性。
@attached(accessor, names: named(didSet))
public macro bind(viewModel key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
/// 将 key 键**单次绑定**到宏所修饰的属性的值的属性。
///
/// - 使用范围：视图。
/// - 绑定键名：宏参数 key 的值。
/// - 绑定目标：被宏修饰属性的值对象的 (viewModel 属性。
@attached(accessor, names: named(didSet))
public macro link(viewModel key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")



#endif
