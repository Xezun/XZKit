//
//  XZImageViewerHideAnimationController.h
//  XZPageView
//
//  Created by 徐臻 on 2025/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageViewerHideAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZImageViewerHideAnimationController *)animationControllerWithSourceView:(UIView *)sourceView;
@end

NS_ASSUME_NONNULL_END
