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

/// 视图模型 ViewModel 基类。为视图模型提供了`ready`机制、层级关系等基础功能。
/// - Note: 本基类为简化开发而提供，并非 module 必须，可选。
@interface XZMocoaViewModel : NSObject <XZMocoaViewModel>

/// 当前视图模型所属的模块。一般情况下，此属性并非必须。
///
/// 对于像 UITableView 或 UICollectionView 等管理子视图的视图来说，管理下级元素需要通过设置此属性获取所属的模块。
@property (nonatomic, strong, nullable) XZMocoaModule *module;

/// 数据。
///
/// - Note: 属性可写是为兼容 Swift 结构体数据类型，默认情况下，修改属性除修改数据外，不执行任何操作。
///
/// 在实际开发中，数据在大部分情形下，都是单向流动，比如从网络/缓存到页面展示，双向的数据流动的业务场景并不多，视图模型只需要处理数据一次即可。
///
/// 基于此，默认情况下 XZMocoa 认为数据始终不变，视图模型不会监听数据 Model 的变更。而对于要监听数据的变化的少量情形，我们可以传统的通过 KVO 或通知方式来处理。
///
/// - 数据在视图模型外更新，视图模型监听。
///
/// ```objc
/// - (void)prepare {
///     [super prepare];
///     [self.model addObserver:self forKeyPath:@"aKey" options:NSKeyValueObservingOptionNew context:nil];
/// }
/// - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
///     if ([keyPath isEqualToString:@"aKey"]) {
///         // do sth
///     } else {
///         [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
///     }
/// }
/// ```
///
/// - 视图模型更新数据，建议提供精细化的方法，来触发数据的变更。
///
/// > 比如在 XZMocoaTableView 中，如果 section 数据发生更新，就可以通过如下方法来通知视图模型处理。
///
/// ```objc
/// @implementation TableViewSectionViewModel
///
/// // 视图的删除按钮事件的绑定方法
/// - (void)deleteDataAtIndex:(NSInteger)index sender:(id)sender {
///     NSMutableArray *array = (id)self.model;
///     [array removeObjectAtIndex:index]; // 更新数据
///     [self deleteCellAtIndex:index];    // 更新视图
/// }
///
/// @end
/// ```
/// 虽然方法略显笨拙，但是学习成本更低，且效率更高，且相比引入一套高负载的监听机制，在成本上更低廉。
///
/// - 具有从属关系的视图模型，可以通过 Updates 机制，将事件传递给上级视图模型处理。
///
/// ```swift
/// class TableViewCellViewModel: XZMocoaTableViewCellViewModel {
///
///     func deleteButtonAction() {
///         // cell 受 table 管理，自身是没办法删除的（使用 CoreData 除外，因为 fetchedController 具有监听数据的作用），所以需要将事件传递给上层处理。
///         sendUpdates(forKey: .delete, value: nil)
///     }
///
///     func showAllButtonAction() {
///         // cell 自行更新数据
///         self.model.showAll = true;
///         // 如果高度变化，重载 cell 需要上层 table 处理
///         sendUpdates(forKey: .reload, value: nil)
///     }
///
/// }
/// ```
@property (nonatomic, strong, nullable) id model;

/// 视图在列表中的排序。
@property (nonatomic) NSInteger index;

/// 标准初始化方法。一般情况下，子类应尽量避免添加新的初始化方法，保证接口统一。
/// @param model 数据
- (instancetype)initWithModel:(nullable id)model NS_DESIGNATED_INITIALIZER;

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
- (void)prepare;

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
// 层级更新机制：在具有层级关系的业务模块中，下级模块向上级模块传递数据或事件，或者上级模块监听下级模块的数据或事件，
// 在 iOS 开发中一般使用代理模式，因为代理协议可以让上下级的逻辑关系看起来更清晰。
// 但是在使用 MVVM 设计模式开发时，因为模块的划分，原本在 MVC 模式下，可以直接交互的逻辑，变得不再
// 直接，这将间接导致我们在开发时，需要额外的工作量来设计模块交互的代码，开发效率和开发体验将会受影响。
// 而如果不进行模块分层，或减少划分模块，那么很可能导致模块太大，代码也就不可避免的出现臃肿，这又与我
// 们采用 MVVM 设计模式开发的初衷不符，所以划分模块是必须也是必要的。幸运的是，在实际开发中，大部分情
// 况下，模块与模块之间的交互，都是一些简单的交互，在框架层提供一种简单的交互机制，即可解决大部分层级模
// 块间的交互需求，所以 Mocoa 设计了基于层级关系的 Mocoa Hierarchy Updates 机制。
// 该机制，只为解决层级模块间的交互问题，对于不同模块间的交互，或者比较复杂的
// 交互，Mocoa 也是建议采用常规代理或通知机制，对于代码而言，保持可维护性是优先级最高的。

/// 更新方式。
typedef NSString *XZMocoaUpdatesKey NS_EXTENSIBLE_STRING_ENUM;

/// 更新信息模型。
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
+ (instancetype)updatesWithKey:(XZMocoaUpdatesKey)key value:(nullable id)value source:(XZMocoaViewModel *)source;
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
- (void)sendUpdatesForKey:(XZMocoaUpdatesKey)key value:(nullable id)value;
@end


// Mocoa Keyed Actions
// 设计背景：
// 一种基于 target-action 方式的事件监听机制。
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

/// 添加 target-action 事件。
/// @attention
/// 绑定的 action 方法，必须无返回值，因为没有针对返回值的内存管理，可能会引起泄漏。可使用如下形式：
/// @code
/// - (void)method;
/// - (void)method:(XZMocoaViewModel *)sender;
/// - (void)method:(XZMocoaViewModel *)sender value:(nullable id)value;
/// - (void)method:(XZMocoaViewModel *)sender value:(nullable id)value key:(XZMocoaKey)key;
/// @endcode
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
/// @param key 事件，nil 表示发送默认事件
/// @param value 事件值
- (void)sendActionsForKey:(XZMocoaKey)key value:(nullable id)value;

@end

@class UIControl;

@interface XZMocoaViewModel (XZStoryboardSupporting)

/// 视图分发过来的 IB 转场事件，默认返回 YES 值。
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender;

/// 控制器分发过来的 IB 转场事件。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender;

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
