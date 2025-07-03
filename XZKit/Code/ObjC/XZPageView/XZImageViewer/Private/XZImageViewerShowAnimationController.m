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
@import XZGeometry;

@implementation XZImageViewerShowAnimationController {
    UIView *_sourceView;
}

+ (XZImageViewerShowAnimationController *)animationControllerWithSourceView:(UIView *)sourceView {
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
    
    UIView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    XZImageViewer * const toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView        * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.backgroundColor = UIColor.clearColor;
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    [toView layoutIfNeeded];
    
    XZImageViewerItemView *itemView = toVC.pageView.currentView;
    [itemView layoutIfNeeded];
    
    UIImageView * const imageView = itemView.imageView;
    imageView.clipsToBounds = _sourceView.clipsToBounds;
    imageView.contentMode   = _sourceView.contentMode;
    [containerView addSubview:imageView];
    
    CGRect const imageToRect = imageView.frame;
    imageView.frame = [_sourceView convertRect:_sourceView.bounds toView:containerView];
    
    NSTimeInterval const duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        fromView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        imageView.frame = imageToRect;
        toView.backgroundColor = UIColor.blackColor;
    } completion:^(BOOL finished) {
        if (transitionContext.transitionWasCancelled) {
            [toView removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [transitionContext completeTransition:YES];
            toView.backgroundColor = UIColor.blackColor;
        }
        itemView.imageView = imageView;
        fromView.transform = CGAffineTransformIdentity;
    }];
}

@end
