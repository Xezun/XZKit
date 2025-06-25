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

//@interface _XZImageViewerView : UIView
//@property (nonatomic, readonly, nonnull) XZCarouselView *carouselView;
//- (void)setFrame:(CGRect)frame keepsCarouselViewFullScreen:(BOOL)keepsCarouselViewFullScreen;
//@end

@interface XZImageViewer () <UIViewControllerTransitioningDelegate, XZPageViewDelegate, XZPageViewDataSource> {
    // 记录状态栏的初始状态。
    BOOL _prefersStatusBarHidden;
    UIPercentDrivenInteractiveTransition *_interactionController;
}

@property (nonatomic, readonly) XZPageView *pageView;

@end

@implementation XZImageViewer

+ (BOOL)isViewControllerBasedStatusBarAppearance {
    NSNumber *number = [NSBundle.mainBundle.infoDictionary objectForKey:@"UIViewControllerBasedStatusBarAppearance"];
    return number == nil || [number boolValue];
}

#pragma mark - 生命周期及重写的方法

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
//        self.transitioningDelegate = self;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.transitioningDelegate = self;
    }
    return self;
}

- (XZPageView *)pageView {
    return (XZPageView *)self.view;
}

- (void)loadView {
    self.view = [[XZPageView alloc] initWithFrame:UIScreen.mainScreen.bounds];;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZPageView * const pageView = self.pageView;
    pageView.backgroundColor = UIColor.blackColor;
    pageView.delegate = self;
    pageView.dataSource = self;
    
    // 双击缩放
    UITapGestureRecognizer * const doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerAction:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    
    // 单击退场
    UITapGestureRecognizer * const tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // 拖动退场
     UIPanGestureRecognizer * const panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [panGestureRecognizer requireGestureRecognizerToFail:tapGestureRecognizer];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - XZPageViewDataSource

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return [self.dataSource numberOfItemsInImageViewer:self];
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(XZImageViewerItemView *)reusingView {
    if (reusingView == nil) {
        CGRect const kBounds = pageView.bounds;
        reusingView = [[XZImageViewerItemView alloc] initWithFrame:kBounds];
    }
    
    UIImage *image = [_dataSource imageViewer:self loadImageForItemAtIndex:index];
    
    reusingView.imageView.image = image;
    
    return reusingView;
}

#pragma mark - XZPageViewDelegate

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    [self.delegate imageViewer:self didShowImageAtIndex:index];
}

#pragma mark - 事件

- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    XZImageViewerItemView *itemView = self.pageView.currentView;
    [UIView animateWithDuration:itemView.zoomScale == 1.0 ? 0 : XZPageViewAnimationDuration animations:^{
        [itemView setZoomScale:1.0 animated:NO];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer {
//    switch (panGestureRecognizer.state) {
//        case UIGestureRecognizerStateBegan: {
//            // 将屏幕快照放到底层，作为拖拽手势过程中的背景。
//            // 一般情况下，当前控制器在显示时，底层时没有控制器的；
//            // 如果将快照放在当前控制器底层，那么在 in-cell 模式下，dismiss 时当前控制器可能会向下移动，
//            // 而系统没有提供合适的接口来修正其位置（viewWillDisappear/viewDidLayoutSubviews等方法中都不可以，偶尔会发生快照抖动），
//            // 因此这么做会限制 XZImageViewer 的呈现模式必须时普通模式，否则动画效果可能与预期不一样。
//            CGRect const frame = self.pageView.frame;
//            CGPoint const location = [panGestureRecognizer locationInView:self.carouselView];
//            
////            self.carouselView.layer.anchorPoint = CGPointMake(location.x / frame.size.width, location.y / frame.size.height);
////            self.carouselView.frame = frame;
//            
//            _interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
//            if (![XZImageViewer isViewControllerBasedStatusBarAppearance]) {
//                [UIApplication.sharedApplication setStatusBarHidden:_prefersStatusBarHidden withAnimation:(UIStatusBarAnimationNone)];
//            }
//            [self dismissViewControllerAnimated:YES completion:nil];
//            break;
//        }
//        case UIGestureRecognizerStateChanged: {
//            CGRect const kBounds = self.view.bounds;
//            CGPoint const translation = [panGestureRecognizer translationInView:nil];
//            CGFloat const kPercent = MAX(0, translation.y) / kBounds.size.height;
//            
//            CGFloat const kScale = MAX(1.0 - kPercent, 0.3);
//            
//            [_interactionController updateInteractiveTransition:kPercent];
////            self.carouselView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(translation.x, translation.y), kScale, kScale);
//            break;
//        }
//            
//        case UIGestureRecognizerStateCancelled:
//        case UIGestureRecognizerStateEnded: {
//            if (_interactionController == nil) {
//                return;
//            }
//            CGRect const kBounds = self.view.bounds;
//            CGPoint const translation = [panGestureRecognizer translationInView:nil];
//            CGPoint const velocity = [panGestureRecognizer velocityInView:nil];
//            if ( velocity.y > 400 || (translation.y > 0 && translation.y >= 0.3 * kBounds.size.height) ) {
//                CGRect const frame = CGRectIntegral(self.carouselView.frame);
//                self.carouselView.transform = CGAffineTransformIdentity;
//                self.carouselView.frame = frame;
//                [self.carouselView layoutIfNeeded];
//                
//                CGRect const targetRect = [self.view.window convertRect:[self _XZImageViewerSourceRectForCurrentImage:YES] toView:self.view];
//                UIViewContentMode const targetMode = [self _XZImageViewerSourceContentModeForCurrentImage];
//                _interactionController.completionSpeed = 1.0 - _interactionController.percentComplete;
//                [UIView animateWithDuration:_interactionController.duration delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut) animations:^{
//                    self.carouselView.contentMode = targetMode;
//                    [(_XZImageViewerView *)[self view] setFrame:targetRect keepsCarouselViewFullScreen:NO];
//                } completion:nil];
//                [_interactionController finishInteractiveTransition];
//                _interactionController = nil;
//                return;
//            }
//        }
//            
//        case UIGestureRecognizerStateFailed: {
//            if (_interactionController == nil) {
//                return;
//            }
//            UIPercentDrivenInteractiveTransition *interactionController = _interactionController;
//            [UIView animateWithDuration:XZCarouselViewAnimationDuration delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
//                self.carouselView.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                [interactionController cancelInteractiveTransition];
//            }];
//            _interactionController = nil;
//            break;
//        }
//        
//        default:
//            break;
//    }
}

#pragma mark - 私有方法

#pragma mark - 属性

- (NSInteger)currentIndex {
    return self.pageView.currentPage;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    self.pageView.currentPage = currentIndex;
}

- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated {
    [self.pageView setCurrentPage:newIndex animated:animated completion:nil];
}

#pragma mark - UIViewControllerAnimatedTransitioning 代理

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    // 状态栏是否隐藏，与 present 时一致。
    _prefersStatusBarHidden = UIApplication.sharedApplication.isStatusBarHidden;
    
    switch (presented.modalPresentationStyle) {
        case UIModalPresentationFullScreen:
        case UIModalPresentationCustom: {
            return [[_XZImageViewerPresentingAnimationController alloc] initWithDelegate:self];
        }
        default: {
            return nil;
        }
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    switch (dismissed.modalPresentationStyle) {
        case UIModalPresentationFullScreen:
        case UIModalPresentationCustom: {
            return [[_XZImageViewerDismissingAnimationController alloc] initWithDelegate:self];
        }
        default: {
            return nil;
        }
    }
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return _interactionController;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return nil;
}

//- (CGRect)_XZImageViewerSourceRectForCurrentImage:(BOOL)isInteractive {
//    NSInteger const currentIndex = self.carouselView.currentIndex;
//    if ([_delegate respondsToSelector:@selector(imageViewer:sourceRectForImageAtIndex:)]) {
//        return [_delegate imageViewer:self sourceRectForImageAtIndex:currentIndex];
//    }
//    if (isInteractive) {
//        CGRect const frame = self.carouselView.frame;
//        return CGRectOffset(frame, 0, self.view.bounds.size.height - frame.origin.y);
//    }
//    CGRect const kBounds = UIScreen.mainScreen.bounds;
//    return CGRectMake(CGRectGetMidX(kBounds), CGRectGetMidY(kBounds), 0, 0);
//}
//
//- (UIViewContentMode)_XZImageViewerSourceContentModeForCurrentImage {
//    NSInteger const currentIndex = self.carouselView.currentIndex;
//    if ([_delegate respondsToSelector:@selector(imageViewer:sourceContentModeForImageAtIndex:)]) {
//        return [_delegate imageViewer:self sourceContentModeForImageAtIndex:currentIndex];
//    }
//    return self.carouselView.contentMode;
//}

@end



@implementation _XZImageViewerPresentingAnimationController

//- (instancetype)initWithDelegate:(XZImageViewer *)delegate {
//    self = [super init];
//    if (self) {
//        _delegate = delegate;
//    }
//    return self;
//}
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
//    return XZPageViewAnimationDuration;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIView * const containerView = transitionContext.containerView;
//    CGRect const kBounds = containerView.bounds;
//    
//    UIView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    
//    UIView * const shadowView = [[UIView alloc] initWithFrame:kBounds];
//    shadowView.backgroundColor = [UIColor clearColor];
//    [containerView insertSubview:shadowView aboveSubview:fromView];
//    
//    CGRect const _sourceRect = [containerView.window convertRect:[_delegate _XZImageViewerSourceRectForCurrentImage:NO] toView:containerView];
//    UIViewContentMode const _sourceContentMode = [_delegate _XZImageViewerSourceContentModeForCurrentImage];
//    
//    UIViewController * const toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];;
//    _XZImageViewerView * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIViewContentMode const targetContentMode = toView.carouselView.contentMode;
//    // present 有原始模式向目的模式过渡。
//    toView.carouselView.backgroundColor = UIColor.clearColor;
//    toView.carouselView.contentMode     = _sourceContentMode;
//    [toView setFrame:_sourceRect keepsCarouselViewFullScreen:NO];
//    [toView layoutIfNeeded];
//    [containerView addSubview:toView];
//    
//    NSTimeInterval const duration = [self transitionDuration:transitionContext];
//    [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut) animations:^{
//        shadowView.backgroundColor = UIColor.blackColor;
//        // 下面两句的顺序不能颠倒，不然动画效果不对。
//        toView.carouselView.contentMode = targetContentMode;
//        [toView setFrame:[transitionContext finalFrameForViewController:toVC] keepsCarouselViewFullScreen:YES];
//    } completion:^(BOOL finished) {
//        [shadowView removeFromSuperview];
//        if (transitionContext.transitionWasCancelled) {
//            [toView removeFromSuperview];
//            [transitionContext completeTransition:NO];
//        } else {
//            toView.carouselView.backgroundColor = UIColor.blackColor;
//            [transitionContext completeTransition:YES];
//        }
//    }];
//}

@end


@implementation _XZImageViewerDismissingAnimationController

//- (instancetype)initWithDelegate:(XZImageViewer *)delegate {
//    self = [super init];
//    if (self) {
//        _delegate = delegate;
//    }
//    return self;
//}
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
//    return XZCarouselViewAnimationDuration;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIView * const containerView = transitionContext.containerView;
//    CGRect const kBounds = containerView.bounds;
//    
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    CGRect const fromViewFrame1 = [transitionContext initialFrameForViewController:fromVC];
//    _XZImageViewerView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    fromView.carouselView.backgroundColor = UIColor.clearColor;
//    // 虽然在转场完成后，系统会自动将 toView 添加到 window 上显示，但是如果不添加到 containerView 上，那么在 in-cell 状态下，toView 的位置就会异常。
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    toView.frame = [transitionContext finalFrameForViewController:toVC];
//    [containerView insertSubview:toView belowSubview:fromView];
//    
//    UIView * const shadowView = [[UIView alloc] initWithFrame:kBounds];
//    shadowView.backgroundColor = [UIColor blackColor];
//    [containerView insertSubview:shadowView aboveSubview:toView];
//    
//    CGRect const _sourceRect = [containerView.window convertRect:[_delegate _XZImageViewerSourceRectForCurrentImage:NO] toView:containerView];
//    UIViewContentMode const _sourceContentMode = [_delegate _XZImageViewerSourceContentModeForCurrentImage];
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut) animations:^{
//        shadowView.backgroundColor = UIColor.clearColor;
//        if (transitionContext.isInteractive) {
//            return;
//        }
//        fromView.carouselView.contentMode = _sourceContentMode;
//        [fromView setFrame:_sourceRect keepsCarouselViewFullScreen:NO];
//    } completion:^(BOOL finished) {
//        [shadowView removeFromSuperview];
//        if (transitionContext.transitionWasCancelled) {
//            fromView.carouselView.backgroundColor = UIColor.blackColor;
//            [fromView setFrame:fromViewFrame1 keepsCarouselViewFullScreen:YES];
//            [toView removeFromSuperview];
//            [transitionContext completeTransition:NO];
//        } else {
//            [transitionContext completeTransition:YES];
//        }
//    }];
//}

@end

//@implementation _XZImageViewerView {
//    BOOL _keepsCarouselViewFullScreen;
//}
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        _carouselView = [[XZCarouselView alloc] initWithFrame:self.bounds];
//        [self addSubview:_carouselView];
//    }
//    return self;
//}
//
//- (void)setFrame:(CGRect)frame keepsCarouselViewFullScreen:(BOOL const)keepsCarouselViewFullScreen {
//    _keepsCarouselViewFullScreen = keepsCarouselViewFullScreen;
//    [self setFrame:frame];
//}
//
//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    
//    UIWindow * const window = self.window;
//    
//    if (window != nil && _keepsCarouselViewFullScreen) {
//        _carouselView.frame = [window convertRect:window.bounds toView:self];
//    } else {
//        _carouselView.frame = self.bounds;
//    }
//}
//
//@end
