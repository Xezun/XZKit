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
@import XZDefines;
@import XZExtensions;
@import XZGeometry;

@interface XZImageViewer () <UIViewControllerTransitioningDelegate, XZPageViewDelegate, XZPageViewDataSource> {
    // 记录状态栏的初始状态。
    BOOL _prefersStatusBarHidden;
    UIPercentDrivenInteractiveTransition *_interactionController;
}

@end

@implementation XZImageViewer

#pragma mark - 生命周期及重写的方法

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
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
    
    self.view.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.pageView];
    
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 使用 autoresizingMask 效果不正常。
    self.pageView.frame = self.view.bounds;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setSourceView:(UIView *)sourceView {
    if (_sourceView != sourceView) {
        _sourceView = sourceView;
        self.transitioningDelegate = _sourceView ? self : nil;
    }
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    XZImageViewerItemView * const itemView = self.pageView.currentView;
    [itemView setMinimumZoomScale:minimumZoomScale maximumZoomScale:maximumZoomScale];
    _minimumZoomScale = itemView.minimumZoomScale;
    _maximumZoomScale = itemView.maximumZoomScale;
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
    [reusingView setZoomScale:1.0 animated:NO];
    reusingView.index = index;
    reusingView.delegate = self.delegate;
    
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
        if (pageView.currentPage != index) {
            return;
        }
        
        XZImageViewerItemView * const itemView = pageView.currentView;
        itemView.imageView.image = image;
        itemView.imageView.frame = CGRectSetSize(reusingView.imageView.frame, image.size);
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
            [itemView setNeedsLayout];
            [itemView layoutIfNeeded];
        }];
    }];
    
    if (!didSetImage) {
        reusingView.imageView.image = image;
        didSetImage = YES;
    }
    
    reusingView.imageView.frame = CGRectSetSize(reusingView.imageView.frame, image.size);
    [reusingView setNeedsLayout];
    
    return reusingView;
}

- (UIView *)pageView:(XZPageView *)pageView prepareReuseForView:(__kindof UIView *)reusingView {
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
    return [XZImageViewerHideAnimationController animationControllerWithSourceView:self.sourceView];
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
