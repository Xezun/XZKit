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
| `@key` | `@key` / `@key(.name)` / `@key("name")` | 将属性改造为可发送 KTA 事件的计算属性 | Model、ViewModel |
| `@bind` | `@bind` / `@bind(.key)` / `@bind(text: .key)` … | 建立单向绑定（监听 Model 属性 / 监听 ViewModel 事件） | View、ViewModel |
| `#mocoa` | `#mocoa("url")` / `#mocoa(url)` | 通过模块 URL 获取 `XZMocoaModule` 对象 | 表达式 |

### 源码文件构成

| 文件 | 说明 |
| --- | --- |
| [`XZMocoaMacro.swift`](../../Sources/Macro/XZMocoa/XZMocoaMacro.swift) | `@mocoa` 宏实现（`MemberAttributeMacro` + `MemberMacro`），以及点语法转 keyPath 的公共工具 |
| [`XZMocoaKeyMacro.swift`](../../Sources/Macro/XZMocoa/XZMocoaKeyMacro.swift) | `@key` 宏实现（`PeerMacro` + `AccessorMacro`） |
| [`XZMocoaBindMacro.swift`](../../Sources/Macro/XZMocoa/XZMocoaBindMacro.swift) | `@bind` 宏实现（`XZMocoaBindMacro` 为 `PeerMacro`，`XZMocoaBindViewMacro` 为 `AccessorMacro`），含视图属性推断规则 |
| [`XZMocoaModuleMacro.swift`](../../Sources/Macro/XZMocoa/XZMocoaModuleMacro.swift) | `#mocoa` 宏实现（`ExpressionMacro`） |
| [`XZMocoaRole.swift`](../../Sources/Macro/XZMocoa/XZMocoaRole.swift) | `XZMocoaRole` 角色枚举与角色推断逻辑 |

所有宏通过 `XZKitMacros` 编译插件（[`XZKitMacros.swift`](../../Sources/Macro/XZKitMacros.swift)）注册：

```swift
@main
struct XZKitMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NSURLMacro.self,
        XZLogMacro.self,
        XZMocoaMacro.self,
        XZMocoaModuleMacro.self,
        XZMocoaKeyMacro.self,
        XZMocoaBindMacro.self,
        XZMocoaBindViewMacro.self
    ]
}
```

---

## 二、角色识别 `XZMocoaRole`

`@mocoa`、`@key`、`@bind` 的展开结果都取决于所属 class 的 MVVM 角色。角色由 `XZMocoaRole` 表示，取值 `.m`（Model）、`.v`（View）、`.vm`（ViewModel）。

角色推断遵循以下优先级（见 [`XZMocoaRole.swift`](../../Sources/Macro/XZMocoa/XZMocoaRole.swift)）：

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
public macro mocoa(_ role: XZMocoaRole) = #externalMacro(module: "XZKitMacros", type: "XZMocoaMacro")

@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro mocoa() = #externalMacro(module: "XZKitMacros", type: "XZMocoaMacro")
```

`@mocoa` 同时是一个 `MemberAttributeMacro`（为成员注入属性）和 `MemberMacro`（为类新增成员）。它只能用于 `class`，且对 `.m` 角色要求 class 继承自 `NSObject`。

### 3.1 注入 `@objc` 标记（MemberAttribute）

由于 KVO/KTA 依赖 Objective-C 运行时，被 `@key`、`@bind` 标记的成员需要 `@objc`。`@mocoa` 会自动补齐，规则如下：

| 角色 | 目标成员 | 注入条件 |
| --- | --- | --- |
| `.m` | `@key` 属性 | 未标记 `@objc` 时注入 `@objc` |
| `.v` | `@bind` 方法 | 未标记 `@objc` / `@IBAction` 时注入 `@objc` |
| `.vm` | `@key` 或 `@bind` 属性 | 未标记 `@objc` / `@IBOutlet` 时注入 `@objc` |
| `.vm` | `@bind` 方法 | 未标记 `@objc` / `@IBAction` 时注入 `@objc` |

> View 角色的属性不需要 `@objc`（视图属性通过 setter 选择器绑定），因此 `.v` 只处理方法。

### 3.2 织入成员（Member）

#### `.v`（View）：生成 `__xz_bind_prepare()`

遍历类中所有 `@bind` 标记的属性与方法，生成绑定注册方法：

```swift
override func __xz_bind_prepare() {
    super.__xz_bind_prepare()
    guard let viewModel = self.viewModel else { return }
    // ……此处展开每个 @bind 成员的 viewModel.addTarget(...) 语句
}
```

- 若类中已自定义 `__xz_bind_prepare`，宏报错，提示改用 `prepareForViewModel`。
- 若没有任何 `@bind` 成员，则不生成该方法。

#### `.vm`（ViewModel）：生成 `mappingModelKeys`

遍历类中所有 `@bind` 标记的属性与方法，生成 Model 监听映射表：

```swift
override class var mappingModelKeys: [String : Any]? {
    return [
        // ……此处展开 “监听方法选择器 → 被监听的 Model 键” 的映射
    ]
}
```

- 若类中已自定义 `class var mappingModelKeys`，宏发出警告并放弃生成（自动监听不生效）。
- 若没有任何 `@bind` 成员，则不生成该属性。

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

    override class var mappingModelKeys: [String : Any]? {
        return [
            NSStringFromSelector(#selector(Self.userNameDidChange(firstName:lastName:))): ["firstName", "lastName"]
        ]
    }
}
```

---

## 四、`@key` 宏

`@key` 将一个存储属性改造为计算属性，并在 setter 中自动发送变更通知，同时生成一个带下划线前缀的私有存储属性 `_name` 保存实际值。

### 声明

```swift
@attached(peer, names: arbitrary)
@attached(accessor)
public macro key(_ name: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaKeyMacro")

@attached(peer, names: arbitrary)
@attached(accessor)
public macro key() = #externalMacro(module: "XZKitMacros", type: "XZMocoaKeyMacro")
```

- `PeerMacro`：生成私有存储属性 `private var _name: Type = initial`。
- `AccessorMacro`：生成 `get` / `set` 访问器。
- `@key` 只能用于 `var` 属性，且一次只能修饰一个属性；不能用于 View 角色。

### 4.1 参数解析

| 写法 | 键名 | 说明 |
| --- | --- | --- |
| `@key` | 属性名 | 使用属性名作为 KTA 事件名 |
| `@key(.name)` | `name` | 使用 `XZMocoaKey` 点语法枚举值 |
| `@key("user.name")` | `user_name` | 字符串字面量；其中的 `.` 会被替换为 `_` |

- `@key` 最多接受一个用于指定键名的参数，只能是 `String` 字面量或 `XZMocoaKey` 枚举值，且不带参数标签，否则报错。
- 属性的初始值直接由属性声明自身的初始化表达式提供（如 `@key var isVIP = false`），宏会将其转移到生成的私有存储属性 `_isVIP` 上，无需再通过宏参数指定初始值。

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
    var firstName: String? {
        get { return _firstName }
        set {
            if _firstName != newValue {
                _firstName = newValue
                didChangeValue(forKey: "firstName")
            }
        }
    }
    private var _firstName: String?
}
```

> setter 内含 `!= newValue` 判等，仅在值真正变化时才发送通知。若不希望触发通知，可直接读写私有存储属性 `_firstName`。

### 4.3 ViewModel 角色展开（`.vm`）

ViewModel 通过 `sendActions(forKey:value:)` 向已绑定的视图发送 KTA 事件：

```swift
@mocoa(.vm)
class UserViewModel: XZMocoaViewModel {
    @key var name: String?
}
```

展开后（示意）：

```swift
class UserViewModel: XZMocoaViewModel {
    var name: String? {
        get { return _name }
        set {
            if _name != newValue {
                _name = newValue
                sendActions(forKey: "name", value: newValue)
            }
        }
    }
    private var _name: String?
}
```

`@key` 兼容用户自定义的访问器：

- 自定义 `set`：原 `set` 主体被放入 `defer { … }`，在发送 KTA 事件后执行。
- 自定义 `willSet` / `didSet`：宏将其转换为等价逻辑并织入生成的 `set` 中，`didSet` 通过 `oldValue` 保留旧值语义。
- 只读属性（仅 `get`）无法作为 key，报错。

---

## 五、`@bind` 宏

`@bind` 用于建立**单向绑定**。它本身不直接生成代码（无参数形式的 `PeerMacro` 展开为空），而是由类上的 `@mocoa` 读取 `@bind` 标记后统一织入绑定逻辑，因此**必须与 `@mocoa` 配合使用**。

绑定方向取决于角色：

- **ViewModel 角色**：监听 Model 的属性变化（生成 `mappingModelKeys`）。
- **View 角色**：监听 ViewModel 的 KTA 事件（生成 `__xz_bind_prepare`）。

### 5.1 声明族

```swift
// 无参数标签形式（可变参数），View / ViewModel 均可
@attached(peer, names: arbitrary)
public macro bind(_ key: XZMocoaKey...) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindMacro")

// 显式选择器形式，仅 View 属性
@attached(accessor, names: named(didSet))
public macro bind(_ key: XZMocoaKey, selector: Selector) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")

// 带属性名标签的便捷形式（text/image/isEnabled/title…），仅 View 属性
@attached(accessor, names: named(didSet))
public macro bind(text key: XZMocoaKey) = #externalMacro(module: "XZKitMacros", type: "XZMocoaBindViewMacro")
// ……其余同类重载见下文“便捷绑定标签一览”
```

### 5.2 用于 ViewModel（监听 Model）

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

生成的 `mappingModelKeys` 条目形如：

```swift
NSStringFromSelector(#selector(setter: Self.name)): ["name"]   // @bind
NSStringFromSelector(#selector(setter: Self.name)): ["title"]  // @bind("title")
```

#### 修饰方法

不指定参数时，被监听的 Model 键取自方法参数名；也可用参数逐个指定，此时**参数个数须与方法参数个数一致**，否则发出警告。

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

### 5.3 用于 View（监听 ViewModel）

#### 修饰属性

第一个参数为 ViewModel 的 KTA 事件名（`vmKey`），可选的第二个参数指定视图属性名（`vKey`）。

```swift
@mocoa(.v)
class UserView: UIView, XZMocoaView {
    // viewModel.name → nameLabel.text（自动推断 text 后缀）
    @bind(.name) var nameLabel: UILabel!

    // viewModel.color → nameLabel.textColor（显式指定视图属性）
    @bind("color", "textColor") var nameLabel: UILabel!

    // viewModel.reload → tableView.reloadData（显式指定选择器）
    @bind(.reload, selector: #selector(UITableView.reloadData)) var tableView: UITableView!
}
```

在 `__xz_bind_prepare()` 中展开为：

```swift
viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name", value: nil)
viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.textColor), forKey: "color", value: nil)
viewModel.addTarget(tableView, action: #selector(UITableView.reloadData), forKey: "reload", value: nil)
```

- **可选属性**（`?`）的绑定语句会被包裹在 `if let … { }` 中，避免空值绑定。
- 两参数形式支持三种组合：`(vmKey, vKey)`、`(key, selector: aSelector)`、`(title: key, for: state)`（后者仅用于 `UIButton`，展开为 `__xz_bind_<title>_<state>(_:)`）。

#### 修饰方法

被修饰方法即 KTA 事件的处理者，仅支持一个键参数。

```swift
@mocoa(.v)
class UserView: UIView, XZMocoaView {
    // viewModel.iconURL → setIconWithURL(_:)
    @bind("imageURL")
    func setIconWithURL(_ iconURL: URL) { }
}
```

展开为：

```swift
viewModel.addTarget(self, action: #selector(Self.setIconWithURL(_:)), forKey: "imageURL", value: nil)
```

### 5.4 视图属性自动推断

当只提供 `vmKey`（无视图属性名）时，宏会根据**属性类型**和**键名后缀**推断要绑定的视图属性选择器。键名后缀匹配大小写不敏感，采用正则“以 … 结尾”的规则（见 [`XZMocoaBindMacro.swift`](../../Sources/Macro/XZMocoaBindMacro.swift)）。

按属性类型分派：

| 视图类型 | 推断规则（键名后缀 → 绑定目标） |
| --- | --- |
| `UIView`（及未识别的自定义视图） | `hidden`→`isHidden`、`alpha`→`alpha`、`frame`→`frame`、`bounds`→`bounds`、`center`→`center`、`transform`→`transform`、`tintColor`→`tintColor`、`backgroundColor`→`backgroundColor` |
| `UILabel` / `UITextView` | `attributed<文本键>`→`attributedText`、`textAlignment`→`textAlignment`、`<文本键>`→`text`、`<文本键>Color`→`textColor`、`font`→`font`；否则回退 `UIView` 规则 |
| `UITextField` | `attributedPlaceholder`→`attributedPlaceholder`、`placeholder`→`placeholder`；否则回退文本控件规则 |
| `UIImageView` | `<图像键>`→`image`、`<图像键>s`→`animationImages`；否则回退 `UIView` 规则 |
| `UISwitch` | `onTintColor`/`thumbTintColor`/`onImage`/`offImage`→对应属性；否则回退 `UIView` 规则 |
| `UIButton` | `attributed<文本键>`→`__xz_bind_attributedTitle_normal(_:)`、`<文本键>`→`__xz_bind_title_normal(_:)`、`<文本键>ShadowColor`→`__xz_bind_titleShadowColor_normal(_:)`、`<文本键>Color`→`__xz_bind_titleColor_normal(_:)`、`backgroundImage`→`__xz_bind_backgroundImage_normal(_:)`、`image`→`__xz_bind_image_normal(_:)`；否则回退 `UIView` 规则 |

其中：

- **文本键**（`<文本键>`）匹配：`text`、`title`、`name`、`description`、`detail`、`content`、`string`。
- **图像键**（`<图像键>`）匹配：`image`、`icon`、`avatar`、`photo`、`picture`、`thumbnail`。

例如键名 `userName` 以 `name`（文本键）结尾，绑定到 `UILabel` 时推断为 `text`；键名 `avatar` 绑定到 `UIImageView` 时推断为 `image`。若无法推断，宏报错并提示显式指定视图属性。

> 推断是一种便利手段，可能存在歧义。生产代码推荐使用带标签的便捷形式（如 `@bind(text: .name)`）显式指定目标属性。

### 5.5 便捷绑定标签一览

带属性名标签的 `@bind` 只在 View 中修饰属性使用，可显式指定绑定的视图属性，避免推断歧义。可用标签如下：

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

### 5.6 可选视图属性与 `didSet`

对于带标签的 `@bind` 修饰**可选类型**（`?`）视图属性时，`XZMocoaBindViewMacro` 会额外生成 `didSet` 访问器，使得视图实例在 viewModel 已就绪之后才被赋值时，也能重新建立绑定：

```swift
@bind(text: .name) var nameLabel: UILabel?
```

展开后（示意）：

```swift
var nameLabel: UILabel? {
    didSet {
        guard let viewModel = self.viewModel else { return }
        if let nameLabel = self.nameLabel {
            viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name", value: nil)
        }
    }
}
```

相关约束：

- 只读的可选计算属性可能无法实时绑定，宏发出警告，建议改用非可选或隐式可选类型。
- 若属性已自定义 `didSet`，无法再织入动态监听，宏发出警告，提示改用 `@bind(vmKey, vKey)` 形式。

---

## 六、`#mocoa` 宏

`#mocoa` 是一个自由宏（`ExpressionMacro`），用于通过模块 URL 获取 `XZMocoaModule` 对象，等价于 `XZMocoaModule(for:)!`。

### 声明

```swift
@freestanding(expression)
public macro mocoa(_ urlString: String) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "XZMocoaModuleMacro")

@freestanding(expression)
public macro mocoa(_ value: URL) -> XZMocoaModule = #externalMacro(module: "XZKitMacros", type: "XZMocoaModuleMacro")
```

### 用法

```swift
// 字符串形式：编译期校验 URL 合法性
let module = #mocoa("https://mocoa.xezun.com/main")

// URL 形式
let module = #mocoa(URL(string: "https://mocoa.xezun.com/main")!)
```

展开结果：

```swift
XZMocoaModule(for: URL(string: "https://mocoa.xezun.com/main"))!   // 字符串参数
XZMocoaModule(for: someURLExpression)!                             // URL 参数
```

- 只接受一个参数（模块地址），否则报错。
- 字符串参数不能为空，且必须是合法 URL，否则编译期报错。

---

## 七、`XZMocoaKey` 类型

`@key`、`@bind` 的键参数类型为 `XZMocoaKey`。在 Objective-C 中它是一个可扩展字符串枚举（`typedef NSString *XZMocoaKey NS_EXTENSIBLE_STRING_ENUM`），在 Swift 中表现为支持点语法的结构体，框架预置了大量通用键（见 [`XZMocoaKey.h`](../../Sources/ObjC/XZMocoa/XZMocoaDefines/XZMocoaKey.h)），例如：

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
| `@mocoa` 用于非 class | 错误 | 仅可用于 class 的声明 |
| `.m` 角色未继承 `NSObject` | 错误 | 仅可修饰继承自 NSObject 的 class |
| 无法确定角色 | 错误 | 无法确定 `Xxx` 的角色，请通过 role 参数指定 |
| View 自定义 `__xz_bind_prepare` | 错误 | 重写私有方法会导致绑定失效，请使用 `prepareForViewModel` |
| ViewModel 自定义 `mappingModelKeys` | 警告 | 检测到已自定义，自动监听将不生效 |
| `@bind` 指定 key 数量与方法参数不一致 | 警告 | `@bind` 指定的 key 数量（n）与方法参数数量（m）不一致 |
| `@key` 用于只读属性 | 错误 | 只读属性无法作为 key 使用 |
| `@key` 用于 View 角色 | 错误 | 只能用于 Model 或 ViewModel 角色 |
| `@bind` 属性用 `= .init()` 初始化 | 错误 | 请使用 `var view: UIView = .init()` 的形式（需显式类型标注） |
| 无法推断视图属性 | 错误 | 无法为 `key` 推断要绑定的视图属性或视图方法 |
| 可选只读计算属性绑定 | 警告 | 可能无法实时绑定，建议使用非可选或隐式可选类型 |
| 自定义 `didSet` 后绑定 | 警告 | 已自定义 didSet 无法绑定动态监听，请使用 `@bind(vmKey, vKey)` |
| `#mocoa` URL 非法 / 为空 | 错误 | 模块地址不是合法的 URL 字符串 / 不能为空 |

---

## 九、完整示例

以下是一个完整的 MVVM 单元，综合演示 `@mocoa`、`@key`、`@bind` 的配合：

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
}
```

各角色在编译期自动织入的关键代码如下（示意）：

```swift
// UserModel：@key 生成计算属性 + KVO 通知
var firstName: String? {
    get { _firstName }
    set {
        if _firstName != newValue {
            _firstName = newValue
            didChangeValue(forKey: "firstName")
        }
    }
}
private var _firstName: String?

// UserViewModel：@mocoa 生成数据监听映射
override class var mappingModelKeys: [String : Any]? {
    return [
        NSStringFromSelector(#selector(Self.userNameDidChange(firstName:lastName:))): ["firstName", "lastName"],
        NSStringFromSelector(#selector(Self.userVipDidChange(isVip:))): ["isVIP"]
    ]
}

// UserView：@mocoa 生成绑定注册
override func __xz_bind_prepare() {
    super.__xz_bind_prepare()
    guard let viewModel = self.viewModel else { return }
    viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name", value: nil)
    viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.textColor), forKey: "textColor", value: nil)
}
```

数据流：修改 `UserModel.firstName` → KVO 通知 → `UserViewModel.userNameDidChange` 被调用 → 更新 `name` → `sendActions` 发送 KTA 事件 → `UserView.nameLabel.text` 自动刷新。

---

## Author

Xezun, developer@xezun.com

## License

XZMocoa is available under the MIT license. See the LICENSE file for more info.
