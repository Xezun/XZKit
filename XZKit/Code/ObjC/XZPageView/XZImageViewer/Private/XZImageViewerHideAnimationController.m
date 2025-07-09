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
#if SWIFT_PACKAGE
@import XZGeometryCore;
@import XZLog;
#else
@import XZGeometry;
@import XZLog;
#endif

typedef NS_ENUM(NSUInteger, XZImageViewerHideStyle) {
    // 交互式退场
    XZImageViewerHideStyleNone,
    // 缩放退场
    XZImageViewerHideStyleZoom,
    // 向下退场
    XZImageViewerHideStyleDown,
    // 先缩放，后向下退场
    XZImageViewerHideStyleZoomDown,
};

@implementation XZImageViewerHideAnimationController {
    XZImageViewerHideStyle _style;
    UIView *_sourceView;
    UIImageView *_imageView;
}

+ (XZImageViewerHideAnimationController *)animationControllerWithItemView:(XZImageViewerItemView *)itemView sourceView:(UIView *)sourceView {
    return [[self alloc] initWithSourceView:sourceView imageView:itemView.imageView isZoomed:itemView.isZoomed];
}

- (instancetype)initWithSourceView:(UIView *)sourceView imageView:(UIImageView *)imageView isZoomed:(BOOL)isZoomed {
    self = [super init];
    if (self) {
        if (imageView) {
            _style = XZImageViewerHideStyleNone;
        } else if (sourceView) {
            _style = XZImageViewerHideStyleZoom;
        } else if (isZoomed) {
            _style = XZImageViewerHideStyleZoomDown;
        } else {
            _style = XZImageViewerHideStyleDown;
        }
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
    
    CGRect const imageRect0 = [itemView convertRect:itemView.imageFrame toView:containerView];
    CGRect const imageRect1 = [itemView convertRect:[itemView imageRectForBounds:itemView.bounds] toView:containerView];
    CGRect const imageRect2 = CGRectOffset(imageRect1, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageRect1));
    
    imageView.frame = imageRect0;
    [containerView addSubview:imageView];
    
    NSTimeInterval const duration = [self transitionDuration:transitionContext];
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations:^{
        switch (self->_style) {
            case XZImageViewerHideStyleNone: {
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    toView.transform = CGAffineTransformIdentity;
                    [toVC setNeedsStatusBarAppearanceUpdate];
                }];
                break;
            }
            case XZImageViewerHideStyleZoom: {
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    imageView.frame          = sourceRect;
                    fromView.backgroundColor = UIColor.clearColor;
                    toView.transform         = CGAffineTransformIdentity;
                }];
                break;
            }
            case XZImageViewerHideStyleDown: {
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    fromView.backgroundColor = UIColor.clearColor;
                    toView.transform         = CGAffineTransformIdentity;
                    imageView.frame          = imageRect2;
                }];
                break;
            }
            case XZImageViewerHideStyleZoomDown: {
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                    // 必须将下面的操作放一起，贯穿且为整个动画过程，否则 imageViewer 退场后，状态栏的样式可能会不正确。
                    [toVC setNeedsStatusBarAppearanceUpdate];
                    fromView.backgroundColor = UIColor.clearColor;
                    toView.transform         = CGAffineTransformIdentity;
                }];
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                    imageView.frame = CGRectOffset(imageRect2, 0, -imageRect2.size.height);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
                    imageView.frame          = imageRect2;
                }];
                break;
            }
        }
    } completion:^(BOOL finished) {
        if (transitionContext.transitionWasCancelled) {
            [transitionContext completeTransition:NO];
            toView.transform = CGAffineTransformIdentity;
            [toView removeFromSuperview];
            fromView.backgroundColor = UIColor.blackColor;
        } else {
            [transitionContext completeTransition:YES];
        }
        itemView.imageView = imageView;
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end

@implementation XZImageViewerHideInteractiveController

- (instancetype)initWithItemView:(XZImageViewerItemView *)itemView {
    self = [super init];
    if (self) {
        _itemView = itemView;
        _imageViewInitialFrame = itemView.imageView.frame;
    }
    return self;
}

@end
