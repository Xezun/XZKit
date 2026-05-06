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
#import "XZImageViewerAnimationController.h"
#import "XZDefines.h"

@interface XZImageViewer () <UIViewControllerTransitioningDelegate, XZPageViewDelegate, XZPageViewDataSource, UIGestureRecognizerDelegate> {
    XZImageViewerInteractiveTransition *_interactiveTransition;
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
        _pageView.isPrefetchingEnabled = YES;
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
    // 目的：交互式退场时，让状态栏与目标控制器一致。
    //
    // 【UIKit 可能存在 BUG 】
    // 在 animateTransition: 方法中获取布局时，
    // 非交互式退场，目标控制器计算了状态栏高度，获取到 safeArea.top 的值为 20 点；
    // 在交互式退场，目标控制器未计算状态栏高度，获取到 safeArea.top 的值为 0  点。
    // 这导致在交互式转场时，获取 sourceView 位置不准确。
    // 20260506: 经测试 iOS 26 修复了上述 BUG
    //
    // 所以，在交互式退场时，状态栏与目标控制器保持一致，以避免目标控制器布局不正确。
    if (@available(iOS 26.0, *)) {
        return self.presentingViewController.prefersStatusBarHidden;
    }
    return _interactiveTransition ? self.presentingViewController.prefersStatusBarHidden : YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 【UIKit 可能存在 BUG 】
    // 当转场动画时长为 0.35 秒时，Viewer 退场后，状态栏的样式可能不正确，使用 0.3 秒正常，目前使用 0.5 秒也正常。
    return _interactiveTransition ? self.presentingViewController.preferredStatusBarStyle : UIStatusBarStyleDarkContent;
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
    
    // 是否需要展示动画。默认同步加载，无动画。
    BOOL __block needsAnimation = NO;
    
    @enweak(self, reusingView);
    [_dataSource imageViewer:self imageView:reusingView.imageView loadImageForItemAtIndex:index completion:^(BOOL success) {
        @deweak(self, reusingView);
        
        // 已经释放
        if (self == nil || reusingView == nil || !success) {
            return;
        }
        
        // 图片同步加载的
        if (!needsAnimation) {
            return;
        }
        
        XZPageView * const pageView = self.pageView;
        
        // 图片处于未显示状态（在复用时预加载）
        if (reusingView != pageView.currentView && reusingView != pageView.pendingView) {
            [reusingView setNeedsLayout];
            return;
        }
        
        // 为显示中的图片，处理动画效果
        UIImageView *  const imageView = reusingView.imageView;
        NSTimeInterval const duration  = XZPageViewAnimationDuration;
        
        NSString * const animationKey = imageView.layer.animationKeys.firstObject;
        if (animationKey != nil) {
            // 接力转场的入场动画，获取图片当前的位置
            CGRect const fromRect = [imageView.superview convertRect:imageView.layer.presentationLayer.frame toView:reusingView];
            [imageView.layer removeAllAnimations];
            
            // 将 imageView 放回 reusingView 中
            imageView.frame = fromRect;
            reusingView.imageView = imageView;
        }
        
        [UIView animateWithDuration:duration animations:^{
            // 重置缩放
            if (reusingView.isZoomed) {
                [reusingView setZoomScale:1.0 animated:NO];
            }
            [reusingView setNeedsLayout];
            [reusingView layoutIfNeeded];
        }];
    }];
    
    // 如果 block 是异步的，那么在 block 中就需要动画。
    if (!needsAnimation) {
        needsAnimation = YES;
        [reusingView setNeedsLayout];
    }
    
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
    
    CGPoint const translation = [_panGestureRecognizer translationInView:nil];
    
    // 手势方向：垂直
    return (translation.y > 1 || translation.y < -1) && ABS(translation.x / translation.y) < 0.1;
}

#pragma mark - 事件

- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    XZImageViewerItemView *itemView = _pageView.currentView;
    if (!itemView.imageView.image) {
        return;
    }
    if (![itemView.imageView isDescendantOfView:itemView]) {
        return;
    }
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
            _interactiveTransition = [[XZImageViewerInteractiveTransition alloc] initWithItemView:itemView];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGFloat const offset = ABS(translation.y);
            
            // 目标控制器放大：避免手势完成时（需要 80 的距离），目标控制器还没有完成入场，进度突进到 100% 无动画效果。
            [_interactiveTransition updateInteractiveTransition:MIN(80.0, offset) / 80.0];
            
            // 缩放进度
            CGFloat const percent = MIN(160, offset) / 160.0;
            // 背景色变透明
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:(1.0 - percent)];
            
            XZImageViewerItemView * const itemView  = _interactiveTransition.itemView;
            UIImageView           * const imageView = itemView.imageView;
            
            CGRect frame = [itemView convertRect:_interactiveTransition.imageViewInitialRect toView:imageView.superview];
            
            // 拖拽 imageView 根据 sourceView 确定缩放
            if (_sourceView) {
                CGRect  const sourceRect = _sourceView.frame;
                CGFloat const deltaW = (frame.size.width - sourceRect.size.width) * percent * 0.5;
                CGFloat const deltaH = (frame.size.height - sourceRect.size.height) * percent * 0.5;
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
            if ( velocity.y > 400 || (translation.y >= 80) || (translation.y <= -80) ) {
                XZImageViewerInteractiveTransition * const interactionController = _interactiveTransition;

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
                
                _interactiveTransition = nil;
                return;
            }
        }
        case UIGestureRecognizerStateFailed: {
            [_pageView restartAutoPaging];
            
            XZImageViewerInteractiveTransition * const interactionController = _interactiveTransition;
            XZImageViewerItemView              * const itemView              = interactionController.itemView;
            UIImageView                        * const imageView             = itemView.imageView;
            
            [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
                imageView.frame = [itemView convertRect:interactionController.imageViewInitialRect toView:imageView.superview];
                self.view.backgroundColor = UIColor.blackColor;
            } completion:^(BOOL finished) {
                [interactionController cancelInteractiveTransition];
            }];
            
            _interactiveTransition = nil;
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
    return [XZImageViewerAnimationController animationControllerForType:(XZImageViewerTransitionTypeShow) sourceView:self.sourceView itemView:nil];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    XZImageViewerItemView * const itemView = _interactiveTransition.itemView;
    return [XZImageViewerAnimationController animationControllerForType:(XZImageViewerTransitionTypeHide) sourceView:self.sourceView itemView:itemView];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return _interactiveTransition;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return nil;
}

@end
