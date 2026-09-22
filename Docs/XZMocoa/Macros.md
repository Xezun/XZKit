# XZMocoa Swift 宏详解

XZMocoa 提供了一套 Swift 宏，用于在编译期自动织入 MVVM 所需的样板代码（KVO/KTA 监听、`@objc` 标记、绑定注册等），让 Model、View、ViewModel 之间的协作以声明式的方式表达。

宏的实现代码位于 [`Sources/Macro/XZMocoa`](../../Sources/Macro/XZMocoa)，对外声明位于 `XZKitMacros` 编译插件中，随 `XZKit` 一起分发，导入 `XZKit` 即可使用。

```swift
import XZKit
```

> 本文聚焦宏本身的语法、展开结果与实现原理。关于 XZMocoa 框架的整体设计（模块、事件通道、列表渲染等），请参见 [XZMocoa](./README.md)。

---

## 一、宏体系总览

XZMocoa 共提供 4 个宏（含多种重载形式），分别对应 MVVM 的不同职责：

| 宏 | 形式 | 作用 | 适用角色 |
| --- | --- | --- | --- |
| `@mocoa` | `@mocoa` / `@mocoa(.m/.v/.vm)` | 将 class 标记为 MVVM 角色，织入 `@objc`、绑定注册、数据监听映射 | 类声明 |
| `@key` | `@key` / `@key(.name)` / `@key("name")` | 将属性改造为可发送 KVO 或 KTA 事件的属性 | Model、ViewModel |
| `@bind` | `@bind` / `@bind(.key)` / `@bind(text: .key)` … | 建立单向绑定（ViewModel 监听 Model 属性并主动观察 / View 监听 ViewModel 事件） | View、ViewModel |
| `@link` | `@link` / `@link(.key)` / `@link(text: .key)` … | 建立单次绑定（ViewModel 监听 Model 属性但不主动观察 / View 监听 ViewModel 事件） | View、ViewModel |
| `#module` | `#module("url")` / `#module(url)` | 通过模块 URL 获取 `XZMocoaModule` 对象 | 表达式 |

### 源码文件构成

| 文件 | 说明 |
| --- | --- |
| [`MocoaMacro.swift`](../../Sources/Macro/XZMocoa/MocoaMacro.swift) | `@mocoa` 宏实现（`MemberAttributeMacro` + `MemberMacro`） |
| [`KeyMacro.swift`](../../Sources/Macro/XZMocoa/KeyMacro.swift) | `@key` 宏实现（`AccessorMacro`） |
| [`BindMacro.swift`](../../Sources/Macro/XZMocoa/BindMacro.swift) | `@bind` / `@link` 宏实现（`PeerMacro` + `AccessorMacro`） |
| [`ModuleMacro.swift`](../../Sources/Macro/XZMocoa/ModuleMacro.swift) | `#module` 宏实现（`ExpressionMacro`） |
| [`XZKitMacros.swift`](../../Sources/Macro/XZKitMacros.swift) | 编译插件入口，含 `XZMacroMocoaRole` 角色枚举与推断逻辑、公共工具 |

所有宏通过 `XZKitMacros` 编译插件（[`XZKitMacros.swift`](../../Sources/Macro/XZKitMacros.swift)）注册：

```swift
@main
struct XZKitMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        URLMacro.self,
        XZLogMacro.self,
        MocoaMacro.self,
        ModuleMacro.self,
        KeyMacro.self,
        BindMacro.self
    ]
}
```

---

## 二、角色识别 `XZMocoaRole`

`@mocoa`、`@key`、`@bind` 的展开结果都取决于所属 class 的 MVVM 角色。角色由 `XZMocoaRole` 表示，取值 `.m`（Model）、`.v`（View）、`.vm`（ViewModel）。

角色推断遵循以下优先级（见 [`XZKitMacros.swift`](../../Sources/Macro/XZKitMacros.swift) 中的 `XZMacroMocoaRole`）：

1. **显式参数**：`@mocoa(.vm)` 中的 `role` 参数优先。参数不是合法枚举值时报错。
2. **继承类型**：
   - 继承 `XZMocoaModel` → `.m`
   - 继承 `XZMocoaViewModel` → `.vm`
   - 继承 `UIView` / `XZMocoaView` / `UIViewController` → `.v`
3. **命名后缀**：
   - 以 `ViewModel` 结尾 → `.vm`
   - 以 `View` / `Cell` / `Controller` / `Bar` 结尾 → `.v`
   - 以 `Model` 结尾 → `.m`
4. 以上都无法确定时，报错并提示通过 `role` 参数显式指定。

对于附加在**成员**（属性 / 方法）上的 `@key`、`@bind`，宏会向上查找所属 class 的 `@mocoa` 标记来确定角色。因此这些成员宏**必须与类上的 `@mocoa` 配合使用**，否则报错“无法确定所属的角色”。

```swift
// 显式指定角色
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel { }

// 自动推断：继承 XZMocoaViewModel → .vm
@mocoa
class UserViewModel: XZMocoaViewModel { }

// 自动推断：命名以 View 结尾 → .v
@mocoa
class UserView: UIView { }
```

---

## 三、`@mocoa` 宏

### 声明

```swift
@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa(_ role: XZMocoaRole) = #externalMacro(module: "XZKitMacros", type: "MocoaMacro")

@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa() = #externalMacro(module: "XZKitMacros", type: "MocoaMacro")
```

`@mocoa` 同时是一个 `MemberAttributeMacro`（为成员注入属性）和 `MemberMacro`（为类新增成员）。它只能用于 `class`，且对 `.m` 角色要求 class 继承自 `NSObject`。

### 3.1 注入 `@objc` 标记（MemberAttribute）

由于 KVO/KTA 依赖 Objective-C 运行时，被 `@key`、`@bind` 标记的成员需要 `@objc`。`@mocoa` 会自动补齐，规则如下：

| 角色 | 目标成员 | 注入条件 |
| --- | --- | --- |
| `.m` | `@key` 属性 | 未标记 `@objc` 时注入 `@objc` |
| `.v` | `@bind` / `@link` 方法 | 未标记 `@objc` / `@IBAction` 时注入 `@objc` |
| `.vm` | `@key`、`@bind` 或 `@link` 属性 | 未标记 `@objc` / `@key` / `@NSManaged` 时注入 `@objc` |
| `.vm` | `@bind` / `@link` 方法 | 未标记 `@objc` / `@IBAction` 时注入 `@objc` |

> View 角色的属性不需要 `@objc`（视图属性通过 setter 选择器绑定），因此 `.v` 只处理方法。

### 3.2 织入成员（Member）

#### `.v`（View）：生成 `__mocoa_bind_prepare()`

遍历类中所有 `@bind` 标记的属性与方法，生成绑定注册方法：

```swift
override func __mocoa_bind_prepare() {
    super.__mocoa_bind_prepare()
    guard let viewModel = self.viewModel else { return }
    // ……此处展开每个 @bind 成员的 viewModel.addTarget(...) 语句
}
```

- 若类中已自定义 `__mocoa_bind_prepare`，宏报错，提示改用 `prepareForViewModel`。
- 若没有任何 `@bind` 成员，则不生成该方法。

#### `.vm`（ViewModel）：生成 `mappingObserverMethodsForModelKeys` 与 `activelyObservedModelKeys`

遍历类中所有 `@bind` / `@link` 标记的属性与方法，生成 Model 监听映射表和主动观察键集合：

```swift
override class var mappingObserverMethodsForModelKeys: [String : Any]? {
    return [
        // ……此处展开 “监听方法选择器 → 被监听的 Model 键” 的映射（@bind 与 @link 均参与）
    ]
}

override class var activelyObservedModelKeys: [String]? {
    return [
        // ……此处展开 @bind 标记的键（不含仅被 @link 标记的键）
    ]
}
```

- `@bind` 标记的成员：生成映射关系，且其键进入 `activelyObservedModelKeys`，开启 KVO 主动观察。
- `@link` 标记的成员：仅生成映射关系，其键不进入 `activelyObservedModelKeys`，仅在 `prepare` 初始化时触发一次。
- 若 `@link` 标记的键同时被 `@bind` 标记，该键因 `@bind` 成为主动观察键，宏在 `@link` 处发出警告，提示改为 `@bind`。
- 若类中已自定义 `class var mappingObserverMethodsForModelKeys` 或 `class var activelyObservedModelKeys`，宏发出警告并放弃生成（自动监听 / 自动绑定不生效）。
- 若没有任何 `@bind` / `@link` 成员，则两个属性均不生成；仅有 `@link` 成员时，只生成映射表。

#### `.m`（Model）：不织入成员

Model 的数据变更通知由 `@key` 宏在 setter 中处理，`@mocoa` 对 `.m` 角色的 Member 展开为空。

### 3.3 展开示例

```swift
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {
    @bind
    func userNameDidChange(firstName: String?, lastName: String?) { }
}
```

展开后（示意）：

```swift
class UserViewModel: XZMocoaViewModel {
    @objc func userNameDidChange(firstName: String?, lastName: String?) { }

    override class var mappingObserverMethodsForModelKeys: [String : Any]? {
        return [
            NSStringFromSelector(#selector(Self.userNameDidChange(firstName:lastName:))): ["firstName", "lastName"]
        ]
    }

    override class var activelyObservedModelKeys: [String]? {
        return ["firstName", "lastName"]
    }
}
```

---

## 四、`@key` 宏

`@key` 为属性添加 didSet 方法，自动发送 KVO 或 KTA 事件。

### 声明

```swift
@attached(accessor, names: named(didSet))
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "KeyMacro")

@attached(accessor, names: named(didSet))
public macro key() = #externalMacro(module: "XZKitMacros", type: "KeyMacro")
```

`@key` 是一个 `AccessorMacro`，为属性生成 `didSet` 访问器，在值变化时自动发送 KVO 或 KTA 事件。

- 只能用于 `var` 属性，只读属性（`let` 或仅 `get` 的计算属性）会被忽略。
- 不能用于 View 角色，否则报错。
- 若属性已自定义 `set` 或 `didSet`，宏不会再生成 `didSet`，但会检测是否包含发送事件的调用，若不包含则发出警告。

### 4.1 参数解析

| 写法 | 键名 | 说明 |
| --- | --- | --- |
| `@key` | 属性名 | 使用属性名作为 KVO/KTA 事件名 |
| `@key(.name)` | `name` | 使用 `XZMocoaKey` 点语法枚举值 |
| `@key("custom")` | `custom` | 使用字符串字面量 |

### 4.2 Model 角色展开（`.m`）

Model 通过 KVO 的 `didChangeValue(forKey:)` 通知观察者：

```swift
@mocoa(.m)
class UserModel: NSObject {
    @key var firstName: String?
}
```

展开后（示意）：

```swift
class UserModel: NSObject {
    @objc var firstName: String? {
        didSet {
            if firstName == oldValue {
                return
            }
            didChangeValue(forKey: "firstName")
        }
    }
}
```

> `didSet` 内含判等，仅在值真正变化时才发送通知。若属性已自定义 `set` 或 `didSet`，需自行调用 `didChangeValue(forKey:)` 触发监听。

### 4.3 ViewModel 角色展开（`.vm`）

ViewModel 通过 `sendActions(forKey:)` 向已绑定的视图发送 KTA 事件：

```swift
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {
    @key var name: String?
}
```

展开后（示意）：

```swift
class UserViewModel: XZMocoaViewModel {
    @objc var name: String? {
        didSet {
            if name == oldValue {
                return
            }
            sendActions(forKey: "name")
        }
    }
}
```

> 若属性已自定义 `set` 或 `didSet`，需自行调用 `sendActions(forKey:)` 触发监听。

---

## 五、`@bind`与 `@link` 宏

`@bind` 用于建立**单向绑定**，`@link` 用于建立**单次绑定**（仅触发一次，不建立持续监听）。两者语法相同，区别取决于角色：

- **View 角色**：`@bind` 生成 `bindTarget` 持续监听；`@link` 生成 `linkTarget` 仅赋值一次。
- **ViewModel 角色**：两者都生成 Model 监听映射，区别在于 `@bind` 的键会进入 `activelyObservedModelKeys`（KVO 主动观察），而 `@link` 的键不会（仅在初始化时触发一次）。

它们本身不直接生成绑定代码（`PeerMacro` 展开为空），而是由类上的 `@mocoa` 读取标记后统一织入绑定逻辑，因此**必须与 `@mocoa` 配合使用**。

绑定方向取决于角色：

- **ViewModel 角色**：监听 Model 的属性变化（生成 `mappingObserverMethodsForModelKeys`，`@bind` 键另生成 `activelyObservedModelKeys`）。
- **View 角色**：监听 ViewModel 的 KTA 事件（生成 `__mocoa_bind_prepare`）。

> 下文以 `@bind` 为例说明，`@link` 的用法完全相同，区别见上文及 5.5 节。

### 5.0 `@bind` / `@link` 与主动观察机制

**关键区别（ViewModel 角色）：**

- `@bind` 标记的成员：加入映射表，且其键自动进入宏生成的 `activelyObservedModelKeys`，开启 KVO 主动观察。
- `@link` 标记的成员：仅加入映射表，其键**不进入** `activelyObservedModelKeys`，仅在 `prepare` 初始化时触发一次。

```swift
@mocoa
class ViewModel: XZMocoaViewModel {

    @bind var name: String?           // ✅ 加入映射，并进入主动观察键（KVO 监听）

    @link var avatarUrl: String?      // ⚠️ 只加入映射，不被 KVO 监听
}
```

宏自动生成（示意）：

```swift
override class var mappingObserverMethodsForModelKeys: [String : Any]? {
    return [
        NSStringFromSelector(#selector(setter: Self.name)): ["name"],
        NSStringFromSelector(#selector(setter: Self.avatarUrl)): ["avatarUrl"]
    ]
}

override class var activelyObservedModelKeys: [String]? {
    return ["name"]   // 不含 avatarUrl
}
```

> 若 `@link` 标记的键同时被 `@bind` 标记，该键因 `@bind` 成为主动观察键，宏在 `@link` 处发出编译警告，提示改为 `@bind`。
>
> 若类中已手动重写 `mappingObserverMethodsForModelKeys` 或 `activelyObservedModelKeys`，宏发出警告并放弃生成，以手动实现为准。

这种设计使得 `@link` 非常适合静态数据绑定，避免不必要的 KVO 开销。

```swift
// 无参数形式，View / ViewModel 均可
@attached(peer, names: prefixed(_))
public macro bind() = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// 单参数形式，View / ViewModel 均可
@attached(peer, names: prefixed(_))
public macro bind(_ key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// 多参数形式（可变参数），仅 ViewModel 方法
@attached(peer, names: prefixed(_))
public macro bind(_ key1: XZMocoaKey, _ key2: XZMocoaKey, _ keyN: XZMocoaKey...) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// 显式选择器形式，仅 View 属性
@attached(accessor, names: named(didSet))
public macro bind(_ key: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// 显式视图属性名形式，仅 View 属性
@attached(accessor, names: named(didSet))
public macro bind(_ key: XZMocoaKey, key property: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")

// 带属性名标签的便捷形式（text/image/isEnabled/title…），仅 View 属性
@attached(accessor, names: named(didSet))
public macro bind(text key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "BindMacro")
// ……其余同类重载见下文“便捷绑定标签一览”
```

`@link` 的声明族与 `@bind` 完全对称（无参数、单参数、可变参数形式 `@link(_:_:…)`、`selector:`/`key:` 以及带标签的便捷形式），仅宏名不同。其中可变参数形式仅用于 ViewModel 方法，带标签的便捷形式仅用于 View 属性。

### 5.1 用于 ViewModel（监听 Model）

#### 修饰属性

不指定参数表示绑定同名 Model 属性；也可用参数指定 Model 键。

```swift
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {
    // 监听 Model.name，映射到 setter: Self.name
    @bind var name: String?

    // 监听 Model.title，映射到 setter: Self.name
    @bind("title") var name: String?
}
```

生成的 `mappingObserverMethodsForModelKeys` 条目形如：

```swift
NSStringFromSelector(#selector(setter: Self.name)): ["name"]   // @bind
NSStringFromSelector(#selector(setter: Self.name)): ["title"]  // @bind("title")
```

#### 修饰方法

不指定参数时，被监听的 Model 键取自方法参数名；也可用参数逐个指定。指定的键数量**不能多于**方法参数个数（否则报错）；若少于方法参数个数，剩余位置自动用对应参数名补全。

```swift
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {
    // 监听 Model.firstName & Model.lastName
    @bind
    func userNameDidChange(firstName: String?, lastName: String?) { }

    // 监听 Model.foo & Model.bar
    @bind("foo", "bar")
    func foobar(min: Int, max: Int) { }
}
```

生成条目：

```swift
NSStringFromSelector(#selector(Self.userNameDidChange(firstName:lastName:))): ["firstName", "lastName"]
NSStringFromSelector(#selector(Self.foobar(min:max:))): ["foo", "bar"]
```

> 参数既支持字符串字面量 `"foo"`，也支持点语法 `.foo`（会被转换为 keyPath 字符串）。ViewModel 上绑定属性只允许一个无标签参数，方法参数至少一个（否则无法接收被绑定值）。
>
> `@link` 在 ViewModel 上的用法与 `@bind` 完全相同（含可变参数形式），区别仅在于其键不会进入 `activelyObservedModelKeys`，参见 5.0 节。

### 5.2 用于 View（监听 ViewModel）

#### 修饰属性

View 角色的属性绑定支持多种形式：

```swift
@mocoa(.v)
class UserView: UIView, XZMocoaView {
    // 无参数：绑定属性的 setter，键名为属性名
    // viewModel.name → self.name (setter)
    @bind var name: String?

    // 单参数无标签：绑定属性的 setter，键名为参数值
    // viewModel.fullName → self.name (setter)
    @bind("fullName") var name: String?

    // 单参数有标签：绑定属性值的指定属性
    // viewModel.name → nameLabel.text
    @bind(text: .name) var nameLabel: UILabel!

    // 双参数 (key, key:)：绑定属性值的指定属性
    // viewModel.color → nameLabel.textColor
    @bind("color", key: "textColor") var nameLabel: UILabel!

    // 双参数 (key, selector:)：绑定属性值的指定方法
    // viewModel.reload → tableView.reloadData
    @bind(.reload, selector: #selector(UITableView.reloadData)) var tableView: UITableView!

    // 双参数 (title:for:)：绑定 UIButton 指定状态的属性
    // viewModel.confirm → confirmButton.__mocoa_bind_title_normal(_:)
    @bind(title: .confirm, for: .normal) var confirmButton: UIButton!
}
```

在 `__mocoa_bind_prepare()` 中展开为：

```swift
viewModel.bindTarget(self, action: #selector(setter: Self.name), forKey: "name")
viewModel.bindTarget(self, action: #selector(setter: Self.name), forKey: "fullName")
viewModel.bindTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name")
viewModel.bindTarget(nameLabel, action: #selector(setter: UILabel.textColor), forKey: "color")
viewModel.bindTarget(tableView, action: #selector(UITableView.reloadData), forKey: "reload")
viewModel.bindTarget(confirmButton, action: #selector(UIButton.__mocoa_bind_title_normal(_:)), forKey: "confirm")
```

- **可选属性**（`?` / `!`）的绑定语句会被包裹在 `if let … { }` 中，避免空值绑定。
- 只读属性（`let` 或仅 `get` 的计算属性）不支持无标签绑定，需使用带标签形式绑定其子属性。

#### 修饰方法

被修饰方法即 KTA 事件的处理者。根据 KTA 机制，方法最多支持三个参数，且只能绑定一个键。

```swift
@mocoa(.v)
class UserView: UIView, XZMocoaView {
    // 无参数：使用方法参数名作为键名
    // viewModel.imageURL → setIconWithURL(_:)
    @bind
    func setIconWithURL(_ imageURL: URL) { }

    // 单参数：使用参数值作为键名
    // viewModel.avatarURL → setIconWithURL(_:)
    @bind("avatarURL")
    func setIconWithURL(_ iconURL: URL) { }
}
```

展开为：

```swift
viewModel.bindTarget(self, action: #selector(Self.setIconWithURL(_:)), forKey: "imageURL")
viewModel.bindTarget(self, action: #selector(Self.setIconWithURL(_:)), forKey: "avatarURL")
```

> 方法参数形式支持：`()`、`(value)`、`(key, value)`、`(viewModel, key, value)`，无参数宏时分别绑定 `.None`、第一个参数名、第二个参数名、第三个参数名。

### 5.3 便捷绑定标签一览

带属性名标签的 `@bind` / `@link` 只在 View 中修饰属性使用，可显式指定绑定的视图属性。可用标签如下：

- **UIView**：`isHidden`、`alpha`、`frame`、`bounds`、`transform`、`tintColor`、`backgroundColor`
- **UIControl**：`isEnabled`、`isSelected`、`isHighlighted`
- **UILabel**：`text`、`attributedText`、`font`、`textColor`、`textAlignment`
- **UIImageView**：`image`、`animationImages`
- **UITextField**：`placeholder`、`attributedPlaceholder`
- **UITextView**：`isEditable`、`isSelectable`
- **UISlider**：`value`
- **UISwitch**：`isOn`
- **UIButton**：`title`、`attributedTitle`、`titleColor`、`titleShadowColor`、`image`、`backgroundImage`（均搭配 `for state:` 指定控件状态）
- **其它（导航栏等）**：`color`、`name`、`barTintColor`、`backgroundImage`、`isTranslucent`、`style`、`state`、`status`、`title`、`attributedTitle`、`subtitle`、`detailText`、`icon`、`viewModel`

```swift
@bind(text: .name) var nameLabel: UILabel!
@bind(image: .avatar) var avatarView: UIImageView!
@bind(title: .confirm, for: .normal) var confirmButton: UIButton!
```

### 5.4 可选视图属性与 `didSet`

对于带标签的 `@bind` / `@link` 修饰**可选类型**（`?`）或**隐式可选类型**（`!`）视图属性时，宏会额外生成 `didSet` 访问器，使得视图实例在 viewModel 已就绪之后才被赋值时，也能重新建立绑定：

```swift
@bind(text: .name) var nameLabel: UILabel?
```

展开后（示意）：

```swift
var nameLabel: UILabel? {
    didSet {
        guard let viewModel = self.viewModel else { return }
        if let oldValue = oldValue {
            viewModel.removeTarget(oldValue, action: #selector(setter: UILabel.text), forKey: "name")
        }
        if let newValue = self.nameLabel {
            viewModel.bindTarget(newValue, action: #selector(setter: UILabel.text), forKey: "name")
        }
    }
}
```

> 对于非可选类型的 `var` 属性（无 `?`/`!`），`didSet` 中直接调用 `removeTarget` 和 `bindTarget`，无需 `if let` 包裹；`let` 常量属性不生成 `didSet`。

相关约束：

- 计算属性（`computed`）无法生成 `didSet`，宏发出警告，提示自行调用 `bindTarget`/`linkTarget(_:action:forKey:)` 方法实现绑定。
- 若属性已自定义 `set` 或 `didSet`，无法再织入动态监听，宏发出警告，提示自行调用 `bindTarget`/`linkTarget(_:action:forKey:)` 方法实现绑定。
- 上述警告可通过在属性中添加包含方法名（如 `bindTarget`）的注释来消除。

### 5.5 `@link` 单次绑定

`@link` 与 `@bind` 语法完全相同，区别在于：

- **View 角色**：`@bind` 生成 `viewModel.bindTarget(…)`，建立持续监听，ViewModel 值变化时自动更新 View；`@link` 生成 `viewModel.linkTarget(…)`，仅执行一次赋值，不建立持续监听。
- **ViewModel 角色**：两者都生成 `mappingObserverMethodsForModelKeys` 映射关系；`@bind` 的键还会进入 `activelyObservedModelKeys`（KVO 主动观察），`@link` 的键不会，仅在 `prepare` 初始化时触发一次。

适用场景：

- 静态数据展示，值不会变化。
- 只读列表性能优化，避免不必要的监听开销。

```swift
@mocoa(.v)
class UserView: UIView, XZMocoaView {
    // 单次赋值，不监听后续变化
    @link(text: .name) var nameLabel: UILabel!
}
```

---

## 六、`#module` 宏

`#module` 是一个自由宏（`ExpressionMacro`），用于通过模块 URL 获取 `XZMocoaModule` 对象，等价于 `XZMocoaModule(for:)!`。

### 声明

```swift
@freestanding(expression)
public macro module(_ urlString: String) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "ModuleMacro")

@freestanding(expression)
public macro module(_ value: URL) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "ModuleMacro")
```

### 用法

```swift
// 字符串形式：编译期校验 URL 合法性
let module = #module("https://mocoa.xezun.com/main")

// URL 形式
let module = #module(URL(string: "https://mocoa.xezun.com/main")!)
```

展开结果：

```swift
XZMocoaModule(for: URL(string: "https://mocoa.xezun.com/main"))!   // 字符串参数
XZMocoaModule(for: someURLExpression)!                             // URL 参数
```

校验规则（仅字符串参数在编译期校验）：

- 只接受一个参数（模块地址），否则报错“仅支持‘模块地址’作为参数”。
- 字符串参数不能为空，否则报错“模块地址不能为空”。
- 必须是合法 URL，否则报错“模块地址不是合法的 URL 字符串”。
- 地址 path 末尾不能带 `/`，否则报错“请移除模块地址末尾的‘/’字符”。
- 地址 path 需符合 `kind:` / `kind:name` / `:` / `name` 格式，否则报错“地址 path 不符合 kind:|kind:name|:|name 格式”。

---

## 七、`XZMocoaKey` 类型

`@key`、`@bind` 的键参数类型为 `XZMocoaKey`。在 Objective-C 中它是一个可扩展字符串枚举（`typedef NSString *XZMocoaKey NS_TYPED_EXTENSIBLE_ENUM`），在 Swift 中表现为支持点语法的结构体，框架预置了大量通用键（见 [`XZMocoaKey.h`](../../Sources/ObjC/XZMocoa/XZMocoaDefines/XZMocoaKey.h)），例如：

- 通用：`.name`、`.title`、`.subtitle`、`.detailText`、`.icon`、`.image`、`.value`、`.color`、`.status` …
- 视图属性：`.isHidden`、`.alpha`、`.text`、`.textColor`、`.font`、`.placeholder` …
- 动作/事件：`.reload`、`.reloadData`、`.select`、`.confirm`、`.cancel`、`.click`、`.submit` …

在宏中，`.name` 这样的点语法会被解析为字符串 `"name"`；多级点语法 `.a.b` 会被解析为 keyPath `"a.b"`。因此下面两种写法等价：

```swift
@bind(.name) var nameLabel: UILabel!
@bind("name") var nameLabel: UILabel!
```

---

## 八、诊断信息

宏在编译期通过 `XZMacroError`（错误，中断编译）和 `XZMacroDiagnose`（警告 / 错误诊断）反馈问题。常见诊断如下：

| 场景 | 级别 | 提示 |
| --- | --- | --- |
| `@mocoa` 用于非 class | 错误 | @mocoa: 仅可用于 class 的声明 |
| `@mocoa` 参数不是 role | 错误 | @mocoa: 参数 role 不是合法的枚举值 / 目前仅支持 role 参数 |
| 无法确定 class 的角色 | 错误 | @mocoa: 无法确定 `Xxx` 的角色，请通过 role 参数指定 |
| 成员宏找不到所属 `@mocoa` | 错误 | @mocoa: 无法确定 `@key`/`@bind` 所属的角色 |
| View 自定义 `__mocoa_bind_prepare` | 错误 | 重写私有方法 `__mocoa_bind_prepare` 会导致绑定失效，请使用 `prepareForViewModel` 方法代替 |
| ViewModel 自定义 `mappingObserverMethodsForModelKeys` | 警告 | 由于已重写 `mappingObserverMethodsForModelKeys` 属性，宏 @bind 监听 / @link 绑定将不生效 |
| ViewModel 自定义 `activelyObservedModelKeys` | 警告 | 由于已重写 `activelyObservedModelKeys` 属性，宏 @bind 监听 / @link 绑定将不生效 |
| `@link` 标记的键同时被 `@bind` 标记 | 警告 | 由于键被 @bind 绑定，键已成为主动观察键，请修改为 @bind 以消除警告 |
| `@key` 用于 View 角色 | 错误 | @key: 不支持在 View 角色中使用 |
| `@key` 用于非属性 | 错误 | @key: 仅支持属性 |
| `@key` 属性已自定义 set/didSet（Model） | 警告 | 无法添加 didSet 方法，请自行调用 `didChangeValue(forKey:)` 方法触发监听 |
| `@key` 属性已自定义 set/didSet（ViewModel） | 警告 | 无法添加 didSet 方法，请自行调用 `sendActions(forKey:)` 方法触发监听 |
| `@bind`/`@link` 用于 Model 角色 | 错误 | @bind: 数据模型 Model 不支持绑定 |
| `@bind` 绑定键数量超出方法参数个数 | 错误 | 绑定的键数量，超出了方法参数个数 |
| `@bind` 修饰 View 方法且参数超限 | 错误 | 根据 KTA 机制，绑定方法最多支持三个参数 / 仅支持绑定单个 XZMocoaKey 到方法 |
| `@bind` 修饰只读属性（无标签） | 错误 | 只读属性不支持绑定，若要绑定属性值的属性，请使用带参数标签的宏 |
| `@bind` 属性用 `= .init()` 初始化 | 错误 | 请使用 `var propery: Type = initializer()` 的形式初始化属性 |
| `@bind`/`@link` 属性已自定义 didSet | 警告 | 计算属性需自行调用 `bindTarget`/`linkTarget(_:action:forKey:)` 方法实现绑定，添加注释可消除警告 |
| `#module` 参数非法 | 错误 | #module: 仅支持“模块地址”作为参数 / 模块地址不能为空 / 不是合法的 URL 字符串 |
| `#module` path 格式错误 | 错误 | #module: 请移除末尾的“/”字符 / path 不符合 kind:\|kind:name\|:\|name 格式 |

> `@key` 修饰只读属性（`let` 或仅 `get` 的计算属性）时不报错，宏直接忽略（不生成 `didSet`）。

---

## 九、完整示例

以下是一个完整的 MVVM 单元，综合演示 `@mocoa`、`@key`、`@bind`、`@link` 的配合：

```swift
import XZKit

// MARK: - Model：任意 NSObject 子类

@mocoa(.m)
class UserModel: NSObject {
    @key var isVIP = false
    @key var firstName: String?
    @key var lastName: String?
}

// MARK: - ViewModel：将 Model 数据加工为视图所需形式

@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {

    // 可被 View 绑定的属性，值变化时自动发送同名 KTA 事件
    @key var name: String?
    @key var textColor: UIColor = .black

    // 监听 Model 的 firstName、lastName（参数同名，可省略 @bind 参数）
    @bind
    func userNameDidChange(firstName: String?, lastName: String?) {
        name = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }

    // 监听 Model 的 isVIP（参数名不同，显式指定键）
    @bind("isVIP")
    func userVipDidChange(isVip: Bool) {
        textColor = isVip ? .red : .black
    }
}

// MARK: - View：遵循 XZMocoaView 标记协议

@mocoa(.v)
class UserView: UIView, XZMocoaView {

    // viewModel.name → nameLabel.text
    @bind(text: .name)
    // viewModel.textColor → nameLabel.textColor
    @bind(textColor: .textColor)
    var nameLabel: UILabel!

    // viewModel.subtitle → detailLabel.text（单次赋值，不持续监听）
    @link(text: .subtitle)
    var detailLabel: UILabel!
}
```

各角色在编译期自动织入的关键代码如下（示意）：

```swift
// UserModel：@key 生成 didSet + KVO 通知（@objc 由 @mocoa 注入）
@objc var firstName: String? {
    didSet {
        if firstName == oldValue {
            return
        }
        didChangeValue(forKey: "firstName")
    }
}

// UserViewModel：@key 生成 didSet + KTA 通知
@objc var name: String? {
    didSet {
        if name == oldValue {
            return
        }
        sendActions(forKey: "name")
    }
}

// UserViewModel：@mocoa 生成数据监听映射与主动观察键
override class var mappingObserverMethodsForModelKeys: [String : Any]? {
    return [
        NSStringFromSelector(#selector(Self.userNameDidChange(firstName:lastName:))): ["firstName", "lastName"],
        NSStringFromSelector(#selector(Self.userVipDidChange(isVip:))): ["isVIP"]
    ]
}

override class var activelyObservedModelKeys: [String]? {
    return ["firstName", "lastName", "isVIP"]
}

// UserView：@mocoa 生成绑定注册
override func __mocoa_bind_prepare() {
    super.__mocoa_bind_prepare()
    guard let viewModel = self.viewModel else { return }
    viewModel.bindTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name")
    viewModel.bindTarget(nameLabel, action: #selector(setter: UILabel.textColor), forKey: "textColor")
    viewModel.linkTarget(detailLabel, action: #selector(setter: UILabel.text), forKey: "subtitle")
}
```

数据流：修改 `UserModel.firstName` → KVO 通知（`firstName` 为宏生成的主动观察键） → `UserViewModel.userNameDidChange` 被调用 → 更新 `name` → `sendActions` 发送 KTA 事件 → `UserView.nameLabel.text` 自动刷新。

---

## Author

Xezun, developer@xezun.com

## License

XZMocoa is available under the MIT license. See the LICENSE file for more info.
