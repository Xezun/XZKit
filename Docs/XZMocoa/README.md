
# XZMocoa

XZMocoa 是 MVVM Cocoa 的缩写，是一套基于 Cocoa（UIKit/Foundation）设计的 MVVM 开发框架。它基于原生能力设计，可以与 Cocoa 无缝融合，不需要改造既有代码，即可在任何现有项目中应用。

接入 XZMocoa 并不能将项目立即变为 MVVM 设计模式，但 XZMocoa 不影响现有代码，可以仅在新模块下使用 MVVM 设计模式。对于存量代码，推荐先套个壳，让它形式上符合 MVVM 设计模式，然后再渐进式改造，最大限度减少代码改动，以避免影响业务稳定。

## 集成安装

### 使用 Swift Package Manager 集成

`Xcode` -> `File` -> `Add Package Dependencies...` -> `Search or Enter Package URL`

```url
https://github.com/Xezun/XZKit.git
```

在需要使用的 Target 中，添加依赖库 `XZKit`，然后在代码中导入：

```swift
import XZKit
```

## 快速开始

下面是一个完整的 MVVM 单元示例：`Model` 持有数据，`ViewModel` 将数据转换为视图所需的形式，`View` 负责展示。

```swift
import XZKit

// 数据模型，任意 NSObject 子类都可以作为 Model。
@mocoa(.m)
class UserModel: NSObject {
    @objc dynamic var isVIP = false
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
}

// 视图，遵循 XZMocoaView 标记协议，表示其为 MVVM 中的 View 角色。
@mocoa(.v)
class UserView: UIView, XZMocoaView {

    @bind(text: "name")           // 监听 ViewModel 的 name 事件值，绑定到 nameLabel.text
    @bind(textColor: "textColor") // 监听 ViewModel 的 textColor 事件，绑定到 nameLabel.textColor
    var nameLabel: UILabel!

}

// 视图模型。
@mocoa(.vm)
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
```

## 核心概念

XZMocoa 中，一个完整的 MVVM 单元由三个元素组成：

- `XZMocoaModel` 协议：数据模型遵循此协议，以表明 Model 是 MVVM 中的 Model 元素。框架已在内部为 `NSObject` 实现了此协议，因此任何 `NSObject` 子类都可以作为数据模型。
- `XZMocoaView` 协议：视图遵循此协议，以表明 View 是 MVVM 中的 View 元素。协议本身只起标记作用，具体能力由 `UIResponder` 的 `XZMocoaView` 分类提供，所有 `UIResponder` 都是天然的 View 角色。
- `XZMocoaViewModel` 基类：ViewModel 提供的功能要复杂得多，无法通过协议呈现，因此提供了基类。

### 1、Ready 机制

视图模型在创建时可能并不需要立即初始化，比如在 `UIViewController` 中，应该在 `viewDidLoad` 时初始化，或需要额外的初始化参数，因此 XZMocoa 设计了 `ready` 机制来延迟 ViewModel 的初始化时机。

在 `ready` 机制下，开发者应在 ViewModel 的 `-prepare` 方法中进行初始化。

```objc
- (void)prepare {
    [super prepare];

    // 执行当前模块的初始化
}
```

在 Swift 中，应使用 `@prepare` 修饰来指定初始化方法。

```swift
@prepare
private func setup() {
    // 执行初始化
}
```

调用 `-ready` 方法，可强制视图模型执行初始化，该方法一般情况下会自动调用，比如当视图或视图控制器设置 `viewModel` 属性时，`-ready` 方法会自动调用。

> `-ready` 方法可安全地重复调用，`-isReady` 属性表示当前是否已完成初始化。

```objc
ExampleViewModel *viewModel = [[ExampleViewModel alloc] initWithModel:nil];
// 如果子类重写了 viewModel 属性，或使用非 UIResponder 子类作为视图时，需要自行调用 ready 方法。
[viewModel ready];
self.viewModel = viewModel;
```

### 2、层级关系

在页面模块中，子视图模块与父视图模块或控制器模块存在明显的上下级关系。充分利用这种层级关系，可以更方便地处理页面中的上下级交互逻辑，因此 XZMocoa 为 ViewModel 设计了层级关系。

```objc
[superViewModel addSubViewModel:viewModel];
[superViewModel insertSubViewModel:viewModel atIndex:1];
```

通过 `subViewModels` 和 `superViewModel` 属性可以访问上下级，`removeFromSuperViewModel` 可将自身从上级移除，`didRemoveSubViewModel:` 在下级被移除时回调。

### 3、事件通道

基于层级关系，XZMocoa 提供了一套自下而上的事件通道（Key Events Channel）。下级视图模型可通过 `-sendEventsWithKey:value:` 方法沿层级向上传递事件。

```objc
// 在下级中发送事件
[self sendEventsWithKey:XZMocoaKeyReload value:nil];
```

上级通过 `-didReceiveEvents:` 方法接收事件，事件对象为 `XZMocoaEvents`，包含 `key`（事件标识）、`value`（事件值）、`source`（事件创建者）、`target`（事件传递者）等信息。

```objc
- (void)didReceiveEvents:(XZMocoaEvents *)events {
    if ([events.key isEqualToString:XZMocoaKeyReload]) {
        [self reloadData];
    }
}
```

视图与视图模型之间同样通过该通道通信：视图可直接调用 `-sendEventsWithKey:value:` 方法向 viewModel 发送事件。

在 MVC 中，解决此类问题一般通过 `delegate` 实现，上层模块与下层模块的 `delegate` 形成了耦合；利用层级关系处理，则能很好地避免这一点。

### 4、Key Target Action（KTA）机制

在 MVVM 设计模式中，View 通过监听 ViewModel 的属性来展示页面。实际上大部分情况下，View 并不需要一直监听，因为大多数 View 只需渲染一次，在 `-viewModelDidChange` 中即可完成。

对于剩余少量需要监听的事件，使用 `delegate` 需要定义协议，比较繁琐，因此 XZMocoa 设计了 target-action 机制：以 `XZMocoaKey` 字符串作为事件名，View 绑定 key 之后，ViewModel 发送事件时，View 绑定的方法就会被触发。

> 使用`Key`绑定可以解决 View 与 ViewModel 之间的类型依赖，缺点就是编译器无法在编译阶段检查类型错误。

```objc
// View 监听 viewModel 的 isRefreshing 属性
[viewModel addTarget:self action:@selector(refreshingChanged:) forKey:@"isRefreshing"];

- (void)refreshingChanged:(ExampleViewModel *)viewModel {
    if (viewModel.isRefreshing) {
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
    }
}

// ViewModel 发送事件
[self sendActionsForKey:@"isRefreshing"];
```

KTA 还支持值传递形式，将 ViewModel 中 key 对应的值，与 target 的 action 方法绑定：

```objc
// 绑定 text 属性，并赋初始值 initialValue ，若为 nil 表示绑定视图模型当前值。
[viewModel addTarget:label action:@selector(setText:) forKey:XZMocoaKeyText value:@"initialValue"];
// 绑定 image 属性，不赋初始值
[viewModel addTarget:imageView action:@selector(setImage:) forKey:XZMocoaKeyImage];
```

在 Swift 中，使用 `@key` 宏标记属性，即可在属性值改变时自动发送 KTA 事件；使用 `@bind` 宏，可自动建立 View 与 ViewModel 之间的绑定关系。

### 5、数据监听

对数据的监听是 MVVM 设计模式的特色之一，但在 iOS 实际开发中，数据在大部分情形下都是单向流动的（从网络请求到页面展示）。因此默认情况下，XZMocoa 不主动监听 Model 的变更。

对于需要监听数据变化的情形，可以重写类属性 `mappingModelKeys`，注册“视图模型方法”与“数据模型属性”之间的映射关系：

```objc
+ (NSDictionary<NSString *, id> *)mappingModelKeys {
    return @{
        @"setName:"        : @"name",
        @"setRangeMin:max:": @[@"min", @"max"]
    };
}
```

映射关系中的属性发生改变时，对应的方法会被调用。在 Swift 中，使用 `@mocoa` 和 `@bind` 标记属性和方法，即可自动创建上述映射关系：

```swift
@mocoa(.vm)
class ViewModel: XZMocoaViewModel {

    @bind
    func setRange(min: Int, max: Int) {
        // Model 的 min、max 属性任一改变，此方法都会被调用
    }
}
```

> 单个 Runloop 内的键值事件会合并统一处理，即同一个 key 即使在一个 Runloop 内发生多次改变，绑定的方法也只会执行一次。

监听是被动的，除非开启主动监听。

```swift
override var shouldObserveModelKeysActively: Bool {
    return true
}
```

当数据在视图模型外更新时，可通过 `-model:didChangeValuesForKeys:` 方法被动触发监听；当数据管理框架（如 CoreData 的 `NSFetchedResultsController`）自带监听机制时，可在其代理方法中调用此方法，XZMocoa 的列表视图模型已内置了对 `NSFetchedResultsController` 的支持。

## 模块化

不论采用何种设计模式，都应该让代码模块化，这样在更新维护时，变动就可以控制在模块内。XZMocoa 使用 MVVM 设计模式进行模块化：在 MVVM 设计模式下，视图通过自身的 ViewModel 管理逻辑，页面通过划分模块，将逻辑分散在各个子模块中，避免单个页面变得臃肿。

### 1、模块域

XZMocoa 提供了基于 URL 的模块管理方案 `XZMocoaDomain`，任何模块都可以通过 URL 在模块域中注册。

```objc
[[XZMocoaDomain domainNamed:@"mocoa.xezun.com"] setModule:yourModule forPath:@"your/module/path"];
```

上面例子中的模块地址为 `https://mocoa.xezun.com/your/module/path/`，其中 URL 的 scheme 是任意的。

```objc
id yourModule = [XZMocoaDomain moduleForURL:[NSURL URLWithString:@"https://mocoa.xezun.com/your/module/path/"]];
```

`XZMocoaDomain` 使用字典管理模块，无需担心性能问题。模块也可以由 `XZMocoaProvider` 协议提供懒加载，比如读取配置文件。

### 2、Mocoa 模块

XZMocoa 将每一个 MVVM 单元（Model-View-ViewModel）都视为一个模块，称为 Mocoa 模块，用 `XZMocoaModule` 对象表示。在 Mocoa 模块中，有如下约定：

- `Model` 使用 `-init` 作为初始化方法，或者开发者自行约定统一的初始化方法。
- `ViewModel` 使用 `-initWithModel:` 作为初始化方法。
- `View` 中的 `UIViewController` 使用 `-initWithNibName:bundle:` 作为初始化方法。
- `View` 中的 `UIView` 一般使用 `-initWithFrame:` 作为初始化方法，像 `UITableViewCell` 等被管理的视图，则由它们自身决定。

> 这些约定其实就是原生已有的方法，按照原生风格编码，基本不需要额外工作量。

在模块中注册 MVVM 单元的 `Model`、`View`、`ViewModel` 三个部分：

```objc
XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/module/");
module.modelClass     = Model.class;
module.viewClass      = View.class;
module.viewModelClass = ViewModel.class;
```

*注：函数 `XZMocoa(url)` 是 `+[XZMocoaModule moduleForURL:]` 的便利写法。*

模块注册后，即可按照约定使用：

```objc
// 拿到模块的原始数据
NSDictionary *data;
// 获取模块
XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/view/");
// 模型化数据（示例使用了 YYModel）
id<XZMocoaModel> model = [module.modelClass yy_modelWithDictionary:data];
// 创建 viewModel
XZMocoaViewModel *viewModel = [[module.viewModelClass alloc] initWithModel:model];
// 创建 view 并关联视图模型
UIView<XZMocoaView> *view = [UIView viewWithMocoaURL:module.url frame:CGRectMake(0, 0, 100, 100)];
view.viewModel = viewModel;
[self.view addSubview:view];
```

### 3、模块注册方式

模块应在被使用前注册到模块域中，`+load` 方法是非常合适的注册时机。

```objc
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/content/").viewNibClass = self;
}
```

如果项目组对 `+load` 方法的使用有限制，可以通过 `XZMocoaProvider` 协议自定义模块域中模块的提供方式，比如读取配置文件。

```objc
@protocol XZMocoaProvider <NSObject>
- (nullable id)domain:(XZMocoaDomain *)domain moduleForPath:(NSString *)path;
@end
```

### 4、模块的层级

在层级关系中，子模块的路径一般就是它的名字，比如：

| URL                                          | 说明                                                       |
| -------------------------------------------- | ---------------------------------------------------------- |
| `https://mocoa.xezun.com/`                   | 根模块                                                     |
| `https://mocoa.xezun.com/table/`             | `table` 模块                                               |
| `https://mocoa.xezun.com/table/name1/`       | `name1` 是 `table` 模块的子模块                            |
| `https://mocoa.xezun.com/table/name1/name2/` | `name2` 是 `name1` 模块的子模块，`name1` 是 `table` 模块的子模块 |

可以对子模块按分类管理，使用 `:` 分隔，比如：

| URL                                           | 说明                                      |
| --------------------------------------------- | ----------------------------------------- |
| `https://mocoa.xezun.com/table/header:name1/` | `name1` 是 `table` 模块的 `header` 子模块 |
| `https://mocoa.xezun.com/table/footer:name2/` | `name2` 是 `table` 模块的 `footer` 子模块 |

模块也可以没有名字和分类。路径中，没有分类可以省略 `:`，没有名字不能省略 `:`，比如：

| URL                                        | 说明                                   |
| ------------------------------------------ | -------------------------------------- |
| `https://mocoa.xezun.com/table/name/`      | 合法，模块名为 name 分类默认                |
| `https://mocoa.xezun.com/table/kind:name/` | 合法，模块名为 name 分类为 kind                |
| `https://mocoa.xezun.com/table/kind:/`     | 合法，模块名为默认，分类为 kind                   |
| `https://mocoa.xezun.com/table/:/`         | 合法，模块名、分类都为默认                      |
| `https://mocoa.xezun.com/table/kind/`      | 不合法。因为 `kind` 会被作为 `name` 使用 |

访问下级模块，可以使用 `-submoduleForKind:forName:` 方法，或者直接使用下标方式：

```objc
// 常规方式获取下级
XZMocoaModule *submodule = [module submoduleForKind:@"header" forName:@"black"];
// 下标方式获取下级
XZMocoaModule *submodule = module[@"header:black"];
```

对于列表模块，XZMocoa 提供了`cell`、`header`、`footer` 等便利属性，以及对应的 `xxxForName:` 方法。

### 5、默认模块

- 子模块中分类为`XZMocoaKindDefault` （空字符串）的模块，为默认模块的分类。
- 子模块中名称为`XZMocoaNameDefault` （空字符串）的模块，为默认模块的名称。
- 在`Table`或`Collection`列表中，默认分类的子模块为`Cell`模块。

## 列表 MVVM

下面以 iOS 开发中常用的 `UITableView` 组件为例，介绍如何使用 XZMocoa 开发列表页面。

由于原生 `UITableView` 原为 MVC 设计，使用 MVVM 设计模式时，需要适配版本 `XZMocoaTableView`：它仅接管了 `delegate` 和 `dataSource` 代理，未对 `UITableView` 做任何其它处理，`UITableView` 本身以 `contentView` 属性暴露。

### 1、数据协议

所有`NSObject`子类都可以作为列表数据模型，特别的可以直接将`NSArray`二维数组元素映射为列表`Cell`的数据模型。对于自定义模型，需要遵循`XZMocoaGroupModel`协议，才能在 Mocoa 中使用。

```objc
@protocol XZMocoaGroupModel <XZMocoaModel>
@optional
@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
- (nullable id)modelForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section;
- (nullable id)modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath;
@end
```

### 2、创建列表

`XZMocoaTableView` 是标准的 Mocoa 模块，可以直接使用，也可以通过 URL 的方式加载。

```objc
// model，替换为真实数据
NSArray *dataArray;
// viewModel
XZMocoaTableViewModel *tableViewModel = [[XZMocoaTableViewModel alloc] initWithModel:dataArray];
tableViewModel.module = XZMocoa(@"https://mocoa.xezun.com/table/");
// view
XZMocoaTableView *tableView = [[XZMocoaTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
tableView.viewModel = tableViewModel;
[self.view addSubview:tableView];
```

虽然目前并没有创建 cell，但仅需上面这些代码就可以渲染列表了，因为 XZMocoa 会使用占位 cell 渲染。这可以帮助提前验证数据的基本格式问题，并屏蔽原生组件关于 `dataSource` 的各种崩溃问题。

### 3、开发 cell 模块

将每一个 cell 都看作完全独立的模块进行开发，然后注册到相应的列表模块中即可展示。

###### 3.1 定义 View、ViewModel、Model

```objc
@interface ExampleCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@interface ExampleCellViewModel : XZMocoaTableCellViewModel
@property (nonatomic, copy) NSString *name;
@end

@interface ExampleCellModel : NSObject <XZMocoaModel>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end
```

除了 ViewModel 需要使用 XZMocoa 提供的基类外，View 和 Model 是完全自由的。协议 `XZMocoaTableCell` 和 `XZMocoaModel` 是辅助协议，不需要实现，声明遵循后即可使用协议提供的方法。

###### 3.2 处理数据

ViewModel 将数据转化为 View 展示所需的类型，并处理事件。

```objc
@implementation ExampleCellViewModel

- (void)prepare {
    [super prepare];

    self.height = 44.0;

    ExampleCellModel *data = self.model;
    self.name = [NSString stringWithFormat:@"%@ %@", data.firstName, data.lastName];
}

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    // 处理 cell 的点击事件
}

@end
```

ViewModel 向 View 提供稳定的 API，可以减少 View 层改动，同时也能屏蔽数据的细节差异，帮助在实现 View 时脱离具体的数据。

###### 3.3 渲染视图

View 根据 ViewModel 提供的数据进行展示。

```objc
@implementation ExampleCell

- (void)didChangeViewModel:(XZMocoaViewModel *)oldViewModel {
    ExampleCellViewModel *viewModel = self.viewModel;

    self.nameLabel.text = viewModel.name;
}

@end
```

方法 `-didChangeViewModel:` 由 `UIResponder` 的 `XZMocoaView` 分类提供，视图遵循 `XZMocoaView` 协议后即可使用。

###### 3.4 注册模块

将 cell 模块注册到列表模块中，就可以在列表中展示了。在下面的例子中，列表模块为 URL 为 `https://mocoa.xezun.com/table/` 的模块。

```objc
@implementation ExampleCellModel
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/table/").cell.modelClass = self;
}
@end

@implementation ExampleCell
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/table/").cell.viewClass = self;
}
@end

@implementation ExampleCellViewModel
+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/table/").cell.viewModelClass = self;
}
@end
```

在此示例中，只有一种类型的 `cell`，不需要具名，所以直接使用 `.section.cell` 注册。更多详细用法，可参考“Example”示例工程。

### 4、同步更新视图

数据变化后，调用 ViewModel 相应的方法，即可同步更新视图：

```objc
[_dataArray removeObjectAtIndex:0];
// Mocoa 默认不监听数据变化，下面方法的作用就是告诉 ViewModel 数据改变了。
[_tableViewModel deleteSectionAtIndex:0];
```

### 5、局部刷新

在列表页面中，直接使用 `-reloadData` 刷新整个页面是一种偷懒的做法。局部刷新不仅可以节省系统资源，也可以增强用户交互。但是由于数据大部分情况下都来自服务端请求，进行局部刷新需要分析数据变动，这可能会增加不少工作量。

而使用 `XZMocoaTableView` 或 `XZMocoaCollectionView` 可以轻松实现局部刷新：

```objc
[_tableViewModel performBatchUpdates:^{
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:newData];
} completion:nil];
```

将更新数据的操作放在 `batchUpdates` 块中，XZMocoa 会自动根据数据的 `-isEqual:` 方法分析数据变动，并进行局部刷新。

```objc
- (BOOL)isEqual:(ExampleCellModel *)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[ExampleCellModel class]]) return NO;
    return [self.dataID isEqualToString:object.dataID];
}
```

一般情况下，需要重写数据模型的 `-isEqual:/-hash` 方法；但如果数据层已经做了数据管理（同一数据始终是同一个对象，或已经实现了 `-isEqual:`），这一步就可以省略。

## 页面模块

XZMocoa 将 `UIViewController` 视为 MVVM 中特殊的 View，页面即模块。模块中注册 `viewModelClass` 后，即可通过模块 URL 直接创建或打开页面。

```objc
// 创建控制器
UIViewController *nextVC = [UIViewController viewControllerWithMocoaURL:[NSURL URLWithString:@"https://mocoa.xezun.com/main"]];
[self.navigationController pushViewController:nextVC animated:YES];

// 或直接使用便利方法
[self.navigationController pushMocoaURL:[NSURL URLWithString:@"https://mocoa.xezun.com/main"] animated:YES];
```

XZMocoa 为控制器提供了完整的模块化支持：

- `+viewControllerWithMocoaURL:options:`：通过模块 URL 创建控制器，URL 的 query 将作为 options 参数。
- `-initWithMocoaOptions:nibName:bundle:` / `-didInitWithMocoaOptions:`：模块化初始化方法，`options` 中包含模块、URL、参数等信息，可通过下标方式取值。
- `-presentMocoaURL:...`：通过模块 URL 弹出控制器。
- `-addChildViewControllerWithMocoaURL:`：通过模块 URL 添加子控制器。
- `-pushMocoaURL:...`（`UINavigationController`）：通过模块 URL 压栈控制器。
- `-setViewControllersWithMocoaURLs:animated:`（`UITabBarController`）：通过模块 URLs 设置子控制器。

控制器也可通过模块 URL 实例化视图：

```objc
UIView *view = [UIView viewWithMocoaURL:[NSURL URLWithString:@"https://mocoa.xezun.com/header"] frame:CGRectZero];
```

## Swift 宏

在 Swift 中，XZMocoa 提供了 `XZKitMacros` 宏库（随 `XZKit` 一起提供），用于简化 MVVM 开发：

- `@mocoa(.m)` / `@mocoa(.v)` / `@mocoa(.vm)`：将 class 标记为 Mocoa 的 MVVM 角色。
- `@mocoa`（无参数）：自动推断角色。命名以 `Model`、`View`、`ViewModel` 结尾，或继承自 `XZMocoaViewModel`、`XZMocoaModel`、`XZMocoaView`、`UIView`、`UIViewController` 的 class 均可被自动推断。
- `@key` / `@key(_ name:)`：标记 ViewModel 的属性，表明该属性支持 key-target-action 机制。被标记的属性将变为计算属性，并生成带下划线的同名存储属性，属性值改变时自动发送 KTA 事件。
- `@bind` / `@bind(_ key:)`：单向绑定。用于 ViewModel 时，监听 Model 属性的变化；用于 View 时，监听 ViewModel 的 KTA 事件。
- `@bind(_ vmKey:selector:)` / `@bind(text key:)` 等：为常用视图属性（text、image、isEnabled 等）提供便捷绑定形式。
- `@prepare`：标记 View 或 ViewModel 的角色初始化方法（非对象的初始化方法），以取代重写 `-prepare` 或 `-viewModelDidChange` 基类方法。被标记的方法需要使用 `private` 标记，支持多个初始化方法，将按书写顺序执行。
- `#mocoa(URL)`：通过模块 URL 获取 `XZMocoaModule` 对象。

```swift
// 通过模块 URL 获取模块
let module = #mocoa("https://mocoa.xezun.com/main")

// 带角色的标记
@mocoa(.vm)
class ViewModel: XZMocoaViewModel {
		
    // 声明此属性可以通过 KTA 机制监听，监听的键为 name 字符串。
    @key(.name)
    var name: String?

    // 将 model.name 绑定到此方法
    @bind
    func setName(_ name: String?) {
        self.name = name
    }
}
```

## 调试模式

调试模式下，控制台会输出一些信息，帮助调试检查代码。可在 `XZMocoaDefines.h` 中查看相关的调试开关配置。

## Author

Xezun, developer@xezun.com

## License

XZMocoa is available under the MIT license. See the LICENSE file for more info.
