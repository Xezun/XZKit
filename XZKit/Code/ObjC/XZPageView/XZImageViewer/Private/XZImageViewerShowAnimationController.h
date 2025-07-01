//
//  XZImageViewerShowAnimationController.h
//  XZPageView
//
//  Created by 徐臻 on 2025/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageViewerShowAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZImageViewerShowAnimationController *)animationControllerWithSourceView:(UIView *)sourceView;
@end

NS_ASSUME_NONNULL_END
