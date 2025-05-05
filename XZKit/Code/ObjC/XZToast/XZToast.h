//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 显示或隐藏提示信息的回调块函数类型。
/// @param finished 操作过程是否完成
typedef void (^XZToastShowCompletion)(BOOL finished);
typedef void (^XZToastHideCompletion)(void);

@interface XZToast : NSObject

@property (nonatomic, readonly) UIView *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

@end


NS_ASSUME_NONNULL_END
