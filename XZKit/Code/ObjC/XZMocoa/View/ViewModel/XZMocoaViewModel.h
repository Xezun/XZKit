//
//  XZMocoaViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 作为 Mocoa MVVM 中的 ViewModel 元素，需要实现的协议。
NS_SWIFT_UI_ACTOR @protocol XZMocoaViewModel <NSObject>
@required
- (instancetype)initWithModel:(nullable id)model;
@end

/// 视图通过代理接收视图模型的事件。
@protocol XZMocoaViewModelDelegate <NSObject>
@optional
- (nullable UIViewController *)viewModel:(id<XZMocoaViewModel>)viewModel viewController:(void * _Nullable)null;
@end

/// 为简化开发，Mocoa 提供的视图模型基类。
///  
/// - 延迟初始化的 ready 机制。
/// - 层级关系。
/// - 下层模块 到 上层模块 的 Updates 事件机制。
/// - 视图监听视图模型属性的 target-action 机制。
///  
/// # 数据监听
///
/// 对数据的监听是 MVVM 设计模式的特色之一，但在 iOS 实际开发中，数据在大部分情形下，都是单向流动的，类似从网络请求到页面展示的场景居多。
/// 双向的数据流动的业务场景也有，但在开发中并不多。鉴于此，默认情况下 XZMocoa 不监听数据 Model 的变更。
/// 而对于要监听数据的变化的少量情形，我们可以通过传统的方式处理，比如的 KVO 或通知。
///  
/// ## 一、数据在视图模型外更新
/// 1. 通过 Cocoa 传统的 KVO、通知、代理等机制监听。
/// 2. 使用 CoreData 的 NSFetchedResultsController 代理方法。
/// 3. 不监听数据细节，整体刷新。
/// ## 二、数据在视图模型中更新
/// 1. 数据在下层视图模型更新后，可通过 Updates 机制通知上层模型。
/// 2. 数据在下层视图模型更新后，如下层视图模型与上层视图模型关系明确，比如 section 与 tableView 之间，上层视图模型可定义方法供下层视图模型直接调用。
/// 3. 数据在上层视图模型更新后，通过协议定义监听方法，上层视图模型直接调用下层视图模型的协议方法，其实就是代理机制。
/// 4. 数据在上层视图模型更新后，下层视图模型也可以通过 KVO 监听。
/// 5. 数据更新后，视图模型通过 target-action 机制，通知视图渲染。
/// 5. 数据更新后，也可通过 delegate 通知视图。
@interface XZMocoaViewModel : NSObject <XZMocoaViewModel>

/// 视图模型事件的代理，通常为视图。
@property (nonatomic, weak) id<XZMocoaViewModelDelegate> delegate;

/// 当前视图模型所属的模块。一般情况下，此属性并非必须。
///
/// 对于像 UITableView 或 UICollectionView 等管理子视图的视图来说，管理下级元素需要通过设置此属性获取所属的模块。
@property (nonatomic, strong, nullable) XZMocoaModule *module;

/// 数据。
///
/// > 属性可写是为兼容 Swift 结构体数据类型，默认情况下，修改属性除修改数据外，不执行任何操作。
@property (nonatomic, strong, nullable) id model;

/// 视图在列表中的排序。
@property (nonatomic) NSInteger index;

/// 标准初始化方法。一般情况下，子类应尽量避免添加新的初始化方法，保证接口统一。
/// @param model 数据
- (instancetype)initWithModel:(nullable id)model NS_DESIGNATED_INITIALIZER;

/// 通过模块 URL 初始化视图模型。
/// @param URL 模块 URL
/// @param model 数据模型
+ (nullable __kindof XZMocoaViewModel *)viewModelWithURL:(NSURL *)URL model:(nullable id)model NS_SWIFT_NAME(init(_:model:));

/// 是否已完成初始化。
///
/// 关于 ready 机制
/// 1. 延迟初始化时机。
/// 2. 使用 ready/prepare 方法组合，可以避免初始化逻辑反复执行。
/// 3. 视图模型在使用前，必须处于`isReady == YES`状态。
@property (nonatomic, readonly) BOOL isReady;

/// 视图模型在使用前，应调用此方法，以初始化视图模型。
///
/// - 一般情况下，请勿重写此方法。
/// - 上层视图模型会自动向下层视图模型发送`-ready`消息，在层级关系中，仅需顶层视图模型调用此方法即可。
/// - 此方法可重复调用，且不会重复`-prepare`初始化。
- (void)ready;

/// 视图模型的初始化方法。
///
/// - 一般情况下，请勿直接调用此方法，而是调用`-ready`方法，否则可能会重复初始化。
/// - 默认该方法不执行任何操作，建议子类调用`super`以向后兼容。
/// - 在此方法中，视图模型 isReady 始终为 NO 的状态。
/// - 在此方法中创建添加下层视图模型，不需要发送`-ready`消息。
/// - 此方法执行时，视图模型尚为与视图关联，即视图模型在初始化之后，才会被视图所使用。
- (void)prepare NS_REFINED_FOR_SWIFT;

@end

@interface XZMocoaViewModel (XZMocoaViewModelHierarchy)

/// 所有下级视图模型。
/// @note 属性值虽然为不可变数组，但并非拷贝，会跟随实际自动变化。
@property (nonatomic, strong, readonly) NSArray<__kindof XZMocoaViewModel *> *subViewModels;

/// 上级视图模型。
@property (nonatomic, readonly, nullable) __kindof XZMocoaViewModel *superViewModel;

/// 添加下级。
/// @note 会从其现有的上级移除。
- (void)addSubViewModel:(nullable XZMocoaViewModel *)subViewModel;

/// 将下级添加到指定位置。
/// @param subViewModel 下级
/// @param index 位置
- (void)insertSubViewModel:(nullable XZMocoaViewModel *)subViewModel atIndex:(NSInteger)index;

/// 移动原来在 index 位置的下级，到 newIndex 位置。
/// @param index 原始位置
/// @param newIndex 新位置，移动后所在的位置
- (void)moveSubViewModelAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex;

/// 从上级中移除。
- (void)removeFromSuperViewModel;

/// 如果某一个下级被移除，那么此方法会被调用。
/// @note 默认不执行任何操作。
/// @param viewModel 已被移除的下级
- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel;

@end


// - Mocoa Hierarchy Updates -
// 层级更新机制：在具有层级关系的业务模块中，下级模块向上级模块传递数据或事件，或者上级模块监听下级模块的数据或事件。
//
// 在 iOS 开发中，事件传递一般使用代理模式，因为代理协议可以让上下级的逻辑关系看起来更清晰。
// 但是在使用 MVVM 设计模式开发时，因为模块的划分，原本在 MVC 模式下，可以直接交互的逻辑，变得不再直接。
// 比如，如果将 UITableView 视为一个模块，那么这个模块就会过于臃肿；而如果将每个 Cell 视为一个模块，
// 又导致 Cell 与 Cell 之间、Cell 与 TableView 之间的交互变得难以维护，因为需要额外的工作，来设计
// 模块之间的交互，开发效率和开发体验必将受影响。
// 所以 Mocoa 设计了基于层级关系的 Mocoa Hierarchy Updates 机制，来简化层级模块间的交互问题。
//
// 虽然视图 View 可以通过调用 -didReceiveUpdates: 方法来向视图模型 ViewModel 传递事件或数据，
// 但正确的做法应是，直接调用视图模型 ViewModel 的方法，因为视图模型对视图来说是公开的。
// 而视图模型 ViewModel 向视图 View 传递事件或数据，按 Apple Cocoa 的习惯，应使用 delegate 机制，
// 但是也可以使用 Mocoa 提供的 target-action-value 机制。

/// 更新方式。
typedef NSString *XZMocoaUpdatesKey NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(XZMocoaUpdates.Key);

/// 更新信息模型。
NS_SWIFT_NAME(XZMocoaViewModel.Updates)
@interface XZMocoaUpdates : NSObject
/// 更新方式，或者用来区分更新的标记。
@property (nonatomic, copy, readonly) XZMocoaUpdatesKey key;
/// 事件值。
@property (nonatomic, strong, readonly, nullable) id value;
/// 发生当前事件的源对象。
@property (nonatomic, unsafe_unretained, readonly) __kindof XZMocoaViewModel *source;
/// 传递当前事件的对象。
@property (nonatomic, unsafe_unretained, XZ_READONLY) __kindof XZMocoaViewModel *target;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)updatesWithKey:(XZMocoaUpdatesKey)key value:(nullable id)value source:(XZMocoaViewModel *)source NS_SWIFT_NAME(init(_:value:source:));
@end

/// 通用事件。如果视图模型只有一个事件，或者没必要细分事件时，可以使用此名称。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyNone;
/// 重载事件。适用情形：通知上级，执行重载模块的操作（数据已经更新）。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyReload;
/// 更新操作。适用情形：通知上级，执行数据编辑的操作（数据还未编辑）。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyModify;
/// 插入操作。适用情形：通知上级，执行数据插入的操作（新数据未插入）。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyInsert;
/// 删除操作。适用情形：通知上级，执行删除数据的操作（数据还未删除）。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyDelete;
/// 选择操作。比如单选 cell 时，只能由上层控制单选。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeySelect;
/// 反选操作。
FOUNDATION_EXPORT XZMocoaUpdatesKey const XZMocoaUpdatesKeyDeselect;

@protocol XZMocoaView;

@interface XZMocoaViewModel (XZMocoaViewModelHierarchyUpdates)

/// 接收下级模块的更新，或监听到下级模块的数据变化。
/// @discussion
/// 只有在 isReady 状态下，才会传递事件。
/// @discussion
/// 默认情况下，该方法直接将事件继续向上级模块传递，开发者可重写此方法，根据业务需要，控制事件是否向上传递。
/// @param updates 事件信息
- (void)didReceiveUpdates:(XZMocoaUpdates *)updates;

/// 向上级模块发送更新，当前对象将作为事件源。
/// @discussion 只有在 isReady 状态下，才会发送事件。
/// @param key 事件名，如为 nil 则为默认名称 XZMocoaUpdatesKeyNone
/// @param value 事件值
- (void)emitUpdatesForKey:(XZMocoaUpdatesKey)key value:(nullable id)value;

@end


// - Mocoa Target Action Value -
//
// 设计背景：
// 一种基于 target-action 方式的事件监听机制。这是一种被动机制，手动调用才会触发监听事件。
// 在 iOS 开发中，不论采用何种方式进行“键-值”绑定，都有着不小的开发量。
// “高级”的绑定，在形式上会减少一些代码量，但是其带来的维护成本，相对这些代码量并不是经济的。
// 而在 iOS 开发中，UI展示才是主要部分，对于响应式要求其实并不高，不应该放在设计架构的首选。
// 而 target-action 是 iOS 开发中的常用机制，与引入新机制相比，开发和维护成本都大大降低。
// 设计目的：
// ViewModel 的 target-action 机制，主要用于 ViewModel 向 View 发送事件。
// 在开发中，如果 ViewModel 的事件较多且复杂，建议使用 delegate 发送事件。但是对于大多数
// 业务场景中，ViewModel 事件不仅少而且单一，使用 target-action 机制就完全可以满足要求。
//


/// Mocoa Keyed Actions 事件名。
typedef NSString *XZMocoaKey NS_EXTENSIBLE_STRING_ENUM;

/// 没有 key 也可作为一种事件，或者称为默认事件，值为空字符串。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNone;

// 以下为常用的 key
@class UILabel, UIButton, UIImageView;

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentStatus;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsChecked;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValue;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImage;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImageURL;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyName;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedTitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubtitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTextColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFont;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDetailText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStartAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStopAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRefreshing;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRequesting;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsLoading;

/// 用于标记属性可以被添加 target-action 的属性或方法，仅起标记作用。
/// @code
/// @property (nonatomic) BOOL isLoading XZ_MOCOA_KEY();          // The key is 'isLoading'
/// @property (nonatomic) BOOL isLoading XZ_MOCOA_KEY("loading"); // The key is 'loading'
/// - (void)startLoading XZ_MOCOA_KEY("isLoading");               // The key is 'isLoading'
/// @endcode
/// @todo
/// 编译器插件，在属性中添加 mocoa=key 标记，生成的 setter 中添加发送 key 事件的代码。
#define XZ_MOCOA_KEY(key)

@interface XZMocoaViewModel (XZMocoaViewModelTargetAction)

/// 添加 target-action 事件。调用此方法不会触发 action 方法。
///
/// @li 方法 action 必须无返回值，因为没有针对返回值的内存管理，可能会引起泄漏。
/// @li 方法 action 的 value 参数不建议为 union 类型，除非 union 类型的大小为 1/2/4/8/16/32/64/128 字节。
/// @li 参数 action 方法形式如下：
///
/// @code
/// - (void)action;
/// - (void)didChangeValue:(nullable id)value;
/// - (void)key:(XZMocoaKey *)key didChangeValue:(nullable id)value;
/// - (void)viewModel:(XZMocoaViewModel *)sender key:(XZMocoaKey)key didChangeValue:(nullable id)value;
/// @endcode
///
/// 使用示例：
///
/// @code
/// // 绑定 startAnimating 事件
/// [viewModel addTarget:indicator action:@selector(startAnimating) forKey:XZMocoaKeyStartAnimating value:nil];
/// // 绑定 text 属性，并赋初始值 initialValue
/// [viewModel addTarget:label action:@selector(setText:) forKey:XZMocoaKeyText value:@"initialValue"];
/// // 绑定 image 属性，不赋初始值
/// [viewModel addTarget:imageView action:@selector(setImage:) forKey:XZMocoaKeyImage];
/// @endcode
///
/// @param target 接收事件的对象
/// @param action 执行事件的方法
/// @param key 事件，nil 表示添加默认事件
- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key;

/// 移除 target-action 事件。
/// @discussion
/// 移除所有匹配 target、action、key 的事件，值 nil 表示匹配所有，例如都为 nil 会移除所有事件。
/// @param target 接收事件的对象
/// @param action 执行事件的方法
/// @param key 绑定的事件
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable XZMocoaKey)key;

/// 发送 target-action 事件。
/// @param key 事件值
- (void)sendActionsForKey:(XZMocoaKey)key;

/// 添加 target-action-value 事件，将视图模型的 key 键对应的值与 target 的 action 方法绑定。
/// 调用此方法会使用 initialValue 触发一次 action 方法。
///
/// 如果通过 KVC 不能取到 key 对应的值，应当将初始值通过 initialValue 参数传入；如果初始值为 nil 请传入 kCFNull 对象。
///
/// @seealso 更多信息，请参考 `-addTarget:action:forKey:` 方法说明。
///
/// @param target 接收值的对象
/// @param action 接收值的方法，比如属性的 setter 方法
/// @param key 视图模型的事件键
/// @param initialValue 事件初始值，值 nil 表示使用`-valueForKey:`获取视图模型当前值，值 kCFNull 表示 nil 值
- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key value:(nullable id)initialValue;

/// 发送 target-action-value 事件。
///
/// 如果通过 KVC 不能取到 key 对应的值，应当将初始值通过 value 参数传入；如果值为 nil 请传入 kCFNull 对象。
///
/// @param key 事件，nil 表示发送默认事件
/// @param value 事件值，标量值需用 NSValue 包装，值 nil 表示使用`-valueForKey:`获取视图模型当前值，值 NSNull 表示 nil 值
- (void)sendActionsForKey:(XZMocoaKey)key value:(nullable id)value;

@end

@class UIControl;

@interface XZMocoaViewModel (XZStoryboardSupporting)

/// 视图分发过来的 IB 转场事件，默认返回 YES 值。
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender NS_SWIFT_NAME(shouldPerformSegue(withIdentifier:sender:));

/// 控制器分发过来的 IB 转场事件。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender NS_SWIFT_NAME(prepare(for:sender:));

/// 获取视图控制器，或视图所在的控制器。
///
/// > 视图模型不应保存此值，否则可能造成内存泄漏。
///
/// 在 Cocoa 中，视图控制器承担了很多公共功能，类似于 h5 的全局 window 对象，因此提供了访问方式。
/// 但理论上，视图模型应该与视图完全隔离。
@property (nonatomic, readonly, nullable) UIViewController *viewController;

/// 执行 Storyboard 转场的便利方法。
/// - Parameters:
///   - identifier: 标记符
///   - sender: 发送者
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender;

/// 获取导航控制器，或视图所在的导航控制器。
@property (nonatomic, readonly, nullable) UINavigationController *navigationController;
/// 获取页签控制器，或视图所在的页签控制器。
@property (nonatomic, readonly, nullable) UITabBarController *tabBarController;

@end

@interface XZMocoaViewModel (XZMocoaModelObserving)

/// 被动数据模型键值观察机制。
///
/// 注册 视图模型方法 与 数据模型属性 之间映射关系的字典。
///
/// @li 键: 接收数据模型属性值的方法。
/// @li 值: 数据模型的属性名字符串，或属性名字符串组成的数组。
///
/// 方法参数数量，必须与被观察的属性数量一致，比如
///
/// `{ "setMin:max:" : ["min", "max"] }`
///
/// 表示同时观察 min、max 属性，它们二者任一发生改变，都会调用 `-setMin:max:` 方法。
///
/// @note 方法的参数类型、参数数量，比如与属性类型、属性数量保持一致。
@property (class, nullable, readonly) NSDictionary<NSString *, id> *mappingModelKeys;

/// 当视图模型更新了 其他视图模型 的 数据模型 后，可通过此方法通知目标视图模型。
///
/// 默认情况下，此方法按照 mappingModelKeys 调用相应的方法。子类可重写。
///
/// @note 基于 NSFetchedResultsController 的 XZMocoaTableView 会自动触发此方法。
///
/// @param model 数据模型
/// @param keys 值发生改变的属性
- (void)model:(nullable id)model didUpdateValuesForKeys:(NSArray<NSString *> *)keys;

@end


//FOUNDATION_EXPORT void __mocoa_bind_3(XZMocoaViewModel *vm, SEL keySel, UILabel *target) XZ_ATTR_OVERLOAD;
//FOUNDATION_EXPORT void __mocoa_bind_3(XZMocoaViewModel *vm, SEL keySel, UIImageView *target) XZ_ATTR_OVERLOAD;
//
//FOUNDATION_EXPORT void __mocoa_bind_4(XZMocoaViewModel *vm, SEL keySel, UILabel *target, id _Nullable no) XZ_ATTR_OVERLOAD;
//FOUNDATION_EXPORT void __mocoa_bind_4(XZMocoaViewModel *vm, SEL keySel, UIImageView *target, id _Nullable completion) XZ_ATTR_OVERLOAD;
//
//FOUNDATION_EXPORT void __mocoa_bind_5(XZMocoaViewModel *vm, SEL keySel, id target, SEL setter, id _Nullable no) XZ_ATTR_OVERLOAD;
//FOUNDATION_EXPORT void __mocoa_bind_5(XZMocoaViewModel *vm, SEL keySel, id target, XZMocoaAction action, id _Nullable no) XZ_ATTR_OVERLOAD;
//
//#define __mocoa_bind_macro_imp_(index, vm, sel, view, ...) xzmacro_args_paste(__mocoa_bind_, index)(vm, @selector(sel), view, ##__VA_ARGS__)
//#define mocoa(viewModel, key, view, ...) xzmacro_keyize __mocoa_bind_macro_imp_(xzmacro_args_args_count(viewModel, key, view, ##__VA_ARGS__), viewModel, key, view, ##__VA_ARGS__)

NS_ASSUME_NONNULL_END
