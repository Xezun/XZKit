//
//  XZImageViewerHideAnimationController.h
//  XZPageView
//
//  Created by 徐臻 on 2025/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageViewerItemView;

@interface XZImageViewerHideAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
- (instancetype)init NS_UNAVAILABLE;
+ (XZImageViewerHideAnimationController *)animationControllerWithItemView:(nullable XZImageViewerItemView *)itemView sourceView:(nullable UIView *)sourceView;
@end

@interface XZImageViewerHideInteractiveController : UIPercentDrivenInteractiveTransition
@property (nonatomic, readonly) XZImageViewerItemView *itemView;
@property (nonatomic, readonly) CGRect imageViewInitialFrame;
- (instancetype)initWithItemView:(XZImageViewerItemView *)itemView;
@end

NS_ASSUME_NONNULL_END
