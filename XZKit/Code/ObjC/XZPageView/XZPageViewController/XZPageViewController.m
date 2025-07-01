//
//  XZPageViewController.m
//  XZKit
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZPageViewController.h"
#import "XZPageViewContext.h"
#import "XZPageView.h"

typedef NSString *XZTransitionStage;
static XZTransitionStage viewWillAppear    = @"viewWillAppear";
static XZTransitionStage viewDidAppear     = @"viewDidAppear";
static XZTransitionStage viewWillDisappear = @"viewWillDisappear";
static XZTransitionStage viewDidDisappear  = @"viewDidDisappear";

/// 获取控制器生命周期阶段，返回 nil 表示控制器刚添加到 XZPageViewController 上或添加后从未参与生命周期切换。
static XZTransitionStage _Nullable GetTransitionStage(UIViewController * _Nonnull viewController);
/// 设置控制器所处的生命周期阶段，当控制器移出 XZPageViewController 请设置为 nil 。
static void SetTransitionStage(UIViewController * _Nonnull viewController, XZTransitionStage _Nullable transitionAppearance);

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
    BOOL              _isAnimatedStage;
}

@property (nonatomic, readonly) XZPageView *pageView;
@property (nonatomic, readonly, nullable) XZPageView *pageViewIfLoaded;

@end

@implementation XZPageViewController

- (XZPageView *)pageView {
    return (XZPageView *)[self view];
}

- (XZPageView *)pageViewIfLoaded {
    return (XZPageView *)[self viewIfLoaded];
}

- (void)loadView {
    self.view = [[XZPageView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _transitionStage = nil;

    XZPageView * const pageView = self.pageView;
    pageView.isLooped = NO;
    pageView.delegate = self;
    pageView.dataSource = self;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        XZTransitionStage const oldStage = GetTransitionStage(viewController);
        if (oldStage == viewWillAppear || oldStage == viewDidAppear) {
            continue;
        }
        [viewController beginAppearanceTransition:YES animated:animated];
        SetTransitionStage(viewController, viewWillAppear);
    }
    _transitionStage = viewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        XZTransitionStage const oldStage = GetTransitionStage(viewController);
        if (oldStage == viewWillAppear) {
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidAppear);
        } else if (oldStage != viewDidAppear) {
            [viewController beginAppearanceTransition:YES animated:NO];
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidAppear);
        }
    }
    _transitionStage = viewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (UIViewController * const viewController in self.childViewControllers) {
        XZTransitionStage const oldStage = GetTransitionStage(viewController);
        if (oldStage == viewWillDisappear || oldStage == viewDidDisappear) {
            continue;
        }
        [viewController beginAppearanceTransition:NO animated:animated];
        SetTransitionStage(viewController, viewWillDisappear);
    }
    _transitionStage = viewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (UIViewController *viewController in self.childViewControllers) {
        XZTransitionStage const oldStage = GetTransitionStage(viewController);
        if (oldStage == viewWillDisappear) {
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidDisappear);
        } else if (oldStage != nil && oldStage != viewDidDisappear) {
            [viewController beginAppearanceTransition:NO animated:NO];
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidDisappear);
        }
    }
    _transitionStage = viewDidDisappear;
}

- (UIViewController *)currentViewController {
    return (id)self.pageView.currentView.nextResponder;
}

- (UIViewController *)pendingViewController {
    return (id)self.pageView.pendingView.nextResponder;
}

- (void)reloadData {
    [self.pageView reloadData];
}

- (void)setDataSource:(id<XZPageViewControllerDataSource>)dataSource {
    if (_dataSource != dataSource) {
        self.pageViewIfLoaded.dataSource = nil;
        _dataSource = dataSource;
        self.pageViewIfLoaded.dataSource = self;
    }
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
    [self.pageView setCurrentPage:newPage animated:animated];
}

#pragma mark - DataSource

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return [_dataSource numberOfViewControllersInPageViewController:self];
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)reusingView {
    UIViewController * const viewController = [_dataSource pageViewController:self viewControllerForPageAtIndex:index];
    return viewController.view;
}

- (BOOL)pageView:(XZPageView *)pageView shouldReuseView:(__kindof UIView *)reusingView {
    return NO;
}

#pragma mark - Delegate

- (void)pageView:(XZPageView *)pageView willShowView:(UIView *)view animated:(BOOL)animated {
    UIViewController * const viewController = (UIViewController *)view.nextResponder;
    [self addChildViewController:viewController];
    [self forwardTransitionStage:viewWillAppear forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView didShowView:(UIView *)view animated:(BOOL)animated {
    UIViewController * const viewController = (UIViewController *)view.nextResponder;
    [viewController didMoveToParentViewController:self];
    [self forwardTransitionStage:viewDidAppear forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView willHideView:(UIView *)view animated:(BOOL)animated {
    UIViewController * const viewController = (UIViewController *)view.nextResponder;
    [viewController willMoveToParentViewController:nil];
    [self forwardTransitionStage:viewWillDisappear forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView didHideView:(UIView *)view animated:(BOOL)animated {
    UIViewController * const viewController = (UIViewController *)view.nextResponder;
    [viewController removeFromParentViewController];
    [self forwardTransitionStage:viewDidDisappear forViewController:viewController animated:animated];
}

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(pageViewController:didShowViewControllerAtIndex:)]) {
        [self.delegate pageViewController:self didShowViewControllerAtIndex:index];
    }
}

- (void)pageView:(XZPageView *)pageView didTurnPageInTransition:(CGFloat)transition {
    if ([self.delegate respondsToSelector:@selector(pageViewController:didTurnViewControllerInTransition:)]) {
        [self.delegate pageViewController:self didTurnViewControllerInTransition:transition];
    }
}

- (void)forwardTransitionStage:(XZTransitionStage const)newStage forViewController:(UIViewController * const)viewController animated:(BOOL)animated {
    // 只在 viewDidAppear 转发转场
    if (_transitionStage != viewDidAppear) {
        return;
    }
    XZTransitionStage const oldStage = GetTransitionStage(viewController);
    
    if (newStage == viewWillAppear) {
        if (oldStage == nil || oldStage == viewDidDisappear || oldStage == viewWillDisappear) {
            [viewController beginAppearanceTransition:YES animated:animated];
            SetTransitionStage(viewController, viewWillAppear);
        }
    } else if (newStage == viewDidAppear) {
        if (oldStage == viewWillAppear) {
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidAppear);
        } else if (oldStage == nil || oldStage == viewWillDisappear || oldStage == viewDidDisappear) {
            [viewController beginAppearanceTransition:YES animated:NO];
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidAppear);
        }
    } else if (newStage == viewWillDisappear) {
        if (oldStage == viewDidAppear || oldStage == viewWillAppear) {
            [viewController beginAppearanceTransition:NO animated:animated];
            SetTransitionStage(viewController, viewWillDisappear);
        }
    } else if (newStage == viewDidDisappear) {
        if (oldStage == viewWillAppear || oldStage == viewDidAppear) {
            [viewController beginAppearanceTransition:NO animated:NO];
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidDisappear);
        } else if (oldStage == viewWillDisappear) {
            [viewController endAppearanceTransition];
            SetTransitionStage(viewController, viewDidDisappear);
        }
    }
}

@end


#import <objc/runtime.h>

static const void * const _transitionAppearance = &_transitionAppearance;

static XZTransitionStage GetTransitionStage(UIViewController *viewController) {
    return objc_getAssociatedObject(viewController, _transitionAppearance);
}

static void SetTransitionStage(UIViewController *viewController, XZTransitionStage transitionAppearance) {
    objc_setAssociatedObject(viewController, _transitionAppearance, transitionAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
