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

@interface XZToastManager : NSObject <XZToastConfiguration>

@property (nonatomic) NSInteger maximumNumberOfToasts;
@property (nonatomic, strong, nullable) UIColor * textColor;
@property (nonatomic, strong, nullable) UIFont  * font;
@property (nonatomic, strong, nullable) UIColor * backgroundColor;
@property (nonatomic, strong, nullable) UIColor * shadowColor;
- (void)setNeedsLayoutToasts;
- (void)layoutToastsIfNeeded;

@property (nonatomic) NSArray<XZToastTask *> *tasks;

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion;
- (void)hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion;

@property (nonatomic) NSArray<UIView *> *subviews;

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
