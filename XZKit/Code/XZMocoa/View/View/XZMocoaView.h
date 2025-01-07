//
//  XZMocoaView.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "XZMocoaViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - XZMocoaView 协议

/// 作为 Mocoa MVVM 中的 View 元素，需要实现的协议。
/// @discussion 任何 UIResponder 及子类，默认都是 Mocoa MVVM 中的 View 元素，声明遵循此协议，即可获得协议中定义的属性和方法。
/// @discussion 用此协议标记类，用来表明该类为 Mocoa MVVM 的 View 元素，与其它设计模式的类进行简单区分。
/// @discussion 由于运行时特性，协议的默认实现可能会被类目或子类覆盖，需要开发者自行注意。
NS_SWIFT_UI_ACTOR @protocol XZMocoaView <NSObject>

@optional
/// 视图模型。
/// 一般情况下，视图的 ViewModel 不应该改变。
/// 但是与 B 端不同，在 C 端利用“视图重用机制”可以有效提升性能，此属性被设计为可写的。
@property (nonatomic, strong, nullable) __kindof XZMocoaViewModel *viewModel;

/// 视图模型 KVO 事件，默认不执行任何操作。
- (void)viewModelWillChange;

/// 视图模型 KVO 事件，默认不执行任何操作。
- (void)viewModelDidChange;

/// 获取当前视图所在的视图控制器，如果自身已经是控制器，则返回自身。
@property (nonatomic, readonly, nullable) __kindof UIViewController *viewController;

/// 当前视图所属的导航控制器。
@property (nonatomic, readonly, nullable) __kindof UINavigationController *navigationController;

/// 当前视图所属栏目控制器。
@property (nonatomic, readonly, nullable) __kindof UITabBarController *tabBarController;

/// 控制器分发过来的 IB 转场事件，默认返回 YES 值。
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier;

/// 控制器分发过来的 IB 转场事件。
- (void)prepareForSegue:(UIStoryboardSegue *)segue;

@end

/// 模块初始化参数。可像字典一样取值。
/// @code
/// XZMocoaOptions options;
/// id value = options[@"value"];
/// @endcode
@interface XZMocoaOptions : NSObject
/// 原始 URL
@property (nonatomic, readonly) NSURL *url;
/// 合并了 URL query 参数
@property (nonatomic, readonly) NSDictionary *options;
- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (BOOL)containsKey:(NSString *)aKey;
@end


@interface UIView (XZMocoaModuleSupporting)
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options frame:(CGRect)frame;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url frame:(CGRect)frame;
+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url;
- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame;
- (void)awakeWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame;
@end


@interface UIViewController (XZMocoaModuleSupporting)

/// 根据视图控制器的模块地址，构造视图控制器。
/// @discussion
/// 参数 url 的 query 将作为 options 参数，调用 -viewControllerWithMocoaModule:options: 方法完成实例化控制器。
/// @param url 模块地址
/// @param options 额外参数
+ (nullable __kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options;

/// 根据视图控制器的模块地址，构造视图控制器。
+ (nullable __kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url;

/// XZMocoa 使用此方法初始化控制器。
/// @discussion
/// 便利初始化方法，默认直接调用 -initWithNibName:bundle: 方法完成初始化。
/// @discussion
/// 子类可以通过重写此方法获取 options 中的参数信息，或将控制器的初始化改为其它初始化方法。
/// @param options 初始化参数
- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(nullable NSString *)nibName bundle:(nullable NSBundle *)bundle;

/// 通过 XZMocoaURL 弹出层控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
/// @param animated 是否动画
/// @param completion 回调
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)animated;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated;
- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url completion:(void (^_Nullable)(void))completion;
- (nullable __kindof UIViewController *)presentViewControllerWithMocoaURL:(nullable NSURL *)url animated:(BOOL)animated completion:(void (^_Nullable)(void))completion API_DEPRECATED_WITH_REPLACEMENT("-presentMocoaURL:animated:completion:", ios(1.0, 12.0));

/// 通过 XZMocoaURL 添加子控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
- (nullable __kindof UIViewController *)addChildMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options;
- (nullable __kindof UIViewController *)addChildMocoaURL:(nullable NSURL *)url;
- (nullable __kindof UIViewController *)addChildViewControllerWithMocoaURL:(nullable NSURL *)url API_DEPRECATED_WITH_REPLACEMENT("-addChildMocoaURL:", ios(1.0, 12.0));
@end

@class CADisplayLink;

@interface UINavigationController (XZMocoaModuleSupporting)

/// 通过 XZMocoaURL 创建根控制器初始化。
/// @discussion 如果没有找到 XZMocoaURL 对应的控制器，那么将调用 -init 方法进行初始化。
/// @param url XZMocoaURL
- (instancetype)initWithRootMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options;
/// 通过 XZMocoaURL 创建根控制器初始化。
- (instancetype)initWithRootMocoaURL:(nullable NSURL *)url;
- (instancetype)initWithRootViewControllerWithMocoaURL:(nullable NSURL *)url API_DEPRECATED_WITH_REPLACEMENT("-initWithRootMocoaURL:", ios(1.0, 12.0));

/// 通过 XZMocoaURL 压栈子控制器。
/// @discussion 如果 XZMocoaURL 没有对应的控制器，那么此方法将不产生任何效果。
/// @param url XZMocoaURL
/// @param animated 是否动画。
/// @param options 参数
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)animated;
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url animated:(BOOL)animated;
- (nullable __kindof UIViewController *)pushMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options;
- (nullable __kindof UIViewController *)pushViewControllerWithMocoaURL:(nullable NSURL *)url animated:(BOOL)animated API_DEPRECATED_WITH_REPLACEMENT("-pushMocoaURL:animated:", ios(1.0, 12.0));

@end

@interface UITabBarController (XZMocoaModuleSupporting)

/// 通过 XZMocoaURLs 设置子控制器。
/// @discussion 如果某个 XZMocoaURL 没有对应的控制器，那么该 XZMocoaURL 会被忽略。
/// @param urls XZMocoaURLs
/// @param animated 是否动画
- (nullable NSArray<__kindof UIViewController *> *)setMocoaURLs:(nullable NSArray<NSURL *> *)urls animated:(BOOL)animated;
- (nullable NSArray<__kindof UIViewController *> *)setViewControllersWithMocoaURLs:(nullable NSArray<NSURL *> *)urls animated:(BOOL)animated API_DEPRECATED_WITH_REPLACEMENT("-setMocoaURLs:animated:", ios(1.0, 12.0));
@end

NS_ASSUME_NONNULL_END

