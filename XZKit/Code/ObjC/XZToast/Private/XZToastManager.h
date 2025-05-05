//
//  XZToastManager.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToastItem;

@interface XZToastManager : NSObject

@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic) NSArray<XZToastItem *> *items;

- (void)showToast:(XZToastItem *)item;
- (void)hideToast:(nullable XZToastItem *)item completion:(XZToastHideCompletion)completion;

@property (nonatomic) NSArray<UIView *> *subviews;

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController;

@end

@interface XZToastTask : NSOperation

@end

NS_ASSUME_NONNULL_END
