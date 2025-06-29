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
    UIImageView *_imageView;
}

+ (XZImageViewerHideAnimationController *)animationControllerWithSourceView:(UIView *)sourceView imageView:(UIImageView *)imageView {
    return [[self alloc] initWithSourceView:sourceView imageView:imageView];
}

- (instancetype)initWithSourceView:(UIView *)sourceView imageView:(UIImageView *)imageView {
    self = [super init];
    if (self) {
        _sourceView = sourceView;
        _imageView  = imageView;
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
    [fromView layoutIfNeeded];
    
    // 虽然在转场完成后，系统会自动将 toView 添加到 window 上显示，但是如果不添加到 containerView 上，那么在 in-cell 状态下，toView 的位置就会异常。
    UIViewController * const toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView insertSubview:toView belowSubview:fromView];
    [toView layoutIfNeeded];
    
    XZImageViewerItemView * const itemView = fromVC.pageView.currentView;
    [itemView layoutIfNeeded];
    itemView.hidden = YES;
    
    if (_sourceView) {
        if (_imageView) {
            UIImageView *imageView = _imageView;
            imageView.clipsToBounds = _sourceView.clipsToBounds;
            imageView.contentMode = _sourceView.contentMode;
            imageView.frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
            [containerView addSubview:imageView];
            
            NSTimeInterval const duration = [self transitionDuration:transitionContext];
            [UIView animateWithDuration:duration delay:0 options:0 animations:^{
                fromView.backgroundColor = UIColor.clearColor;
//                imageView.frame = [self->_sourceView convertRect:self->_sourceView.bounds toView:containerView];;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                itemView.hidden = NO;
                if (transitionContext.transitionWasCancelled) {
                    [toView removeFromSuperview];
                    fromView.backgroundColor = UIColor.blackColor;
                    [transitionContext completeTransition:NO];
                } else {
                    [transitionContext completeTransition:YES];
                }
            }];
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:itemView.imageView.image];
            imageView.clipsToBounds = _sourceView.clipsToBounds;
            imageView.contentMode = _sourceView.contentMode;
            imageView.frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
            [containerView addSubview:imageView];
            
            NSTimeInterval const duration = [self transitionDuration:transitionContext];
            [UIView animateWithDuration:duration delay:0 options:0 animations:^{
                fromView.backgroundColor = UIColor.clearColor;
                imageView.frame = [self->_sourceView convertRect:self->_sourceView.bounds toView:containerView];;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                itemView.hidden = NO;
                if (transitionContext.transitionWasCancelled) {
                    [toView removeFromSuperview];
                    fromView.backgroundColor = UIColor.blackColor;
                    [transitionContext completeTransition:NO];
                } else {
                    [transitionContext completeTransition:YES];
                }
            }];
        }
    } else {
        UIImageView *imageView = _imageView ?: [[UIImageView alloc] initWithImage:itemView.imageView.image];
        imageView.frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
        [containerView addSubview:imageView];
        
        NSTimeInterval const duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            fromView.backgroundColor = UIColor.clearColor;
            imageView.frame = CGRectOffset(imageView.frame, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageView.frame));
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            itemView.hidden = NO;
            if (transitionContext.transitionWasCancelled) {
                [toView removeFromSuperview];
                fromView.backgroundColor = UIColor.blackColor;
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
            }
        }];
    }
}

@end


@implementation XZImageViewerHideInteractiveController

- (instancetype)initWithImageView:(UIImageView *)imageView {
    self = [super init];
    if (self) {
        _imageView = imageView;
    }
    return self;
}

@end
