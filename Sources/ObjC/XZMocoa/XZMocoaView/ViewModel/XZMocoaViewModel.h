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
#import <XZKit/XZMocoaModule.h>
#import <XZKit/XZMocoaModel.h>
#else
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaViewModelDelegate <NSObject>
@end

/// 作为 Mocoa MVVM 中的 ViewModel 元素，需要实现的协议。
NS_SWIFT_UI_ACTOR @protocol XZMocoaViewModel <NSObject>
@required
- (instancetype)initWithModel:(nullable id)model;
@end

@class XZMocoaTargetActionTable;
@protocol XZMocoaView;

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
NS_SWIFT_UI_ACTOR @interface XZMocoaViewModel : NSObject <XZMocoaViewModel> {
    @package
    /// 用于处理 MVC 与 MVVM 的兼容性问题，不要使用此属性来获取视图。
    id<XZMocoaView> __weak _view;
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

/// 一般情况下，子类请勿重写此方法。
///
/// 视图模型在使用前，应调用此方法，以初始化视图模型。
///
/// 当视图或视图控制器设置 `viewModel` 属性时，此方法会自动调用。
///
/// 此方法：
/// - 标记已初始，避免重复初始化，即此方法可安全的重复调用。
/// - 向下层视图模型发送 `-ready` 消息。
- (void)ready;

/// 视图模型的初始化方法。
///
/// - 一般情况下，请勿直接调用此方法，而是调用`-ready`方法，否则可能会重复初始化。
/// - 子类重写应调用`super`实现。
/// - 在此方法中，视图模型 isReady 始终为 NO 的状态。
/// - 在此方法中创建添加下层视图模型，不需要发送`-ready`消息。
/// - 此方法执行时，视图模型尚为与视图关联，即视图模型在初始化之后，才会被视图所使用。
- (void)prepare;

@end

@interface XZMocoaViewModel (XZMocoaHierarchy)

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


/// 事件标识符。
///
/// ## Mocoa Events Channel
///
/// 一种基于标识符的事件机制。
///
/// ### 1、视图层向视图模型层传递事件。
///
/// 一般情况下，View 向 ViewModel 传递事件，推荐 ViewModel 定义接收事件的方法，然后由 View 绑定或调用。
/// 为了简化事件处理，Mocoa 为所有子类预先定义了一个接收事件的方法 ``-didReceiveEvents:`` 以方便事件处理。
///
/// ### 2、自下而上的层事件。
///
/// 在具有层级关系的模块中，通过层级关系链，自下而上传递事件，比如`Cell`层将事件传递给`Table`层处理。
typedef NSString *XZMocoaEventsName NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(XZMocoaEvents.Name);

/// 更新信息模型。
@interface XZMocoaEvents : NSObject
/// 标记符，事件名。
@property (nonatomic, copy, readonly) XZMocoaEventsName name;
/// 事件值。
@property (nonatomic, strong, readonly, nullable) id value;
/// 创建事件的对象。
@property (nonatomic, unsafe_unretained, readonly) id source;
/// 传递事件的对象。
@property (nonatomic, unsafe_unretained, readonly) __kindof XZMocoaViewModel *target;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)eventsWithName:(nullable XZMocoaEventsName)key value:(nullable id)value source:(id)source NS_SWIFT_NAME(init(_:value:source:));
@end

@class UIButton;

/// 通用事件。如果视图模型只有一个事件，或者没必要细分事件时，可以使用此名称。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameNone;
/// 重载事件。适用情形：通知上级，执行重载模块的操作（数据已经更新）。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameReload;
/// 更新操作。适用情形：通知上级，执行数据编辑的操作（数据还未编辑）。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameModify;
/// 插入操作。适用情形：通知上级，执行数据插入的操作（新数据未插入）。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameInsert;
/// 删除操作。适用情形：通知上级，执行删除数据的操作（数据还未删除）。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameDelete;
/// 选择操作。比如单选 cell 时，只能由上层控制单选。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameSelect;
/// 反选操作。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameDeselect;
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameConfirm;
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameSubmit;
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameCancel;
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameValueChanged;

@protocol XZMocoaView;

@interface XZMocoaViewModel (XZMocoaEventsChannel)

/// 创建 `XZMocoaEvents` 并调用 ``-sendEvents:`` 方法。
/// @param name 事件名，如为 nil 则为默认名称 XZMocoaEventsNameNone
/// @param value 事件值
- (void)sendEventsWithName:(nullable XZMocoaEventsName)name value:(nullable id)value NS_SWIFT_NAME(sendEvents(_:value:));

/// 默认直接向 `superViewModel` 转发事件，其中`events.target` 会变为当前对象。
/// @param events 事件
- (void)sendEvents:(XZMocoaEvents *)events;

/// 收到下级或视图的事件。
///
/// 默认直接调用 ``-sendEvents:`` 方法将事件转发出去。
///
/// 子类重写应，先处理逻辑，然后再决定是否调用 `super` 方法。
/// @param events 事件信息
- (void)didReceiveEvents:(XZMocoaEvents *)events;

@end

/// Key Target Action 事件名。
///
/// # Mocoa Key Target Action (KTA) 机制
///
/// 一种基于 target-action 方式的事件监听机制。这是一种被动机制，手动调用才会触发监听事件。
///
/// ## 设计背景
///
/// 不论采用何种方式进行“键-值”绑定，都有着不小的开发量，“高级”的绑定，在形式上会减少一些代码量，
/// 但是其带来的维护成本，相对这些代码量并不是经济的。在 iOS 实际开发中，UI 展示才是主要部分，
/// 对于响应式要求其实并不高，不应该放在设计架构的首选，而 target-action 机制是 iOS 开发中的常用机制，
/// 与引入新机制相比，学习成本更低。
///
/// ## 设计目的
///
/// 主要用于 View 监听 ViewModel 的值，也可以用于 ViewModel 向 View 发送事件。
/// > 如果 ViewModel 的事件较多且复杂，建议使用 delegate 发送事件。
///
/// 在 Swift 中，可通过 `@key` 宏标记属性，自动发送事件。
typedef NSString *XZMocoaKey NS_EXTENSIBLE_STRING_ENUM;

/// 特殊 key 键，值为空字符串。
///
/// 在添加或发送 key-target-action 事件时，如果 key 参数使用了 nil 则会使用此键。
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyNone NS_SWIFT_NAME(None);

/// 用于标记属性可以被添加 target-action 的属性或方法，仅起标记作用。
/// @code
/// @property (nonatomic) BOOL isLoading XZ_MOCOA_KEY();          // The key is 'isLoading'
/// @property (nonatomic) BOOL isLoading XZ_MOCOA_KEY("loading"); // The key is 'loading'
/// - (void)startLoading XZ_MOCOA_KEY("isLoading");               // The key is 'isLoading'
/// @endcode
/// @todo
/// 编译器插件，在属性中添加 mocoa=key 标记，生成的 setter 中添加发送 key 事件的代码。
#define XZ_MOCOA_KEY(key)

@interface XZMocoaViewModel (XZMocoaKeyTargetAction)

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
- (void)addTarget:(id)target action:(SEL)action forKey:(nullable XZMocoaKey)key;

/// 移除 target-action 事件。
/// @discussion
/// 移除所有匹配 target、action、key 的事件，值 nil 表示匹配所有，例如都为 nil 会移除所有事件。
/// @param target 接收事件的对象
/// @param action 执行事件的方法
/// @param key 绑定的事件
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable XZMocoaKey)key;

/// 发送 target-action 事件。
/// @param key 事件值
- (void)sendActionsForKey:(nullable XZMocoaKey)key;

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
- (void)addTarget:(id)target action:(SEL)action forKey:(nullable XZMocoaKey)key value:(nullable id)initialValue;

/// 发送 target-action-value 事件。
///
/// 如果通过 KVC 不能取到 key 对应的值，应当将初始值通过 value 参数传入；如果值为 nil 请传入 kCFNull 对象。
///
/// @param key 事件，nil 表示发送默认事件
/// @param value 事件值，标量值需用 NSValue 包装，值 nil 表示使用`-valueForKey:`获取视图模型当前值，值 NSNull 表示 nil 值
- (void)sendActionsForKey:(nullable XZMocoaKey)key value:(nullable id)value;

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

@interface XZMocoaViewModel (XZMocoaModelObserving)

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
///     @"setName:": @"name",
///     @"setRangeMin:max:" : @[@"min", @"max"]
/// }
/// ```
///
/// 在 Swift 中，可使用 `@mocoa` 和 `@bind` 标记属性或方法，即可自动创建上述映射关系。
///
/// ```swift
/// @mocoa
/// ViewModel: XZMocoaViewModel {
///     @bind
///     func setRange(min: Int, max: Int) {
///     }
/// }
/// ```
///
/// - SeeAlso: ``shouldObserveModelKeysActively`` 属性
@property (class, nullable, readonly) NSDictionary<NSString *, id> *mappingModelKeys;

/// 是否主动观察数据模型。默认 NO 否。
///
/// ### 被动观察机制
///
/// 由于以下原因，视图模型 ViewModel 对 Model 数据模型的观察，默认是被动的。
///
/// - 大多是业务展示类数据，不需要监听；
/// - 下层模型可以直接通过 Mocoa Events Channel 层事件通道通知上层模型。
/// - 上层模型可以直接调用下层模型``model:didChangeValuesForKeys:``的方法，被动触发监听。
/// - 在某些情况下，数据不需要动态监听，比如当 `UITableViewCell` 需要刷新时，往往整个 Cell 视图的重载。
/// - 数据管理框架，比如 CoreData 框架，自带数据监听机制。
///
/// 若要开启主动键值观察，重写此属性，并返回`YES`即可。
///
/// 使用 `NSKeyValueObserving` 机制对 ``mappingModelKeys`` 中的键进行观察，
/// 且单个 Runloop 内的键值事件，会合并统一处理，即在一个 Runloop 内，同一个 key 即使发生多次改变，绑定的方法只会执行一次。
///
/// 在 Swift 中，使用 `@mocoa` 和 `@bind` 标记的绑定的键值事件，也属于此被动观察机制。
@property (nonatomic, readonly) BOOL shouldObserveModelKeysActively;

/// 视图模型接收数据更新的通用方法。
///
/// 此方法默认会根据 `key` 调用那些通过 ``mappingModelKeys`` 注册的数据监听方法。
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
- (void)model:(nullable id)model didChangeValuesForKeys:(NSSet<XZMocoaKey> *)changedKeys;

@end

// 常用的 key 枚举
@class UILabel, UIButton, UIImageView;

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDefault;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyContentStatus;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStatus;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsChecked;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsEnabled;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyValue;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyName;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIcon;

@class UIView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsHidden;

@class UILabel;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyFont;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTextColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyShadowColor;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedText;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedTextColor;

@class UITextField;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPlaceholder;

@class UIImageView;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImage;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyHighlightedImage;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyImageURL;

@class UIButton;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyTitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyAttributedTitle;

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeySubtitle;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyDetailText;

FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStartAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyStopAnimating;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRefreshing;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsRequesting;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsLoading;

@class UISwitch;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsOn;

@class UINavigationBar;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyIsTranslucent;
FOUNDATION_EXPORT XZMocoaKey const XZMocoaKeyPrefersLargeTitles;

NS_ASSUME_NONNULL_END
