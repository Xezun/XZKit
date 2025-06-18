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
@optional
@property (nonatomic, copy, nullable) NSString *text;
- (void)applyConfiguration:(id<XZToastConfiguration>)configuration;
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
NS_REFINED_FOR_SWIFT @interface XZToast : NSObject <NSCopying>

/// 默认数量限制。
@property (class) NSInteger maximumNumberOfToasts;
@property (class) UIColor * textColor;
@property (class) UIFont  * font;
@property (class) UIColor * backgroundColor;
@property (class) UIColor * shadowColor;

/// 设置默认位置偏移量。
+ (void)setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position;

/// 获取默认位置偏移量。
+ (CGFloat)toastOffsetForPosition:(XZToastPosition)position;

/// 呈现提示消息的视图。
@property (nonatomic, readonly) __kindof UIView<XZToastView> *view;

/// 提示消息文案。
///
/// 视图`view`必须在实现了`XZToastView`协议才能访问此属性。
@property (nonatomic, copy, nullable) NSString *text;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView<XZToastView> *)view NS_DESIGNATED_INITIALIZER;

/// 便利构造方法。
/// - Parameter view: 呈现提示消息的视图
+ (instancetype)viewToast:(UIView<XZToastView> *)view NS_SWIFT_UNAVAILABLE("Use instance initializer instead.");

/// 文本消息提示类型。
/// - Parameter text: 文本内容
+ (instancetype)messageToast:(NSString *)text NS_SWIFT_NAME(init(message:));

/// 带图片的消息提示类型。
/// 图片。
/// - Parameters:
///   - text: 文本内容
///   - image: 图片，尺寸推荐 37x37 宽高，最大支持 50x50 宽高
+ (instancetype)messageToast:(NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(init(message:image:));

/// 加载类型的提示。
/// - Parameter text: 文本内容
+ (instancetype)loadingToast:(nullable NSString *)text NS_SWIFT_NAME(init(loading:));

/// 操作状态提示类型：成功状态。
/// - Parameter text: 文本内容
+ (instancetype)successToast:(nullable NSString *)text NS_SWIFT_NAME(init(success:));

/// 操作状态提示类型：失败状态。
/// - Parameter text: 文本内容
+ (instancetype)failureToast:(nullable NSString *)text NS_SWIFT_NAME(init(failure:));

/// 操作状态提示类型：警告状态。
/// - Parameter text: 文本内容
+ (instancetype)warningToast:(nullable NSString *)text NS_SWIFT_NAME(init(warning:));

/// 操作状态提示类型：等待状态。
/// - Parameter text: 文本内容
+ (instancetype)waitingToast:(nullable NSString *)text NS_SWIFT_NAME(init(waiting:));

/// 构件一个全局共享视图的 XZToast 对象，返回值不是单例。
///
/// 如果 toast 视图正在被其它 toast 使用，那么该 toast 会被提前终止。
///
/// 
///
/// - Parameters:
///   - style: 外观样式
///   - text: 提示文案
///   - image: 提示图标，并非所有类型的 XZToast 都适用，比如 loading 类型不展示图片
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(init(shared:text:image:));
+ (instancetype)sharedToast:(XZToastStyle)style text:(nullable NSString *)text NS_SWIFT_UNAVAILABLE("Use XZToast.shared(_:text:image:) instead.");
+ (instancetype)sharedToast:(XZToastStyle)style image:(nullable UIImage *)image NS_SWIFT_UNAVAILABLE("Use XZToast.shared(_:text:image:) instead.");

@end

NS_REFINED_FOR_SWIFT @interface XZToastTask : XZToast

@end


@protocol XZToastConfiguration <NSObject>

/// 可同时展示的 toast 的数量。
@property (nonatomic) NSInteger maximumNumberOfToasts;
@property (nonatomic, nullable) UIColor * textColor;
@property (nonatomic, nullable) UIFont  * font;
@property (nonatomic, nullable) UIColor * backgroundColor;
@property (nonatomic, nullable) UIColor * shadowColor;

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

/// 刷新 toast 的布局。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
///
/// 比如在容器视图为滚动视图时，可通过调用此方法刷新位置，让 toast 跟随滚动。
- (void)setNeedsLayoutToasts;
- (void)layoutToastsIfNeeded;

@end

NS_ASSUME_NONNULL_END
