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
    [containerView insertSubview:toView belowSubview:fromView];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [toView layoutIfNeeded];
    // 在缩放前获取源的位置
    CGRect const sourceRect = [_sourceView convertRect:_sourceView.bounds toView:containerView];
    // 缩放 toVC 的原因是：交互式退场的动画，由交互手势处理了，这里如果不添加动画，需要额外的逻辑去维护。
    toView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    XZImageViewerItemView * const itemView = fromVC.pageView.currentView;
    [itemView layoutIfNeeded];
    
    if (_imageView) {
        // 交互式
        UIImageView * const imageView = _imageView;
        if (_sourceView) {
            imageView.clipsToBounds = _sourceView.clipsToBounds;
            imageView.contentMode   = _sourceView.contentMode;
        }
        imageView.frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
        [containerView addSubview:imageView];
        
        NSTimeInterval const duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (transitionContext.transitionWasCancelled) {
                toView.transform = CGAffineTransformIdentity;
                [toView removeFromSuperview];
                fromView.backgroundColor = UIColor.blackColor;
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
            }
            itemView.imageView = imageView;
        }];
    } else if (_sourceView) {
        // 非交互式
        UIImageView * const imageView = itemView.imageView;
        imageView.clipsToBounds = _sourceView.clipsToBounds;
        imageView.contentMode   = _sourceView.contentMode;
        imageView.frame         = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
        [containerView addSubview:imageView];
        
        NSTimeInterval const duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            imageView.frame          = sourceRect;
            fromView.backgroundColor = UIColor.clearColor;
            toView.transform         = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (transitionContext.transitionWasCancelled) {
                toView.transform = CGAffineTransformIdentity;
                [toView removeFromSuperview];
                fromView.backgroundColor = UIColor.blackColor;
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
            }
            itemView.imageView = imageView;
        }];
    } else {
        // 非交互式，无源视图：图片向下平移
        UIImageView * const imageView = itemView.imageView; 
        imageView.frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:containerView];
        [containerView addSubview:imageView];
        
        NSTimeInterval const duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            imageView.frame          = CGRectOffset(imageView.frame, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageView.frame));
            fromView.backgroundColor = UIColor.clearColor;
            toView.transform         = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (transitionContext.transitionWasCancelled) {
                toView.transform = CGAffineTransformIdentity;
                [toView removeFromSuperview];
                fromView.backgroundColor = UIColor.blackColor;
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
            }
            itemView.imageView = imageView;
        }];
    }
}

@end

@implementation XZImageViewerHideInteractiveController

- (instancetype)initWithImageView:(UIImageView *)imageView {
    self = [super init];
    if (self) {
        _imageView = imageView;
        _imageRect = imageView.frame;
    }
    return self;
}

@end
