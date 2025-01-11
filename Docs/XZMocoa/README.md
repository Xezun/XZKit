
# XZMocoa

[![CI Status](https://img.shields.io/badge/Build-pass-brightgreen.svg)](https://cocoapods.org/pods/XZMocoa)
[![Version](https://img.shields.io/cocoapods/v/XZMocoa.svg?style=flat)](https://cocoapods.org/pods/XZMocoa)
[![License](https://img.shields.io/cocoapods/l/XZMocoa.svg?style=flat)](https://cocoapods.org/pods/XZMocoa)
[![Platform](https://img.shields.io/cocoapods/p/XZMocoa.svg?style=flat)](https://cocoapods.org/pods/XZMocoa)

XZMocoa 是基于 Cocoa 框架设计的一款 MVVM 设计模式的基础框架，完全 Apple 风格的代码风格，可无缝接入到任意项目中。

## 示例项目

要运行示例工程，请在拉取代码后，先在`Pods`目录下执行`pod install`命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## 版本需求

iOS 11.0+，Xcode 14.0+

## 如何安装

推荐使用 [CocoaPods](https://cocoapods.org) 安装 XZMocoa 框架，在`Podfile`文件中添加下面这行代码即可。

XZMocoa is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZMocoa'
```

## 如何使用

下面以 iOS 开发中的常用的`UITableView`组件为例，介绍如何使用 XZMocoa 进行开发。

由于原生`UITableView`原为 MVC 设计，在使用 MVVM 设计模式时，我们需要使用适配版本，即`XZMocoaTableView`。

不过，需要注意的是，并不是不能直接使用`UITableView`，而是直接使用需要自行处理`dataSource`，而这一般是每次使用`UITableView`都会重复的代码。
所以XZMocoa直接将这部分重复的逻辑封装起来，即`XZMocoaTableView`仅接管了`delegate`和`dataSource`代理，未对`UITableView`做任何其它处理。

##### 1、设计数据

合理的数据结构，会大大的简化数据处理的过程，但实际开发过程中，数据可能并非总是我们期望的样子。
因此，为了让所有列表数据都能够在`XZMocoaTableView`中使用，XZMocoa设计了`XZMocoaTableModel`和`XZMocoaTableViewSectionModel`协议，来规范作为`XZMocoaTableView`数据的基本格式。而且任何数据只要实现这两个协议，就在`XZMocoaTableView`中使用。

> 协议只是规范，并非强制要求。
> 实际上，所有数据也都可以作为`XZMocoaTableView`的数据，但是如果不实现协议的话，XZMocoa不会对数据进行`section` 或`cell`的区分，实际效果就可能并非预期效果。

```objc
@protocol XZMocoaTableModel <XZMocoaModel>
@property (nonatomic, readonly) NSInteger numberOfSectionModels;
- (nullable id<XZMocoaTableViewSectionModel>)modelForSectionAtIndex:(NSInteger)index;
@end

@protocol XZMocoaTableViewSectionModel <XZMocoaModel>
@optional
@property (nonatomic, readonly) NSInteger numberOfCellModels;
- (nullable id)modelForCellAtIndex:(NSInteger)index;
- (NSInteger)numberOfModelsForSupplementaryKind:(XZMocoaKind)kind;
- (nullable id)modelForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
@end
```

严格来讲，数据不应该承担业务逻辑。

但是一般情况下，数据的结构，与数据类型是紧密相关的，即它们是一对一的关系，将它们一起处理，维护起来也是最方便的。

上述这两个协议，其实本质就是XZMocoa获取数据结构的一种方式而已，并非限定了数据的格式，通常情况下，可以在Category中实现这个协议，而不必影响数据本身。

> 数组天然是符合`XZMocoaTableView`规范的数据，即数组一维中的元素，会作为`section`数据，数组二维中的元素，会作为`cell`数据。

##### 2、创建列表

`XZMocoaTableView`是标准的 XZMocoa 模块，可以直接使用，可以通过`URL`的方式加载（参见“模块化”部分）。

```objc
// model, replace it with real data
NSArray *dataArray;
// viewModel
XZMocoaTableViewModel *tableViewModel = [[XZMocoaTableViewModel alloc] initWithModel:dataArray];
tableViewModel.module = XZModule(@"https://mocoa.xezun.com/table/");
[tableViewModel ready];
// view
XZMocoaTableView *tableView = [[XZMocoaTableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
tableView.viewModel = tableViewModel;
[self.view addSubview:tableView];
```

虽然目前我们并没有创建`cell`，但是仅仅需要上面这些代码，就可以渲染列表了，因为XZMocoa会使用`PlaceholderCell`占位渲染。
这可以帮我们提前验证数据基本格式问题，并解决原生组件关于`dataSource`的各种崩溃问题。

> `PlaceholderCell`仅在`DEBUG`环境下显示，在`Release`环境下会自动隐藏。

##### 3、开发`cell`模块

使用 XZMocoa 你可以将每一个`cell`都看作是完全独立的模块进行开发，然后注册到相应的`tableView`模块中即可展示。

> 开发`cell`模块，与开发普通 MVVM 模块的过程基本一样，仅需要按照 MVVM 的基本要求编写即可。

###### 3.1 定义 View、ViewModel、Model

```objc
@interface ExampleCell : UITableViewCell <XZMocoaTableViewCell>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@interface ExampleCellViewModel : XZMocoaTableViewCellViewModel
@property (nonatomic, copy) NSString *name;
@end

@interface ExampleCellModel : NSObject <XZMocoaTableViewCellModel>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end
```

除了`ViewModel`需要使用 Mocoa 提供的基类外，`View`和`Model`是完全自由的。

协议`XZMocoaTableViewCell`和`XZMocoaTableViewCellModel`是辅助协议，不需要实现，而是声明遵循后，即可使用协议方法的协议。

###### 3.2 处理数据

`ViewModel`将数据转化为`View`展示所需的类型，并处理事件。

```objc
@implementation ExampleCellViewModel
- (void)prepare {
    [super prepare];

    self.height = 44.0;
    
    ExampleModel *data = self.model;
    self.name = [NSString stringWithFormat:@"%@ %@", data.firstName, data.lastName];
}

- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /// 处理 cell 的点击事件
}
@end
```

ViewModel向View提供稳定的API，这可以减少View层改动，同时也能屏蔽数据的细节差异，帮助我们在实现View时，可以脱离具体的数据。

###### 3.3 渲染视图

`View`根据`ViewModel`提供的数据进行展示。

```objc
@implementation ExampleCell
- (void)viewModelDidChange {
    ExampleViewModel *viewModel = self.viewModel;
    
    self.nameLabel.text = viewModel.name;
}
@end
```

方法`viewModelDidChange`是`XZMocoaView`协议提供的方法，声明该协议即可获得该方法。

###### 3.4 注册模块

将`cell`模块注册到`tableView`模块中，就可以在`tableView`中展示了。在下面的例子中，`tableView`模块为`URL`为`https://mocoa.xezun.com/table/`的模块。

> 在`UITableView`中`section`没有直接视图，但却是不可少的逻辑层，所以在XZMocoa中，需要将`cell`是注册在`section`之下，而非直接在`tableView`之下。

```objc
@implementation ExampleCellModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/table/").section.cell.modelClass = self;
}
@end

@implementation ExampleCell
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/table/").section.cell.viewNibClass = self;
}
@end

@implementation ExampleCellViewModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/table/").section.cell.viewModelClass = self;
}
@end
```

至此，使用`XZMocoaTableView`渲染列表的一个简单示例就完成了，现在运行代码，就可以看到实际效果。

在这个示例中，我们只有一种类型的`section`和`cell`，不需要具名，所以直接使用`.section.cell`注册，更多详细用法，可参考“Example”示例工程。

###### 3.5 总结

使用 Mocoa 渲染列表，与使用原生的`UITableView`相比：

- 不用编写`delegate`或`dataSource`方法。
- 不用先编写`cell`，Mocoa 会先用占位视图替代，直到`cell`模块编写完成。
- 模块`cell`完全独立，编写`cell`后，仅需注册模块，不需在`tableView`或`collectionView`中注册。

还有，我们再也不用担心`dataSource`导致的Crash问题了。

## 模块化

不论采用何种设计模式，都应该让你的代码模块化。这样在更新维护时，变动就可以控制在模块内，从而避免牵一发而动全身。

XZMocoa使用MVVM设计模式进行模块化，因为在MVVM设计模式下，视图可以通过自身的`ViewModel`管理逻辑，
这样页面就可以通过划分模块的方式，将逻辑就可以分散在各个子模块中，从而避免单个页面变得臃肿。

> 即在MVVM模式下，页面从视图的集合，变成了模块的集合，页面从管理自视图的，变为管理子模块。

###### 1、管理模块

XZMocoa为模块提供了基于`URL`的模块管理方案`XZMocoaDomain`，任何模块都可以通过`URL`在`XZMocoaDomain`中注册。

```objc
[[XZMocoaDomain doaminNamed:@"mocoa.xezun.com"] setModule:yourModule forPath:@"your/module/path"];
```

上面例子中的模块地址为`https://mocoa.xezun.com/your/module/path/`，其中 URL 的`scheme`是任意的。

```objc
id yourModule = [XZMocoaDomain moduleForURL:@"https://mocoa.xezun.com/your/module/path/"];
```

`XZMocoaDomain`其实就是简单地使用`NSMutableDictionary`管理模块，所以你不必担心它的性能问题。

在实际开发中，有些提供了各种各样方法的“模块”，通过上面注册的方式拿到一个匿名的`id`类型，似乎显得多次一举。
但是在XZMocoa看来，这样的“模块”并不是真正的模块，而只是一个组件，或提供方法的工具类，因为真正的模块应该是能独自完成功能的，不需要或者仅需要少量基本数据作为参数。
比如，每个App就可以看作是一个独立的模块，`void main(int, char *)`是它们统一入口函数。

###### 2、XZMocoa模块

XZMocoa将每一个MVVM单元`Model-View-ViewModel`都视为一个模块，称为Mocoa模块，用`XZMocoaModule`对象表示。在Mocoa模块中，有如下约定。

- `Model`使用`-init`作为初始化方法，或者开发者自行约定统一的初始化方法。
- `ViewModel`使用`-initWithModel:`作为初始化方法。
- `View`中的`UIViewController`使用`-initWithNibName:bundle:`作为初始化方法
- `View`中的`UIView`一般使用`-initWithFrame:`作为初始化方法，像`UITableViewCell`等被管理的视图，则它们自身决定。

上面这些约定，其实就是原生已有的方法，如果我们按照原生风格进行编码，这些基本不需要额外工作量。

> 推荐使用原生风格进行编码，可以有效降低维护成本、学习成本。

在Mocoa中注册MVVM模块的`View`、`Model`、`ViewModel`三个部分。

```objc
XZMocoaModule *module = XZModule(@"https://mocoa.xezun.com/module/");
module.modelClass     = Model.class;
module.viewClass      = View.class;
module.viewModelClass = ViewModel.class;
```

*注：函数`XZMocoa(url)`是`+[XZMocoaModule moduleForURL:]`的便利写法。*

模块在注册后，我们就可以按照约定好的基本规则使用它们了，比如对于一个普通的视图模块，我们在拿到数据后，可以像下面这样使用它。

```objc
// 拿到了模块的原始数据
NSDictionary *data;
// 获取到模块。 
XZMocoaModule *module = XZModule(@"https://mocoa.xezun.com/view/");
// 这里使用了 YYModel 组件处理模型化数据
id<XZMocoaModel> model = [module.modelClass yy_modelWithDictionary:data]; 
// 创建 viewModel
XZMocoaViewModel *viewModel = [[module.viewModelClass alloc] initWithModel:model];
[viewModel ready];
// 创建 view
UIView<XZMocoaView> *view = [module instantiateViewWithFrame:CGRectMake(0, 0, 100, 100)];
view.viewModel = viewModel;
[self.view addSubview:view];
```

对于页面`UIViewController`模块，Mocoa认为它是一个独立模块，所以在启动页面时，提供了便利方法。

```objc
UIView<XZMocoaView> *view;
NSURL *url = [NSURL URLWithString:@"https://mocoa.xezun.com/main"];
[view.navigationController pushMocoaURL:url animated:YES];
```

即，我们可以通过页面模块的`URL`直接打开页面。

> 使用`View`打开控制器，在MVC设计模式中是不合理的，但是在MVVM设计模式中，`UIViewController`仅仅是特殊的`View`而已。

###### 3、模块注册方式

模块应该在被使用前注册到`XZMocoaDomain`中，因此`+load`方法非常合适的注册时机。

```objc
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/20/content/").viewNibClass = self;
}
```

如果项目组对`+load`方法使用有限制，可以通过`XZMocoaModuleProvider`协议自定义`XZMocoaDomain`的模块提供方式，比如读配置文件。

```objc
@protocol XZMocoaModuleProvider <NSObject>
- (nullable id)domain:(XZMocoaDomain *)domain moduleForPath:(NSString *)path;
@end
```

###### 4、模块的层级

在层级关系中，子模块的路径，一般就是它的名字，比如：

| URL                                          | 说明                                                       |
| -------------------------------------------- | ---------------------------------------------------------- |
| `https://mocoa.xezun.com/`                   | 根模块                                                     |
| `https://mocoa.xezun.com/table/`             | `table`模块                                                |
| `https://mocoa.xezun.com/table/name1/`       | `name1`是`table`模块的子模块                               |
| `https://mocoa.xezun.com/table/name1/name2/` | `name2`是`name1`模块的子模块，`name1`是`table`模块的子模块 |

如果子模块有分类，使用`:`分隔，比如：

| URL                                                   | 说明                                   |
| ----------------------------------------------------- | -------------------------------------- |
| `https://mocoa.xezun.com/table/section/header:name1/` | `name1`是`section`模块的`header`子模块 |
| `https://mocoa.xezun.com/table/section/footer:name2/` | `name2`是`section`模块的`footer`子模块 |

模块也可以没有名字和分类，但是在路径中，没有分类可以省略`:`，没有名字不能省略`:`，比如：

| URL                                        | 说明                                   |
| ------------------------------------------ | -------------------------------------- |
| `https://mocoa.xezun.com/table/name/`      | 合法                                   |
| `https://mocoa.xezun.com/table/kind:name/` | 合法                                   |
| `https://mocoa.xezun.com/table/kind:/`     | 合法                                   |
| `https://mocoa.xezun.com/table/:/`         | 合法                                   |
| `https://mocoa.xezun.com/table/kind/`      | 不合法。因为 kind 会被作为 name 使用。 |

###### 5、默认模块

一般情况下，名称为`XZMocoaNameDefault`的模块，一般为同级模块中的默认模块，比如在`XZMocoaTableView`或`XZMocoaCollectionView`中。

1、为名称为`name`的`section`模块创建`ViewModel`对象时，会按照以下顺序使用`viewModelClass`配置。

- 当前`tableView`中名称为`name`的`section`模块的`viewModelClass`
- 当前`tableView`中名称为`XZMocoaNameDefault`的`section`模块的`viewModelClass`
- 使用`PlaceholderViewModelClass`

2、为名称为`name`的`cell`模块创建`ViewModel`对象时，会按照以下顺序使用`viewModelClass`配置。

- `tableView`中，当前`section`中名称为`name`的`cell`模块的`viewModelClass`

- `tableView`中，当前`section`中名称为`XZMocoaNameDefault`的`cell`模块的`viewModelClass`

- `tableView`中，默认`section`中名称为`name`的`cell`模块的`viewModelClass`

- `tableView`中，默认`section`中名称为`XZMocoaNameDefault`的`cell`模块的`viewModelClass`

- 使用`PlaceholderViewModelClass`

  *默认`section`模块，即名称为`XZMocoaNameDefault`的`section`模块。*

## Mocoa MVVM

Mocoa 建议使用 MVVM 模式设计您的代码，包括控制器，而且列表页面中，每一个区块视图`cell`也应该设计为独立的 MVVM 模块。

> 区块视图为业务视图，而非视图组件，因为视图组件没有业务逻辑，不需要使用 MVVM 设计模式。

为更好地使用 MVVM 设计模式，Mocoa 为原生拓展了一些能力。

- `XZMocoaModel`协议，Model 遵循此协议，以表明 Model 是 MVVM 中的 `Model` 元素。
- `XZMocoaView`协议，View 遵循此协议，以表明 View 是 MVVM 中的 `View` 元素，同时获得`XZMocoaView`协议提供的能力。
- `XZMocoaViewModel`基类，`ViewModel`提供的功能要复杂的多，无法通过协议的方式呈现，因此提供了基类。

Mocoa 与其说是框架，不如说是规范，通过协议规范 MVVM 的实现方法。

#### 1、层级机制

在页面模块中，子视图模块，与父视图模块或控制器模块，存在明显的上下级关系。充分利用这种层级关系，可以更方便的处理页面中的一些上下级的交互逻辑，因此 Mocoa 设计了`ViewModel`的层级关系。

```objc
[superViewModel addSubViewModel:viewModel];
[viewModel insertSubViewModel:viewModel atIndex:1]
```

然后我们就可以通过层级关系，收发`emit`事件。

```objc
// send the emition
- (void)sendUpdate:(NSString *)name value:(id)value;

// handle the emition
- (void)didReceiveUpdate:(XZMocoaUpdate *)emition;
```

比如在`UITableView`列表中，`cell`模块改变了内容时，希望`UITableView`模块刷新页面时，可以像下面这样处理。

```objc
// 在 cell 中
- (void)handleUserAction {
    // change the data then
    self.height = 100; // a new height
    [self sendUpdate:XZMocoaUpdateNameReload value:nil];
}

// 在 UITableView 模块中
- (void)didReceiveUpdate:(XZMocoaUpdate *)emition {
    if ([emition.name isEqualToString:XZMocoaUpdateNameReload]) {
        [self reloadData];
    }
}
```

当前这么做，需要一些默认的约定，比如将`XZMocoaUpdateNameReload`作为刷新视图的事件。
在 MVC 中，解决上面的问题，一般是通过`delegate`实现，这明显或破坏模块的整体性，上层模块与下层模块的`delegate`形成了耦合，但是利用层级关系处理，就能很好的避免这一点。

同时，层级关系事件的局限性也很明显，仅适合处理比较明确的事件，不过在模块封装完整的情况下，下层模块也不应该有其它事件需要传递给上级处理。

#### 2、ready 机制

在模块层级关系中，模块在创建时，可能并不需要立即初始化，或者模块需要额外的初始化参数，比如在`UIViewController`中，应该在`viewDidLoad`时初始化，因此 Mocoa 设计了`ready`机制来延迟`ViewModel`的初始化时机。

在`ready`机制下，开发者应该在`ViewModel`的`-prepare`方法中进行初始化。

```objc

- (void)prepare {
    [super prepare];

    // 执行当前模块的初始化
}

```

如果是顶层模块，应该在合适的时机调用`ViewModel`的`-ready`方法。比如页面模块，一般是顶层模块，建议在`-viewDidLoad`中执行。

```objc
- (void)viewDidLoad {
    [super viewDidLoad];

    Example20ViewModel *viewModel = [[Example20ViewModel alloc] initWithModel:nil];
    [viewModel ready];

    self.viewModel = viewModel;
    self.tableView.viewModel = viewModel.tableViewModel;
}
```

因为控制器顶层模块，引用模块时不需要准备数据，它的数据是`ViewModel`自行处理的，所以初始化它的`model`是`nil`，在`View`中自己创建`ViewModel`也是合理的。
同时 Mocoa 也约定：

- 在顶层独立的`UIViewController`页面模块中，应由`View`（即`UIViewController`）在合适的时机自行创建`ViewModel`。

由外部提供数据的不完全独立的页面模块，加载使用方式则与`UIView`基本一致。

```objc
XZMocoaModule *module = XZModule(@"https://mocoa.xezun.com/");

id model;
XZMocoaViewModel *viewModel = [[module.viewModelClass alloc] initWithModel:model];
UIViewController<XZMocoaView> *nextVC = [module instantiateViewControllerWithOptions:nil];
nextVC.viewModel = viewModel; // not ready here, and nextVC must call -ready in -viewDidLoad method before use it.
[view.navigationController pushViewController:nextVC animated:YES];
```

Mocoa 为独立的顶层模块，提供了进入的便利方法。

```objc
// UIViewController
- (void)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)flag completion:(void (^_Nullable)(void))completion;
- (void)addChildMocoaURL:(nullable NSURL *)url;
// UINavigationController
- (void)pushMocoaURL:(nullable NSURL *)url animated:(BOOL)animated;
```

#### 3、target-action

在 MVVM 设计模式中，`View`通过监听`ViewModel`的属性来展示页面，但是实际上，大部分情况下，`View`并不需要一直监听，因为大多数的`View`只需要渲染一次。
所以 Mocoa 没有设计如何实现监听的代码，因为大部分页面渲染在`viewModelDidChange`中就能完成了。

在剩下的小部分情况中，我们可以通过`delegate`的方式来实现，这比监听更直观，且易维护。
不过，使用`delegate`由于需要定义协议，使用起来比较麻烦，所以了简化这些在少量事件的处理，Mocoa 设计了`target-action`机制。

这是一种半自动的机制，使用`NSString`作为`key`，`View`在绑定的`key`之后，`ViewModel`在调用`-sendActionsForKey:`方法时，`View`绑定的方法就会被触发。

```objc
// view 监听了 viewModel 的 isHeaderRefreshing 属性
[viewModel addTarget:self action:@selector(headerRefreshingChanged:) forKey:@"isHeaderRefreshing"];

- (void)headerRefreshingChanged:(Example20ViewModel *)viewModel {
    if (viewModel.isHeaderRefreshing) {
        [self.tableView.contentView.xz_headerRefreshingView beginAnimating];
    } else {
        [self.tableView.contentView.xz_headerRefreshingView endAnimating];
    }
}

// viewModel 发送事件
[self sendActionsForKey:@"isHeaderRefreshing"];
```

`target-action`机制，相当于使用`keysEvents`代替了`delegate`协议，处理一些简单的事件。

#### 4、MVVM 化适配

原生的大部分视图控件，在 MVVM 设计模式下使用，都是合适的，但某些特殊类型的视图，需要进行 MVVM 化之后，才适合在 MVVM 中使用。
比如具有视图管理功能的`UITableView`和`UICollectionView`列表视图，Mocoa 将它们封装为更适合在 MVVM 设计模式中使用的`XZMocoaTableView`和`XZMocoaCollectionView`视图。

###### 4.1、UIView 的适配化

在 MVVM 中，`UIViewController`的角色是`View`，所以在 Mocoa 中，通过`View`可以直接获取对应的控制器。


```objc
@protocol XZMocoaView <NSObject>
@property (nonatomic, readonly, nullable) __kindof UIViewController *viewController;
@property (nonatomic, readonly, nullable) __kindof UINavigationController *navigationController;
@property (nonatomic, readonly, nullable) __kindof UITabBarController *tabBarController;
@end
```

###### 4.2 UITableView/UICollectionView 的适配化

`XZMocoaTableView`和`XZMocoaCollectionView`是适配化后的列表视图，仅对`UITableView`和`UICollectionView`进行了一次简单的封装。

1. 通过`ViewModel`管理`cell`的高度。

```objc
@interface XZMocoaTableCellViewModel : XZMocoaListCellViewModel
@optional
@property (nonatomic) CGFloat height;
@end
```

2. 列表事件，重新转发给`cell`，并再转发给`ViewModel`处理。

```objc
@interface XZMocoaTableCellViewModel : XZMocoaListCellViewModel
@optional
- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(XZMocoaTableView *)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(XZMocoaTableView *)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath*)indexPath;
@end
```

Mocoa 目前默认只转发了基本的三个事件，如需要更多事件，需要开发者重写或在`Category`中自行实现。

3. 同步更新视图。

当数据变化后，调用`ViewModel`相应的方法，即可更新视图。

```objc
[_dataArray removeObjectAtIndex:0];
[_tableViewModel deleteSectionAtIndex:0];
```

4. 局部刷新。

一般情况下，在列表页面中，直接使用`-reloadData`刷新整个页面，虽然可以达到目的，但是很明显，这是一种偷懒的做法。局部刷新，不仅可以节省系统资源，也可以增强用户交互，使用户很清楚的知道页面更新的部分，同时也提供了应用的档次。但是由于数据大部分情况下，都是从服务端请求的，进行局部刷新就需要分析数据变动，这可能会增加不少工作量，这也是我们很少使用局部刷新的主要原因。

但是现在，使用`XZMocoaTableView`或`XZMocoaCollectionView`即可轻松实现局部刷新。

```objc
[_tableViewModel performBatchUpdates:^{
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:newData];
} completion:nil];
```

即，将更新数据的操作，放在`batchUpdates`块中，Mocoa 即会自动根据数据的`-isEqual:`方法，分析数据的变动，并进行局部刷新。

```objc
- (BOOL)isEqual:(Example20Group102CellModel *)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[Example20Group102CellModel class]]) return NO;
    return [self.nid isEqualToString:object.nid];
}
```

一般情况下，我们需要重写数据模型的`-isEqual:`方法，但是如果在数据层已经做了数据管理，比如从数据层获取的数据，同一数据始终是同一个对象，或已经做了`-isEqual:`处理，这一步就可以省略。

另外，在“示例工程”中，有使用 Mocoa 的完整的示例可以参考。

## 调试模式

调试模式下，控制台会输出一些信息，帮助我们调试检查代码。

```ruby
pod 'XZMocoa/Debug'
```

## Author

Xezun, developer@xezun.com

## License

XZMocoa is available under the MIT license. See the LICENSE file for more info.

