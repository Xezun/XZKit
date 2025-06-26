//
//  XZImageViewerHideAnimationController.m
//  XZPageView
//
//  Created by 徐臻 on 2025/6/27.
//

#import "XZImageViewerHideAnimationController.h"
#import "XZPageView.h"
#import "XZImageViewer.h"
#import "XZImageViewerItemView.h"
@import XZGeometry;

@implementation XZImageViewerHideAnimationController {
    UIView *_sourceView;
}

+ (XZImageViewerHideAnimationController *)animationControllerWithSourceView:(UIView *)sourceView {
    if (sourceView == nil) {
        return nil;
    }
    return [[self alloc] initWithSourceView:sourceView];
}

- (instancetype)initWithSourceView:(UIView *)sourceView {
    self = [super init];
    if (self) {
        _sourceView = sourceView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return XZPageViewAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView * const containerView = transitionContext.containerView;
    
    XZImageViewer * const fromVC   = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView        * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    fromView.frame = [transitionContext initialFrameForViewController:fromVC];
    [containerView addSubview:fromView];
    
    // 虽然在转场完成后，系统会自动将 toView 添加到 window 上显示，但是如果不添加到 containerView 上，那么在 in-cell 状态下，toView 的位置就会异常。
    UIViewController * const toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView insertSubview:toView belowSubview:fromView];
    
    XZImageViewerItemView * const itemView = fromVC.pageView.currentView;
    itemView.imageView.clipsToBounds = _sourceView.clipsToBounds;
    itemView.imageView.contentMode   = _sourceView.contentMode;

    CGRect const sourceRect = [_sourceView convertRect:_sourceView.bounds toView:containerView];

    NSTimeInterval const duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        fromView.backgroundColor = UIColor.clearColor;
        itemView.imageView.frame = sourceRect;
    } completion:^(BOOL finished) {
        if (transitionContext.transitionWasCancelled) {
            [toView removeFromSuperview];
            fromView.backgroundColor = UIColor.blackColor;
            itemView.imageView.frame = CGRectSetSize(itemView.imageView.frame, itemView.imageView.image.size);
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
        }
    }];
}

@end
