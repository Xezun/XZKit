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


@protocol XZToastView <NSObject>
@optional
@property (nonatomic, copy, nullable) NSString *text;
@end

typedef NS_ENUM(NSUInteger, XZToastStyle) {
    XZToastStyleMessage,
    XZToastStyleLoading,
    XZToastStyleSuccess,
    XZToastStyleFailure,
    XZToastStyleWarning,
    XZToastStyleWaiting,
} NS_SWIFT_NAME(XZToast.Style);

/// 一种用于展示业务或逻辑状态的提示消息。
///
/// 这是一个基类，业务可通过子类自定义提示消息的视图。
@interface XZToast : NSObject

/// 默认数量限制。
@property (class) NSInteger maximumNumberOfToasts;

/// 设置默认位置偏移量。
+ (void)setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position;

/// 获取默认位置偏移量。
+ (CGFloat)offsetForToastInPosition:(XZToastPosition)position;

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

@end

NS_ASSUME_NONNULL_END
