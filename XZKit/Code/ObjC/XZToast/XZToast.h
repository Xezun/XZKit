//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>
#import "XZToastDefines.h"
#import "UIKit+XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZToastConfiguration;

@protocol XZToastView <NSObject>
/// 提示文本。
@property (nonatomic, copy, nullable) NSString *text;
/// 当视图将要在控制器中显示时，此方法会被调用。
///
/// 如果视图被复用，那么视图每次被复用时，此方法也会被调用，即使视图已经在控制器中。
///
/// - Parameter viewController: 当前视图将要展示于其中的控制器对象
- (void)willShowInViewController:(UIViewController *)viewController;
@optional
/// 进度。
@property (nonatomic) CGFloat progress;
@end

typedef NS_ENUM(NSUInteger, XZToastStyle) {
    XZToastStyleMessage,
    XZToastStyleLoading,
    XZToastStyleSuccess,
    XZToastStyleFailure,
    XZToastStyleWarning,
    XZToastStyleWaiting,
} NS_REFINED_FOR_SWIFT;

/// 一种用于展示业务或逻辑状态的提示消息。
///
/// 这是一个基类，业务可通过子类自定义提示消息的视图。
NS_REFINED_FOR_SWIFT @interface XZToast : NSObject <XZToastView, NSCopying>

/// 呈现提示消息的视图。
@property (nonatomic, readonly) __kindof UIView *view;

/// 提示消息文案。
///
/// 视图`view`必须在实现了`XZToastView`协议才能访问此属性。
@property (nonatomic, copy, nullable) NSString *text;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

/// 便利构造方法。
/// - Parameter view: 呈现提示消息的视图
+ (instancetype)viewToast:(UIView *)view NS_SWIFT_NAME(view(_:));

#pragma mark - 便利构造器

/// 便利方法。构造提示消息。
/// - Parameters:
///   - style: 提示消息样式
///   - text: 提示消息文案
///   - image: 提示消息图片
///   - progress: 进度，值在 0 ~ 1.0 范围以内；目前仅支持 loading 类型的提示消息；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)toastWithStyle:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image progress:(CGFloat)progress NS_SWIFT_NAME(init(style:text:image:progress:));

/// 便利方法。构造全局共享的提示消息。
///
/// 如果当前已有共享的提示消息视图，那么此方法会直接使用该视图，作为提示消息的展示视图。
///
/// - Parameters:
///   - style: 提示消息样式
///   - text: 提示消息文案
///   - image: 提示消息图片
///   - progress: 进度，值在 0 ~ 1.0 范围以内；目前仅支持 loading 类型的提示消息；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image progress:(CGFloat)progress NS_SWIFT_NAME(init(shared:text:image:progress:));

#pragma mark - 二级便利构造器

/// 带图片的消息提示类型。
/// 图片。
/// - Parameters:
///   - text: 提示消息文案
///   - image: 图片，尺寸推荐 37x37 宽高，最大支持 50x50 宽高
+ (instancetype)toastWithStyle:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(init(style:text:image:));

/// 带进度的提示消息。目前仅支持 loading 类型的提示消息。
/// - Parameters:
///   - style: 提示消息样式
///   - text: 提示消息文案
///   - progress: 进度，值在 0 ~ 1.0 范围以内；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)toastWithStyle:(XZToastStyle)style text:(NSString *)text progress:(CGFloat)progress NS_SWIFT_NAME(init(style:text:progress:));

/// 文本消息提示类型。
/// - Parameter text: 提示消息文案
+ (instancetype)messageToast:(NSString *)text NS_SWIFT_NAME(message(_:));

/// 加载类型的提示。
/// - Parameter text: 提示消息文案
+ (instancetype)loadingToast:(nullable NSString *)text NS_SWIFT_NAME(loading(_:));

/// 带加载进度的提示消息类型。
/// - Parameters:
///   - text: 消息文本内容
///   - progress: 进度，值在 0 ~ 1.0 范围以内；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)loadingToast:(nullable NSString *)text progress:(CGFloat)progress NS_SWIFT_NAME(loading(_:progress:));

/// 操作状态提示类型：成功状态。
/// - Parameter text: 提示消息文案
+ (instancetype)successToast:(nullable NSString *)text NS_SWIFT_NAME(success(_:));

/// 操作状态提示类型：失败状态。
/// - Parameter text: 提示消息文案
+ (instancetype)failureToast:(nullable NSString *)text NS_SWIFT_NAME(failure(_:));

/// 操作状态提示类型：警告状态。
/// - Parameter text: 提示消息文案
+ (instancetype)warningToast:(nullable NSString *)text NS_SWIFT_NAME(warning(_:));

/// 操作状态提示类型：等待状态。
/// - Parameter text: 提示消息文案
+ (instancetype)waitingToast:(nullable NSString *)text NS_SWIFT_NAME(waiting(_:));

/// 构造全局共享视图的提示消息对象。
///
/// 请注意，返回值不是单例。如果 toast 视图正在被其它 toast 使用，那么该 toast 会被提前终止。
///
/// - Parameters:
///   - style: 提示消息样式
///   - text: 提示文案
///   - image: 提示图标，并非所有类型的 XZToast 都适用，比如 loading 类型不展示图片
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(shared(_:text:image:));

/// 构造全局共享视图的展示进度的提示消息。
/// - Parameters:
///   - style: 提示消息样式，目前仅 loading 样式有效
///   - text: 提示消息文案
///   - progress: 进度，值在 0 ~ 1.0 范围以内；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text progress:(CGFloat)progress NS_SWIFT_NAME(shared(_:text:progress:));

/// 构造一个全局共享的提示消息对象。
/// - Parameters:
///   - style: 提示消息样式
///   - text: 提示消息文案
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text NS_SWIFT_NAME(shared(_:text:));

/// 构造一个全局共享的提示消息对象。
/// - Parameters:
///   - style: 提示消息样式
///   - image: 提示消息图片
+ (instancetype)sharedToast:(XZToastStyle)style image:(nullable UIImage *)image NS_SWIFT_NAME(shared(_:image:));

@end

@interface XZToast (XZToastConfiguration)

/// 默认数量限制。
@property (class) NSInteger maximumNumberOfToasts;
/// 默认文本颜色。
@property (class) UIColor * textColor;
/// 默认文本字体。
@property (class) UIFont  * font;
/// 默认背景色。
@property (class) UIColor * backgroundColor;
/// 默认阴影色。
@property (class) UIColor * shadowColor;
/// 进度默认颜色。
@property (class) UIColor * color;
/// 进度轨道的默认颜色。
@property (class) UIColor * trackColor;

/// 设置默认位置偏移量。
+ (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position;

/// 获取默认位置偏移量。
+ (CGFloat)offsetForPosition:(XZToastPosition)position;

/// 获取指定样式提示消息的默认提示图片。
+ (nullable UIImage *)imageForStyle:(XZToastStyle)style;

/// 设置指定样式提示消息的默认提示图片。
/// - Parameters:
///   - image: 图片
///   - style: 消息样式
+ (void)setImage:(nullable UIImage *)image forStyle:(XZToastStyle)style;

@end

NS_REFINED_FOR_SWIFT @interface XZToastTask : XZToast
/// 隐藏（移除）当前提示信息。
/// - Parameter completion: 提示信息隐藏后执行的回调
- (void)hide:(void (^_Nullable)(void))completion;
@end


/// 配置 XZToast 内置样式的对象。
@protocol XZToastConfiguration <NSObject>

/// 可同时展示的 toast 的数量。默认 1 。
@property (nonatomic) NSInteger maximumNumberOfToasts;

/// 文本颜色。
@property (nonatomic) UIColor * textColor;

/// 文本字体。
@property (nonatomic) UIFont  * font;

/// 背景色。
@property (nonatomic) UIColor * backgroundColor;

/// 投影色。
@property (nonatomic) UIColor * shadowColor;

/// 进度颜色。
@property (nonatomic) UIColor * color;

/// 进度轨道颜色。
@property (nonatomic) UIColor * trackColor;


/// 设置 toast 相对默认位置的偏移值。
///
/// 默认偏移值：
/// - top: 向下偏移 +20.0 点
/// - middle: 不偏移 0.0 点
/// - bottom: 向上偏移 -20.0 点
///
/// - Parameters:
///   - offset: 偏移值，正数向下，负数向上
///   - position: toast 展示位置
- (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position;

/// 获取指定位置 toast 的偏移值。
/// - Parameter position: toast 展示位置
- (CGFloat)offsetForPosition:(XZToastPosition)position;

/// 标记 XZToast 需要调整布局。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
///
/// 比如在容器视图为滚动视图时，可通过调用此方法刷新位置，让 toast 跟随滚动。
- (void)setNeedsLayoutToasts;


/// 如果当前已经标记了需要更新布局，那么调用此方法会立即更新布局。
///
/// > 默认情况下，每个 runloop 周期，最多只会执行一次布局刷新。
- (void)layoutToastsIfNeeded;

@end

NS_ASSUME_NONNULL_END
