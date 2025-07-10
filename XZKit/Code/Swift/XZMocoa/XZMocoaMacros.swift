//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by 徐臻 on 2025/6/13.
//

import Foundation

#if SWIFT_PACKAGE
@_exported import XZKitObjC
/// 通过 URL 构造 Mocoa 模块。
///
/// ```swift
/// #module("https://mocoa.xezun.com/main")
/// ```
@freestanding(expression)
public macro module<T>(_ value: T) -> XZMocoaModule = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaModuleMacro")

public enum XZMocoaRole {
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
public macro mocoa(_ role: XZMocoaRole) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaMacro")

@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaMacro")

// MARK: - @key

/// 标记 .vm 的属性，使其获得带下划线前缀的存储属性和自动发送 key-action 的能力。
/// 不带参数，使用属性名作为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 标记 .vm 的属性，使其获得带下划线前缀的存储属性和自动发送 key-action 的能力。
/// 单个参数且不带标签，参数为键名。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 标记 .vm 的属性，使其获得带下划线前缀的存储属性和自动发送 key-action 的能力。
/// 单个参数，带 value 标签，以属性名作为键，以 value 参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(value: Any) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 标记 .vm 的属性，使其获得带下划线前缀的存储属性和自动发送 key-action 的能力。
/// 两个参数：第一个参数为键名，第二个参数为初始值。
@attached(peer, names: arbitrary)
@attached(accessor, names: arbitrary)
public macro key(_ name: XZMocoaKey, _ value: Any) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaKeyMacro")

/// 单向同步：用于 .v 和 .vm 的普通绑定标记。
/// ```swift
/// @mocoa(.vm)
/// class ViewModel: XZMocoaViewModel {
///
///     // 将 model.name 绑定到 #selector(setter: Self.name) 方法
///     @bind
///     var name: String?
///
///     // 将 model.desc 绑定到 #selector(setter: Self.description) 方法
///     @bind(.desc)
///     var description: String?
///
///     // 将 model.min、model.max 绑定到当前方法
///     @bind
///     func didChange(_ min: Int, max: Int) { }
///
///     // 将 model.var1、model.var2 绑定到当前方法
///     @bind(var1, var2)
///     func didChange(min: Int, max: Int) { }
/// }
/// ```
@attached(peer, names: arbitrary)
public macro bind() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

/// 单向同步：用于 .v 和 .vm 的的普通绑定标记。
/// - SeeAlso: 不带参数的 `macro bind()` 宏
@attached(peer, names: arbitrary)
public macro bind(_ key: XZMocoaKey...) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindMacro")

/// 单向同步：专用于 .v 的绑定标记；如果属性为可选类型，将生成 `didSet` 以实现动态绑定。
/// ```swift
/// @mocoa(.v)
/// class View: UIView, XZMocoaView {
///
///     // 将 viewModel.text 绑定给 textLabel.text
///     @bind
///     var textLabel: UILabel!
///
///     // 将 viewModel.name  绑定给 textLabel.text
///     @bind(.name)
///     var textLabel: UILabel!
///
///     // 将 viewModel.textColor 绑定给 textLabel.textColor
///     @bind(v: .textColor)
///     var textLabel: UILabel!
///
///     // 将 viewModel.color 绑定给 textLabel.textColor
///     @bind(.color, .textColor)
///     var textLabel: UILabel!
///
///     // 将 viewModel.imageURL 绑定给 -[imageView setImageWithURL:] 方法
///     @bind(.imageURL, selector: #selector(setImageWithURL:))
///     var imageView: UIImageView!
///
///     // 将 viewModel.imageURL 绑定到此方法
///     @bind
///     func setAvatar(with imageURL: URL?) {
///         avatarImageView.sd_setImage(with: imageURL)
///     }
///
///     // 将 viewModel.backgroundURL 绑定到此方法
///     @bind(.backgroundURL)
///     func setBackgroundImage(with imageURL: URL?) {
///         backgroundImageView.sd_setImage(with: imageURL)
///     }
///
/// }
/// ```
@attached(accessor, names: named(didSet))
public macro bind(v vkey: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindViewMacro")

@attached(accessor, names: named(didSet))
public macro bind(_ vmKey: XZMocoaKey, v vkey: XZMocoaKey) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindViewMacro")

@attached(accessor, names: named(didSet))
public macro bind(_ vmKey: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaBindViewMacro")

@attached(body)
public macro ready() = #externalMacro(module: "XZMocoaMacros", type: "XZMocoaReadyMacro")
#endif
