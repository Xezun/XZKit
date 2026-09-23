//
//  XZMocoaViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaKey.h>
#import <XZKit/XZMocoaModule.h>
#import <XZKit/XZMocoaModel.h>
#else
#import "XZMocoaDefines.h"
#import "XZMocoaKey.h"
#import "XZMocoaModule.h"
#import "XZMocoaModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 作为 Mocoa MVVM 中的 ViewModel 元素，需要实现的协议。
NS_SWIFT_UI_ACTOR @protocol XZMocoaViewModel <NSObject>
@required
- (instancetype)initWithModel:(nullable id)model;
@end

@class XZMocoaTargetActionTable, XZMocoaEvents;
@protocol XZMocoaView;

@protocol XZMocoaContext <NSObject>
@property (nonatomic, readonly, nullable) UIViewController       *viewController;
@property (nonatomic, readonly, nullable) UINavigationController *navigationController;
@property (nonatomic, readonly, nullable) UITabBarController     *tabBarController;
/// 模块间传递事件的事件通道。
- (void)didReceiveEvents:(XZMocoaEvents *)events;
@end

/// 视图模型基类。
///  
/// 基类为视图模型提供了以下基础能力：
/// - 延迟初始化的 ready 机制。
/// - 层级关系。
/// - 基于层级的 Key Events 事件通道。
/// - 视图监听视图模型属性的 Key Target Action 机制。
///  
/// # 数据监听
///  
/// 对数据的监听是 MVVM 设计模式的特色之一，但在 iOS 实际开发中，数据在大部分情形下，都是单向流动的，类似从网络请求到页面展示的场景居多。
/// 双向的数据流动的业务场景也有，但在开发中并不多。鉴于此，默认情况下 XZMocoa 不监听数据 Model 的变更。
/// 而对于要监听数据的变化的少量情形，我们可以通过传统的方式处理，比如 KVO 或通知。
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
/// 6. 数据更新后，也可通过 delegate 通知视图。
NS_SWIFT_UI_ACTOR @interface XZMocoaViewModel : NSObject <XZMocoaViewModel> {
    @package
    id<XZMocoaContext> __unsafe_unretained _context;
}

@property (nonatomic, readonly, nullable) UIViewController       *viewController;
@property (nonatomic, readonly, nullable) UINavigationController *navigationController;
@property (nonatomic, readonly, nullable) UITabBarController     *tabBarController;

/// 当前视图模型所属的模块。
///
/// 一般情况下，此属性并非必须。但是对于具有管理功能的视图来说，比如 UITableView 或 UICollectionView 等，必须指定模块，才能自动管理子视图。
@property (nonatomic, strong, nullable) XZMocoaModule *module;

/// 数据。
///
/// > 属性可写是为兼容 Swift 结构体数据类型，默认情况下，修改属性除修改数据外，不执行任何操作。
@property (nonatomic, strong, nullable) id model;

/// 视图的 frame 值。
///
/// 修改属性不会发送事件，以避免发送事件太频繁。
///
/// 如果视图的值受数据影响时，此值将起作用，且不同的视图，可能其中仅部分值有效，比如在 UITableView 中，仅 height 值有效。
@property (nonatomic) CGRect frame;

/// 标准初始化方法。一般情况下，子类应尽量避免添加新的初始化方法，保证接口统一。
/// @param model 数据
- (instancetype)initWithModel:(nullable id)model NS_DESIGNATED_INITIALIZER;

/// 通过模块 URL 初始化视图模型。
/// @param URL 模块 URL
/// @param model 数据模型
+ (nullable __kindof XZMocoaViewModel *)viewModelWithURL:(NSURL *)URL model:(nullable id)model NS_SWIFT_NAME(init(_:model:));

/// 通过 XZMocoaModule 对象初始化视图模型。
/// @param module 模块对象
/// @param model 数据模型
+ (nullable __kindof XZMocoaViewModel *)viewModelWithModule:(XZMocoaModule *)module model:(nullable id)model NS_SWIFT_NAME(init(_:model:));


// MARK: - Ready 机制

/// 是否已完成初始化。
///
/// 关于 ready 机制
/// 1. 延迟初始化时机。
/// 2. 使用 ready/prepare 方法组合，可以避免初始化逻辑反复执行。
/// 3. 视图模型在使用前，必须处于`isReady == YES`状态。
@property (nonatomic, readonly) BOOL isReady;

/// 一般情况下，子类请勿重写此方法。
///
/// 视图模型在使用前，应调用此方法，以初始化视图模型。
///
/// > 默认情况下`UIResponder`子类，设置 `viewModel` 属性时，会自动调用此方法。
///
/// - 此方法会标记视图模型已经初始化，因此，方法可安全的重复调用。
/// - 此方法会向下层视图模型发送 `-ready` 消息。
- (void)ready;

/// 视图模型的延迟初始化方法。
///
/// - 将视图模型的初始化，从创建时，延迟到使用前。
/// - 一般情况下，请勿直接调用此方法，而是调用`-ready`方法，否则可能会重复初始化。
/// - 子类重写应调用`super`实现。
/// - 在此方法中，视图模型 isReady 始终为 NO 的状态，调用`super`不会改变此状态。
/// - 在此方法中创建添加下层视图模型，不需要发送`-ready`消息。
/// - 此方法执行时，视图模型尚未与视图关联，即视图模型在初始化之后，才会被视图所使用。
- (void)prepare NS_REQUIRES_SUPER;

@end

// MARK: - 层级关系

@interface XZMocoaViewModel (XZMocoaHierarchy)

/// 所有下层视图模型。
///
/// 属性值虽然为不可变数组，但并非拷贝，元素数量会跟随实际情况自动变化。
@property (nonatomic, strong, readonly) NSArray<__kindof XZMocoaViewModel *> *subViewModels;

/// 上层视图模型。
@property (nonatomic, readonly, nullable) __kindof XZMocoaViewModel *superViewModel;

/// 添加下层视图模型。如果视图模型`subViewModel`当前有上层视图模型，那么会先从其上层移除。
- (void)addSubViewModel:(nullable XZMocoaViewModel *)subViewModel;

/// 将下层添加到指定位置。
/// @param subViewModel 下层
/// @param index 位置
- (void)insertSubViewModel:(nullable XZMocoaViewModel *)subViewModel atIndex:(NSInteger)index;

/// 移动原来在 index 位置的下层，到 newIndex 位置。
/// @param index 原始位置
/// @param newIndex 新位置，移动后所在的位置
- (void)moveSubViewModelAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex;

/// 从上层中移除。
- (void)removeFromSuperViewModel;

/// 如果某一个下层被移除，那么此方法会被调用。
/// @note 默认不执行任何操作。
/// @param subViewModel 已被移除的下层
- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)subViewModel;

@end

// MARK: - Key Events Channel

/// ## Mocoa Events Channel
///
/// 基于层级关系的事件通道。
///
/// ### 1、视图 View 与视图模型 ViewModel 之间的事件通道。
///
/// 简单的事件，视图可直接通过``-sendEventsWithKey:value``方法向 viewModel 发送事件。
/// 复杂的事件，推荐 ViewModel 定义接收事件的方法，然后由 View 绑定或直接调用。
///
/// ### 2、视图模型 ViewModel 自下而上的层事件通道。
///
/// 下层视图模型，可通过调用``-sendEventsWithKey:value``方法，沿视图模型层级关系，自下向上传递事件。


/// 通道事件。
@interface XZMocoaEvents : NSObject {
    @package
    __kindof XZMocoaViewModel *_target;
}
/// 标记符。
@property (nonatomic, copy, readonly) XZMocoaKey key;
/// 事件值。
@property (nonatomic, strong, readonly, nullable) id value;
/// 创建事件的对象，视图或下层视图模型。
@property (nonatomic, readonly) id source;
/// 传递事件的对象。
@property (nonatomic, readonly) __kindof XZMocoaViewModel *target;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)eventsWithKey:(XZMocoaKey)key value:(nullable id)value source:(id)source NS_SWIFT_NAME(init(_:value:source:));
@end

@interface XZMocoaViewModel (XZMocoaKeyEventsChannel)

/// 创建 `XZMocoaEvents` 并调用 ``-sendEvents:`` 方法。
///
/// 在 KTA 机制中，`XZMocoaKey`是“事件”，而在这里是事件的事件名。
/// - `sendEventsWithKey` 是转发事件。
/// - `sendActionsForKey` 是调用方法。
///
/// @param key 事件名，如为 nil 则为默认名称 kMocoaNilKey
/// @param value 事件值
- (void)sendEventsWithKey:(nullable XZMocoaKey)key value:(nullable id)value NS_SWIFT_NAME(sendEvents(_:value:));

/// 默认直接向 `superViewModel` 转发事件，其中`events.target` 会变为当前对象。
/// @param events 事件
- (void)sendEvents:(XZMocoaEvents *)events;

/// 收到下层或视图的事件。
///
/// 默认直接调用 ``-sendEvents:`` 方法将事件转发出去。
///
/// 子类重写时应先处理逻辑，然后再决定是否调用 `super` 方法。
/// @param events 事件信息
- (void)didReceiveEvents:(XZMocoaEvents *)events;

@end

// MARK: - Key Target Action

/// Key Target Action 事件名。
///
/// # Mocoa Key Target Action (KTA) 机制
///
/// 一种基于 target-action 方式的“键-值”绑定机制，但是被动的，手动调用才会触发监听事件。
///
/// ## 设计背景
///
/// iOS 原生的 KVO 机制，在实现上不够直观，而三方框架的又往往太复杂，而 target-action 机制是 iOS 开发中的常用机制，相对更方便且学习成本低。
///
/// ## 设计目的
///
/// 主要用于 View 监听 ViewModel 的值，也可以用于 ViewModel 向 View 发送事件。
///
/// > 如果 ViewModel 的事件较多且复杂，建议使用 delegate 发送事件。
///
/// 在 Swift 中，可通过 `@key` 宏标记属性，自动发送事件。

@interface XZMocoaViewModel (XZMocoaKeyTargetAction)

/// 将 key 绑定到 target 的 action 方法。仅绑定，不触发方法。
///
/// @li 视图模型对 target 为 weak 弱引用。
/// @li 方法 action 必须无返回值，因为没有针对返回值的内存管理，可能会引起泄漏。
/// @li 方法 action 的 value 参数不建议为 union 类型，除非 union 类型的大小为 1/2/4/8/16/32/64/128 字节。
/// @li 参数 action 方法形式如下：
///
/// @code
/// - (void)keyAction;
/// - (void)keyDidChangeValue:(nullable id)value;
/// - (void)key:(XZMocoaKey)key didChangeValue:(nullable id)value;
/// - (void)viewModel:(XZMocoaViewModel *)sender key:(XZMocoaKey)key didChangeValue:(nullable id)value;
/// @endcode
///
/// 使用示例：
///
/// @code
/// // 绑定 startAnimating 事件
/// [viewModel addTarget:indicator action:@selector(startAnimating) forKey:XZMocoaKeyStartAnimating];
/// // 绑定 text 属性
/// [viewModel bindTarget:label action:@selector(setText:) forKey:XZMocoaKeyText];
/// // 赋值 text 属性，不绑定
/// [viewModel linkTarget:label action:@selector(setText:) forKey:XZMocoaKeyText];
/// @endcode
///
/// @param target 绑定事件的对象
/// @param action 绑定事件的方法
/// @param key 绑定的事件，可使用 nil 或 kMocoaNilKey 或空字符串添加默认事件
- (void)addTarget:(id)target action:(SEL)action forKey:(nullable XZMocoaKey)key;

/// 执行 key 事件绑定的所有方法，并传递参数 value 值。
///
/// 没有属性关联的纯事件，必须使用此方法发送事件。
///
/// @param key 绑定的事件，nil 表示发送默认事件
/// @param value 事件值
- (void)sendActionsForKey:(nullable XZMocoaKey)key value:(nullable id)value;

/// 执行 key 事件绑定的所有方法，事件值为视图模型以 key 为键，通过 KVC 取到的值。
/// 
/// @param key 绑定的事件
- (void)sendActionsForKey:(nullable XZMocoaKey)key;

/// 将事件 key 从 target 上移除指定绑定方法。
/// @discussion
/// 移除所有匹配 target、action、key 的事件，值 nil 表示匹配所有，例如都为 nil 会移除所有事件。
/// @param target 绑定事件的对象
/// @param action 绑定事件的方法
/// @param key 绑定的事件
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable XZMocoaKey)key;

/// 链接 target 对象，即使用 key 的当前值，执行一次 target 的 action 方法。
///
/// 此操作不会建立绑定关系，用于同步静态的视图数据，可视为是单次绑定。
///
/// @param target 接收值的对象
/// @param action 接收值的方法
/// @param key 获取值的键
- (void)linkTarget:(id)target action:(SEL)action forKey:(nullable XZMocoaKey)key;

/// 单向绑定：将 key 绑定到 target 的 action 方法，并立即触发一次 action 方法。
/// 
/// 对视图模型调用`-valueForKey:`方法取值，并将值作为 action 方法的 value 参数。
/// 
/// @SeeAlso 更多信息，请参考 `-addTarget:action:forKey:` 方法说明。
/// 
/// @param target 绑定事件的对象
/// @param action 绑定事件的方法
/// @param key 绑定的事件
- (void)bindTarget:(id)target action:(SEL)action forKey:(nullable XZMocoaKey)key;

@end

@class UIControl;

@interface XZMocoaViewModel (XZStoryboardSupporting)

/// 当发生 Segue 跳转时：
/// 1. 视图控制器首收到事件，该事件会被 Mocoa 拦截。
/// 2. 如果控制器是 sender 是 Mocoa 视图，那么会将事件转发给该 sender 的 viewModel 视图模型，如果视图模型不存在，转发给视图。
/// 3. 如果视图控制器是 Mocoa 视图，那么转发给视图控制器的视图模型；如果视图模型不存在，执行原生逻辑。
/// 视图分发过来的 IB 转场事件，默认返回 YES 值。
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender NS_SWIFT_NAME(shouldPerformSegue(withIdentifier:sender:));

/// Mocoa转发拦截控制器事件。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender NS_SWIFT_NAME(prepare(for:sender:));

@end

@class NSNotificationCenter;

@interface XZMocoaViewModel (XZMocoaKeyObserver)

/// “视图模型”观察“数据模型”的键值观察映射表。
///
/// 注册 视图模型方法 与 数据模型属性 之间映射关系的字典。
///
/// - 键: 接收数据模型属性值的方法。
/// - 值: 数据模型的“属性名”字符串，或“属性名”字符串组成的数组。
///
/// - Important: 方法的参数类型、参数数量，必须与属性类型、属性数量保持一致。
///
/// 比如要同时观察 min、max 属性，它们二者任一发生改变，都要调用指定方法，那么映射关系如下。
///
/// ```objc
/// @{
///     @"setRangeMin:max:" : @[@"min", @"max"]
/// }
/// ```
///
/// 在 Swift 中，可使用 `@mocoa` 和 `@bind` 标记属性或方法，即可自动创建上述映射关系。
///
/// ```swift
/// @mocoa
/// class ViewModel: XZMocoaViewModel {
///     @bind
///     func setRange(min: Int, max: Int) {
///     }
/// }
/// ```
///
/// - SeeAlso: 键值观察是被动的，开启主动观察，请参考 ``activelyObservedModelKeys`` 属性。
@property (class, nullable, readonly) NSDictionary<NSString *, id> *mappingObserverMethodsForModelKeys;

/// 主动观察的数据模型键的集合。
///
/// - `nil` 表示不主动观察。
/// - `@[]` 表示主动观察 ``mappingObserverMethodsForModelKeys`` 中的所有键。
/// - 具体字符串数组：主动观察数组中指定的键。
///
/// ## 宏绑定机制说明
///
/// 使用 `@mocoa` 宏时：
/// - `@bind` 标记的属性和方法会自动加入映射表，并根据此属性决定是否监听。
/// - `@link` 标记的属性和方法只会建立绑定映射，仅在`-prepare`初始化时执行一次，不加入主动观察。
/// - 如果 `@link` 标记的键，也被 `@bind` 标记，那么 `@link` 也会升级为主动观察。
/// - 如果在子类中返回具体键列表，将覆盖自动推断的结果。
///
/// ## 示例
///
/// ```objc
/// // 完全不主动观察
/// - (NSArray *)activelyObservedModelKeys { return nil; }
/// 
/// // 主动观察 mapping 中的所有键
/// - (NSArray *)activelyObservedModelKeys { return @[]; }
/// 
/// // 仅观察指定键（排除 @link 绑定的键）
/// - (NSArray *)activelyObservedModelKeys { return @[@"name"]; }
/// ```
@property (class, nonatomic, readonly, nullable) NSArray<NSString *> *activelyObservedModelKeys;

/// 主动观察了数据模型的能力是否开启。
///
/// 开启主动观察，请重写 ``activelyObservedModelKeys`` 静态属性。
///
/// 此属性仅用于判断状态，重写此属性不影响观察行为的主动性和被动性。
///
/// 此属性为 YES 时，表示视图模型已开启主动观察，不论实际是否有主动观察的键。
@property (nonatomic, readonly) BOOL isActivelyObservingModelKeys;

/// 视图模型接收数据更新的通用方法。
///
/// 此方法默认会根据 `key` 调用那些通过 ``mappingObserverMethodsForModelKeys`` 注册的数据监听方法。
///
/// > 当视图模型更新了 其他视图模型 的 数据模型 后，也可通过此方法通知目标视图模型。
///
/// 使用 ``NSFetchedResultsController`` 作为数据源时，可以在代理方法中，触发此方法以跟踪数据变化。
/// 
/// ```objc
/// - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(NSManagedObject *)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
///     NSDictionary<NSString *, id> * const changedValues = anObject.changedValuesForCurrentEvent;
///     [viewModel model:anObject didChangeValuesForKeys:[NSSet setWithArray:changedValues.allKeys]];
/// }
/// ```
///
/// 当 ``NSFetchedResultsController`` 作为视图模型 ``XZMocoaTableView`` 的数据源和代理时，会自动触发此方法。
///
/// - Note: 为了方便在 Swift 中使用枚举，参数 keys 集合元素使用了 XZMocoaKey 类型，理论上应该为 NSString 类型。
///
/// - Parameters:
///   - model: 数据模型
///   - changedKeys: 值发生改变的属性
- (void)model:(id)model didChangeValuesForKeys:(NSSet<XZMocoaKey> *)changedKeys;

@end

NS_ASSUME_NONNULL_END
