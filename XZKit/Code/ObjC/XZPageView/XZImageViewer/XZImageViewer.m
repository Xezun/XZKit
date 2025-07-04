//
//  XZImageViewer.m
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import "XZImageViewer.h"
#import "XZPageViewDefines.h"
#import "XZPageView.h"
#import "XZImageViewerItemView.h"
#import "XZImageViewerShowAnimationController.h"
#import "XZImageViewerHideAnimationController.h"
#import "XZDefines.h"
@import XZExtensions;
@import XZGeometry;

@interface XZImageViewer () <UIViewControllerTransitioningDelegate, XZPageViewDelegate, XZPageViewDataSource, UIGestureRecognizerDelegate> {
    XZImageViewerHideInteractiveController *_hideController;
    UIPanGestureRecognizer *_panGestureRecognizer;
}

@end

@implementation XZImageViewer

#pragma mark - 生命周期及重写的方法

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

@synthesize pageView = _pageView;

- (XZPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[XZPageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        _pageView.delegate = self;
        _pageView.dataSource = self;
    }
    return _pageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pageView.frame = self.view.bounds;
    [self.view addSubview:self.pageView];
    
    // 双击缩放
    UITapGestureRecognizer * const _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerAction:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:_doubleTapGestureRecognizer];
    
    // 单击退场
    UITapGestureRecognizer * const _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    
    // 拖动退场
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    _panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    [_tapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];
    [_panGestureRecognizer requireGestureRecognizerToFail:_tapGestureRecognizer];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    // 交互式退场时，让状态栏与目标控制器一致。
    // Apple 交互式转场可能存在 BUG ：
    // 非交互式退场，在 animateTransition: 方法中布局时，目标控制器是计算了状态栏的布局，safeArea.top = 20
    // 但在交互式退场时，目标控制器布局没有计算状态栏，即 safeArea.top = 0
    // 所以在交互式退场时，提前将状态栏显示出来，以避免目标控制器布局不正确。
    return _hideController ? self.presentingViewController.prefersStatusBarHidden : YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _hideController ? self.presentingViewController.preferredStatusBarStyle : UIStatusBarStyleLightContent;
}

- (void)setSourceView:(UIView *)sourceView {
    if (_sourceView != sourceView) {
        _sourceView = sourceView;
    }
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    _minimumZoomScale = minimumZoomScale;
    _maximumZoomScale = maximumZoomScale;
    [_pageView reloadData];
}

#pragma mark - XZPageViewDataSource

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return [self.dataSource numberOfItemsInImageViewer:self];
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(XZImageViewerItemView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[XZImageViewerItemView alloc] initWithImageViewer:self];
        reusingView.frame = pageView.bounds;
    }
    [reusingView setMinimumZoomScale:_minimumZoomScale maximumZoomScale:_maximumZoomScale];
    reusingView.index = index;
    
    BOOL __block didSetImage = NO;
    
    enweak(self, reusingView);
    UIImage *image = [_dataSource imageViewer:self loadImageForItemAtIndex:index completion:^(UIImage * _Nonnull image) {
        deweak(self, reusingView);
        
        if (!didSetImage) {
            reusingView.imageView.image = image;
            didSetImage = YES;
            return;
        }
        
        if (self == nil) {
            return;
        }
        
        XZPageView * const pageView = self.pageView;

        XZImageViewerItemView *itemView = pageView.currentView;
        if (itemView.index != index) {
            itemView = pageView.pendingView;
            if (itemView.index != index) {
                return;
            }
        }
        
        UIImageView * const imageView = itemView.imageView;
        NSTimeInterval duration = XZPageViewAnimationDuration;
        
        NSString * const animationKey = imageView.layer.animationKeys.firstObject;
        if (animationKey == nil) {
            itemView.imageView.image = image;
        } else {
            // 接力入场动画
            CAAnimation * const animation = [imageView.layer animationForKey:animationKey];
            duration = animation.duration - (CACurrentMediaTime() - animation.beginTime);
            
            // 获取当前位置
            CGRect const fromRect = [imageView.superview convertRect:imageView.layer.presentationLayer.frame toView:itemView];
            [imageView.layer removeAllAnimations];
            
            // 将 imageView 放回
            imageView.image = image;
            imageView.frame = fromRect;
            itemView.imageView = imageView;
        }
        
        [UIView animateWithDuration:duration animations:^{
            [itemView setNeedsLayout];
            [itemView layoutIfNeeded];
        }];
    }];
    
    if (!didSetImage) {
        reusingView.imageView.image = image;
        didSetImage = YES;
    }
    
    [reusingView setNeedsLayout];
    
    return reusingView;
}

- (BOOL)pageView:(XZPageView *)pageView shouldReuseView:(XZImageViewerItemView *)reusingView {
    [reusingView setZoomScale:1.0 animated:NO];
    return YES;
}

#pragma mark - XZPageViewDelegate

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    [self.delegate imageViewer:self didShowImageAtIndex:index];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != _panGestureRecognizer) {
        return YES;
    }
    
    XZImageViewerItemView * const itemView = _pageView.currentView;
    
    // 缩放状态下，不可手势退场（理论上不会触发）
    if (itemView == nil || itemView.zoomScale != 1.0) {
        return NO;
    }
    
    // 拖动的目标是 imageView
    if (!CGRectContainsPoint(itemView.imageView.bounds, [gestureRecognizer locationInView:itemView.imageView])) {
        return NO;
    }
    
    CGPoint const translation = [_panGestureRecognizer translationInView:nil];
    
    // 垂直向下拖动
    if (translation.y <= 0 || ABS(translation.x / translation.y) > 0.1) {
        return NO;
    }
    
    return YES;
}

#pragma mark - 事件

- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    XZImageViewerItemView *itemView = _pageView.currentView;
    if (itemView.zoomScale != 1.0) {
        [itemView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint const location = [tap locationInView:itemView.imageView];
        
        // _scrollView.scrollEnabled = !_isZoomingLockEnabled;
        // 会触发 layoutSubviews 方法；会触发代理方法。
        [itemView zoomToRect:CGRectMake(location.x, location.y, 0, 0) animated:YES];
    }
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer != _panGestureRecognizer) {
        return;
    }
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [_pageView suspendAutoPaging];
            XZImageViewerItemView * const itemView = _pageView.currentView;
            _hideController = [[XZImageViewerHideInteractiveController alloc] initWithItemView:itemView];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGFloat const translationY = MAX(0, translation.y);
            
            // 目标控制器放大：只需要 40 的距离即可跑满进度，避免手势完成时，目标控制器还没有完成入场，进度突进到 100% 无动画效果。
            [_hideController updateInteractiveTransition:MIN(40.0, translationY) / 40.0];
            
            // 根据 sourceView 确定缩放
            CGFloat const percent = MIN(160, translationY) / 160.0;
            // 背景色透明
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:(1.0 - percent)];
            
            XZImageViewerItemView * const itemView  = _hideController.itemView;
            UIImageView           * const imageView = itemView.imageView;
            
            // 拖拽 imageView
            CGRect frame = [itemView convertRect:_hideController.imageViewInitialFrame toView:imageView.superview];
            if (_sourceView) {
                CGFloat const deltaW = (frame.size.width - _sourceView.frame.size.width) * percent * 0.5;
                CGFloat const deltaH = (frame.size.height - _sourceView.frame.size.height) * percent * 0.5;
                frame = CGRectInset(frame, deltaW, deltaH);
            }
            frame.origin.x += translation.x;
            frame.origin.y += translation.y;
            imageView.frame = frame;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGPoint const velocity    = [panGestureRecognizer velocityInView:nil];
            if ( velocity.y > 400 || (translation.y >= 80) ) {
                XZImageViewerHideInteractiveController * const interactionController = _hideController;

                UIView      * const sourceView    = _sourceView;
                UIImageView * const imageView     = interactionController.itemView.imageView;
                UIView      * const containerView = imageView.superview;
                
                [interactionController updateInteractiveTransition:1.0];
                [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
                    if (sourceView) {
                        imageView.frame = [sourceView convertRect:sourceView.bounds toView:containerView];
                    } else {
                        imageView.frame = CGRectOffset(imageView.frame, 0, CGRectGetMaxY(containerView.bounds) - CGRectGetMinY(imageView.frame));
                    }
                    self.view.backgroundColor = UIColor.clearColor;
                } completion:^(BOOL finished) {
                    [interactionController finishInteractiveTransition];
                }];
                
                _hideController = nil;
                return;
            }
        }
        case UIGestureRecognizerStateFailed: {
            [_pageView restartAutoPaging];
            
            XZImageViewerHideInteractiveController * const interactionController = _hideController;
            XZImageViewerItemView                  * const itemView              = interactionController.itemView;
            UIImageView                            * const imageView             = itemView.imageView;
            
            [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
                imageView.frame = [itemView convertRect:interactionController.imageViewInitialFrame toView:imageView.superview];
                self.view.backgroundColor = UIColor.blackColor;
            } completion:^(BOOL finished) {
                [interactionController cancelInteractiveTransition];
            }];
            
            _hideController = nil;
            [self setNeedsStatusBarAppearanceUpdate];
            break;
        }
        
        default:
            break;
    }
}

#pragma mark - 私有方法

#pragma mark - 属性

- (NSInteger)currentIndex {
    return self.pageView.currentPage;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated {
    [self.pageView setCurrentPage:newIndex animated:animated];
}

#pragma mark - UIViewControllerAnimatedTransitioning 代理

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [XZImageViewerShowAnimationController animationControllerWithSourceView:self.sourceView];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    XZImageViewerItemView * const itemView = _hideController.itemView;
    return [XZImageViewerHideAnimationController animationControllerWithItemView:itemView sourceView:self.sourceView];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return _hideController;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return nil;
}

@end
