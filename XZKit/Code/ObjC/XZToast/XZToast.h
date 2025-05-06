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

/// 显示或隐藏提示信息的回调块函数类型。
/// @param finished 操作过程是否完成
typedef void (^XZToastCompletion)(BOOL finished);

@interface XZToast : NSObject

@property (nonatomic, readonly) UIView *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

@end

//@interface XZToastTask : NSObject
//
//@property (nonatomic, readonly) XZToast *toast;
//@property (nonatomic, readonly) BOOL isCancelled;
//- (void)cancel;
//
//@end

NS_ASSUME_NONNULL_END
