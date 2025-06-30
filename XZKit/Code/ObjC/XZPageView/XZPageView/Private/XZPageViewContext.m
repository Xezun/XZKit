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

@implementation XZPageViewContext {
    CGSize _viewSize;
}

+ (XZPageViewContext *)contextForView:(XZPageView *)pageView orientation:(XZPageViewOrientation)orientation {
    switch (orientation) {
        case XZPageViewOrientationHorizontal: {
            return [[XZPageViewContext alloc] initWithView:pageView];
            break;
        }
        case XZPageViewOrientationVertical: {
            return [[XZPageViewVerticalContext alloc] initWithView:pageView];
            break;
        }
        default: {
            NSString *reason = [NSString stringWithFormat:@"参数 orientation=%ld 不是合法的枚举值", (long)orientation];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
            break;
        }
    }
}

- (instancetype)initWithView:(XZPageView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (XZPageViewOrientation)orientation {
    return XZPageViewOrientationHorizontal;
}

- (void)layoutSubviews:(const CGRect)bounds {
    if (CGSizeEqualToSize(bounds.size, _viewSize)) {
        return;
    }
    _viewSize = bounds.size;
    // 布局子视图
    [self layoutCurrentView:bounds];
    [self layoutPendingView:bounds];
    // 重新配置 _scrollView
    _view.contentSize = bounds.size;
    [self adaptContentInset:bounds];
}

- (void)scheduleAutoPagingTimerIfNeeded {
    if (_view->_numberOfPages <= 1 || _view.window == nil || _view->_autoPagingInterval <= 0) {
        // 不满足计时器启动条件，销毁当前计时器。
        [_view->_autoPagingTimer invalidate];
        _view->_autoPagingTimer = nil;
    } else {
        NSTimeInterval const timeInterval = _view->_autoPagingInterval + XZPageViewAnimationDuration;
        if (_view->_autoPagingTimer.timeInterval != timeInterval) {
            [_view->_autoPagingTimer invalidate];
            _view->_autoPagingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(autoPagingTimerAction:) userInfo:nil repeats:YES];
        }
        // 定时器首次触发的时间
        _view->_autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (void)autoPagingTimerAction:(NSTimer *)timer {
    NSInteger const newPage = XZLoopPage(_view->_currentPage, YES, _view->_numberOfPages - 1, YES);
    [self setCurrentPage:newPage animated:YES];
    // 自动翻页，发送翻页事件
    [self didShowPageAtIndex:newPage];
}

- (void)suspendAutoPagingTimer {
    if (_view->_autoPagingTimer != nil) {
        _view->_autoPagingTimer.fireDate = NSDate.distantFuture;
    }
}

- (void)restartAutoPagingTimer {
    if (_view->_numberOfPages > 1 && _view->_autoPagingTimer != nil) {
        _view->_autoPagingTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_view->_autoPagingInterval];
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
    
    [self handlDelegateMethodForClass:aClass];
}

- (void)handlDelegateMethodForClass:(Class)aClass {
    typedef void (*MethodType)(id<XZPageViewDelegate>, SEL, XZPageView *, CGFloat);
    _view->_didTurnPage = nil;
    
    SEL const selector = @selector(pageView:didTurnPageInTransition:);
    if (![aClass instancesRespondToSelector:selector]) {
        return;
    }
    
    MethodType const didTurnPage = (MethodType)method_getImplementation(class_getInstanceMethod(aClass, selector));
    if (didTurnPage == NULL) return;
    
    _view->_didTurnPage = ^(XZPageView * const self, CGFloat x, CGFloat width) {
        id const delegate = self.delegate;
        if (delegate == nil || delegate == self) return;
        CGFloat const transition = x / width;
        // 一次翻多页的情况，在当前设计模式下不存在。
        // 如果有，可以根据 transition 的正负判断翻页方向，再根据 fromPage 和 toPage 以及它们之差，计算出翻页进度。
        didTurnPage(delegate, selector, self, transition);
    };
}

- (UIView *)viewForPageAtIndex:(NSInteger)index reusingView:(UIView *)reusingView {
    return [_view.dataSource pageView:_view viewForPageAtIndex:index reusingView:reusingView];
}

- (BOOL)shouldReuseView:(UIView *)reusingView {
    return [_view.dataSource pageView:_view shouldReuseView:reusingView];
}

- (void)willShowView:(UIView *)view animated:(BOOL)animated {
    id<XZPageViewDelegate> const delegate = _view.delegate;
    if ([delegate respondsToSelector:@selector(pageView:willShowView:animated:)]) {
        [delegate pageView:_view willShowView:view animated:animated];
    }
}

- (void)didShowView:(UIView *)view animated:(BOOL)animated {
    id<XZPageViewDelegate> const delegate = _view.delegate;
    if ([delegate respondsToSelector:@selector(pageView:didShowView:animated:)]) {
        [delegate pageView:_view didShowView:view animated:animated];
    }
}

- (void)willHideView:(UIView *)view animated:(BOOL)animated {
    id<XZPageViewDelegate> const delegate = _view.delegate;
    if ([delegate respondsToSelector:@selector(pageView:willHideView:animated:)]) {
        [delegate pageView:_view willHideView:view animated:animated];
    }
}

- (void)didHideView:(UIView *)view animated:(BOOL)animated {
    id<XZPageViewDelegate> const delegate = _view.delegate;
    if ([delegate respondsToSelector:@selector(pageView:didHideView:animated:)]) {
        [delegate pageView:_view didHideView:view animated:animated];
    }
}

- (void)didShowPageAtIndex:(NSInteger)index {
    id<XZPageViewDelegate> const delegate = _view.delegate;
    if ([delegate respondsToSelector:@selector(pageView:didShowPageAtIndex:)]) {
        [delegate pageView:_view didShowPageAtIndex:index];
    }
}

// 子类重写的方法

- (void)layoutCurrentView:(CGRect const)bounds {
    _view->_currentView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (void)layoutPendingView:(CGRect const)bounds {
    switch (_view.effectiveUserInterfaceLayoutDirection) {
        case UIUserInterfaceLayoutDirectionRightToLeft: {
            CGFloat const x = (_view->_pendingPageDirection ? -bounds.size.width : +bounds.size.width);
            _view->_pendingView.frame = CGRectMake(x, 0, bounds.size.width, bounds.size.height);
            break;
        }
        case UIUserInterfaceLayoutDirectionLeftToRight:
        default: {
            CGFloat const x = (_view->_pendingPageDirection ? +bounds.size.width : -bounds.size.width);
            _view->_pendingView.frame = CGRectMake(x, 0, bounds.size.width, bounds.size.height);
            break;
        }
    }
}

/// 调整 contentInset 以适配 currentPage 和 isLooped 状态。
/// @note 仅在需要调整 contentInset 的地方调用此方法。
- (void)adaptContentInset:(CGRect const)bounds {
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (_view->_numberOfPages <= 1) {
        // 只有一个 page 不可滚动。
    } else if (_view->_isLooped) {
        // 循环模式下，可左右滚动，设置左右边距作为滚动区域。
        newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, bounds.size.width);
    } else if (_view->_currentPage == 0) {
        // 非循环模式下，展示第一页时，不能向后滚动。
        switch (_view.effectiveUserInterfaceLayoutDirection) {
            case UIUserInterfaceLayoutDirectionRightToLeft:
                newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, 0);
                break;
            case UIUserInterfaceLayoutDirectionLeftToRight:
                newInsets = UIEdgeInsetsMake(0, 0, 0, bounds.size.width);
                break;
            default:
                break;
        }
    } else if (_view->_currentPage == _view->_numberOfPages - 1) {
        // 非循环模式下，展示最后一页时，不能向前滚动。
        switch (_view.effectiveUserInterfaceLayoutDirection) {
            case UIUserInterfaceLayoutDirectionRightToLeft:
                newInsets = UIEdgeInsetsMake(0, 0, 0, bounds.size.width);
                break;
            case UIUserInterfaceLayoutDirectionLeftToRight:
                newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, 0);
                break;
            default:
                break;
        }
    } else {
        // 非循环模式下，展示的不是第一页，也不是最后一页，可以前后滚动。
        newInsets = UIEdgeInsetsMake(0, bounds.size.width, 0, bounds.size.width);
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(newInsets, _view.contentInset)) {
        return;
    }
    
    // 使用 setBounds 不会触发 didScroll 事件。
    // 重置到原点，避免 contentInset 触发 didScroll 事件，影响其它逻辑
    [_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    _view.contentInset = newInsets;
    [_view setBounds:bounds];
}

/// 发生滚动
- (void)didScroll:(BOOL)stopped {
    CGRect  const bounds  = _view.bounds;
    CGSize  const size    = bounds.size;
    CGFloat const offsetX = bounds.origin.x;
    
    // 只有一张图时，只有原点是合法位置
    if (_view->_numberOfPages <= 1) {
        if (stopped && offsetX != 0) {
            [_view setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 还在原点时，不需要处理
    if (offsetX == 0) {
        if (_view->_pendingView) {
            [self willHideView:_view->_pendingView animated:NO];
            [self willShowView:_view->_currentView animated:NO];
            
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            [self didShowView:_view->_currentView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_reusingView = _view->_pendingView;
                _view->_reusingPage = _view->_pendingPage;
            }
            
            _view->_pendingView = nil;
            _view->_pendingPage = NSNotFound;
        }
        return;
    }
    
    BOOL      const isLTR       = (_view.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight);
    NSInteger const maxPage     = _view->_numberOfPages - 1;
    BOOL      const direction   = isLTR ? offsetX > 0 : offsetX < 0;
    NSInteger const pendingPage = XZLoopPage(_view->_currentPage, direction, maxPage, _view->_isLooped);
    
    // 没有目标页面，就不需要处理加载及翻页了。
    if (pendingPage == NSNotFound) {
        if (stopped) {
            // 停止在非页面位置，自动归位
            [_view setContentOffset:CGPointZero animated:YES];
        }
        if (_view->_pendingView) {
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_reusingView = _view->_pendingView;
                _view->_reusingPage = _view->_pendingPage;
            }
            _view->_pendingView = nil;
            _view->_pendingPage = NSNotFound;
        }
        return;
    }
    
    // 检查当前预加载的视图是否正确
    if (_view->_pendingPage != pendingPage) {
        [self willHideView:_view->_currentView animated:YES];
        
        if (_view->_pendingView) {
            NSLog(@"待显视图：当前与目标不一致，%ld vs %ld", _view->_pendingPage, pendingPage);
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_pendingView];
            } else if (_view->_reusingPage == pendingPage) {
                _view->_pendingView = _view->_reusingView;
                _view->_reusingView = nil;
                _view->_reusingPage = NSNotFound;
            } else {
                _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_reusingView];
                _view->_reusingView = nil;
                _view->_reusingPage = NSNotFound;
            }
            
            [self willShowView:_view->_pendingView animated:YES];
            [_view addSubview:_view->_pendingView];
            [self layoutPendingView:bounds];
        } else if (_view->_reusingPage == pendingPage) {
            NSLog(@"待显视图：直接使用复用视图，%ld", pendingPage);
            _view->_pendingView = _view->_reusingView;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
        } else {
            NSLog(@"待显视图：加载新的待显视图，%ld", pendingPage);
            _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_reusingView];
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
        }
        
        [self willShowView:_view->_pendingView animated:YES];
        [_view addSubview:_view->_pendingView];
        _view->_pendingPage = pendingPage;
        _view->_pendingPageDirection = direction;
        [self layoutPendingView:bounds];
    } else if (direction != _view->_pendingPageDirection) {
        NSLog(@"待显视图：与当前方向不一致，%d, %ld", direction, pendingPage);
        _view->_pendingPageDirection = direction;
        [self layoutPendingView:bounds];
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
        [self didScrollToPendingPage:bounds maxPage:maxPage direction:direction];
        
        // 用户翻页，发送代理事件：中间已经展示的是当前页内容，但是 offset 未修改。
        // 此时已经完成翻页，直接发送了 show 事件，而没有转场进度 100% 的事件。
        // 1、即使发送进度 100% 的事件，事件也会被 show 事件所覆盖，因为这两个事件是串行的。
        // 2、此时，新页面可能已经进入转场，旧页面应该属于退场状态。
        [self didShowPageAtIndex:_view->_currentPage];
        
        // 恢复翻页前的展示位置，如果 x 不为零，会加载下一页，并发送转场进度
        CGFloat const x = fmod(offsetX, PageWidth);
        // 不能使用 setContentOffset:animated:NO 方法，会触发 scrollViewDidEndDecelerating 代理方法
        _view.contentOffset = CGPointMake(x, 0);
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
            [self didScrollToPendingPage:bounds maxPage:maxPage direction:direction];
            // 发送翻页事件
            [self didShowPageAtIndex:_view->_currentPage];
            // 这里不取模，认为是正好完成翻页
            _view.contentOffset = CGPointZero;
        } else {
            // 发送转场进度
            XZCallBlock(_view->_didTurnPage, _view, offsetX, PageWidth);
            // 滚动停止，滚动未过半，不执行翻页，退回原点，否则执行翻页
            CGFloat const halfPageWidth = PageWidth * 0.5;
            if (offsetX >= +halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向右滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointMake(PageWidth, 0) animated:YES];
            } else if (offsetX <= -halfPageWidth) {
                XZLog(@"翻页修复：停止滚动，向左滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointMake(-PageWidth, 0) animated:YES];
            } else {
                // 滚动未超过一半，不翻页，回到原点
                XZLog(@"翻页修复：停止滚动，滚动距离未超过一半，不翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointZero animated:YES];
            }
        }
    } else {
        // 发送转场进度
        XZCallBlock(_view->_didTurnPage, _view, offsetX, PageWidth);
    }
}

- (void)didScrollToPendingPage:(CGRect const)bounds maxPage:(NSInteger const)maxPage direction:(BOOL const)direction {
    // 当前视图退出展示
    [_view->_currentView removeFromSuperview];
    [self didHideView:_view->_currentView animated:YES];
    
    // 当前视图进入重用池
    if ([self shouldReuseView:_view->_currentView]) {
        _view->_reusingView = _view->_currentView;
        _view->_reusingPage = _view->_currentPage;
    }
    
    // 待显视图进入展示中
    _view->_currentView = _view->_pendingView;
    _view->_currentPage = _view->_pendingPage;
    _view->_pendingPage = NSNotFound;
    _view->_pendingView = nil;
    [self layoutCurrentView:bounds];
    [self didShowView:_view->_currentView animated:YES];
    
    // 调整 contentInset
    [self adaptContentInset:bounds];
}

- (void)setCurrentPage:(NSInteger const)newPage animated:(BOOL)animated {
    if (_view->_currentPage == newPage) {
        return;
    }
    NSParameterAssert(newPage >= 0 && newPage < _view->_numberOfPages);
    
    // 动画思路：
    // 1、将目标加载到 reusingPage 上，并计算从 currentPage 到 reusingPage 的滚动方向。
    // 2、将 reusingPage 与 currentPage 互换，然后按照滚动方向，调整它们的位置，然后将窗口移动到原始视图。
    // 3、然后执行动画到目标视图。
    
    CGRect    const bounds  = _view.bounds;
    NSInteger const maxPage = _view->_numberOfPages - 1;
    
    [UIView performWithoutAnimation:^{
        // 加载目标视图
        if (_view->_pendingPage == newPage) {
            // 已经是目标视图了
        } else if (_view->_pendingView) {
            // 有视图，但是不是目标视图
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_pendingView];
            } else {
                _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_reusingView];
            }
            _view->_pendingPage = newPage;
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        } else if (_view->_reusingPage == newPage) {
            _view->_pendingView = _view->_reusingView;
            _view->_pendingPage = newPage;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
            
            [self willHideView:_view->_currentView animated:animated];
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        } else {
            _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_reusingView];
            _view->_pendingPage = newPage;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
            
            [self willHideView:_view->_currentView animated:animated];
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        }
        
        // 关于滚动方向
        // 从 A => B 的滚动方向，并不一定与 B => A 相反，所以为了保证滚动方向不变，
        // 使用从 current 到 reusing 的滚动方向的反向，而不是直接计算从 reusing 到 current 的方向。
        _view->_pendingPageDirection = !XZScrollDirection(_view->_currentPage, _view->_pendingPage, maxPage, _view->_isLooped);
        
        // 交换值并布局
        XZExchangeValue(_view->_currentPage, _view->_pendingPage);
        XZExchangeValue(_view->_currentView, _view->_pendingView);
        [self layoutCurrentView:bounds];
        [self layoutPendingView:bounds];
        
        // 根据当前情况调整边距，因为可能会因此 didScroll 事件，所以先将位置重置到原点，这样即使触发事件，也不影响。
        [self adaptContentInset:bounds];
        
        // 如果需要展示动画的话，先恢复显示内容
        if (animated) {
            // offset.x 实际上就是 currentPage 的偏移，由于 currentPage 已经交换为 reusingPage 所以可以直接通过偏移计算目标位置
            CGFloat const x = _view->_pendingView.frame.origin.x + bounds.origin.x;
            [_view setBounds:CGRectMake(x, bounds.origin.y, bounds.size.width, bounds.size.height)];
        }
    }];
    
    if (animated) {
        // 动画到当前视图上。
        // 修改 bounds 不会触发 -scrollViewDidScroll: 方法，但是会触发 -layoutSubviews 方法。
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
            [self->_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        } completion:^(BOOL finished) {
            [self->_view->_pendingView removeFromSuperview];
            [self didHideView:self->_view->_pendingView animated:YES];
            
            if ([self shouldReuseView:self->_view->_pendingView]) {
                self->_view->_reusingView = self->_view->_pendingView;
                self->_view->_reusingPage = self->_view->_pendingPage;
            }
            self->_view->_pendingView = nil;
            self->_view->_pendingPage = NSNotFound;
            
            [self didShowView:self->_view->_currentView animated:YES];
        }];
    } else {
        [_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        
        [self->_view->_pendingView removeFromSuperview];
        [self didHideView:self->_view->_pendingView animated:NO];
        
        if ([self shouldReuseView:self->_view->_pendingView]) {
            self->_view->_reusingView = self->_view->_pendingView;
            self->_view->_reusingPage = self->_view->_pendingPage;
        }
        self->_view->_pendingView = nil;
        self->_view->_pendingPage = NSNotFound;
        
        [self didShowView:self->_view->_currentView animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _view) {
        return;
    }
    [self didScroll:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != _view) {
        return;
    }
    
    if (_view->_numberOfPages <= 1) {
        return;
    }
    
    // 用户操作，暂停计时器
    [self suspendAutoPagingTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != _view) {
        return;
    }
    
    // 用户停止操作，恢复计时器
    [self restartAutoPagingTimer];
    
    // 检查翻页：用户停止操作
    if (decelerate) {
        return; // 进入减速状态，在减速停止后再决定
    }
    
    // 直接停止滚动了。
    [self didScroll:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _view) {
        return;
    }
    [self didScroll:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != _view) {
        return;
    }
    [self didScroll:YES];
}

@end


@implementation XZPageViewVerticalContext

- (XZPageViewOrientation)orientation {
    return XZPageViewOrientationVertical;
}

- (void)layoutCurrentView:(CGRect const)bounds {
    _view->_currentView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (void)layoutPendingView:(CGRect const)bounds {
    CGFloat const y = (_view->_pendingPageDirection ? +bounds.size.height : -bounds.size.height);
    _view->_pendingView.frame = CGRectMake(0, y, bounds.size.width, bounds.size.height);
}

/// 调整 contentInset 以适配 currentPage 和 isLooped 状态。
/// @note 仅在需要调整 contentInset 的地方调用此方法。
- (void)adaptContentInset:(CGRect const)bounds {
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (_view->_numberOfPages <= 1) {
        // 只有一个 page 不可滚动。
    } else if (_view->_isLooped) {
        // 循环模式下，可左右滚动，设置左右边距作为滚动区域。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, bounds.size.height, 0);
    } else if (_view->_currentPage == 0) {
        // 非循环模式下，展示第一页时，不能向下滚动。
        newInsets = UIEdgeInsetsMake(0, 0, bounds.size.height, 0);
    } else if (_view->_currentPage == _view->_numberOfPages - 1) {
        // 非循环模式下，展示最后一页时，不能向上滚动。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, 0, 0);
    } else {
        // 非循环模式下，展示的不是第一页，也不是最后一页，可以前后滚动。
        newInsets = UIEdgeInsetsMake(bounds.size.height, 0, bounds.size.height, 0);
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(newInsets, _view.contentInset)) {
        return;
    }
    
    // 使用 setBounds 不会触发 didScroll 事件。
    // 重置到原点，避免 contentInset 触发 didScroll 事件，影响其它逻辑
    [_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    _view.contentInset = newInsets;
    [_view setBounds:bounds];
}

- (void)didScroll:(BOOL)stopped {
    CGRect  const bounds  = _view.bounds;
    CGSize  const size    = bounds.size;
    CGFloat const offsetY = bounds.origin.y;
    
    // 只有一张图时，只有原点是合法位置
    if (_view->_numberOfPages <= 1) {
        if (stopped && offsetY != 0) {
            [_view setContentOffset:CGPointZero animated:YES];
        }
        return;
    }
    
    // 还在原点时，不需要处理
    if (offsetY == 0) {
        if (_view->_pendingView) {
            [self willHideView:_view->_pendingView animated:NO];
            [self willShowView:_view->_currentView animated:NO];
            
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            [self didShowView:_view->_currentView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_reusingView = _view->_pendingView;
                _view->_reusingPage = _view->_pendingPage;
            }
            
            _view->_pendingView = nil;
            _view->_pendingPage = NSNotFound;
        }
        return;
    }
    
    NSInteger const maxPage     = _view->_numberOfPages - 1;
    BOOL      const direction   = offsetY > 0;
    NSInteger const pendingPage = XZLoopPage(_view->_currentPage, direction, maxPage, _view->_isLooped);
    
    // 没有目标页面，就不需要处理加载及翻页了。
    if (pendingPage == NSNotFound) {
        if (stopped) {
            // 停止在非页面位置，自动归位
            [_view setContentOffset:CGPointZero animated:YES];
        }
        if (_view->_pendingView) {
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_reusingView = _view->_pendingView;
                _view->_reusingPage = _view->_pendingPage;
            }
            _view->_pendingView = nil;
            _view->_pendingPage = NSNotFound;
        }
        return;
    }
    
    // 检查当前预加载的视图是否正确
    if (_view->_pendingPage != pendingPage) {
        [self willHideView:_view->_currentView animated:YES];
        
        if (_view->_pendingView) {
            NSLog(@"待显视图：当前与目标不一致，%ld vs %ld", _view->_pendingPage, pendingPage);
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_pendingView];
            } else if (_view->_reusingPage == pendingPage) {
                _view->_pendingView = _view->_reusingView;
                _view->_reusingView = nil;
                _view->_reusingPage = NSNotFound;
            } else {
                _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_reusingView];
                _view->_reusingView = nil;
                _view->_reusingPage = NSNotFound;
            }
            
            [self willShowView:_view->_pendingView animated:YES];
            [_view addSubview:_view->_pendingView];
            [self layoutPendingView:bounds];
        } else if (_view->_reusingPage == pendingPage) {
            NSLog(@"待显视图：直接使用复用视图，%ld", pendingPage);
            _view->_pendingView = _view->_reusingView;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
        } else {
            NSLog(@"待显视图：加载新的待显视图，%ld", pendingPage);
            _view->_pendingView = [self viewForPageAtIndex:pendingPage reusingView:_view->_reusingView];
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
        }
        
        [self willShowView:_view->_pendingView animated:YES];
        [_view addSubview:_view->_pendingView];
        _view->_pendingPage = pendingPage;
        _view->_pendingPageDirection = direction;
        [self layoutPendingView:bounds];
    } else if (direction != _view->_pendingPageDirection) {
        NSLog(@"待显视图：与当前方向不一致，%d, %ld", direction, pendingPage);
        _view->_pendingPageDirection = direction;
        [self layoutPendingView:bounds];
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
        [self didScrollToPendingPage:bounds maxPage:maxPage direction:direction];
        
        // 用户翻页，发送代理事件：中间已经展示的是当前页内容，但是 offset 未修改。
        // 此时已经完成翻页，直接发送了 show 事件，而没有转场进度 100% 的事件。
        // 1、即使发送进度 100% 的事件，事件也会被 show 事件所覆盖，因为这两个事件是串行的。
        // 2、此时，新页面可能已经进入转场，旧页面应该属于退场状态。
        [self didShowPageAtIndex:_view->_currentPage];
        
        // 恢复翻页前的展示位置，如果 x 不为零，会加载下一页，并发送转场进度
        CGFloat const y = fmod(offsetY, PageHeight);
        // 不能使用 setContentOffset:animated:NO 方法，会触发 scrollViewDidEndDecelerating 代理方法
        _view.contentOffset = CGPointMake(0, y);
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
            [self didScrollToPendingPage:bounds maxPage:maxPage direction:direction];
            
            // 发送翻页事件
            [self didShowPageAtIndex:_view->_currentPage];
            
            // 这里不取模，认为是正好完成翻页
            _view.contentOffset = CGPointZero;
        } else {
            // 发送转场进度
            XZCallBlock(_view->_didTurnPage, _view, offsetY, PageHeight);
            // 滚动停止，滚动未过半，不执行翻页，退回原点，否则执行翻页
            CGFloat const halfPageHeight = PageHeight * 0.5;
            if (offsetY >= +halfPageHeight) {
                XZLog(@"翻页修复：停止滚动，向右滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointMake(PageHeight, 0) animated:YES];
            } else if (offsetY <= -halfPageHeight) {
                XZLog(@"翻页修复：停止滚动，向左滚动距离超过一半，翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointMake(-PageHeight, 0) animated:YES];
            } else {
                // 滚动未超过一半，不翻页，回到原点
                XZLog(@"翻页修复：停止滚动，滚动距离未超过一半，不翻页，%@", NSStringFromCGRect(bounds));
                [_view setContentOffset:CGPointZero animated:YES];
            }
        }
    } else {
        // 发送转场进度
        XZCallBlock(_view->_didTurnPage, _view, offsetY, PageHeight);
    }
}

- (void)setCurrentPage:(NSInteger const)newPage animated:(BOOL)animated {
    if (_view->_currentPage == newPage) {
        return;
    }
    NSParameterAssert(newPage >= 0 && newPage < _view->_numberOfPages);
    
    // 动画思路：
    // 1、将目标加载到 reusingPage 上，并计算从 currentPage 到 reusingPage 的滚动方向。
    // 2、将 reusingPage 与 currentPage 互换，然后按照滚动方向，调整它们的位置，然后将窗口移动到原始视图。
    // 3、然后执行动画到目标视图。
    
    CGRect    const bounds  = _view.bounds;
    NSInteger const maxPage = _view->_numberOfPages - 1;
    
    [UIView performWithoutAnimation:^{
        // 加载目标视图
        if (_view->_pendingPage == newPage) {
            // 已经是目标视图了
        } else if (_view->_pendingView) {
            // 有视图，但是不是目标视图
            [self willHideView:_view->_pendingView animated:NO];
            [_view->_pendingView removeFromSuperview];
            [self didHideView:_view->_pendingView animated:NO];
            
            if ([self shouldReuseView:_view->_pendingView]) {
                _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_pendingView];
            } else {
                _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_reusingView];
            }
            _view->_pendingPage = newPage;
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        } else if (_view->_reusingPage == newPage) {
            _view->_pendingView = _view->_reusingView;
            _view->_pendingPage = newPage;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
            
            [self willHideView:_view->_currentView animated:animated];
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        } else {
            _view->_pendingView = [self viewForPageAtIndex:newPage reusingView:_view->_reusingView];
            _view->_pendingPage = newPage;
            _view->_reusingView = nil;
            _view->_reusingPage = NSNotFound;
            
            [self willHideView:_view->_currentView animated:animated];
            
            [self willShowView:_view->_pendingView animated:animated];
            [_view addSubview:_view->_pendingView];
        }
        
        // 关于滚动方向
        // 从 A => B 的滚动方向，并不一定与 B => A 相反，所以为了保证滚动方向不变，
        // 使用从 current 到 reusing 的滚动方向的反向，而不是直接计算从 reusing 到 current 的方向。
        _view->_pendingPageDirection = !XZScrollDirection(_view->_currentPage, _view->_pendingPage, maxPage, _view->_isLooped);
        
        // 交换值并布局
        XZExchangeValue(_view->_currentPage, _view->_pendingPage);
        XZExchangeValue(_view->_currentView, _view->_pendingView);
        [self layoutCurrentView:bounds];
        [self layoutPendingView:bounds];
        
        // 根据当前情况调整边距，因为可能会因此 didScroll 事件，所以先将位置重置到原点，这样即使触发事件，也不影响。
        [self adaptContentInset:bounds];
        
        // 如果需要展示动画的话，先恢复显示内容
        if (animated) {
            CGFloat const y = _view->_pendingView.frame.origin.y + bounds.origin.y;
            [_view setBounds:CGRectMake(bounds.origin.x, y, bounds.size.width, bounds.size.height)];
        }
    }];
    
    if (animated) {
        // 动画到当前视图上。
        // 修改 bounds 不会触发 -scrollViewDidScroll: 方法，但是会触发 -layoutSubviews 方法。
        [UIView animateWithDuration:XZPageViewAnimationDuration animations:^{
            [self->_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        } completion:^(BOOL finished) {
            [self->_view->_pendingView removeFromSuperview];
            [self didHideView:self->_view->_pendingView animated:YES];
            
            if ([self shouldReuseView:self->_view->_pendingView]) {
                self->_view->_reusingView = self->_view->_pendingView;
                self->_view->_reusingPage = self->_view->_pendingPage;
            }
            self->_view->_pendingView = nil;
            self->_view->_pendingPage = NSNotFound;
            
            [self didShowView:self->_view->_currentView animated:YES];
        }];
    } else {
        [_view setBounds:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        
        [self->_view->_pendingView removeFromSuperview];
        [self didHideView:self->_view->_pendingView animated:NO];
        
        if ([self shouldReuseView:self->_view->_pendingView]) {
            self->_view->_reusingView = self->_view->_pendingView;
            self->_view->_reusingPage = self->_view->_pendingPage;
        }
        self->_view->_pendingView = nil;
        self->_view->_pendingPage = NSNotFound;
        
        [self didShowView:self->_view->_currentView animated:NO];
    }
}

@end
