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

@property (nonatomic) NSUInteger maximumNumberOfToasts;

@property (nonatomic, readonly) BOOL isExclusive;
@property (nonatomic, readonly) CGFloat *offsets;

@property (nonatomic) NSArray<XZToastTask *> *tasks;

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion;
- (void)hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion;

@property (nonatomic) NSArray<UIView *> *subviews;

+ (nullable XZToastManager *)managerForViewController:(UIViewController *)viewController;

- (void)setNeedsLayoutToasts;
- (void)layoutToastsIfNeeded;

@end

NS_ASSUME_NONNULL_END
