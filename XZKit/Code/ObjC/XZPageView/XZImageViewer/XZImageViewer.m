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

@interface XZImageViewer () <UIViewControllerTransitioningDelegate, XZPageViewDelegate, XZPageViewDataSource, UIGestureRecognizerDelegate> {
    XZImageViewerHideInteractiveController *_interactionController;
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
    
    self.view.contentMode = UIViewContentModeScaleAspectFit;
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
        if (pageView.currentPage != index) {
            return;
        }
        
        XZImageViewerItemView * const itemView = pageView.currentView;
        itemView.imageView.image = image;
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
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
    
    if (itemView == nil) {
        return NO;
    }
    
    if (!CGRectContainsPoint(itemView.imageView.bounds, [gestureRecognizer locationInView:itemView.imageView])) {
        return NO;
    }
    
    CGPoint const translation = [_panGestureRecognizer translationInView:nil];
    
    if (translation.x / translation.y > 0.1) {
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
    XZImageViewerItemView * const itemView = _pageView.currentView;
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:itemView.imageView.image];
            _interactionController = [[XZImageViewerHideInteractiveController alloc] initWithImageView:imageView];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGRect  const bounds      = self.view.bounds;
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGFloat const percent     = MAX(0, translation.y) / bounds.size.height;
            
            // 更新背景色
            [_interactionController updateInteractiveTransition:percent];
            
            // 拖拽 imageView
            CGRect frame = [itemView.imageView convertRect:itemView.imageView.bounds toView:_interactionController.imageView.superview];
            frame = CGRectInset(frame, frame.size.width * percent, frame.size.height * percent);
            frame.origin.x += translation.x;
            frame.origin.y += translation.y;
            _interactionController.imageView.frame = frame;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGRect  const bounds      = self.view.bounds;
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGFloat const percent     = MAX(0, translation.y) / bounds.size.height;
            CGPoint const velocity    = [panGestureRecognizer velocityInView:nil];
            if ( velocity.y > 400 || (translation.y > 0 && translation.y >= 0.3 * bounds.size.height) ) {
                [_interactionController updateInteractiveTransition:1.0];

                UIView      * const sourceView = self.sourceView;
                UIImageView * const imageView  = _interactionController.imageView;
                                
                self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0 - percent];
                [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
                    if (sourceView) {
                        imageView.frame = [sourceView convertRect:sourceView.bounds toView:imageView.superview];
                    } else {
                        imageView.frame = CGRectOffset(imageView.frame, 0, CGRectGetMaxY(imageView.superview.bounds) - CGRectGetMinY(imageView.frame));
                    }
                    self.view.backgroundColor = UIColor.clearColor;
                } completion:^(BOOL finished) {
                    [_interactionController finishInteractiveTransition];
                    _interactionController = nil;
                }];
                return;
            }
        }
        case UIGestureRecognizerStateFailed: {
            CGRect  const bounds      = self.view.bounds;
            CGPoint const translation = [panGestureRecognizer translationInView:nil];
            CGFloat const percent     = MAX(0, translation.y) / bounds.size.height;
            UIImageView * const imageView  = _interactionController.imageView;
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0 - percent];
            [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
                imageView.frame = [itemView.imageView convertRect:itemView.bounds toView:imageView.superview];
                self.view.backgroundColor = UIColor.blackColor;
            } completion:^(BOOL finished) {
                [_interactionController cancelInteractiveTransition];
                _interactionController = nil;
            }];
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
    return [XZImageViewerHideAnimationController animationControllerWithSourceView:self.sourceView imageView:_interactionController.imageView];
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
