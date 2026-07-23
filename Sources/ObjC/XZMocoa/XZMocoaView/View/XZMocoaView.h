//
//  XZMocoaView.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/12.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaViewModel.h>
#import <XZKit/UIView+XZKit.h>
#else
#import "XZMocoaViewModel.h"
#import "UIView+XZKit.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - XZMocoaView

/// 当前 XZMocoaView 协议只起标记作用，表面视图或视图控制器为 Mocoa 中的 View 角色。
///
/// 在 Objective-C 中定义的协议，在 Swift 6.0 之后使用，没有实现就会无法通过编译，因此 XZMocoaView 协议中的方法都移至 UIResponder 的 XZMocoaView 类目中去了。
NS_SWIFT_UI_ACTOR @protocol XZMocoaView <NSObject>
@end

/// 所有 UIResponder 是天然的 MVVM 中 View 角色，所以为 UIResponder 拓展了 viewModel 属性。
@interface UIResponder (XZMocoaView)
/// 视图模型。
///
/// 在标准 MVVM 模型中，视图模型是绑定到视图上的，即这里 `viewModel` 属性应该是只读的。但是在 iOS 开发中，“视图重用机制”可以有效提升性能，所以此属性被设计为可写的，让视图可以渲染不同的视图模型。
///
/// 比如在 UITableView 中，同一个 UITableViewCell 视图在重用时，会被用来渲染不同的数据。
///
/// > 注意原生控件的默认行为，比如 UITableViewCell 或 UICollectionViewCell 在进入复用时，会清除原生组件上的数据。
/// > 但是当视图再次复用时，属性 viewModel 可能并不会改变，也就无法触发视图刷新，而视图内容又被清除了，从而导致内容丢失。
/// > 此时，在 -prepareForReuse 方法中，同时清除 viewModel 属性即可。
@property (nonatomic, strong, nullable) __kindof XZMocoaViewModel *viewModel;
/// 属性 viewModel 的 willSet 监听方法，默认不执行任何操作。
/// - Parameter newValue: 目标视图模型
- (void)viewModelWillChange:(nullable XZMocoaViewModel *)newValue;
/// 属性 viewModel 的 didSet 监听方法，默认不执行任何操作。
/// - Parameter newValue: 目标视图模型
- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue;
/// 视图使用 viewModel 进行初始化。
///
/// 不使用 viewModelDidChange 方法的原因是，视图控制器在设置 viewModel 时，视图可能并没有初始化。
- (void)prepareForViewModel NS_REQUIRES_SUPER;
/// 由 Cocoa MVC 中的控制器分发过来的 Segue 转场事件。
///
/// 在视图或视图控制器中，Segue 事件转发规则如下。
/// 1. 如果当前视图或视图控制器是 XZMocoaView 角色，那么事件会转发给视图控制器自身的 ViewModel 处理。
/// 2. 如果 sender 为 XZMocoaView 角色，就转发给 sender 处理。
/// 3. 返回 YES 值。
/// 在视图模型中，Segue 事件转发规则如下。
/// 1. 如果 sender 为 XZMocoaView 角色，就转发给 sender 处理。
/// 2. 返回 YES 值。
/// 因此，在 StoryBoard 中，视图的 Segue 转场会通过控制转发给视图，并最终转发给视图模型处理。
/// 如果通过代码触发 Segue 事件，sender 参数应该传入接收事件的视图。
///
/// - TODO: 似乎可以研究通过 identifier 查找子模块转发事件
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender NS_SWIFT_NAME(shouldPerformSegue(withIdentifier:sender:));
/// 控制器分发过来的 IB 转场事件。
///
/// 默认情况下，将按如下优先级对事件进行转发。
/// 1. 如果当前视图为 XZMocoaView 那么，事件将转发给 viewModel 处理。
/// 2. 如果 sender 为 XZMocoaView 的话，就转发给 sender 处理。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender NS_SWIFT_NAME(prepare(for:sender:));
@end
@interface UIView (XZMocoaView)
@end
@interface UIViewController (XZMocoaView)
@end
@interface UINavigationController (XZMocoaView)
@end
@interface UITabBarController (XZMocoaView)
@end

#pragma mark - XZMocoaModuleSupporting

typedef NSString *XZMocoaOptionKey NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(XZMocoaOptions.Key);

/// 传递给目标页面的数据模型。
FOUNDATION_EXPORT XZMocoaOptionKey const XZMocoaOptionKeyModel;
/// 传递给目标页面参数中 name 字段。
FOUNDATION_EXPORT XZMocoaOptionKey const XZMocoaOptionKeyName;

/// 模块初始化参数。可像字典一样取值。
/// @code
/// XZMocoaOptions options;
/// id value = options[@"value"];
/// @endcode
@interface XZMocoaOptions : NSObject

/// 模块。
@property (nonatomic, readonly) XZMocoaModule *module;
/// 原始 URL
@property (nonatomic, readonly) NSURL *url;
/// 合并了 URL query 参数
@property (nonatomic, readonly) NSDictionary<XZMocoaOptionKey, id> *options;

- (nullable id)objectForKeyedSubscript:(XZMocoaOptionKey)key;
- (BOOL)containsKey:(XZMocoaOptionKey)aKey;

@end


@interface UIView (XZMocoaModuleSupporting)
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options frame:(CGRect)frame;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url frame:(CGRect)frame;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url;
- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame;
- (void)awakeFromNibWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame;
@end


@interface UIViewController (XZMocoaModuleSupporting)

/// 根据视图控制器的模块地址，构造视图控制器。
/// @discussion
/// 参数 url 的 query 将作为 options 参数，调用 -viewControllerWithMocoaModule:options: 方法完成实例化控制器。
/// @param url 模块地址
/// @param options 额外参数
+ (nullable __kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options;

/// 根据视图控制器的模块地址，构造视图控制器。
+ (nullable __kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url;

/// Mocoa 使用此方法初始化控制器。
/// @discussion
/// 便利初始化方法，先调用 -initWithNibName:bundle: 方法完成基本初始化，再调用 -didInitWithMocoaOptions: 完成额外初始化。
/// @discussion
/// 通过 Mocoa 加载由 xib/storyboard 定义的控制器，由于控制器已经初始化，此方法不会被调用，但是会调用 -didInitWithMocoaOptions: 方法。
/// @discussion
/// 子类可以通过 options 中的参数信息，调用指定初始化方法完成最终的初始化。
/// @discussion
/// 在 Swift 中，此方法无法访问，但是可通过重写``-didInitWithMocoaOptions:``方法接收 Mocoa 初始化参数。
/// @note
/// 在 Category 中定义的初始化方法，无法用`NS_DESIGNATED_INITIALIZER`标记，也无法桥接到 Swift 中。
///
/// @param options 初始化参数
- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(nullable NSString *)nibName bundle:(nullable NSBundle *)bundle;

/// 通过 Mocoa 创建控制器的额外初始化方法。
///
/// 通过 Mocoa 提供的方法创建的控制器，一定会调用此方法。
/// 在 Swift 中，不能重写便利初始化方法，只能通过此方法接收 Mocoa 初始化参数。
///
/// 默认情况下，此方法会尝试为控制器创建视图模型，子类可以在调用`super`之前，自行创建视图模型，以避免自动创建符合实际需求。
///
/// @param options 初始化参数
- (void)didInitWithMocoaOptions:(XZMocoaOptions *)options;

/// 通过 XZMocoaURL 弹出层控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
/// @param animated 是否动画
/// @param completion 回调
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options animated:(BOOL)animated;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url completion:(void (^_Nullable)(void))completion;

/// 通过 XZMocoaURL 添加子控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
- (nullable __kindof UIViewController *)addChildViewControllerWithMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options;
- (nullable __kindof UIViewController *)addChildViewControllerWithMocoaURL:(nullable NSURL *)url;
@end

@class CADisplayLink;

@interface UINavigationController (XZMocoaModuleSupporting)

/// 通过 XZMocoaURL 压栈子控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
/// @param animated 是否动画。
/// @param options 参数
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options animated:(BOOL)animated;
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url animated:(BOOL)animated;
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary<XZMocoaOptionKey, id> *)options;

@end

@interface UITabBarController (XZMocoaModuleSupporting)

/// 通过 XZMocoaURLs 设置子控制器。
/// @discussion 如果某个 XZMocoaURL 没有对应的控制器，那么该 XZMocoaURL 会被忽略。
/// @param urls XZMocoaURLs
/// @param animated 是否动画
- (nullable NSArray<__kindof UIViewController *> *)setViewControllersWithMocoaURLs:(nullable NSArray<NSURL *> *)urls animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END

