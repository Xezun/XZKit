//
//  XZImageViewerShowAnimationController.m
//  XZPageView
//
//  Created by 徐臻 on 2025/6/27.
//

#import "XZImageViewerShowAnimationController.h"
#import "XZPageView.h"
#import "XZImageViewer.h"
#import "XZImageViewerItemView.h"

@implementation XZImageViewerShowAnimationController {
    UIView * _Nullable _sourceView;
}

+ (XZImageViewerShowAnimationController *)animationControllerWithSourceView:(UIView *)sourceView {
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
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView * const containerView = transitionContext.containerView;
    
    UIView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    XZImageViewer * const toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView        * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.backgroundColor = UIColor.clearColor;
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    [toView layoutIfNeeded];
    
    XZImageViewerItemView * const itemView = toVC.pageView.currentView;
    [itemView layoutIfNeeded];
    
    UIImageView * const imageView   = itemView.imageView;
    CGRect        const imageToRect = [itemView convertRect:itemView.imageFrame toView:containerView];
    
    [containerView addSubview:imageView];
    
    if (_sourceView) {
        imageView.clipsToBounds = _sourceView.clipsToBounds;
        imageView.contentMode   = _sourceView.contentMode;
        imageView.frame = [_sourceView convertRect:_sourceView.bounds toView:containerView];
    } else {
        imageView.frame = CGRectOffset(imageToRect, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageToRect));
    }
    
    NSTimeInterval const duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        fromView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        imageView.frame    = imageToRect;
        toView.backgroundColor = UIColor.blackColor;
    } completion:^(BOOL finished) {
        itemView.imageView = imageView;
        fromView.transform = CGAffineTransformIdentity;
        if (transitionContext.transitionWasCancelled) {
            [toView removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            toView.backgroundColor = UIColor.blackColor;
        }
    }];
}

@end
