//
//  XZToastManager.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToastTask;

@interface XZToastManager : NSObject

@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic) NSArray<XZToastTask *> *tasks;

- (void)showToast:(XZToastTask *)task;
- (void)hideToast:(nullable XZToastTask *)task completion:(nullable void (^)(void))completion;

@property (nonatomic) NSArray<UIView *> *subviews;

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController;

- (void)setNeedsLayoutToastViews;

@end

NS_ASSUME_NONNULL_END
