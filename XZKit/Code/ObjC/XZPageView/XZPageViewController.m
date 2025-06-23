//
//  XZPageViewController.m
//  XZKit
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZPageViewController.h"
#import "XZPageViewContext.h"

typedef NSString *XZTransitionStage;
static XZTransitionStage viewWillAppear    = @"viewWillAppear";
static XZTransitionStage viewDidAppear     = @"viewDidAppear";
static XZTransitionStage viewWillDisappear = @"viewWillDisappear";
static XZTransitionStage viewDidDisappear  = @"viewDidDisappear";

/// 获取控制器生命周期阶段，返回 nil 表示控制器刚添加到 XZPageViewController 上或添加后从未参与生命周期切换。
static XZTransitionStage _Nullable getTransitionStatus(UIViewController * _Nonnull viewController);
/// 设置控制器所处的生命周期阶段，当控制器移出 XZPageViewController 请设置为 nil 。
static void setTransitionStatus(UIViewController * _Nonnull viewController, XZTransitionStage _Nullable transitionAppearance);

@interface XZPageViewController () {
    // 记录当前控制器
    UIViewController * __weak _currentViewController;
    // 记录转场过程中，将要出现的控制器。
    UIViewController * __weak _pendingViewController;
    /// 当前控制器的转场阶段。生命周期控制规则：
    /// XZPageViewController 在其生命周期方法内，将生命周期强制同步到其子控制器；
    /// 代理事件触发的子控制器的生命周期，除控制器移除外，其它的只在 XZPageViewController 处于 viewDidAppear 时才执行；
    /// 同时触发控制器方法时，都监测控制器当前的状态，如有需要，先转换状态，以保证不论控制器处于什么状态，都是以最后的状态为准。
    XZTransitionStage _transitionStage;
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
    
    _transitionStage = viewDidDisappear;

    XZPageView * const pageView = self.pageView;
    pageView.contentMode = UIViewContentModeScaleToFill;
    pageView.isLooped   = NO;
    pageView.delegate   = self;
    pageView.dataSource = self;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        XZTransitionStage const currentTransition = getTransitionStatus(viewController);
        if (currentTransition == viewWillAppear || currentTransition == viewDidAppear) {
            continue;
        }
        if (currentTransition != nil) {
            [viewController willMoveToParentViewController:self];
        }
        [viewController beginAppearanceTransition:YES animated:animated];
        setTransitionStatus(viewController, viewWillAppear);
    }
    _transitionStage = viewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_currentViewController != nil) {
        XZTransitionStage const currentTransition = getTransitionStatus(_currentViewController);
        if (currentTransition == viewWillAppear) {
            [_currentViewController endAppearanceTransition];
            [_currentViewController didMoveToParentViewController:self];
            setTransitionStatus(_currentViewController, viewDidAppear);
        } else if (currentTransition != viewDidAppear) {
            if (currentTransition != nil) {
                [_currentViewController willMoveToParentViewController:self];
            }
            [_currentViewController beginAppearanceTransition:YES animated:NO];
            [_currentViewController endAppearanceTransition];
            [_currentViewController didMoveToParentViewController:self];
            setTransitionStatus(_currentViewController, viewDidAppear);
        }
    }
    _transitionStage = viewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (UIViewController * const viewController in self.childViewControllers) {
        XZTransitionStage const currentTransition = getTransitionStatus(viewController);
        if (currentTransition == viewWillDisappear || currentTransition == viewDidDisappear) {
            continue;
        }
        if (currentTransition == nil) {
            [viewController willMoveToParentViewController:nil];
            continue;
        }
        [viewController willMoveToParentViewController:nil];
        [viewController beginAppearanceTransition:NO animated:animated];
        setTransitionStatus(viewController, viewWillDisappear);
    }
    _transitionStage = viewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        XZTransitionStage const currentTransition = getTransitionStatus(viewController);
        if (currentTransition == viewDidDisappear || currentTransition == nil ) {
            continue;
        }
        if (currentTransition == viewWillDisappear) {
            [viewController endAppearanceTransition];
            setTransitionStatus(viewController, viewDidDisappear);
            continue;
        }
        [viewController willMoveToParentViewController:nil];
        [viewController beginAppearanceTransition:NO animated:NO];
        [viewController endAppearanceTransition];
        setTransitionStatus(viewController, viewDidDisappear);
    }
    _transitionStage = viewDidDisappear;
}

- (void)reloadData {
    [self.pageView reloadData];
}

- (BOOL)isLooped {
    return self.pageView.isLooped;
}

- (void)setLooped:(BOOL)isLooped {
    self.pageView.isLooped = isLooped;
}

- (XZPageViewOrientation)orientation {
    return self.pageView.orientation;
}

- (void)setOrientation:(XZPageViewOrientation)orientation {
    self.pageView.orientation = orientation;
}

- (NSTimeInterval)autoPagingInterval {
    return self.pageView.autoPagingInterval;
}

- (void)setAutoPagingInterval:(NSTimeInterval)autoPagingInterval {
    self.pageView.autoPagingInterval = autoPagingInterval;
}

- (NSInteger)currentPage {
    return self.pageView.currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)newPage animated:(BOOL)animated {
    // 回调是异步的。
    [self.pageView setCurrentPage:newPage animated:animated completion:^(BOOL finished) {
        if (self->_pendingViewController == nil) {
            return;
        }
        if (self->_currentViewController) {
            [self forwardTransitionStage:viewDidDisappear forViewController:self->_currentViewController animated:animated];
        }
        self->_currentViewController = self->_pendingViewController;
        [self forwardTransitionStage:viewDidAppear forViewController:self->_currentViewController animated:animated];
        self->_pendingViewController = nil;
    }];
    
    // 检查是否翻页
    _pendingViewController = (id)self.pageView.currentView.nextResponder;
    if (_currentViewController == _pendingViewController) {
        _pendingViewController = nil;
        return;
    }
    
    // 发送事件
    if (_currentViewController) {
        [self forwardTransitionStage:viewWillDisappear forViewController:_currentViewController animated:animated];
    }
    [self forwardTransitionStage:viewWillAppear forViewController:_pendingViewController animated:animated];
}

#pragma mark - DataSource

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return [_dataSource numberOfViewControllersInPageViewController:self];
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)reusingView {
    UIViewController *viewController = [_dataSource pageViewController:self viewControllerForPageAtIndex:index];
    [self addChildViewController:viewController];
    return viewController.view;
}

- (nullable UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(nonnull __kindof UIView *)reusingView {
    UIViewController *viewController = (UIViewController *)[reusingView nextResponder];
    [viewController removeFromParentViewController];
    return nil;
}

#pragma mark - Delegate

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    UIViewController * const viewController = (UIViewController *)[pageView.currentView nextResponder];
    
    if (_currentViewController) {
        [self forwardTransitionStage:(viewDidDisappear) forViewController:_currentViewController animated:YES];
    }
    
    if (viewController == _pendingViewController) {
        _currentViewController = viewController;
        [self forwardTransitionStage:(viewDidAppear) forViewController:_currentViewController animated:YES];
    } else {
        [self forwardTransitionStage:(viewWillAppear) forViewController:viewController animated:NO];
        _currentViewController = viewController;
        [self forwardTransitionStage:(viewDidAppear) forViewController:_currentViewController animated:NO];
    }
    
    _pendingViewController = nil;
    
    if ([_delegate respondsToSelector:@selector(pageViewController:didShowViewControllerAtIndex:)]) {
        [_delegate pageViewController:self didShowViewControllerAtIndex:pageView.currentPage];
    }
}

- (void)pageView:(XZPageView *)pageView didTurnPageToView:(UIView *)nextView inTransition:(CGFloat)transition {
    UIViewController * const nextViewController = (id)nextView.nextResponder;
    
    if (_pendingViewController == nil) {
        [self forwardTransitionStage:(viewWillDisappear) forViewController:_currentViewController animated:YES];
        _pendingViewController = nextViewController;
        [self forwardTransitionStage:(viewWillAppear) forViewController:_pendingViewController animated:YES];
    } else if (_pendingViewController != nextViewController) {
        [self forwardTransitionStage:(viewDidDisappear) forViewController:_pendingViewController animated:YES];
        _pendingViewController = nextViewController;
        [self forwardTransitionStage:(viewWillAppear) forViewController:_pendingViewController animated:YES];
    } else {
        // 持续转场中
    }
    
    if ([_delegate respondsToSelector:@selector(pageViewController:didTurnViewController:inTransition:)]) {
        [_delegate pageViewController:self didTurnViewController:_pendingViewController inTransition:transition];
    }
}

- (void)forwardTransitionStage:(nonnull XZTransitionStage const)transitionAppearance forViewController:(UIViewController * const)viewController animated:(BOOL)animated {
    if (transitionAppearance == viewWillAppear) {
        if (_transitionStage == viewDidAppear || _transitionStage == viewWillAppear) {
            // 当前控制器处于 viewDidAppear/viewWillAppear 状态，才向控制器发送或补发 viewWillAppear 事件。
            XZTransitionStage const currentTransition = getTransitionStatus(viewController);
            if (currentTransition == nil) {
                [viewController beginAppearanceTransition:YES animated:animated];
                setTransitionStatus(viewController, viewWillAppear);
            } else if (currentTransition == viewDidDisappear) {
                // 控制器未显示，发送事件。
                [viewController willMoveToParentViewController:self];
                [viewController beginAppearanceTransition:YES animated:animated];
                setTransitionStatus(viewController, viewWillAppear);
            } else if (currentTransition == viewDidAppear || currentTransition == viewWillAppear) {
                // 控制器将要或者已经显示，不需要操作。
            } else {
                // 控制器将要消失。
                [viewController willMoveToParentViewController:self];
                [viewController beginAppearanceTransition:YES animated:animated];
                setTransitionStatus(viewController, viewWillAppear);
            }
        }
        return;
    }
    
    if (transitionAppearance == viewDidAppear) {
        if (_transitionStage == viewDidAppear) {
            // 当前控制器处于 viewDidAppear 状态，才向控制器发送 viewDidAppear 事件。
            XZTransitionStage const currentTransition = getTransitionStatus(viewController);
            if (currentTransition == viewDidAppear) {
                // 控制器已经是 viewDidAppear 状态，不需要处理。
            } else if (currentTransition == viewWillAppear) {
                // 当前为 viewWillAppear 状态，正常情况下的状态。
                [viewController endAppearanceTransition];
                [viewController didMoveToParentViewController:self];
                setTransitionStatus(viewController, viewDidAppear);
            } else {
                if (currentTransition != nil) {
                    [viewController willMoveToParentViewController:self];
                }
                [viewController beginAppearanceTransition:YES animated:NO];
                [viewController endAppearanceTransition];
                [viewController didMoveToParentViewController:self];
                setTransitionStatus(viewController, viewDidAppear);
            }
        }
        return;
    }
    
    if (transitionAppearance == viewWillDisappear) {
        if (_transitionStage == viewDidAppear || _transitionStage == viewWillDisappear) {
            // 当前控制器处于 viewDidAppear/viewWillDisappear 状态，才向控制器发送或补发 viewWillDisappear 事件。
            XZTransitionStage const currentTransition = getTransitionStatus(viewController);
            if (currentTransition == viewDidAppear) {
                [viewController willMoveToParentViewController:nil];
                [viewController beginAppearanceTransition:NO animated:animated];
                setTransitionStatus(viewController, viewWillDisappear);
            } else if (currentTransition == viewWillDisappear || currentTransition == viewDidDisappear || currentTransition == nil) {
                // 已经是该状态，不需要处理。
            } else {
                // 将要出现的状态。
                [viewController willMoveToParentViewController:nil];
                [viewController beginAppearanceTransition:NO animated:animated];
                setTransitionStatus(viewController, viewWillDisappear);
            }
        }
        return;
    }
    
    if (transitionAppearance == viewDidDisappear) {
        // 控制器被移除。
        XZTransitionStage const currentTransition = getTransitionStatus(viewController);
        if (currentTransition == nil) {
            // 已经 viewDidDisappear 就不需要操作了。
            [viewController willMoveToParentViewController:nil];
        } else if (currentTransition == viewDidDisappear) {
            setTransitionStatus(viewController, nil);
        } else if (currentTransition == viewWillDisappear) {
            // 正常情况下。
            [viewController endAppearanceTransition];
            setTransitionStatus(viewController, nil);
        } else if (currentTransition == viewDidAppear || currentTransition == viewWillAppear) {
            [viewController willMoveToParentViewController:nil];
            [viewController beginAppearanceTransition:NO animated:NO];
            [viewController endAppearanceTransition];
            setTransitionStatus(viewController, nil);
        }
        return;
    }
}

@end


#import <objc/runtime.h>

static const void * const _transitionAppearance = &_transitionAppearance;

static XZTransitionStage getTransitionStatus(UIViewController *viewController) {
    return objc_getAssociatedObject(viewController, _transitionAppearance);
}

static void setTransitionStatus(UIViewController *viewController, XZTransitionStage transitionAppearance) {
    objc_setAssociatedObject(viewController, _transitionAppearance, transitionAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
