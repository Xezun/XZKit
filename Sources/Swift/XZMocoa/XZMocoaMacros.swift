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
public macro mocoa() = #externalMacro(module: "XZKitMacros", type: "XZMocoaMacro")

// MARK: - @key

/// 标记 ViewModel 的属性，表明该属性支持 key-target-action 机制，支持在 View 中使用参数指定的 `name` 进行绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 被标记的属性，将变为计算属性，并同时生成带下划线的同名属性来存储属性值。
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
/// @bind(textColor: "color")
/// let nameLabel: UILabel
///
/// // 监听事件：ViewModel 发送的 "textColor" 事件
/// // 监听方法：nameLabel 的 #selector(setter: UILabel.textColor) 方法
/// @bind(textColor: "textColor")
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

@attached(accessor, names: named(didSet))
public macro bind(_ vmKey: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UIView

/// 建立从 ViewModel.{key} 到 View.tintColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(tintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.backgroundColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(backgroundColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UIControl

/// 建立从 ViewModel.{key} 到 View.isEnabled 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isEnabled key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.isSelected 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isSelected key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.isHighlighted 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isHighlighted key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UILabel

/// 建立从 ViewModel.{key} 到 View.text 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(text key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.attributedText 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(attributedText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.font 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(font key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.textColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(textColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.textAlignment 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(textAlignment key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UIImageView

/// 建立从 ViewModel.{key} 到 View.image 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(image key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.animationImages 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(animationImages key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UITextField

/// 建立从 ViewModel.{key} 到 View.placeholder 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(placeholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.attributedPlaceholder 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(attributedPlaceholder key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UITextView

/// 建立从 ViewModel.{key} 到 View.isEditable 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isEditable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.isSelectable 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isSelectable key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UISlider

/// 建立从 ViewModel.{key} 到 View.value 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(value key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UISwitch

/// 建立从 ViewModel.{key} 到 View.isOn 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isOn key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - UIButton

/// 建立从 ViewModel.{key} 到 View.normalTitle 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(title key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.attributedTitle 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(attributedTitle key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.titleColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(titleColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.titleShadowColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(titleShadowColor key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.image 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(image key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.backgroundImage 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(backgroundImage key: XZMocoaKey, for state: UIControl.State) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// MARK: - Other

/// 建立从 ViewModel.{key} 到 View.color 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(color key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.name 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(name key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.barTintColor 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(barTintColor key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.backgroundImage 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(backgroundImage key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.isTranslucent 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(isTranslucent key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.style 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(style key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.state 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(state key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.status 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(status key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.title 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(title key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.attributedTitle 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(attributedTitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.subtitle 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(subtitle key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 建立从 ViewModel.{key} 到 View.detailText 的单向绑定关系。
@attached(accessor, names: named(didSet))
public macro bind(detailText key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

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
