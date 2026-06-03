//
//  XZImageViewerAnimationController.m
//  XZPageView
//
//  Created by Xezun on 2025/6/27.
//

#import "XZImageViewerAnimationController.h"
#import "XZPageView.h"
#import "XZImageViewer.h"
#import "XZImageViewerItemView.h"

#define XZImageViewerAnimationDuration 0.35

@interface XZImageViewerPresentAnimationController : XZImageViewerAnimationController <UIViewControllerAnimatedTransitioning>
@end

@interface XZImageViewerDismissAnimationController : XZImageViewerAnimationController <UIViewControllerAnimatedTransitioning>
@end

@implementation XZImageViewerAnimationController

- (instancetype)initWithSourceView:(UIView *)sourceView itemView:(XZImageViewerItemView *)itemView {
    return [super init];
}

+ (id<UIViewControllerAnimatedTransitioning>)animationControllerForType:(XZImageViewerTransitionType)type sourceView:(UIView *)sourceView itemView:(XZImageViewerItemView *)itemView {
    switch (type) {
        case XZImageViewerTransitionTypeShow:
            return [[XZImageViewerPresentAnimationController alloc] initWithSourceView:sourceView itemView:nil];
        case XZImageViewerTransitionTypeHide:
            return [[XZImageViewerDismissAnimationController alloc] initWithSourceView:sourceView itemView:itemView];
    }
}

@end


@implementation XZImageViewerPresentAnimationController {
    UIView * _Nullable _sourceView;
}

- (instancetype)initWithSourceView:(UIView *)sourceView itemView:(XZImageViewerItemView *)itemView {
    self = [super initWithSourceView:sourceView itemView:itemView];
    if (self) {
        _sourceView = sourceView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return XZImageViewerAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView * const containerView = transitionContext.containerView;
    
    // UIView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
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
        // fromView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        imageView.frame    = imageToRect;
        toView.backgroundColor = UIColor.blackColor;
    } completion:^(BOOL finished) {
        itemView.imageView = imageView;
        // fromView.transform = CGAffineTransformIdentity;
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

/// 退场方式。
typedef NS_ENUM(NSUInteger, XZImageViewerDismissStyle) {
    // 交互式退场
    XZImageViewerDismissStyleNone,
    // 缩放退场
    XZImageViewerDismissStyleZoom,
    // 向下退场
    XZImageViewerDismissStyleDown,
    // 先缩放，后向下退场
    XZImageViewerDismissStyleZoomDown,
};

@implementation XZImageViewerDismissAnimationController {
    XZImageViewerDismissStyle _style;
    UIView *_sourceView;
    UIImageView *_imageView;
}

- (instancetype)initWithSourceView:(UIView *)sourceView itemView:(XZImageViewerItemView *)itemView {
    self = [super initWithSourceView:nil itemView:nil];
    if (self) {
        _sourceView = sourceView;
        _imageView  = itemView.imageView;
        
        if (_imageView) {
            _style = XZImageViewerDismissStyleNone;
        } else if (sourceView) {
            _style = XZImageViewerDismissStyleZoom;
        } else if (itemView.isZoomed) {
            _style = XZImageViewerDismissStyleZoomDown;
        } else {
            _style = XZImageViewerDismissStyleDown;
        }
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return XZImageViewerAnimationDuration;
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
    
    XZImageViewerItemView * const itemView = fromVC.pageView.currentView;
    [itemView layoutIfNeeded];
    
    UIImageView *imageView = _imageView;
    if (_imageView) {
        if (_sourceView) {
            imageView.clipsToBounds = _sourceView.clipsToBounds;
            imageView.contentMode   = _sourceView.contentMode;
        }
    } else if (_sourceView) {
        // 非交互式
        imageView = itemView.imageView;
        imageView.clipsToBounds = _sourceView.clipsToBounds;
        imageView.contentMode   = _sourceView.contentMode;
    } else {
        // 非交互式，无源视图：图片向下平移
        imageView = itemView.imageView;
    }
    
    // itemView 可能处于缩放状态：缩放状态 => 正常状态 => 原始状态
    CGRect const imageRect0 = [itemView convertRect:itemView.imageFrame toView:containerView];
    CGRect const imageRect1 = [itemView convertRect:[itemView imageRectForBounds:itemView.bounds] toView:containerView];
    CGRect const imageRect2 = CGRectOffset(imageRect1, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageRect1));
    
    imageView.frame = imageRect0;
    [containerView addSubview:imageView];
    
    NSTimeInterval const duration = [self transitionDuration:transitionContext];
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        switch (self->_style) {
            case XZImageViewerDismissStyleNone: {
                // 交互式退场，backgroundColor 和 imageView 的动画已由手势处理。
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    // 需要添加这个动画，否则手势没有转场效果。
                    imageView.alpha          = 0.9;
                }];
                break;
            }
            case XZImageViewerDismissStyleZoom: {
                // 缩放到 sourceView 的位置
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    fromView.backgroundColor = UIColor.clearColor;
                    imageView.frame          = sourceRect;
                    imageView.alpha          = 0.9;
                }];
                break;
            }
            case XZImageViewerDismissStyleDown: {
                // 直接向下平移退场，没有指定 sourceView
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    fromView.backgroundColor = UIColor.clearColor;
                    imageView.alpha          = 0.9;
                    imageView.frame          = imageRect2;
                }];
                break;
            }
            case XZImageViewerDismissStyleZoomDown: {
                // 处于缩放状态，在离开显示区域前，先缩放到普通状态，然后再退场。
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                    // 必须将下面的操作放一起，贯穿且为整个动画过程，否则 imageViewer 退场后，状态栏的样式可能会不正确。
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    fromView.backgroundColor = UIColor.clearColor;
                    imageView.alpha          = 0.9;
                }];
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    imageView.frame = CGRectOffset(imageRect2, 0, -imageRect2.size.height);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
                    imageView.frame = imageRect2;
                }];
                break;
            }
        }
    } completion:^(BOOL finished) {
        itemView.imageView = imageView;
        if (transitionContext.transitionWasCancelled) {
            [transitionContext completeTransition:NO];
            imageView.alpha = 1.0;
            [toView removeFromSuperview];
            fromView.backgroundColor = UIColor.blackColor;
        } else {
            [transitionContext completeTransition:YES];
        }
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end

@implementation XZImageViewerInteractiveTransition

- (instancetype)initWithItemView:(XZImageViewerItemView *)itemView {
    self = [super init];
    if (self) {
        _itemView = itemView;
        _imageViewInitialRect = [itemView.imageView convertRect:itemView.imageView.bounds toView:itemView];
    }
    return self;
}

@end
