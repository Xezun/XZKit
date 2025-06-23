//
//  XZPageViewContext.m
//  XZPageView
//
//  Created by Xezun on 2024/9/24.
//

#import "XZPageViewContext.h"
#import "XZPageViewExtension.h"
@import ObjectiveC;
#if __has_include(<XZDefines/XZRuntime.h>)
#import <XZDefines/XZRuntime.h>
#import <XZDefines/XZMacros.h>
#else
#import "XZRuntime.h"
#import "XZMacros.h"
#endif

@interface XZPageViewVerticalContext : XZPageViewContext

@end

@implementation XZPageViewContext

+ (XZPageViewContext *)contextWithPageView:(XZPageView *)pageView orientation:(XZPageViewOrientation)orientation {
    switch (orientation) {
        case XZPageViewOrientationHorizontal: {
            return [[XZPageViewContext alloc] initWithPageView:pageView];
            break;
        }
        case XZPageViewOrientationVertical: {
            return [[XZPageViewVerticalContext alloc] initWithPageView:pageView];
            break;
        }
        default: {
            NSString *reason = [NSString stringWithFormat:@"参数 orientation=%ld 不是合法的枚举值", (long)orientation];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
            break;
        }
    }
}

- (instancetype)initWithPageView:(XZPageView *)pageView {
    self = [super init];
    if (self) {
        _pageView = pageView;
    }
    return self;
}

- (XZPageViewOrientation)orientation {
    return XZPageViewOrientationHorizontal;
}

- (void)layoutSubviews:(const CGRect)bounds {
    // 布局子视图
    [self layoutCurrentPageView:bounds];
    [self layoutReusingPageView:bounds];
    // 重新配置 _scrollView
    _pageView.contentSize = bounds.size;
    [self adjustContentInsets:bounds];
}

- (void)reloadCurrentPageView:(CGRect const)bounds {
    NSInteger const currentPage = _pageView->_currentPage;
    UIView *  const oldView     = _pageView->_currentView;
    
    // 进入备用状态，从 window 移除；当再次重用时，需要重新添加到 window 上
    [oldView removeFromSuperview];
    
    // 没有数据时，如果有当前页，则进入备用状态。
    if (currentPage == NSNotFound) {
        if (oldView != nil) {
            _pageView->_currentView = [_pageView.dataSource pageView:_pageView prepareForReusingView:oldView];
        }
        return;
    }
    
    UIView * const newView = [_pageView.dataSource pageView:_pageView viewForPageAtIndex:currentPage reusingView:oldView];
    [_pageView addSubview:newView];
    _pageView->_currentView = newView;
}

- (void)reloadReusingPageView:(CGRect const)bounds {
    NSInteger const reusingPage = _pageView->_reusingPage;
    UIView *  const oldView     = _pageView->_reusingView;
    
    [oldView removeFromSuperview];
    
    // 没有数据，备用视图进入备用状态。
    if (reusingPage == NSNotFound) {
        if (oldView != nil) {
            _pageView->_reusingView = [_pageView.dataSource pageView:_pageView prepareForReusingView:oldView];
        }
        return;
    }
    
    UIView * const newView = [_pageView.dataSource pageView:_pageView viewForPageAtIndex:reusingPage reusingView:oldView];
    [_pageView addSubview:newView];
    _pageView->_reusingView = newView;
}

- (void)scheduleAutoPagingTimerIfNeeded {
    if (_pageView->_numberOfPages <= 1 || _pageView.window == nil || _pageView->_autoPagingInterval <= 0) {
        // 不满足计时器启动条件，销毁当前计时器。
        [_pageView->_autoPagingTimer invalidate];
        _pageView->_autoPagingTimer = nil;
    } else {
        NSTimeInterval const timeInterval = _pageView->_autoPagingInterval + XZPageViewAnimationDuration;
        if (_pageView->_autoPagingTimer.timeInterval != timeInterval) {
            [_pageView->_autoPagingTimer invalidate];
            _pageView->_autoPagingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(autoPagingTimerAction:) userInfo:nil repeats:YES];
        }
        // 定时器首次触发的时间
        _pageView->_autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (void)autoPagingTimerAction:(NSTimer *)timer {
    NSInteger const newPage = XZLoopPage(_pageView->_currentPage, YES, _pageView->_numberOfPages - 1, YES);
    [self setCurrentPage:newPage animated:YES completion:nil];

    // 自动翻页，发送事件
    XZCallBlock(_pageView->_didShowPage, _pageView, _pageView->_currentPage);
}

- (void)freezeAutoPagingTimer {
    if (_pageView->_autoPagingTimer != nil) {
        _pageView->_autoPagingTimer.fireDate = NSDate.distantFuture;
    }
}

- (void)resumeAutoPagingTimer {
    if (_pageView->_autoPagingTimer != nil) {
        _pageView->_autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_pageView->_autoPagingInterval];
    }
}

- (void)handleDelegateOfClass:(Class)aClass {
    if ([aClass isSubclassOfClass:[XZPageView class]]) {
        return;
    }
    
    static const void * const _isHandled = &_isHandled;
    if (!objc_getAssociatedObject(aClass, _isHandled)) {
        objc_setAssociatedObject(aClass, _isHandled, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        {
            typedef void (*MethodType)(XZPageViewContext *, SEL, UIScrollView *);
            SEL          const sel   = @selector(scrollViewDidScroll:);
            MethodType   const imp   = (MethodType)method_getImplementation(class_getInstanceMethod([XZPageViewContext class], sel));
            const char * const types = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), sel, NO, YES).types;
            xz_objc_class_addMethodWithBlock(aClass, sel, types, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
            }, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass(aClass)
                };
                ((void(*)(struct objc_super *, SEL, UIScrollView *))objc_msgSendSuper)(&super, sel, scrollView);
            }, ^id _Nonnull(SEL  _Nonnull selector) {
                return ^(id self, XZPageView *scrollView) {
                    if ([scrollView isKindOfClass:[XZPageView class]]) {
                        imp(scrollView->_context, sel, scrollView);
                    }
                    ((void(*)(id, SEL, UIScrollView *))objc_msgSend)(self, selector, scrollView);
                };
            });
        }
        
        {
            typedef void (*MethodType)(XZPageViewContext *, SEL, UIScrollView *);
            SEL          const sel   = @selector(scrollViewWillBeginDragging:);
            MethodType   const imp   = (MethodType)method_getImplementation(class_getInstanceMethod([XZPageViewContext class], sel));
            const char * const types = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), sel, NO, YES).types;
            xz_objc_class_addMethodWithBlock(aClass, sel, types, ^(id<UIScrollViewDelegate> self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
            }, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass(aClass)
                };
                ((void(*)(struct objc_super *, SEL, UIScrollView *))objc_msgSendSuper)(&super, sel, scrollView);
            }, ^id _Nonnull(SEL  _Nonnull selector) {
                return ^(id self, XZPageView *scrollView) {
                    if ([scrollView isKindOfClass:[XZPageView class]]) {
                        imp(scrollView->_context, sel, scrollView);
                    }
                    ((void(*)(id, SEL, UIScrollView *))objc_msgSend)(self, selector, scrollView);
                };
            });
        }
        
        {
            typedef void (*MethodType)(XZPageViewContext *, SEL, UIScrollView *, BOOL);
            SEL          const sel   = @selector(scrollViewDidEndDragging:willDecelerate:);
            MethodType   const imp   = (MethodType)method_getImplementation(class_getInstanceMethod([XZPageViewContext class], sel));
            const char * const types = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), sel, NO, YES).types;
            xz_objc_class_addMethodWithBlock(aClass, sel, types, ^(id self, XZPageView *scrollView, BOOL decelerate) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView, decelerate);
                }
            }, ^(id self, XZPageView *scrollView, BOOL decelerate) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView, decelerate);
                }
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass(aClass)
                };
                ((void(*)(struct objc_super *, SEL, UIScrollView *, BOOL))objc_msgSendSuper)(&super, sel, scrollView, decelerate);
            }, ^id _Nonnull(SEL  _Nonnull selector) {
                return ^(id self, XZPageView *scrollView, BOOL decelerate) {
                    if ([scrollView isKindOfClass:[XZPageView class]]) {
                        imp(scrollView->_context, sel, scrollView, decelerate);
                    }
                    ((void(*)(id, SEL, UIScrollView *, BOOL))objc_msgSend)(self, selector, scrollView, decelerate);
                };
            });
        }
        
        {
            typedef void (*MethodType)(XZPageViewContext *, SEL, UIScrollView *);
            SEL          const sel   = @selector(scrollViewDidEndDecelerating:);
            MethodType   const imp   = (MethodType)method_getImplementation(class_getInstanceMethod([XZPageViewContext class], sel));
            const char * const types = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), sel, NO, YES).types;
            xz_objc_class_addMethodWithBlock(aClass, sel, types, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
            }, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass(aClass)
                };
                ((void(*)(struct objc_super *, SEL, UIScrollView *))objc_msgSendSuper)(&super, sel, scrollView);
            }, ^id _Nonnull(SEL  _Nonnull selector) {
                return ^(id self, XZPageView *scrollView) {
                    if ([scrollView isKindOfClass:[XZPageView class]]) {
                        imp(scrollView->_context, sel, scrollView);
                    }
                    ((void(*)(id, SEL, UIScrollView *))objc_msgSend)(self, selector, scrollView);
                };
            });
        }
        
        {
            typedef void (*MethodType)(XZPageViewContext *, SEL, UIScrollView *);
            SEL          const sel   = @selector(scrollViewDidEndScrollingAnimation:);
            MethodType   const imp   = (MethodType)method_getImplementation(class_getInstanceMethod([XZPageViewContext class], sel));
            const char * const types = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), sel, NO, YES).types;
            xz_objc_class_addMethodWithBlock(aClass, sel, types, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
            }, ^(id self, XZPageView *scrollView) {
                if ([scrollView isKindOfClass:[XZPageView class]]) {
                    imp(scrollView->_context, sel, scrollView);
                }
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass(aClass)
                };
                ((void(*)(struct objc_super *, SEL, UIScrollView *))objc_msgSendSuper)(&super, sel, scrollView);
            }, ^id _Nonnull(SEL  _Nonnull selector) {
                return ^(id self, XZPageView *scrollView) {
                    if ([scrollView isKindOfClass:[XZPageView class]]) {
                        imp(scrollView->_context, sel, scrollView);
                    }
                    ((void(*)(id, SEL, UIScrollView *))objc_msgSend)(self, selector, scrollView);
                };
            });
        }
    }
    
    [self notifyDelegateOfClass:aClass];
}

- (void)notifyDelegateOfClass:(Class)aClass {
    [self notifyDidShowPage:aClass];
    [self notifyDidTurnPage:aClass];
}

/// - Attention: 调用次方法前已判断 aClass 遵循 XZPageViewDelegate 协议。
- (void)notifyDidShowPage:(nonnull Class)aClass {
    typedef void (*MethodType)(id<XZPageViewDelegate>, SEL, XZPageView *, NSInteger);
    _pageView->_didShowPage = nil;
    
    SEL const selector = @selector(pageView:didShowPageAtIndex:);
    if (![aClass instancesRespondToSelector:selector]) {
        return;
    }
    
    MethodType const didShowPage = (MethodType)method_getImplementation(class_getInstanceMethod(aClass, selector));
    if (didShowPage == NULL) return;
    
    _pageView->_didShowPage = ^(XZPageView * const self, NSInteger currentPage) {
        id const delegate = self.delegate;
        if (delegate == nil || delegate == self) return;
        didShowPage(delegate, selector, self, currentPage);
    };
}

/// - Attention: 调用次方法前已判断 aClass 遵循 XZPageViewDelegate 协议。
- (void)notifyDidTurnPage:(nonnull Class)aClass {
    typedef void (*MethodType)(id<XZPageViewDelegate>, SEL, XZPageView *, CGFloat);
    _pageView->_didTurnPage = nil;
    
    SEL const selector = @selector(pageView:didTurnPageInTransition:);
    if (![aClass instancesRespondToSelector:selector]) {
        return;
    }
    
    MethodType const didTurnPage = (MethodType)method_getImplementation(class_getInstanceMethod(aClass, selector));
    if (didTurnPage == NULL) return;
    
    _pageView->_didTurnPage = ^(XZPageView * const self, CGFloat x, CGFloat width) {
        id const delegate = self.delegate;
        if (delegate == nil || delegate == self) return;
        CGFloat const transition = x / width;
        // 一次翻多页的情况，在当前设计模式下不存在。
        // 如果有，可以根据 transition 的正负判断翻页方向，再根据 fromPage 和 toPage 以及它们之差，计算出翻页进度。
        didTurnPage(delegate, selector, self, transition);
    };
}

// 子类重写的方法

- (void)layoutCurrentPageView:(CGRect const)bounds {
    _pageView->_currentView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (void)layoutReusingPageView:(CGRect const)bounds {
    switch (_pageView.effectiveUserInterfaceLayoutDirection) {
        case UIUserInterfaceLayoutDirectionRightToLeft: {
            CGFloat const x = (_pageView->_reusingPageDirection ? -bounds.size.width : +bounds.size.width);
            _pageView->_reusingView.frame = CGRectMake(x, 0, bounds.size.width, bounds.size.height);
            break;
        }
        case UIUserInterfaceLayoutDirectionLeftToRight:
        default: {
            CGFloat const x = (_pageView->_reusingPageDirection ? +bounds.size.width : -bounds.size.width);
            _pageView->_reusingView.frame = CGRectMake(x, 0, bounds.size.width, bounds.size.height);
            break;
        }
    }
}

/// 调整 contentInset 以适配 currentPage 和 isLooped 状态。
/// @note 仅在需要调整 contentInset 的地方调用此方法。
- (void)adjustContentInsets:(CGRect const)bounds {
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (_pageView->_numberOfPages <= 1) {
        // 只有一个 page 不可滚动。
    } else if (_pageView->_isLooped) {
        // 循环模式下，可左右滚动，设置左右边距作为滚动区域。
        newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, bounds.size.width);
    } else if (_pageView->_currentPage == 0) {
        // 非循环模式下，展示第一页时，不能向后滚动。
        switch (_pageView.effectiveUserInterfaceLayoutDirection) {
            case UIUserInterfaceLayoutDirectionRightToLeft:
                newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, 0);
                break;
            case UIUserInterfaceLayoutDirectionLeftToRight:
            default:
                newInsets = UIEdgeInsetsMake(0, 0, 0, bounds.size.width);
                break;
        }
    } else if (_pageView->_currentPage == _pageView->_numberOfPages - 1) {
        // 非循环模式下，展示最后一页时，不能向前滚动。
        switch (_pageView.effectiveUserInterfaceLayoutDirection) {
            case UIUserInterfaceLayoutDirectionRightToLeft:
                newInsets = UIEdgeInsetsMake(0, 0, 0, bounds.size.width);
                break;
            case UIUserInterfaceLayoutDirectionLeftToRight:
            default:
                newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, 0);
                break;
        }
    } else {
        // 非循环模式下，展示的不是第一页，也不是最后一页，可以前后滚动。
        newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, bounds.size.width);
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(newInsets, _pageView.contentInset)) {
        return;
    }
    
    // 使用 setBounds 不会触发 didScroll 事件。
    // 重置到原点，避免 contentInset 触发 didScroll 事件，影响其它逻辑
    [_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    _pageView.contentInset = newInsets;
    [_pageView setBounds:bounds];
}

/// 发生滚动
- (void)didScroll:(BOOL)stopped {
    CGRect  const bounds  = _pageView.bounds;
    CGSize  const size    = bounds.size;
    CGFloat const offsetX = bounds.origin.x;
    
    // 只有一张图时，只有原点是合法位置
    if (_pageView->_numberOfPages <= 1) {
        if (stopped && offsetX != 0) {
            [_pageView setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 还在原点时，不需要处理
    if (offsetX == 0) {
        return;
    }
    
    BOOL      const isLTR       = (_pageView.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight);
    NSInteger const maxPage     = _pageView->_numberOfPages - 1;
    BOOL      const direction   = isLTR ? offsetX > 0 : offsetX < 0;
    NSInteger const pendingPage = XZLoopPage(_pageView->_currentPage, direction, maxPage, _pageView->_isLooped);
    
    // 没有目标页面，就不需要处理加载及翻页了。
    if (pendingPage == NSNotFound) {
        if (stopped) {
            // 停止在非页面位置，自动归位
            [_pageView setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 检查当前预加载的视图是否正确
    if (_pageView->_reusingPage != pendingPage) {
        _pageView->_reusingPage = pendingPage;
        _pageView->_reusingPageDirection = direction;
        [self reloadReusingPageView:bounds];
        [self layoutReusingPageView:bounds];
    } else if (direction != _pageView->_reusingPageDirection) {
        _pageView->_reusingPageDirection = direction;
        [self layoutReusingPageView:bounds];
    }
    
    // @discussion
    // 当页面宽度不是整数时，比如 370.1 点，UIScrollView 会使用 370.0 点进行翻页，
    // 页面停止滚动时，滚动距离不足一个页面宽度，从而被认定为没有翻页，但是对于用户来说，从视觉上来讲，却已经完成了翻页。
    // 幸好的是，在这种情形下，由于页面位置十分接近，即使再次滚动修正位置，对实际体验也无影响。
    // 因此，我们需要监听停止滚动的方法，并在停止滚动时，对页面状态进行检测。
    // @discussion
    // 理论上在减速前，即 -scrollViewWillEndDragging:withVelocity:targetContentOffset: 方法中，
    // 检测停止时能否满足翻页效果更好，但是这个方法在 iOS 14 以下系统中存在BUG，
    // 参数 targetContentOffset 的值，可能并非不是最终停止的位置，似乎未进行像素取整。
    // 另外，在代理方法中，修改 targetContentOffset 不会结束原有的减速效果，
    // 而调用 -setContentOffset:animated: 方法修正位置，需要需要异步才能生效。
    
    CGFloat const PageWidth = size.width;
    
    // 滚动满足一页
    if (offsetX <= -PageWidth || offsetX >= +PageWidth) {
        // 执行翻页：_currentPage 与 _reusingPage 交换
        [self didScrollToReusingPage:bounds maxPage:maxPage direction:direction];
        
        // 用户翻页，发送代理事件：中间已经展示的是当前页内容，但是 offset 未修改。
        // 此时已经完成翻页，直接发送了 show 事件，而没有转场进度 100% 的事件。
        // 1、即使发送进度 100% 的事件，事件也会被 show 事件所覆盖，因为这两个事件是串行的。
        // 2、此时，新页面可能已经进入转场，旧页面应该属于退场状态。
        XZCallBlock(_pageView->_didShowPage, _pageView, _pageView->_currentPage);
        
        // 恢复翻页前的展示位置，如果 x 不为零，会加载下一页，并发送转场进度
        CGFloat const x = fmod(offsetX, PageWidth);
        // 不能使用 setContentOffset:animated:NO 方法，会触发 scrollViewDidEndDecelerating 代理方法
        _pageView.contentOffset = CGPointMake(x, 0);
        return;
    }
    
    // 滚动不足一页
    
    // 滚动已停止，且不足一页：检查翻页情况。
    // @discussion
    // 在某些极端情况下，可能会发生，翻页停在中间的情况。
    if (stopped) {
        if (PageWidth - offsetX < 1.0 || -PageWidth - offsetX > -1.0) {
            // 小于一个点，可能是因为 width 不是整数，翻页宽度与 width 不一致，认为翻页完成
            XZLog(@"翻页修复：停止滚动，距翻页不足一个点，%@", NSStringFromCGRect(bounds));
            [self didScrollToReusingPage:bounds maxPage:maxPage direction:direction];
            XZCallBlock(_pageView->_didShowPage, _pageView, _pageView->_currentPage);
            // 这里不取模，认为是正好完成翻页
            _pageView.contentOffset = CGPointZero;
        } else {
            // 发送转场进度
            XZCallBlock(_pageView->_didTurnPage, _pageView, offsetX, PageWidth);
            // 滚动停止，滚动未过半，不执行翻页，退回原点，否则执行翻页
            CGFloat const halfPageWidth = PageWidth * 0.5;
            if (offsetX >= +halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向右滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointMake(PageWidth, 0) animated:YES];
            } else if (offsetX <= -halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向左滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointMake(-PageWidth, 0) animated:YES];
            } else {
                // 滚动未超过一半，不翻页，回到原点
                XZLog(@"翻页修复：停止滚动，滚动距离未超过一半，不翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointZero animated:YES];
            }
        }
    } else {
        // 发送转场进度
        XZCallBlock(_pageView->_didTurnPage, _pageView, offsetX, PageWidth);
    }
}

- (void)didScrollToReusingPage:(CGRect const)bounds maxPage:(NSInteger const)maxPage direction:(BOOL const)direction {
    XZExchangeValue(_pageView->_currentPage, _pageView->_reusingPage);
    XZExchangeValue(_pageView->_currentView, _pageView->_reusingView);
    
    [self layoutCurrentPageView:bounds];
    _pageView->_reusingPageDirection = !direction;
    [self layoutReusingPageView:bounds];
    
    // 调整 contentInset
    [self adjustContentInsets:bounds];
}

/// 本方法不发送事件。
- (void)setCurrentPage:(NSInteger const)newPage animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion {
    if (_pageView->_currentPage == newPage) {
        dispatch_main_async(completion, NO);
        return;
    }
    NSParameterAssert(newPage >= 0 && newPage < _pageView->_numberOfPages);
    
    // 动画思路：
    // 1、将目标加载到 reusingPage 上，并计算从 currentPage 到 reusingPage 的滚动方向。
    // 2、将 reusingPage 与 currentPage 互换，然后按照滚动方向，调整它们的位置，然后将窗口移动到原始视图。
    // 3、然后执行动画到目标视图。
    
    CGRect    const bounds  = _pageView.bounds;
    NSInteger const maxPage = _pageView->_numberOfPages - 1;
    
    [UIView performWithoutAnimation:^{
        // 加载目标视图
        if (_pageView->_reusingPage != newPage) {
            _pageView->_reusingPage = newPage;
            [self reloadReusingPageView:bounds];
        }
        
        // 关于滚动方向
        // 从 A => B 的滚动方向，并不一定与 B => A 相反，所以为了保证滚动方向不变，
        // 使用从 current 到 reusing 的滚动方向的反向，而不是直接计算从 reusing 到 current 的方向。
        _pageView->_reusingPageDirection = !XZScrollDirection(_pageView->_currentPage, _pageView->_reusingPage, maxPage, _pageView->_isLooped);
        
        // 交换值并布局
        XZExchangeValue(_pageView->_currentPage, _pageView->_reusingPage);
        XZExchangeValue(_pageView->_currentView, _pageView->_reusingView);
        [self layoutCurrentPageView:bounds];
        [self layoutReusingPageView:bounds];
        
        // 根据当前情况调整边距，因为可能会因此 didScroll 事件，所以先将位置重置到原点，这样即使触发事件，也不影响。
        [self adjustContentInsets:bounds];
        
        // 如果需要展示动画的话，先恢复显示内容
        if (animated) {
            // offset.x 实际上就是 currentPage 的偏移，由于 currentPage 已经交换为 reusingPage 所以可以直接通过偏移计算目标位置
            CGFloat const x = _pageView->_reusingView.frame.origin.x + bounds.origin.x;
            [_pageView setBounds:CGRectMake(x, bounds.origin.y, bounds.size.width, bounds.size.height)];
        }
    }];
    
    if (animated) {
        // 动画到当前视图上。
        // 修改 bounds 不会触发 -scrollViewDidScroll: 方法，但是会触发 -layoutSubviews 方法。
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
            [self->_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        } completion:completion];
    } else {
        [_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        dispatch_main_async(completion, YES);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _pageView) {
        return;
    }
    [self didScroll:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != _pageView) {
        return;
    }
    
    if (_pageView->_numberOfPages <= 1) {
        return;
    }
    
    // 用户操作，暂停计时器
    [self freezeAutoPagingTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != _pageView) {
        return;
    }
    
    // 用户停止操作，恢复计时器
    if (_pageView->_numberOfPages > 1) {
        [self resumeAutoPagingTimer];
    }
    
    // 检查翻页：用户停止操作
    if (decelerate) {
        return; // 进入减速状态，在减速停止后再决定
    }
    
    // 直接停止滚动了。
    [self didScroll:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _pageView) {
        return;
    }
    [self didScroll:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != _pageView) {
        return;
    }
    [self didScroll:YES];
}

@end


@implementation XZPageViewVerticalContext

- (XZPageViewOrientation)orientation {
    return XZPageViewOrientationVertical;
}

- (void)layoutCurrentPageView:(CGRect const)bounds {
    _pageView->_currentView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (void)layoutReusingPageView:(CGRect const)bounds {
    CGFloat const y = (_pageView->_reusingPageDirection ? +bounds.size.height : -bounds.size.height);
    _pageView->_reusingView.frame = CGRectMake(0, y, bounds.size.width, bounds.size.height);
}

/// 调整 contentInset 以适配 currentPage 和 isLooped 状态。
/// @note 仅在需要调整 contentInset 的地方调用此方法。
- (void)adjustContentInsets:(CGRect const)bounds {
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (_pageView->_numberOfPages <= 1) {
        // 只有一个 page 不可滚动。
    } else if (_pageView->_isLooped) {
        // 循环模式下，可左右滚动，设置左右边距作为滚动区域。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, bounds.size.height, 0);
    } else if (_pageView->_currentPage == 0) {
        // 非循环模式下，展示第一页时，不能向下滚动。
        newInsets = UIEdgeInsetsMake(0, 0, bounds.size.height, 0);
    } else if (_pageView->_currentPage == _pageView->_numberOfPages - 1) {
        // 非循环模式下，展示最后一页时，不能向上滚动。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, 0, 0);
    } else {
        // 非循环模式下，展示的不是第一页，也不是最后一页，可以前后滚动。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, bounds.size.height, 0);
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(newInsets, _pageView.contentInset)) {
        return;
    }
    
    // 使用 setBounds 不会触发 didScroll 事件。
    // 重置到原点，避免 contentInset 触发 didScroll 事件，影响其它逻辑
    [_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    _pageView.contentInset = newInsets;
    [_pageView setBounds:bounds];
}

/// 发生滚动
- (void)didScroll:(BOOL)stopped animated:(BOOL)animated {
    CGRect  const bounds  = _pageView.bounds;
    CGSize  const size    = bounds.size;
    CGFloat const offsetY = bounds.origin.y;
    
    // 只有一张图时，只有原点是合法位置
    if (_pageView->_numberOfPages <= 1) {
        if (stopped && offsetY != 0) {
            [_pageView setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 还在原点时，不需要处理
    if (offsetY == 0) {
        return;
    }
    
    NSInteger const maxPage     = _pageView->_numberOfPages - 1;
    BOOL      const direction   = offsetY > 0;
    NSInteger const pendingPage = XZLoopPage(_pageView->_currentPage, direction, maxPage, _pageView->_isLooped);
    
    // 没有目标页面，就不需要处理加载及翻页了。
    if (pendingPage == NSNotFound) {
        if (stopped) {
            // 停止在非页面位置，自动归位
            [_pageView setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 检查当前预加载的视图是否正确
    if (_pageView->_reusingPage != pendingPage) {
        _pageView->_reusingPage = pendingPage;
        _pageView->_reusingPageDirection = direction;
        [self reloadReusingPageView:bounds];
        [self layoutReusingPageView:bounds];
    } else if (direction != _pageView->_reusingPageDirection) {
        _pageView->_reusingPageDirection = direction;
        [self layoutReusingPageView:bounds];
    }
    
    // @discussion
    // 当页面宽度不是整数时，比如 370.1 点，UIScrollView 会使用 370.0 点进行翻页，
    // 页面停止滚动时，滚动距离不足一个页面宽度，从而被认定为没有翻页，但是对于用户来说，从视觉上来讲，却已经完成了翻页。
    // 幸好的是，在这种情形下，由于页面位置十分接近，即使再次滚动修正位置，对实际体验也无影响。
    // 因此，我们需要监听停止滚动的方法，并在停止滚动时，对页面状态进行检测。
    // @discussion
    // 理论上在减速前，即 -scrollViewWillEndDragging:withVelocity:targetContentOffset: 方法中，
    // 检测停止时能否满足翻页效果更好，但是这个方法在 iOS 14 以下系统中存在BUG，
    // 参数 targetContentOffset 的值，可能并非不是最终停止的位置，似乎未进行像素取整。
    // 另外，在代理方法中，修改 targetContentOffset 不会结束原有的减速效果，
    // 而调用 -setContentOffset:animated: 方法修正位置，需要需要异步才能生效。
    
    CGFloat const PageHeight = size.height;
    
    // 滚动满足一页
    if (offsetY <= -PageHeight || offsetY >= +PageHeight) {
        // 执行翻页：_currentPage 与 _reusingPage 交换
        [self didScrollToReusingPage:bounds maxPage:maxPage direction:direction];
        
        // 用户翻页，发送代理事件：中间已经展示的是当前页内容，但是 offset 未修改。
        // 此时已经完成翻页，直接发送了 show 事件，而没有转场进度 100% 的事件。
        // 1、即使发送进度 100% 的事件，事件也会被 show 事件所覆盖，因为这两个事件是串行的。
        // 2、此时，新页面可能已经进入转场，旧页面应该属于退场状态。
        XZCallBlock(_pageView->_didShowPage, _pageView, _pageView->_currentPage);
        
        // 恢复翻页前的展示位置，如果 x 不为零，会加载下一页，并发送转场进度
        CGFloat const y = fmod(offsetY, PageHeight);
        // 不能使用 setContentOffset:animated:NO 方法，会触发 scrollViewDidEndDecelerating 代理方法
        _pageView.contentOffset = CGPointMake(0, y);
        return;
    }
    
    // 滚动不足一页
    
    // 滚动已停止，且不足一页：检查翻页情况。
    // @discussion
    // 在某些极端情况下，可能会发生，翻页停在中间的情况。
    if (stopped) {
        if (PageHeight - offsetY < 1.0 || -PageHeight - offsetY > -1.0) {
            // 小于一个点，可能是因为 width 不是整数，翻页宽度与 width 不一致，认为翻页完成
            XZLog(@"翻页修复：停止滚动，距翻页不足一个点，%@", NSStringFromCGRect(bounds));
            [self didScrollToReusingPage:bounds maxPage:maxPage direction:direction];
            XZCallBlock(_pageView->_didShowPage, _pageView, _pageView->_currentPage);
            // 这里不取模，认为是正好完成翻页
            _pageView.contentOffset = CGPointZero;
        } else {
            // 发送转场进度
            XZCallBlock(_pageView->_didTurnPage, _pageView, offsetY, PageHeight);
            // 滚动停止，滚动未过半，不执行翻页，退回原点，否则执行翻页
            CGFloat const halfPageWidth = PageHeight * 0.5;
            if (offsetY >= +halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向右滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointMake(0, PageHeight) animated:YES];
            } else if (offsetY <= -halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向左滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointMake(0, -PageHeight) animated:YES];
            } else {
                // 滚动未超过一半，不翻页，回到原点
                XZLog(@"翻页修复：停止滚动，滚动距离未超过一半，不翻页，%@", NSStringFromCGRect(bounds));
                [_pageView setContentOffset:CGPointZero animated:YES];
            }
        }
    } else {
        // 发送转场进度
        XZCallBlock(_pageView->_didTurnPage, _pageView, offsetY, PageHeight);
    }
}

- (void)didScrollToReusingPage:(CGRect const)bounds maxPage:(NSInteger const)maxPage direction:(BOOL const)direction {
    XZExchangeValue(_pageView->_currentPage, _pageView->_reusingPage);
    XZExchangeValue(_pageView->_currentView, _pageView->_reusingView);
    
    [self layoutCurrentPageView:bounds];
    _pageView->_reusingPageDirection = !direction;
    [self layoutReusingPageView:bounds];
    
    // 调整 contentInset
    [self adjustContentInsets:bounds];
}

/// 本方法不发送事件。
- (void)setCurrentPage:(NSInteger const)newPage animated:(BOOL)animated {
    if (_pageView->_currentPage == newPage) {
        return;
    }
    NSParameterAssert(newPage >= 0 && newPage < _pageView->_numberOfPages);
    
    // 动画思路：
    // 1、将目标加载到 reusingPage 上，并计算从 currentPage 到 reusingPage 的滚动方向。
    // 2、将 reusingPage 与 currentPage 互换，然后按照滚动方向，调整它们的位置，然后将窗口移动到原始视图。
    // 3、然后执行动画到目标视图。
    
    CGRect    const bounds  = _pageView.bounds;
    NSInteger const maxPage = _pageView->_numberOfPages - 1;
    
    [UIView performWithoutAnimation:^{
        // 加载目标视图
        if (_pageView->_reusingPage != newPage) {
            _pageView->_reusingPage = newPage;
            [self reloadReusingPageView:bounds];
        }
        
        // 关于滚动方向
        // 从 A => B 的滚动方向，并不一定与 B => A 相反，所以为了保证滚动方向不变，
        // 使用从 current 到 reusing 的滚动方向的反向，而不是直接计算从 reusing 到 current 的方向。
        _pageView->_reusingPageDirection = !XZScrollDirection(_pageView->_currentPage, _pageView->_reusingPage, maxPage, _pageView->_isLooped);
        
        // 交换值并布局
        XZExchangeValue(_pageView->_currentPage, _pageView->_reusingPage);
        XZExchangeValue(_pageView->_currentView, _pageView->_reusingView);
        [self layoutCurrentPageView:bounds];
        [self layoutReusingPageView:bounds];
        
        // 根据当前情况调整边距，因为可能会因此 didScroll 事件，所以先将位置重置到原点，这样即使触发事件，也不影响。
        [self adjustContentInsets:bounds];
        
        // 如果需要展示动画的话，先恢复显示内容
        if (animated) {
            // offset.x 实际上就是 currentPage 的偏移，由于 currentPage 已经交换为 reusingPage 所以可以直接通过偏移计算目标位置
            CGFloat const y = _pageView->_reusingView.frame.origin.y + bounds.origin.y;
            [_pageView setBounds:CGRectMake(bounds.origin.x, y, bounds.size.width, bounds.size.height)];
        }
    }];
    
    if (animated) {
        // 动画到当前视图上。
        // 修改 bounds 不会触发 -scrollViewDidScroll: 方法，但是会触发 -layoutSubviews 方法。
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
            [self->_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        }];
    } else {
        [_pageView setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    }
}

@end
