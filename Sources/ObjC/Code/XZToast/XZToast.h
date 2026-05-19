//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZToastDefines.h>
#import <XZKit/UIKit+XZToast.h>
#else
#import "XZToastDefines.h"
#import "UIKit+XZToast.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 一种页面内的、非打断式的提示性消息。
NS_REFINED_FOR_SWIFT
@interface XZToast : NSObject <NSCopying> {
    @package
    __kindof UIView * _Nullable _view;
}

/// 消息样式。
@property (nonatomic, readonly) XZToastStyle style;

/// 消息视图。
@property (nonatomic, readonly, nullable) __kindof UIView *view;

- (instancetype)init NS_UNAVAILABLE;

/// 构造消息的初始化方法。
/// - Parameters:
///   - style: 消息样式
///   - view: 消息视图，若提供则为自定义视图的消息
- (instancetype)initWithStyle:(XZToastStyle)style view:(nullable UIView *)view NS_DESIGNATED_INITIALIZER;

/// 构造通用消息的方法。
/// - Parameters:
///   - style: 消息类型
///   - text: 消息文本
///   - image: 消息图标
///   - progress: 消息进度，若非进度类型消息，请使用 -1.0 值。
+ (instancetype)toastWithStyle:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image progress:(CGFloat)progress;

/// 构造通用（非进度类型）消息的便利方法。
/// - Parameters:
///   - style: 消息类型
///   - text: 消息文本
///   - image: 消息图标
+ (instancetype)toastWithStyle:(XZToastStyle)style text:(nullable NSString *)text image:(nullable UIImage *)image;

#pragma mark - 便利构造器

/// 构造通用文本样式消息。
/// - Parameter text: 消息文案
+ (instancetype)messageToast:(NSString *)text NS_SWIFT_NAME(message(_:));
/// 构造通用文本样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)messageToast:(NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(message(_:image:));

/// 构造通用加载样式消息。
/// - Parameter text: 消息文案
+ (instancetype)loadingToast:(nullable NSString *)text NS_SWIFT_NAME(loading(_:));
/// 构造通用加载样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)loadingToast:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(loading(_:image:));
/// 构造通用加载样式消息，并指定进度。
/// - Parameter text: 消息文案
/// - Parameter progress: 进度，值在 0 ~ 1.0 范围以内；小于 0 的数字，将不会展示进度，而是加载动画
+ (instancetype)loadingToast:(nullable NSString *)text progress:(CGFloat)progress NS_SWIFT_NAME(loading(_:progress:));

/// 构造通用成功样式消息。
/// - Parameter text: 消息文案
+ (instancetype)successToast:(nullable NSString *)text NS_SWIFT_NAME(success(_:));
/// 构造通用成功样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)successToast:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(success(_:image:));

/// 构造通用失败样式消息。
/// - Parameter text: 消息文案
+ (instancetype)failureToast:(nullable NSString *)text NS_SWIFT_NAME(failure(_:));
/// 构造通用失败样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)failureToast:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(failure(_:image:));

/// 构造通用警告样式消息。
/// - Parameter text: 消息文案
+ (instancetype)warningToast:(nullable NSString *)text NS_SWIFT_NAME(warning(_:));
/// 构造通用警告样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)warningToast:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(warning(_:image:));

/// 构造通用等待样式消息。
/// - Parameter text: 消息文案
+ (instancetype)waitingToast:(nullable NSString *)text NS_SWIFT_NAME(waiting(_:));
/// 构造通用等待样式消息。
/// - Parameter text: 消息文案
/// - Parameter image: 消息图片
+ (instancetype)waitingToast:(nullable NSString *)text image:(nullable UIImage *)image NS_SWIFT_NAME(waiting(_:image:));

@end

@interface XZToast (XZExtendedToast)

/// 消息文案。
///
/// 如果属性的``view``未实现了``XZToastView``协议，那么设置此属性不会有任何效果。
@property (nonatomic, copy, nullable) NSString *text;

/// 消息图片。
///
/// 如果属性的``view``未实现了``XZToastView``协议，那么设置此属性不会有任何效果。
@property (nonatomic, strong, nullable) UIImage *image;

/// 消息进度。
///
/// 如果属性的``view``未实现了``XZToastView``协议，那么设置此属性不会有任何效果。
@property (nonatomic) CGFloat progress;

@end

@interface XZToast (XZToastAppearance)

/// 默认的消息视图的类。
@property (class, nonatomic) Class viewClass;
/// 默认的数量限制。设置 0 表示不限制数量，设置负数无效。
@property (class, nonatomic) NSInteger maximumNumberOfToasts;
/// 默认的文本颜色。
@property (class, nonatomic) UIColor * textColor;
/// 默认的文本字体。
@property (class, nonatomic) UIFont  * font;
/// 默认的背景色。
@property (class, nonatomic) UIColor * backgroundColor;
/// 默认的阴影色。
@property (class, nonatomic) UIColor * shadowColor;
/// 进度的默认颜色。
@property (class, nonatomic) UIColor * color;
/// 进度轨道默认的颜色。
@property (class, nonatomic) UIColor * trackColor;
/// 默认展示时长，默认 1.0 秒。
@property (class, nonatomic) NSTimeInterval duration;

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

NS_ASSUME_NONNULL_END
