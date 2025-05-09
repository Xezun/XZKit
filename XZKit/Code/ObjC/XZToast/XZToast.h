//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 显示或隐藏 toast 的动画时长，0.3 秒。
FOUNDATION_EXPORT NSTimeInterval const XZToastAnimationDuration NS_SWIFT_NAME(XZToast.animationDuration);

/// XZToast 的显示位置。
typedef NS_ENUM(NSUInteger, XZToastPosition) {
    /// XZToast 显示在顶部。
    XZToastPositionTop = 0, // 会被用作数组 index 必须从 0 开始
    /// XZToast 显示在中部。
    XZToastPositionMiddle,
    /// XZToast 显示在底部。
    XZToastPositionBottom,
};

/// 显示或隐藏提示信息的回调块函数类型。
/// @param finished 如果 toast 在 duration 之前被取消，该参数为 NO 值
typedef void (^XZToastCompletion)(BOOL finished);

@interface XZToast : NSObject

@property (nonatomic, readonly) UIView *view;

@property (nonatomic, copy, nullable) NSString *text;

- (void)startAnimating;
- (void)stopAnimating;

@property (nonatomic, readonly) BOOL isAnimating;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

+ (XZToast *)messageToast:(NSString *)text NS_SWIFT_NAME(message(_:));

+ (XZToast *)loadingToast:(NSString *)text NS_SWIFT_NAME(loading(_:));

@end

NS_ASSUME_NONNULL_END
