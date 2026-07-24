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


/// 单向同步，用于标记 Mocoa 中的 .v 和 .vm 角色的绑定标记。
///
/// ### 属性绑定
///
/// 标记 Mocoa 角色中，需要单向同步的属性。
///
/// 1. 在 Swift 中，需要使用 `dynamic` 修饰属性，否则无法使用 KVO
///
/// ```swift
/// @mocoa(.m)
/// class Model: NSObject {
///     @objc dynamic var name: String?
///     @objc dynamic var age: Int = 0
/// }
/// ```
///
/// 2. ViewModel 绑定 Model 的属性
///
/// ```swift
/// @mocoa(.vm)
/// class ViewModel: XZMocoaViewModel {
///
///     // 将 model.name 绑定到 #selector(setter: Self.name) 方法
///     @bind
///     var name: String?
///

///
///     // 将 model.min、model.max 绑定到当前方法
///     @bind
///     func didChange(_ min: Int, max: Int) { }
///
///
///     @bind(.var1, .var2)
///     func didChange(min: Int, max: Int) { }
/// }
/// ```
///
/// 3. View 绑定 ViewModel 的属性
///
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

///
///     // 将 viewModel.imageURL 绑定到此方法
///     @bind
///     func setAvatar(with imageURL: URL?) {
///         avatarImageView.sd_setImage(with: imageURL)
///     }
///
///
///
/// }
/// ```


/// 为 ViewModel 与 Model 之间，或 View 与 ViewModel 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// #### 在 ViewModel 中使用
///
/// - 将 ViewModel 的属性，与 Model 的同名属性进行绑定。
/// ```swift
/// @bind var name: String = "Visitor" // model.name 绑定到此属性
/// ```
/// - 将 ViewModel 方法参数名，与 Model 的同名属性进行绑定。
///
/// ```swift
/// // 主要用于 model 的属性需要处理后才能使用的情形
/// @key
/// var detail: String = "Waiting"
/// @bind
/// func statusValueChanged(_ status: Bool) {
///     // model.status 绑定到此方法，方法的参数名或标签名就是 model 的属性名
///     // 在此方法中更新 detail 间接实现将 model.status 绑定到 viewModel.detail
///     self.detail = status ? "Done" : "Waiting"
/// }
/// // 支持一个方法同时监听多个参数
/// @bind
/// func didChange(min: Int, max: Int) { }
/// ```
///
/// #### 在 View 中使用
///
/// 在 View 中，宏 `@bind` 绑定实际上是 ViewModel 的 KTA 事件值。
/// 一般情况下，请遵循约定，使用 ViewModel 的属性名作为 KTA 的事件名，在以下的表述中，ViewModel 属性即，表示以属性名为事件名的 KTA 事件的事件值。
///
/// - 将 View 的默认属性，与 ViewModel 同名属性绑定起来。
///
///     目前支持默认属性：
///     - UILabel.text
///     - UITextView.text
///     - UIImageView.image
///     - UISwitch.isOn
///
/// ```swift
/// @bind // 将 viewModel.text 绑定到 nameLabel.text
/// var nameLabel: UILabel = .init()
/// @bind // 将 viewModel.image 绑定到 iconImageView.image
/// var iconImageView: UIImageView = .init()
/// ```
///
/// - 将 View 方法的参数名，与 ViewModel 的同名属性绑定起来。
///
/// ```swift
/// @bind // 将 viewModel.imageURL 绑定到此方法的参数
/// func setBackgroundImage(with imageURL: URL?) {
///     imageView.sd_setImage(with: imageURL)
/// }
/// ```
@attached(peer, names: arbitrary)
public macro bind() = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

/// 为 ViewModel 与 Model 之间，或 View 与 ViewModel 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// #### 在 ViewModel 中使用
///
/// - 将 Model 的属性 `key` 绑定到宏所标记的 ViewModel 属性或方法
///
/// ```swift
/// // 将 model.desc 绑定到 age 属性方法
/// @bind("desc")
/// var age: String?
/// // 将 model.var 属性，绑定此方法，对应 age 参数
/// @bind(.var)
/// func didChange(age: Int) { }
/// ```
///
/// #### 在 View 中使用
///
/// - 将 ViewModel.key 属性，绑定到 View 的默认属性或方法
///
/// ```swift
/// // 将 viewModel.name 绑定给 textLabel.text
/// @bind(.name)
/// var textLabel: UILabel!
/// // 将 viewModel.backgroundURL 绑定到此方法
/// @bind(.backgroundURL)
/// func setBackgroundImage(with imageURL: URL?) {
///     backgroundImageView.sd_setImage(with: imageURL)
/// }
/// ```
///
/// - SeeAlso: ``bind()``
///
/// - Parameter key: Model 或 ViewModel 的属性
@attached(peer, names: arbitrary)
public macro bind(_ key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

/// 为 ViewModel 与 Model 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// > 支持在 ViewModel 中使用，不支持在 View 中使用。
///
/// 将 Model 的多个属性，绑定给 ViewModel 的方法，方法参数与属性一一对应。
///
/// ```swift
/// // 将 model 的 var1、var2 属性，绑定此当前方法，对应 min、max 参数
/// @bind(.var1, .var2)
/// func didChange(min: Int, max: Int) { }
/// ```
///
/// - SeeAlso: 方法参数名与属性名相同时，可省略 `@bind` 中的参数，详见 ``@bind()`` 不带参数的宏。
///
/// - Parameter key: Model的属性
@attached(peer, names: arbitrary)
public macro bind(_ mkey1: XZMocoaKey, mkey2: XZMocoaKey...) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 将 View.key 属性与 ViewModel.key 属性的进行绑定。
///
/// - Parameter key: ViewModel 和 View 的属性
@attached(accessor, names: named(didSet))
public macro bind(key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 将 View.vkey 属性与 ViewModel.vmkey 属性进行绑定。
///
/// - Parameters:
///   - vmkey: ViewModel 的属性
///   - vkey: View 的属性
@attached(accessor, names: named(didSet))
public macro bind(key vmKey: XZMocoaKey, _ vkey: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

/// 为 View 与 ViewModel 之间建立单向绑定。
///
/// 属性所属的 class 需先用 `@mocoa` 标记。
///
/// 将 View.selector() 方法与 ViewModel.vmkey 属性的进行绑定。
///
/// ```swift
/// // 将 viewModel.imageURL 绑定给 -[imageView setImageWithURL:] 方法
/// @bind(key: .imageURL, selector: #selector(setImageWithURL:))
/// var imageView: UIImageView!
/// ```
///
/// > 总结，在 View 中，宏 `@bind` 的第一个参数始终是 ViewModel 的属性，在同名时也是视图的属性。
///
/// - Parameters:
///   - vmkey: ViewModel 的属性
///   - selector: View 的方法
@attached(accessor, names: named(didSet))
public macro bind(key vmKey: XZMocoaKey, _ selector: Selector) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

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
