//
//  XZMocoaMacros.swift
//  XZKit
//
//  Created by Xezun on 2025/6/13.
//

import Foundation

/// 获取地址为 urlString 的 Mocoa 模块。
///
/// ```swift
/// #mocoa("https://mocoa.xezun.com/main")
/// ```
@freestanding(expression)
public macro mocoa(_ urlString: String) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "XZMocoaModuleMacro")

/// 获取地址为 URL 的 Mocoa 模块。
@freestanding(expression)
public macro mocoa(_ value: URL) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "XZMocoaModuleMacro")

/// 被宏 `@mocoa` 修饰的对象，在 Mocoa 中的角色。
public enum XZMocoaRole {
    /// 被修饰的对象为 Model 数据模型。
    case m
    /// 被修饰的对象为 View 视图。
    case v
    /// 被修饰的对象为 ViewModel 视图模型。
    case vm
}

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
public macro mocoa(_ role: XZMocoaRole) = #externalMacro(module: "XZKitMacros", type: "XZMocoaMacro")

/// 将 class 标记为 Mocoa 的 MVVM 角色，并自动推断其角色类型。
///
/// 角色命名规范：
/// - ViewModel 角色：继承自 XZMocoaViewModel 或以 ViewModel 结尾
/// - Model 角色：继承自 XZMocoaModel 或以 Model 结尾
/// - View 角色：继承自 UIView、UIViewController、XZMocoaView 或以 View/Controller/Cell/Bar 的结尾
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
public macro mocoa() = #externalMacro(module: "XZKitMacros", type: "XZMocoaMacro")

// MARK: - @key

/// 标记 ViewModel 的属性，表明该属性支持 key-target-action 机制，支持在 View 中使用参数指定的 `name` 进行绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 被标记的属性，将变为计算属性，并同时生成带下划的同名属性来存储属性值。
/// ```swift
/// @key
/// var name: String = "John"
/// // 等价于
/// var name: String {
///     get { return _name }
///     set { _name = newValue } // setter 还包括发送 key-action 事件的代码
/// }
/// var _name: String = "John"
/// ```
///
/// 设置属性自动发送 KTA 事件，值会同步到已绑定的视图，若不需要同步视图，可直接访问其带下划线的存储属性。
///
/// 框架为预置了一些通用的 key 名，方便直接使用点语法。
///
/// ```swift
/// @key(.name)
/// var desc: String?
/// ```
///
/// - SeeAlso: 事件名与属性名同名时，可不用指定 name 参数，参见不带参数的 `@key` 宏。
/// - Parameter name: 该属性变化时，发送 KTA 事件的事件名
@attached(peer, names: arbitrary)
@attached(accessor)
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaKeyMacro")

/// 标记 ViewModel 的属性，表明该属性支持 key-target-action 机制，支持在 View 中使用该属性名进行绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 使用属性名作为 KTA 事件的事件名。
///
/// - SeeAlso: 更多使用规则见带参数的 `@key(_:)` 宏。
@attached(peer, names: arbitrary)
@attached(accessor)
public macro key() = #externalMacro(module: "XZKitMacros", type: "XZMocoaKeyMacro")

/// 为 ViewModel 与 Model 之间，或 View 与 ViewModel 之间建立单向绑定。
///
/// > 必须与 `@mocoa` 配合使用。
///
/// #### 一、用于 ViewModel 角色
///
/// - 为 ViewModel 实现监听 Model 属性的能力。
/// - 修饰 ViewModel 的属性时，若不指定参数，表示绑定同名属性。
/// - 修饰 ViewModel 的方法时，若不指定参数，表示绑定与方法参数同名的属性。
///
/// ```swift
/// // 监听属性：Model.name
/// // 监听方法：setter: ViewModel.name
/// @bind
/// var name: String?
///
/// // 监听属性：Model.title
/// // 监听方法：setter: ViewModel.name
/// @bind("title")
/// var name: String?
///
/// // 监听属性：Model.foobar
/// // 监听方法：ViewModel.method(with:)
/// @bind
/// func method(with foobar: Int)
///
/// // 监听属性：Model.min & Model.max
/// // 监听方法：ViewModel.method(min:max:)
/// @bind
/// func method(min: Int, max: Int)
///
/// // 监听属性：Model.foo & Model.bar
/// // 监听方法：ViewModel.foobar(min:max:)
/// @bind("foo", "bar")
/// func foobar(min: Int, max: Int)
/// ```
///
/// #### 二、用于 View 角色
///
/// - 为 View 实现监听 ViewModel 的 Key-Target-Action （KTA）事件的能力。
/// - 修饰 View 的属性时，监听事件的方法是 View 属性值（子视图）的方法。
/// - 修饰 View 的属性时，若不指定监听的事件名，默认监听的事件名，与所修饰的属性类型有关：
///     - UILabel 默认监听 text 事件
///     - UITextView 默认监听 text 事件
///     - UITextField 默认监听 text 事件
///     - UIImageView 默认监听 image 事件
///     - UISwitch 默认监听 isOn 事件
/// - 修饰 View 的方法时，监听事件的方法是 View 的方法。
/// - 修饰 View 的方法时，只支持一个参数，一个方法只能监听一个事件。
/// - 用于 View 时，`@bind` 的第一个参数始终为 KTA 事件名，
///
/// ```swift
/// // 监听事件：ViewModel 发送的 "text" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.text)  方法
/// @bind
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "name" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.text)  方法
/// @bind("name")
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "color" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.textColor)  方法
/// @bind("color", "textColor")
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "textColor" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.textColor) 方法
/// @bind(key: "textColor")
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "color" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.textColor) 方法
/// @bind(key: "color", "textColor")
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "imageURL" 事件
/// // 监听方法：imageView 的 #selector(sd_setImageWithURL(_:) 方法
/// @bind(key: "imageURL", selector: #selector(sd_setImageWithURL(_:))
/// let imageView: UIImageView
///
/// // 监听事件：ViewModel 发送的 "iconURL" 事件
/// // 监听方法：View 的 setIconWithURL(_:) 方法
/// @bind
/// func setIconWithURL(_ iconURL: URL)
///
/// // 8. 监听 ViewModel 名为 "imageURL" 的 KTA 事件，监听的方法为视图 View 的 setIconWithURL(_:) 方法。
/// // 监听事件：ViewModel 发送的 "imageURL" 事件
/// // 监听方法：View 的 setIconWithURL(_:) 方法
/// @bind("imageURL")
/// func setIconWithURL(_ iconURL: URL)
/// ```
@attached(peer, names: arbitrary)
public macro bind() = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

/// 为 ViewModel 与 Model 之间，或 View 与 ViewModel 之间建立单向绑定。
///
/// - SeeAlso: 详细用法见不带参数的 ``bind()`` 宏。
///
/// - Parameter key: Model的属性
@attached(peer, names: arbitrary)
public macro bind(_ key1: XZMocoaKey, _ key2: XZMocoaKey...) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// - SeeAlso: 详细用法见不带参数的 ``bind()`` 宏。
@attached(accessor, names: named(didSet))
public macro bind(key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// - SeeAlso: 详细用法见不带参数的 ``bind()`` 宏。
///
/// - Parameters:
///   - vmkey: ViewModel 的属性
///   - vkey: View 的属性
@attached(accessor, names: named(didSet))
public macro bind(key vmKey: XZMocoaKey, _ vkey: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// - SeeAlso: 详细用法见不带参数的 ``bind()`` 宏。
///
/// - Parameters:
///   - vmkey: ViewModel 的属性
///   - selector: View 的方法
@attached(accessor, names: named(didSet))
public macro bind(key vmKey: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 标记方法为 View 或 ViewModel 的角色初始化方法（非对象的初始化方法）。
///
/// 此标记用以取代视图模型的`-[XZMocoaViewModel prepare]`基类方法。
///
/// 被标记的方法需要使用 `private` 标记，并且支持多个初始化方法，多个初始化方法将按书写顺序执行。
///
/// ```swift
/// class ViewModel: XZMocoaViewModel {
///
///     @prepare
///     private func setup() {
///
///     }
///
/// }
/// ```
@attached(body)
public macro prepare() = #externalMacro(module: "XZKitMacros", type: "XZMocoaPrepareMacro")
