//
//  XZToastManager.h
//  XZToast
//
//  Created by Xezun on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToastTask;

@interface XZToastManager ()

/// 显示 XZToast 的控制器，默认为当前对象所属的控制器。
@property (nonatomic, readonly) UIViewController *viewController;

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion;

- (void)hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion;
- (void)hideToastWithTask:(nullable XZToastTask *)task completion:(nullable void (^)(void))completion;

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
