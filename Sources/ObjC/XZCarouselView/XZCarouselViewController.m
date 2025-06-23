//
//  XZPageViewController.m
//  XZKit
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZPageViewController.h"

typedef NSString *_XZTransitionAppearance;
static _XZTransitionAppearance _XZTransitionViewWillAppear    = @"_XZTransitionViewWillAppear";
static _XZTransitionAppearance _XZTransitionViewDidAppear     = @"_XZTransitionViewDidAppear";
static _XZTransitionAppearance _XZTransitionViewWillDisappear = @"_XZTransitionViewWillDisappear";
static _XZTransitionAppearance _XZTransitionViewDidDisappear  = @"_XZTransitionViewDidDisappear";

/// 获取控制器生命周期阶段，返回 nil 表示控制器刚添加到 XZPageViewController 上或添加后从未参与生命周期切换。
static _XZTransitionAppearance _Nullable _XZGetTransitionAppearance(UIViewController * _Nonnull viewController);
/// 设置控制器所处的生命周期阶段，当控制器移出 XZPageViewController 请设置为 nil 。
static void _XZSetTransitionAppearance(UIViewController * _Nonnull viewController, _XZTransitionAppearance _Nullable transitionAppearance);

@interface XZPageViewController () {
    // 当前控制器，因为控制器有可能重用，使用 index 可能无法有效判断控制器。
    UIViewController * __weak _currentViewController;
    // 记录的 index ，旧的 index 。
    NSInteger _currentIndex;
    // 是否已经开始转场。
    BOOL _isTransitioning;
    /// 当前控制器的转场阶段。生命周期控制规则：
    /// XZPageViewController 在其生命周期方法内，将生命周期强制同步到其子控制器；
    /// 代理事件触发的子控制器的生命周期，除控制器移除外，其它的只在 XZPageViewController 处于 viewDidAppear 时才执行；
    /// 同时触发控制器方法时，都监测控制器当前的状态，如有需要，先转换状态，以保证不论控制器处于什么状态，都是以最后的状态为准。
    _XZTransitionAppearance _transitionAppearance;
}

@end

@implementation XZPageViewController

- (XZPageView *)pageView {
    return (XZPageView *)[self view];
}

- (void)loadView {
    self.view = [[XZPageView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _transitionAppearance = _XZTransitionViewDidDisappear;
    _currentIndex = XZPageViewNotFound;
    
    self.pageView.contentMode = UIViewContentModeScaleToFill;
    self.pageView.wrapped     = NO;
    
    self.pageView.delegate   = self;
    self.pageView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
        if (currentTransition == _XZTransitionViewWillAppear || currentTransition == _XZTransitionViewDidAppear) {
            continue;
        }
        if (currentTransition != nil) {
            [viewController willMoveToParentViewController:self];
        }
        [viewController beginAppearanceTransition:YES animated:animated];
        _XZSetTransitionAppearance(viewController, _XZTransitionViewWillAppear);
    }
    _transitionAppearance = _XZTransitionViewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_currentViewController != nil) {
        _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(_currentViewController);
        if (currentTransition == _XZTransitionViewWillAppear) {
            [_currentViewController endAppearanceTransition];
            [_currentViewController didMoveToParentViewController:self];
            _XZSetTransitionAppearance(_currentViewController, _XZTransitionViewDidAppear);
        } else if (currentTransition != _XZTransitionViewDidAppear) {
            if (currentTransition != nil) {
                [_currentViewController willMoveToParentViewController:self];
            }
            [_currentViewController beginAppearanceTransition:YES animated:NO];
            [_currentViewController endAppearanceTransition];
            [_currentViewController didMoveToParentViewController:self];
            _XZSetTransitionAppearance(_currentViewController, _XZTransitionViewDidAppear);
        }
    }
    _transitionAppearance = _XZTransitionViewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (UIViewController * const viewController in self.childViewControllers) {
        _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
        if (currentTransition == _XZTransitionViewWillDisappear || currentTransition == _XZTransitionViewDidDisappear) {
            continue;
        }
        if (currentTransition == nil) {
            [viewController willMoveToParentViewController:nil];
            continue;
        }
        [viewController willMoveToParentViewController:nil];
        [viewController beginAppearanceTransition:NO animated:animated];
        _XZSetTransitionAppearance(viewController, _XZTransitionViewWillDisappear);
    }
    _transitionAppearance = _XZTransitionViewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
        if (currentTransition == _XZTransitionViewDidDisappear || currentTransition == nil ) {
            continue;
        }
        if (currentTransition == _XZTransitionViewWillDisappear) {
            [viewController endAppearanceTransition];
            _XZSetTransitionAppearance(viewController, _XZTransitionViewDidDisappear);
            continue;
        }
        [viewController willMoveToParentViewController:nil];
        [viewController beginAppearanceTransition:NO animated:NO];
        [viewController endAppearanceTransition];
        _XZSetTransitionAppearance(viewController, _XZTransitionViewDidDisappear);
    }
    _transitionAppearance = _XZTransitionViewDidDisappear;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}


- (void)reloadData {
    [self.pageView reloadData];
}

- (NSInteger)currentIndex {
    return self.pageView.currentIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated {
    [self.pageView setCurrentIndex:newIndex animated:animated];
}

#pragma mark - DataSource

- (NSInteger)numberOfViewsInPageView:(XZPageView *)pageView {
    return [_dataSource numberOfViewControllersInPageViewController:self];
}

- (UIView *)pageView:(XZPageView *)pageView viewForIndex:(NSInteger)index reusingView:(UIView *)reusingView {
    UIViewController *viewController = [_dataSource pageViewController:self viewControllerForIndex:index reusingViewController:(UIViewController *)(reusingView.nextResponder)];
    [self addChildViewController:viewController];
    return viewController.view;
}

- (BOOL)pageView:(XZPageView *)pageView shouldEnqueueView:(UIView *)view atIndex:(NSInteger)index {
    UIViewController *viewController = (UIViewController *)[view nextResponder];
    [viewController removeFromParentViewController];
    if ([_dataSource respondsToSelector:@selector(pageViewController:shouldEnqueueViewController:atIndex:)]) {
        return [_dataSource pageViewController:self shouldEnqueueViewController:viewController atIndex:index];
    }
    return NO;
}

#pragma mark - Delegate

- (void)_XZPageViewControllerForwardTransitionAppearance:(nonnull _XZTransitionAppearance const)transitionAppearance forViewController:(UIViewController * const)viewController animated:(BOOL)animated {
    if (transitionAppearance == _XZTransitionViewWillAppear) {
        if (_transitionAppearance == _XZTransitionViewDidAppear || _transitionAppearance == _XZTransitionViewWillAppear) {
            // 当前控制器处于 viewDidAppear/viewWillAppear 状态，才向控制器发送或补发 viewWillAppear 事件。
            _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
            if (currentTransition == nil) {
                [viewController beginAppearanceTransition:YES animated:animated];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewWillAppear);
            } else if (currentTransition == _XZTransitionViewDidDisappear) {
                // 控制器未显示，发送事件。
                [viewController willMoveToParentViewController:self];
                [viewController beginAppearanceTransition:YES animated:animated];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewWillAppear);
            } else if (currentTransition == _XZTransitionViewDidAppear || currentTransition == _XZTransitionViewWillAppear) {
                // 控制器将要或者已经显示，不需要操作。
            } else {
                // 控制器将要消失。
                [viewController willMoveToParentViewController:self];
                [viewController beginAppearanceTransition:YES animated:animated];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewWillAppear);
            }
        }
        return;
    }
    
    if (transitionAppearance == _XZTransitionViewDidAppear) {
        if (_transitionAppearance == _XZTransitionViewDidAppear) {
            // 当前控制器处于 viewDidAppear 状态，才向控制器发送 viewDidAppear 事件。
            _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
            if (currentTransition == _XZTransitionViewDidAppear) {
                // 控制器已经是 viewDidAppear 状态，不需要处理。
            } else if (currentTransition == _XZTransitionViewWillAppear) {
                // 当前为 viewWillAppear 状态，正常情况下的状态。
                [viewController endAppearanceTransition];
                [viewController didMoveToParentViewController:self];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewDidAppear);
            } else {
                if (currentTransition != nil) {
                    [viewController willMoveToParentViewController:self];
                }
                [viewController beginAppearanceTransition:YES animated:NO];
                [viewController endAppearanceTransition];
                [viewController didMoveToParentViewController:self];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewDidAppear);
            }
        }
        return;
    }
    
    if (transitionAppearance == _XZTransitionViewWillDisappear) {
        if (_transitionAppearance == _XZTransitionViewDidAppear || _transitionAppearance == _XZTransitionViewWillDisappear) {
            // 当前控制器处于 viewDidAppear/viewWillDisappear 状态，才向控制器发送或补发 viewWillDisappear 事件。
            _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
            if (currentTransition == _XZTransitionViewDidAppear) {
                [viewController willMoveToParentViewController:nil];
                [viewController beginAppearanceTransition:NO animated:animated];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewWillDisappear);
            } else if (currentTransition == _XZTransitionViewWillDisappear || currentTransition == _XZTransitionViewDidDisappear || currentTransition == nil) {
                // 已经是该状态，不需要处理。
            } else {
                // 将要出现的状态。
                [viewController willMoveToParentViewController:nil];
                [viewController beginAppearanceTransition:NO animated:animated];
                _XZSetTransitionAppearance(viewController, _XZTransitionViewWillDisappear);
            }
        }
        return;
    }
    
    if (transitionAppearance == _XZTransitionViewDidDisappear) {
        // 控制器被移除。
        _XZTransitionAppearance const currentTransition = _XZGetTransitionAppearance(viewController);
        if (currentTransition == nil) {
            // 已经 viewDidDisappear 就不需要操作了。
            [viewController willMoveToParentViewController:nil];
        } else if (currentTransition == _XZTransitionViewDidDisappear) {
            _XZSetTransitionAppearance(viewController, nil);
        } else if (currentTransition == _XZTransitionViewWillDisappear) {
            // 正常情况下。
            [viewController endAppearanceTransition];
            _XZSetTransitionAppearance(viewController, nil);
        } else if (currentTransition == _XZTransitionViewDidAppear || currentTransition == _XZTransitionViewWillAppear) {
            [viewController willMoveToParentViewController:nil];
            [viewController beginAppearanceTransition:NO animated:NO];
            [viewController endAppearanceTransition];
            _XZSetTransitionAppearance(viewController, nil);
        }
        return;
    }
}

- (void)pageView:(XZPageView *)pageView willBeginTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    UIViewController *viewController = (UIViewController *)[view nextResponder];
    
    if ([_delegate respondsToSelector:@selector(pageViewController:willBeginTransitioningViewController:atIndex:animated:)]) {
        [_delegate pageViewController:self willBeginTransitioningViewController:viewController atIndex:index animated:animated];
    }
    
    [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewWillAppear) forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView didBeginTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
     UIViewController *viewController = (UIViewController *)[view nextResponder];
    // 如果这里调用 didMoveToParentViewController 那么在 endAppearanceTransition 时会被系统自动再触发一次 didMove(toParent:) 方法。
    // 大概是因为 didMoveToParentViewController 需要在 transition 结束后调用，所以限定只有当前控制器才调用 didMoveToParentViewController 方法。
    // [viewController didMoveToParentViewController:self];
    if ([_delegate respondsToSelector:@selector(pageViewController:didBeginTransitioningViewController:atIndex:animated:)]) {
        [_delegate pageViewController:self didBeginTransitioningViewController:viewController atIndex:index animated:animated];
    }
}

- (void)pageView:(XZPageView *)pageView willEndTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    UIViewController *viewController = (UIViewController *)(view.nextResponder);
    
    if ([_delegate respondsToSelector:@selector(pageViewController:willEndTransitioningViewController:atIndex:animated:)]) {
        [_delegate pageViewController:self willEndTransitioningViewController:viewController atIndex:index animated:animated];
    }
    
    [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewWillDisappear) forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView didEndTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    UIViewController *viewController = (UIViewController *)(view.nextResponder);
    
    [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewDidDisappear) forViewController:viewController animated:animated];
    
    if ([_delegate respondsToSelector:@selector(pageViewController:didEndTransitioningViewController:atIndex:animated:)]) {
        [_delegate pageViewController:self didEndTransitioningViewController:viewController atIndex:index animated:animated];
    }
}

- (void)pageView:(XZPageView *)pageView didShowView:(nonnull UIView *)currentView atIndex:(NSInteger)currentIndex {
    UIViewController *viewController = (UIViewController *)[currentView nextResponder];
    
    if ([_delegate respondsToSelector:@selector(pageViewController:didShowViewController:atIndex:)]) {
        [_delegate pageViewController:self didShowViewController:viewController atIndex:currentIndex];
    }
}

- (void)pageView:(XZPageView *)pageView didTransition:(CGFloat)transition animated:(BOOL)animated {
    NSInteger const newIndex = pageView.currentIndex;
    if (_currentIndex == newIndex) {
        if (transition == 0) {
            if (_isTransitioning) { // 转场取消了。
                _isTransitioning = NO;
                [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewWillAppear) forViewController:_currentViewController animated:NO];
                [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewDidAppear) forViewController:_currentViewController animated:NO];
            }
        } else if (!_isTransitioning) {
            _isTransitioning = YES;
            [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewWillDisappear) forViewController:_currentViewController animated:animated];
        }
    } else {
        if (transition == 0) { // 页面切换完成。
            UIViewController *viewController = (UIViewController *)[[pageView viewForIndex:newIndex] nextResponder];
            
            _isTransitioning = NO;
            _currentIndex = newIndex;
            _currentViewController = viewController;
    
            [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewDidAppear) forViewController:viewController animated:animated];
        } else if (!_isTransitioning) {
            _isTransitioning = YES;
            [self _XZPageViewControllerForwardTransitionAppearance:(_XZTransitionViewWillDisappear) forViewController:_currentViewController animated:animated];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(pageViewController:didTransition:animated:)]) {
        [_delegate pageViewController:self didTransition:transition animated:animated];
    }
}

- (XZEdgeInsets)pageView:(XZPageView *)pageView edgeInsetsForGestureTransitioningView:(UIView *)view atIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pageViewController:edgeInsetsForGestureTransitionViewController:atIndex:)]) {
        return [_delegate pageViewController:self edgeInsetsForGestureTransitionViewController:(UIViewController *)[view nextResponder] atIndex:index];
    }
    return XZEdgeInsetsZero;
}

@end


#import <objc/runtime.h>

static const void * const _transitionAppearance = &_transitionAppearance;

static _XZTransitionAppearance _XZGetTransitionAppearance(UIViewController *viewController) {
    return objc_getAssociatedObject(viewController, _transitionAppearance);
}

static void _XZSetTransitionAppearance(UIViewController *viewController, _XZTransitionAppearance transitionAppearance) {
    objc_setAssociatedObject(viewController, _transitionAppearance, transitionAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
