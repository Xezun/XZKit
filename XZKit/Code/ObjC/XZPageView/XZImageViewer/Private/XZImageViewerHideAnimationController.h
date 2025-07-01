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
+ (XZImageViewerHideAnimationController *)animationControllerWithSourceView:(UIView *)sourceView imageView:(nullable UIImageView *)imageView;
@end


@interface XZImageViewerHideInteractiveController : UIPercentDrivenInteractiveTransition
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) CGRect imageRect;
- (instancetype)initWithImageView:(UIImageView *)imageView;
@end
NS_ASSUME_NONNULL_END
