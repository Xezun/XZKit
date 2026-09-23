
# XZMocoa

Mocoa 是 MVVM Cocoa 的缩写，是一套基于 Cocoa（UIKit/Foundation）设计的 MVVM 开发框架。它基于原生能力设计，可以与 Cocoa 无缝融合，不需要改造既有代码，即可在任何现有项目中应用。

## 一、集成安装

### 使用 Swift Package Manager 集成

`Xcode` -> `File` -> `Add Package Dependencies...` -> `Search or Enter Package URL`

```url
https://github.com/Xezun/XZKit.git
```

在需要使用的 Target 中，添加依赖库 `XZKit`，然后在代码中导入：

```swift
import XZKit
```

## 二、快速开始

下面是一个完整的 MVVM 单元示例：`Model` 持有数据，`ViewModel` 将数据转换为视图所需的形式，`View` 负责展示。

```swift
import XZKit

// 数据模型，任意 NSObject 子类都可以作为 Model。
@mocoa
class UserModel: NSObject {
    @key var isVIP = false
    @key var firstName: String?
    @key var lastName: String?
}

// 视图模型。
@mocoa
class UserViewModel: XZMocoaViewModel {

    // @key 标记的属性，可被 View 绑定，属性值改变时自动发送同名 KTA 事件。
    @key
    var name: String?

    @key
    var textColor: UIColor = .black

    // @bind 标记的方法，监听 firstName lastName 属性的变化。方法参数与数据模型属性相同，可省略 @bind 的参数。
    @bind
    func userNameDidChange(firstName: String?, lastName: String?) {
        name = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }

    // 方法参数与属性不同时，通过 @bind 的参数指明。
    @bind("isVIP")
    func userVipDidChange(isVip: Bool) {
        textColor = isVip ? .red : .black
    }
}

// 视图，遵循 XZMocoaView 标记协议，表示其为 MVVM 中的 View 角色。
@mocoa
class UserView: UIView, XZMocoaView {
  
    // 监听 ViewModel 的 name 值，绑定到 nameLabel.text
    // 监听 ViewModel 的 textColor 值，绑定到 nameLabel.textColor
    @bind(text: .name)
    @bind(textColor: .textColor) 
    var nameLabel: UILabel!

}
```

## 三、核心概念

XZMocoa 中，一个完整的 MVVM 单元由三个元素组成：

- `XZMocoaModel` 协议：可选，数据模型遵循此协议，以表明 Model 是 MVVM 中的 Model 元素，所有 `NSObject` 子类都可以作为数据模型。
- `XZMocoaView` 协议：可选，视图遵循此协议，以表明 View 是 MVVM 中的 View 元素，所有 `UIResponder` 都是天然的 View 角色。
- `XZMocoaViewModel` 基类：必选，Mocoa 提供的功能，基本都由视图模型基类或子类提供。

### 1、Ready 机制

一种延迟初始化的机制，主要有两个目的：
- 适配 Cocoa 的懒加载机制，将视图模型的初始化，延迟到使用前。比如在 `UIViewController` 中，视图模型默认会在 `viewDidLoad` 时初始化。
- 需要额外的初始化条件，可以等条件满足之后再进行初始化。

在 `ready` 机制下，开发者应在 ViewModel 的 `-prepare` 方法中进行初始化。

```swift
override func prepare() {
    super.prepare()
    
    // 执行初始化
}
```

若要视图模型立即执行初始化，可直接调用 `-ready` 方法。

> 一般情况下 `-ready` 方法会自动调用，且有防重复机制，可通过 `-isReady` 属性获取视图模型当前是否已完成初始化。

### 2、层级关系

主要用于组织管理视图模块，将视图分块管理时，视图模块之间就形成了层级关系。

```swift
self.addSubViewModel(viewModel)
// 支持指定位置，子类可根据自身需要使用。
self.insertSubViewModel(viewModel, at: 0)
```

通过 `subViewModels` 和 `superViewModel` 属性可以访问上下级，`removeFromSuperViewModel` 可将自身从上级移除，`didRemoveSubViewModel:` 在下级被移除时回调。

### 3、事件通道

事件通道（Key Events Channel）是一套自下而上的、基于层级关系的事件机制，可用于实现模块之间的传值和事件处理。

> 事件通道以字符串（XZMocoaKey）为标识符，可降低模块间的耦合。
> 相应的代价，就是无法在编译阶段排查类型或参数错误，因此事件参数在使用前必须做好类型检查。

视图或视图模型，都可使用 `-sendEventsWithKey:value:` 方法，通过层级关系向上传递事件。

```swift
// 在下级中发送事件
self.sendEvents(.reloadData, value: nil)
```

上级通过 `-didReceiveEvents:` 方法接收事件，事件对象为 `XZMocoaEvents`，包含 `key`（事件标识）、`value`（事件值）、`source`（事件创建者）、`target`（事件传递者）等信息。

```swift
// view
@objc func reloadButtonAction() {
    self.sendEvents(.reloadData, value: nil)
}

// viewModel
override func didReceive(_ events: XZMocoaEvents) {
    switch events.key {
    case .reloadData:
        self.reloadData()
    default:
        super.didReceive(events)
    }
}
```

不在层级关系中的模块，可通过如下方式建立事件通道。

> 新模块若不属于层级关系，在创建模块的`options`参数中，可通过`XZMocoaKeyViewModel`键，建立新模块与指定视图模型之间的事件通道。

```swift
// 即使目标页面不是 Mocoa 模块，目标页面也可通过事件通道向 self.viewModel 发送事件。
self.navigationController?.pushViewController(with: #URL("https://target.module.com/path"), options: [
    .viewModel: self.viewModel
])
```

### 4、Key Target Action（KTA）机制

以字符串（XZMocoaKey）为标识符，实现 ViewModel 向 View 传值或处理事件的机制。

> 与事件通道一样，编译器也无法在编译阶为 KTA 机制检查类型错误。

```swift
// 使用 @bind 宏绑定 KTA 事件值
@bind(text: .name)
var nameLabel: UILabel!

// 上面的 @bind 宏的展开后
viewModel.bindTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: "name")
```

KTA 机制也可用于处理事件。

```swift
// View
viewModel.addTarget(self, action: #selector(beginRefreshing), forKey: "beginRefreshing")

@objc func beginRefreshing() {

}

// ViewModel
self.sendActions(forKey: "beginRefreshing", value: nil)
```

### 5、数据监听

#### 被动监听（默认）

默认情况下（`activelyObservedModelKeys` 返回 `nil`），数据监听是被动的：不附加 KVO 观察，监听方法仅在数据变化被外部通知时触发。

原因如下：
- 在实际开发中，数据在大部分情形下都是单向流动的，比如从网络请求到页面展示，没有数据监听需求。
- 当数据管理框架可能自带监听机制时，比如 CoreData 的 `NSFetchedResultsController` 就原生支持。

> 列表视图`XZMocoaTableView/XZMocoaColletionView`已内置了对 `NSFetchedResultsController` 的支持。

若要触发监听方法，调用视图模型 `-model:didChangeValuesForKeys:` 方法即可。

```swift
viewModel.model(model, didChangeValuesForKeys: ["name"])
```

使用 `@mocoa` 和 `@bind` 宏，可自动创建映射关系。

```swift
// 监听方法和被监听的模型属性的映射关系
override class var mappingObserverMethodsForModelKeys: [String : Any]? {
    return [
        NSStringFromSelector(#selector(self.rangeDidChange(_:_:))): ["min", "max"]
    ]
}

@objc func rangeDidChange(_ min: Int, _ max: Int) {
    
}
```

使用 `@mocoa` 和 `@bind` 宏，可自动创建上述映射关系。

```swift
@mocoa
class ViewModel: XZMocoaViewModel {

    @bind
    func rangeDidChange(_ min: Int, _ max: Int) {
        // Model 的 min、max 属性任一改变，此方法都会被调用
    }
}
```

#### 主动监听

通过重写类属性 `activelyObservedModelKeys`，控制哪些键需要 KVO 主动监听。开启主动监听后，初始化（`prepare`）时会触发一次所有映射的键，此后由 KVO 持续观察。

```swift
/// 开启主动监听，观察 mappingObserverMethodsForModelKeys 中的所有键。
override class var activelyObservedModelKeys: [String]? {
    return []  // @[]表示观察所有映射的键
}

// 或

/// 仅观察指定键，排除 @link 绑定的键。
override class var activelyObservedModelKeys: [String]? {
    return ["name", "age"]  // 具体数组，仅观察这些键
}

// 或不启用主动监听
override class var activelyObservedModelKeys: [String]? {
    return nil  // nil 表示不启用 KVO 主动监听
}
```

**绑定模式说明：**

- `nil`：**无绑定模式** → 不附加 KVO → 全部被动绑定，需手动调用 `-model:didChangeValuesForKeys:` 触发
- `@[]`：**全量绑定模式** → 附加 mapping 中的所有键 → 无被动绑定
- `["key1", "key2"]`：**半量绑定模式** → 仅附加指定键 → 其余键被动绑定

可通过实例属性 `isActivelyObservingModelKeys` 判断视图模型是否已开启主动观察（仅用于状态判断，重写不影响观察行为）。

**使用 `@mocoa` + `@bind` / `@link` 宏时，主动观察键自动生成：**

- `@bind` 标记的键自动加入映射表，并进入 `activelyObservedModelKeys`（KVO 主动观察）。
- `@link` 标记的键只加入映射表，不进入 `activelyObservedModelKeys`，仅在 `prepare` 初始化时触发一次。
- 若 `@link` 标记的键同时被 `@bind` 标记，该键升级为主动观察键，宏会发出编译警告。
- 手动重写 `mappingObserverMethodsForModelKeys` 或 `activelyObservedModelKeys` 将覆盖宏的自动生成（宏发出警告并放弃生成）。

```swift
@mocoa
class ViewModel: XZMocoaViewModel {
    
    @bind var name: String?      // ✅ 加入映射，并进入 activelyObservedModelKeys（KVO 监听）
    
    @link var avatarUrl: String? // ⚠️ 只加入映射，不被 KVO 监听，仅初始化时触发一次
}

// 宏自动生成（示意）：name 会被 KVO 监听，avatarUrl 不会被 KVO 监听
// override class var activelyObservedModelKeys: [String]? { return ["name"] }
```

**KVO 事件处理：**

监听基于 KVO 机制，且单个 Runloop 内的键值事件会合并统一处理，同一个 key 在同一个 Runloop 内发生多次改变，绑定的方法只会执行一次。

## 四、模块化

不论采用何种设计模式，都应该让代码模块化，这样在更新维护时，变动就可以控制在模块内。XZMocoa 使用 MVVM 设计模式进行模块化：在 MVVM 设计模式下，视图通过自身的 ViewModel 管理逻辑，页面通过划分模块，将逻辑分散在各个子模块中，避免单个页面变得臃肿。

### 1、Mocoa 模块

XZMocoa 将每一个 MVVM 单元（Model-View-ViewModel）都视为一个 Mocoa 模块，用 `XZMocoaModule` 对象表示。

在模块中注册 MVVM 单元的 `Model`、`View`、`ViewModel` 三个部分：

```swift
let module = #module("https://mocoa.xzkit.com/module/to/path")
module.modelClass = Model.self
module.viewClass = View.self
module.viewModelClass = ViewModel.self
```

*注：`#module` 是获取 `XZMocoaModule` 对象的 Swift 宏。*

推举在实现模块时，使用默认初始化方法，以提高模块的通用性。

- `Model` 使用 `-init` 作为初始化方法，或者开发者自行约定统一的初始化方法。
- `ViewModel` 使用 `-initWithModel:` 作为初始化方法。
- `View` 中的 `UIViewController` 使用 `-initWithNibName:bundle:` 作为初始化方法。
- `View` 中的 `UIView` 一般使用 `-initWithFrame:` 作为初始化方法，像 `UITableViewCell` 等被管理的视图，则由它们自身决定。

模块注册后，即可按照约定使用：

```swift
let module = #module("https://mocoa.xzkit.com/module/to/path")

let model = XZJSON.decode(data, class: TestModel.self)!
let viewModel = module.instantiateViewModel(model: model)!
let view = module.instantiateView(frame: .zero, options: nil)!

view.viewModel = viewModel
self.addSubview(view)
```

### 2、模块域

模块域`XZMocoaDomain`就是一组使用字典管理的模块的集合。将模块通过`URL`将注册到域中，然后就可以通过`URL`获取模块。

### 3、模块注册

模块应在被使用前注册到模块域中，`+load` 方法是非常合适的注册时机。

```objc
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/content").viewNibClass = self;
}
```

如果项目组对 `+load` 方法的使用有限制，可以通过 `XZMocoaProvider` 协议自定义模块域中模块的提供方式，比如读取配置文件。

模块域通过 `XZMocoaProvider` 协议查找模块，可重写模块查找方式，比如读取配置文件。

假如有配置文件结构如下。

```json
{
    "path": {
        "View": "ViewClassName",
        "ViewModel": "ViewModelClassName",
        "Model": "ModelClassName"
    }
}
```

实现 `XZMocoaProvider` 协议。

```swift
class ModuleProvider: NSObject, XZMocoaProvider {
    
    func domain(_ domain: XZMocoaDomain, moduleForPath path: String) -> Any? {
        let dict = fetchConfiguartionFromFile()
        guard let info = dict[path] else { return nil }
        guard let module = XZMocoaModule(domain: domain.name, path: path) else { return nil }
        if let ClassName = info["View"], let ClassObject = NSClassFromString(ClassName) {
            module.viewClass = ClassObject
        }
        if let ClassName = info["ViewModel"], let ClassObject = NSClassFromString(ClassName) {
            module.viewModelClass = ClassObject
        }
        if let ClassName = info["Model"], let ClassObject = NSClassFromString(ClassName) {
            module.modelClass = ClassObject
        }
        return module
    }
     
}

// 设置 provider 为自定义的对象。
XZMocoaDomain(named: "module.domain.com").provider = ModuleProvider()
```

### 4、模块的层级

访问下级模块，可以使用 `-submoduleForKind:forName:` 方法，或者直接使用下标方式：

```objc
// 常规方式获取下级
XZMocoaModule *submodule = [module submoduleForKind:@"header" forName:@"black"];
// 下标方式获取下级
XZMocoaModule *submodule = module[@"header:black"];
```

模块的层级与模块的路径是互相对应的，比如：

| URL                                          | 说明                          |
| -------------------------------------------- | ----------------------------- |
| `https://mocoa.xezun.com`                   | 根模块                         |
| `https://mocoa.xezun.com/table`             | `table` 模块是根模块的子模块     |
| `https://mocoa.xezun.com/table/name1`       | `name1` 是 `table` 模块的子模块 |
| `https://mocoa.xezun.com/table/name1/name2` | `name2` 是 `name1` 模块的子模块 |

同一层级的模块，支持按`kind`分类管理，在路径中使用 `:` 分隔，比如：

| URL                                           | 说明                                      |
| --------------------------------------------- | ----------------------------------------- |
| `https://mocoa.xezun.com/table/header:name1` | `name1` 是 `table` 模块的 `header` 子模块 |
| `https://mocoa.xezun.com/table/footer:name2` | `name2` 是 `table` 模块的 `footer` 子模块 |

- 子模块中分类为 `kMocoaNilKind` （空字符串）的模块，为模块的默认分类。
- 子模块中名称为 `kMocoaNilName` （空字符串）的模块，为模块的默认名称。
- 在路径中，没有分类可以省略 `:`，没有名字不能省略 `:`。

| URL                                        | 说明                                   |
| ------------------------------------------ | -------------------------------------- |
| `https://mocoa.xezun.com/table/name`      | 合法，默认分类中名为 `name` 的模块            |
| `https://mocoa.xezun.com/table/kind:name` | 合法，分类 `kind` 中名为 `name` 的模块          |
| `https://mocoa.xezun.com/table/kind:`     | 合法，分类 `kind` 中名为 空 的模块          |
| `https://mocoa.xezun.com/table/:`         | 合法，分类和名称都为 空 的模块                |
| `https://mocoa.xezun.com/table/kind`      | 不合法。因为 `kind` 会被作为 `name` 使用  |

> 按照规则，模块 `table` 的地址的标准形式是 `https://mocoa.xezun.com/table` 。
> 由于 `NSURL` 的 `path` 属性，会过滤末尾的 `/` 字符，所以 `https://mocoa.xezun.com/table/` 也是 `table` 模块自身。
> 所以表示 `table` 模块中，默认分类、默认名字的子模块，需要在末尾添加 `:` 符号，即 `https://mocoa.xezun.com/table/:` 地址。


## 五、列表渲染

下面以 iOS 开发中常用的 `UITableView` 组件为例，介绍如何使用 XZMocoa 开发列表页面。

> 由于原生 `UITableView` 原为 MVC 设计，使用 MVVM 设计模式时，需要对其进行改造。
> 框架内置的 `XZMocoaTableView` 就是 `UITableView` 的适配版本，它仅接管了 `delegate` 和 `dataSource` 代理，未做任何其它处理，`UITableView` 本身以 `contentView` 属性对外暴露。
> 由于 `XZMocoaTableView` 并没接管所有 `delegate` 方法，用到某些特定代理方法时，需要用 `XZMocoaTableView` 的子类来实现。

### 1、数据协议

所有`NSObject`子类都可以作为列表数据模型，特别的，二维数组`NSArray`元素可以直接映射为列表`Cell`的数据模型。对于自定义数据模型，可通过`XZMocoaGroupModel`协议，将数据转换为 Mocoa 可用的标准数据。

```swift
/// 列表中 section 的数量。
func mocoa(_ context: Any, numberOfSections null: Any?) -> Int
/// 列表中 section 中 cell 的数量。
func mocoa(_ context: Any, numberOfCellsInSection section: Int) -> Int
/// 列表中 cell 的数据模型。
func mocoa(_ context: Any, modelForCellAt indexPath: IndexPath) -> Any?
/// 列表中 section 的附加视图数量。
func mocoa(_ context: Any, kind: XZMocoaKind, numberOfSupplementsInSection section: Int) -> Int
/// 列表中附加视图的数据模型。
func mocoa(_ context: Any, kind: XZMocoaKind, modelForSupplementAt indexPath: IndexPath) -> Any? 
```

### 2、创建列表

`XZMocoaTableView` 是标准的 Mocoa 模块，可以直接使用，也可以通过 URL 的方式加载。

```objc
// model，替换为真实数据
NSArray *dataArray;
// viewModel
XZMocoaTableViewModel *tableViewModel = [[XZMocoaTableViewModel alloc] initWithModel:dataArray];
tableViewModel.module = XZMocoa(@"https://mocoa.xezun.com/table");
// view
XZMocoaTableView *tableView = [[XZMocoaTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
tableView.viewModel = tableViewModel;
[self.view addSubview:tableView];
```

XZMocoa 会使用占位 cell 渲染列表，以帮助提前验证数据的基本格式问题，并屏蔽原生组件关于 `dataSource` 的各种崩溃问题。

### 3、开发 cell 模块

将每一个 cell 都看作完全独立的模块进行开发，然后注册到相应的列表模块中，`XZMocoaTableView`就会根据`mocoaName`自动加载它们。

```swift
@mocoa
class ExampleCellModel: NSObject, XZMocoaModel {
    
    var mocoaName: XZMocoaName? {
        return "example"
    }
    
    @key var firstName: String?
    @key var lastName: String?
}

@mocoa
class ExampleCellViewModel: XZMocoaTableCellViewModel {
    
    @key
    var name: String?

    // 初始化
    override func prepare() {
        super.prepare()
        // 设置 cell 高度
        self.height = 44.0;
    }
    
    // 处理数据，将 firstName lastName 合并为 name
    @bind
    func nameDidChange(firstName: String?, lastName: String?) {
        name = [firstName, lastName].compactMap({ $0 }).joined(separator: " ")
    }
}

@mocoa
class ExampleCell: UITableViewCell {
    
    @bind(text: .name)
    let nameLabel: UILabel = .init()

    // ... 布局代码 ...
}

// 注册模块角色
let module = #module("https://mocoa.xezun.com/table/example")
module.viewClass = ExampleCell.self
module.modelClass = ExampleCellModel.self
module.viewModelClass = ExampleCellViewModel.self
```

### 4、列表更新

数据变化后，调用 ViewModel 相应的方法，即可同步更新视图。

```objc
[_dataArray removeObjectAtIndex:0];
// Mocoa 默认不监听数据变化，下面方法的作用就是告诉 ViewModel 数据改变了。
[_tableViewModel deleteSectionAtIndex:0];
```

### 5、局部刷新

使用 `-performBatchUpdates:completion:` 方法，默认会检查所有数据的`hash`值，如果满足条件，将开启差异分析，进行局部刷新。

```objc
[_tableViewModel performBatchUpdates:^{
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:newData];
} completion:nil];
```

差异分析依赖数据的`hash`值，在 iOS 中，如果使用字符串的`hash`值，字符串的长度须限制在96字节以下。

```objc
let identifier: String

override var hash: Int {
    return identifier.hash
}
```

## 六、页面模块

XZMocoa 将 `UIViewController` 视为 MVVM 中特殊的 View，页面即模块。模块中注册 `viewModelClass` 后，即可通过模块 URL 直接创建或打开页面。

```objc
let viewController = UIViewController.init(#URL("https://domain.com/path/to/page"))!
self.navigationController?.pushViewController(viewController, animated: true)

self.navigationController?.pushViewController(with: #URL("https://domain.com/path/to/page"), animated: true)
```

## 七、Swift 宏

在 Swift 中，XZMocoa 提供了 `XZKitMacros` 宏库（随 `XZKit` 一起提供），用于简化 MVVM 开发：

- `@mocoa(.m)` / `@mocoa(.v)` / `@mocoa(.vm)`：将 class 标记为 Mocoa 的 MVVM 角色。
- `@mocoa`（无参数）：自动推断角色。命名以 `Model`、`View`、`ViewModel` 结尾，或继承自 `XZMocoaViewModel`、`XZMocoaModel`、`XZMocoaView`、`UIView`、`UIViewController` 的 class 均可被自动推断。
- `@key` / `@key(_ name:)`：标记属性支持`@bind`绑定，Model 自动发送 KVO 事件，ViewModel 自动发送 KTA 事件。
- `@bind` / `@bind(_ key:)`：单向绑定。用于 ViewModel 时，监听 Model 属性的变化，键自动进入主动观察；用于 View 时，监听 ViewModel 的 KTA 事件。
- `@bind(_ vmKey:selector:)` / `@bind(text key:)` 等：为常用视图属性（text、image、isEnabled 等）提供便捷绑定形式。
- `@link` / `@link(text key:)` 等：单次绑定，语法与 `@bind` 一致。用于 ViewModel 时，只建立监听映射、不进入主动观察；用于 View 时，只赋值一次而不建立持续监听。
- `#module(URL)`：通过模块 URL 获取 `XZMocoaModule` 对象。

> 宏的完整语法、展开结果与实现原理，参见 [XZMocoa 宏](./Macros.md)。


## Author

Xezun, developer@xezun.com

## License

XZMocoa is available under the MIT license. See the LICENSE file for more info.
