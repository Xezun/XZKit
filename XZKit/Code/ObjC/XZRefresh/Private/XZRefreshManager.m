//
//  XZRefreshManager.m
//  XZRefresh
//
//  Created by Xezun on 2023/8/10.
//

#import "XZRefreshManager.h"
#import "XZRefreshView.h"
#import "XZRefreshStyle1View.h"
#import "XZRefreshStyle2View.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshContext.h"
#import "XZRefreshDefines.h"
#import "XZDefer.h"
#import "XZRuntime.h"

// 改变 UIScrollView 的 frame 或 bounds 属性，
// 如果 adjustedContentInsets 因此也发生改变，则会额外触发 setBounds/scrollViewDidScroll: 等方法被调用。
// 否则，甚至即使 contentOffset 因此而发生改变，也不会触发 scrollViewDidScroll: 方法。
// 直接修改 frame 或 bounds 属性，不会触发 setNeedsLayout 方法，而是直接触发 layoutSubviews 方法。

UIKIT_STATIC_INLINE void UIViewAnimate(BOOL animated, void (^animations)(void), void (^completion)(BOOL finished)) {
    if (animated) {
        [UIView animateWithDuration:XZRefreshAnimationDuration animations:animations completion:completion];
    } else {
        animations();
        dispatch_main_async(completion, NO);
    }
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsIncreaseBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom += bottom;
    return insets;
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsIncreaseTop(UIEdgeInsets insets, CGFloat top) {
    insets.top += top;
    return insets;
}

// KVO 标记。
static void const * const _context = &_context;

/// 布局 header/footer 依赖的要素。
typedef NS_OPTIONS(NSUInteger, XZAxis) {
    XZAxisNone                         = 0 << 0,
    XZAxisContentInsetsTop             = 1 << 1,
    XZAxisContentInsetsBottom          = 1 << 2,
    XZAxisAdjustedContentInsetsTop     = 1 << 3,
    XZAxisAdjustedContentInsetsBottom  = 1 << 4,
    XZAxisBoundsX                      = 1 << 5,
    XZAxisBoundsWidth                  = 1 << 6,
    XZAxisBoundsHeight                 = 1 << 7,
    XZAxisContentSizeHeight            = 1 << 8,
};

/// 返回 YES 表示 bounds 要素发生了改变。
static inline BOOL XZAxisCompareBounds(XZAxis const axis, CGRect const old, CGRect const new) {
    if ((axis & XZAxisBoundsX) && old.origin.x != new.origin.x) {
        return YES;
    }
    if ((axis & XZAxisBoundsWidth) && old.size.width != new.size.width) {
        return YES;
    }
    if ((axis & XZAxisBoundsHeight) && old.size.height != new.size.height) {
        return YES;
    }
    return NO;
}
/// 返回 YES 表示 contentInsets 要素发生了改变。
static inline BOOL XZAxisCompareContentInsets(XZAxis const axis, UIEdgeInsets const old, UIEdgeInsets const new) {
    if ((axis & XZAxisContentInsetsTop) && old.top != new.top) {
        return YES;
    }
    if ((axis & XZAxisContentInsetsBottom) && old.bottom != new.bottom) {
        return YES;
    }
    return NO;
}
/// 返回 YES 表示 adjustedContentInsets 要素发生了改变。
static inline BOOL XZAxisCompareAdjustedContentInsets(XZAxis const axis, UIEdgeInsets const old, UIEdgeInsets const new) {
    if ((axis & XZAxisAdjustedContentInsetsTop) && old.top != new.top) {
        return YES;
    }
    if ((axis & XZAxisAdjustedContentInsetsBottom) && old.bottom != new.bottom) {
        return YES;
    }
    return NO;
}
/// 返回 YES 表示 contentSize 要素发生了改变。
static inline BOOL XZAxisCompareContentSize(XZAxis const axis, CGSize const old, CGSize const new) {
    return ((axis & XZAxisContentSizeHeight) && old.height != new.height);
}


@implementation XZRefreshManager {
    // 记录布局 header/footer 时所依赖的 UIScrollView 属性值。
    // 理论上在需要的地方，比如 frameSize/contentSize/adjustedContentInsets 发生改变后，触发布局方法是最经济、最效率的方案。
    // 但是由于 Apple 原生逻辑的混乱，在上述这些状态改变后，相应的事件触发时机不固定：
    // 1. 当 adjustedContentInset 发生改变后，方法 -scrollViewDidScroll: 先于 -adjustedContentInsetDidChange: 调用。
    //    这将导致在 -scrollViewDidScroll: 方法中，由于 context 未更新而不能判断  header/footer 的正确状态。
    // 2. 无法向 -layoutSubviews 方法注入代码，即使在 +load 中添加或交换方法实现，被注入的代码不执行。
    //    猜测是原生提前获取了 -layoutSubviews 方法的实现，以优化性能，因为在滚动时，方法 layoutSubviews 会一直调用。
    // 3. 当视图大小发生改变时，不一定会触发 -scrollViewDidScroll: 方法，所以需要监听 bounds 属性（KVO）。
    //    比如从 sb/xib 中初始化的大小和最终大小不一致时，初始以 xib/sb 中预设的大小进行布局，但是在 scrollView 调整
    //    到最终大小后，虽然 frame.size/bounds.size 发生了改变，但是并没有触发滚动方法。
    //    因为对 bounds.x 进行了依赖，所有监听了 bounds 属性而不是 frame 属性，另外监听 frame 似乎无效。
    // 基于以上原因，在  中通过判断以下关键值，实时重新计算 header/footer 布局。
    XZAxis       _headerAxis; // 当前布局 header 依赖的要素
    XZAxis       _footerAxis; // 当前布局 footer 依赖的要素
    CGRect       _bounds;
    CGSize       _contentSize;
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _adjustedContentInsets;
    
    /// 记录了 Header 或 Footer 的可见高度：负数为 Header 正数为 Footer 。
    CGFloat _distance;
    XZRefreshContext *_header;
    XZRefreshContext *_footer;
}

- (instancetype)initWithScrollView:(UIScrollView * const)scrollView {
    self = [super init];
    if (self != nil) {
        _scrollView = scrollView;
        
        _header = [XZRefreshContext headerContextForScrollView:scrollView];
        _footer = [XZRefreshContext footerContextForScrollView:scrollView];
        
        NSKeyValueObservingOptions const options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial;
        [scrollView addObserver:self forKeyPath:@"delegate" options:(options) context:(void *)_context];
        [scrollView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:(void *)_context];
//        [scrollView addObserver:self forKeyPath:@"bounds" options:(NSKeyValueObservingOptionNew) context:(void *)_context];
    }
    return self;
}

- (void)dealloc {
    // 理论上 XZRefreshManager 销毁时，UIScrollView 肯定已销毁或在销毁中，scrollView 变量一定为 nil
    UIScrollView * const scrollView = _scrollView;
    if (scrollView) {
        [scrollView removeObserver:self forKeyPath:@"delegate" context:(void *)_context];
        [scrollView removeObserver:self forKeyPath:@"contentSize" context:(void *)_context];
        [scrollView removeObserver:self forKeyPath:@"bounds" context:(void *)_context];
        _scrollView = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != _context) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // 视图大小发生改变，重新布局刷新视图
    if ([keyPath isEqualToString:@"bounds"]) {
        CGRect const new = [change[NSKeyValueChangeNewKey] CGRectValue];
        if (XZAxisCompareBounds(_headerAxis, _bounds, new)) {
            [self setNeedsLayoutHeaderRefreshView];
        }
        if (XZAxisCompareBounds(_footerAxis, _bounds, new)) {
            [self setNeedsLayoutFooterRefreshView];
        }
        return;
    }
    
    // 理论上来讲，contentSize 改变，不会影响 header
    // 1、页面大小发生改变
    // 2、下拉刷新，或上拉加载，导致页面内容变化
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize const new = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (XZAxisCompareContentSize(_headerAxis, _contentSize, new)) {
            [self setNeedsLayoutHeaderRefreshView];
        }
        if (XZAxisCompareContentSize(_footerAxis, _contentSize, new)) {
            [self setNeedsLayoutFooterRefreshView];
        }
        return;
    }
    
    // 当 delegate 改变时，重新监听 UIScrollViewDelegate 事件
    if ([keyPath isEqualToString:@"delegate"]) {
        id<UIScrollViewDelegate> const old = change[NSKeyValueChangeOldKey];
        id<UIScrollViewDelegate> const new = change[NSKeyValueChangeNewKey];
        if (old == new) {
            return;
        }
        [self scrollView:object delegateDidChange:new];
        return;
    }
}

/// 接管代理事件。
- (void)scrollView:(UIScrollView *)scrollView delegateDidChange:(nullable id<UIScrollViewDelegate> const)delegate {
    if (delegate == self || scrollView != _scrollView) {
        return;
    }
    if (delegate == nil) {
        scrollView.delegate = self;
        return;
    }
    
    Class const aClass = delegate.class;
    
    static const void * const _key = &_key;
    if (objc_getAssociatedObject(aClass, _key)) {
        return;
    }
    objc_setAssociatedObject(aClass, _key, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    {
        SEL          const selector = @selector(scrollViewDidScroll:);
        const char * const encoding = xz_objc_class_getMethodTypeEncoding(self.class, selector);
        xz_objc_class_addMethodWithBlock(aClass, selector, encoding, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewDidScroll:scrollView];
        }, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewDidScroll:scrollView];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass(aClass)
            };
            ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&super, selector, scrollView);
        }, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
                [scrollView.xz_refreshManager scrollViewDidScroll:scrollView];
                ((void (*)(id<UIScrollViewDelegate>, SEL, id))objc_msgSend)(self, selector, scrollView);
            };
        });
    }
    
    {
        SEL          const selector = @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:);
        const char * const encoding = xz_objc_class_getMethodTypeEncoding(self.class, selector);
        xz_objc_class_addMethodWithBlock(aClass, selector, encoding, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
            [scrollView.xz_refreshManager scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
            [scrollView.xz_refreshManager scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass(aClass)
            };
            ((void (*)(struct objc_super *, SEL, id, CGPoint, CGPoint *))objc_msgSendSuper)(&super, selector, scrollView, velocity, targetContentOffset);
        }, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
                [scrollView.xz_refreshManager scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
                ((void (*)(id<UIScrollViewDelegate>, SEL, id, CGPoint, CGPoint *))objc_msgSend)(self, selector, scrollView, velocity, targetContentOffset);
            };
        });
    }
    
    {
        SEL          const selector = @selector(scrollViewDidEndDecelerating:);
        const char * const encoding = xz_objc_class_getMethodTypeEncoding(self.class, selector);
        xz_objc_class_addMethodWithBlock(aClass, selector, encoding, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewDidEndDecelerating:scrollView];
        }, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewDidEndDecelerating:scrollView];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass(aClass)
            };
            ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&super, selector, scrollView);
        }, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
                [scrollView.xz_refreshManager scrollViewDidEndDecelerating:scrollView];
                ((void (*)(id<UIScrollViewDelegate>, SEL, id))objc_msgSend)(self, selector, scrollView);
            };
        });
    }
    
    {
        SEL          const selector = @selector(scrollViewWillBeginDragging:);
        const char * const encoding = xz_objc_class_getMethodTypeEncoding(self.class, selector);
        xz_objc_class_addMethodWithBlock(aClass, selector, encoding, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewWillBeginDragging:scrollView];
        }, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
            [scrollView.xz_refreshManager scrollViewWillBeginDragging:scrollView];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass(aClass)
            };
            ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&super, selector, scrollView);
        }, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView) {
                [scrollView.xz_refreshManager scrollViewWillBeginDragging:scrollView];
                ((void (*)(id<UIScrollViewDelegate>, SEL, id))objc_msgSend)(self, selector, scrollView);
            };
        });
    }
    
    {
        SEL          const selector = @selector(scrollViewDidEndDragging:willDecelerate:);
        const char * const encoding = xz_objc_class_getMethodTypeEncoding(self.class, selector);
        xz_objc_class_addMethodWithBlock(aClass, selector, encoding, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, BOOL decelerate) {
            [scrollView.xz_refreshManager scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }, ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, BOOL decelerate) {
            [scrollView.xz_refreshManager scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass(aClass)
            };
            ((void (*)(struct objc_super *, SEL, id, BOOL))objc_msgSendSuper)(&super, selector, scrollView, decelerate);
        }, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(id<UIScrollViewDelegate> self, UIScrollView *scrollView, BOOL decelerate) {
                [scrollView.xz_refreshManager scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
                ((void (*)(id<UIScrollViewDelegate>, SEL, id, BOOL))objc_msgSend)(self, selector, scrollView, decelerate);
            };
        });
    }
    
    // 重新设置代理。
    // UIScrollView 对代理进行了优化，直接获取了代理方法 -scrollViewDidScroll: 的方法实现，
    // 在发送事件时，直接执行调用方法实现，为了让动态添加的方法生效，需要重新设置一遍代理。
    // 重复设置 delegate 属性无效，因为值未改变，UIScrollView 不会重新获取 Method 。
    scrollView.delegate = self;
    scrollView.delegate = delegate;
}

- (void)setHeaderRefreshView:(XZRefreshView *)headerRefreshView {
    if (_header.refreshView == headerRefreshView) {
        return;
    }
    if (_footer.refreshView == headerRefreshView) {
        [self setFooterRefreshView:nil];
    }
    
    [_header.refreshView removeFromSuperview];
    headerRefreshView.refreshManager = self;
    _header.refreshView = headerRefreshView;
    if (headerRefreshView != nil) {
        [_scrollView addSubview:headerRefreshView];
    }
    
    [self setNeedsLayoutHeaderRefreshView];
}

- (void)setFooterRefreshView:(XZRefreshView *)footerRefreshView {
    if (_footer.refreshView == footerRefreshView) {
        return;
    }
    if (_header.refreshView == footerRefreshView) {
        [self setHeaderRefreshView:nil];
    }
    
    [_footer.refreshView removeFromSuperview];
    footerRefreshView.refreshManager = self;
    _footer.refreshView = footerRefreshView;
    if (footerRefreshView != nil) {
        [_scrollView addSubview:footerRefreshView];
    }
    
    [self setNeedsLayoutFooterRefreshView];
}

- (XZRefreshView *)headerRefreshView {
    if (_header.refreshView != nil) {
        return _header.refreshView;
    }
    UIScrollView *  const _scrollView = self->_scrollView;
    CGFloat         const y           = -_scrollView.adjustedContentInset.top - XZRefreshHeight;
    XZRefreshView * const refreshView = [[XZRefreshView.defaultHeaderClass alloc] initWithFrame:CGRectMake(0, y, _scrollView.frame.size.width, XZRefreshHeight)];
    [self setHeaderRefreshView:refreshView];
    return refreshView;
}

- (XZRefreshView *)footerRefreshView {
    if (_footer.refreshView != nil) {
        return _footer.refreshView;
    }
    UIScrollView *  const _scrollView = self->_scrollView;
    UIEdgeInsets    const insets = _scrollView.adjustedContentInset;
    CGRect          const bounds = _scrollView.bounds;
    CGFloat         const y      = MAX(_scrollView.contentSize.height, bounds.size.height - insets.top - insets.bottom) + insets.bottom;
    XZRefreshView * const refreshView = [[XZRefreshView.defaultFooterClass alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, XZRefreshHeight)];
    [self setFooterRefreshView:refreshView];
    return refreshView;
}

- (XZRefreshView *)headerRefreshViewIfLoaded {
    return _header.refreshView;
}

- (XZRefreshView *)footerRefreshViewIfLoaded {
    return _footer.refreshView;
}

- (void)setNeedsLayoutHeaderRefreshView {
    if (!_header.refreshView || _header.needsLayout) {
        return;
    }
    _header.needsLayout = YES;
    __weak typeof(self) wself = self;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [wself layoutHeaderRefreshViewIfNeeded];
    }];
}

- (void)setNeedsLayoutFooterRefreshView {
    if (!_footer.refreshView || _footer.needsLayout) {
        return;
    }
    _footer.needsLayout = YES;
    __weak typeof(self) wself = self;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [wself layoutFooterRefreshViewIfNeeded];
    }];
}

- (void)setNeedsLayoutRefreshViews {
    [self setNeedsLayoutHeaderRefreshView];
    [self setNeedsLayoutFooterRefreshView];
}

- (void)layoutRefreshViewsIfNeeded {
    [self layoutHeaderRefreshViewIfNeeded];
    [self layoutFooterRefreshViewIfNeeded];
}

- (void)layoutHeaderRefreshViewIfNeeded {
    if (_header.needsLayout) {
        [self layoutHeaderRefreshView];
        _header.needsLayout = NO;
    }
}

// 1、头部刷新视图布局在可视区域之上，按边距适配方式确定可视区域。
// 2、偏移 offset 为在默认默认布局基础之上，按 offset 向上偏移 -offset 。
// 在刷新时，刷新高度 refreshHeight 会合并到 .contentInset.top 中。
- (void)layoutHeaderRefreshView {
    XZLog(@"布局 Header");
    XZRefreshContext * const _header      = self->_header;
    XZRefreshView    * const _refreshView = _header.refreshView;
    if (_refreshView == nil) {
        return;
    }
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_header.state & XZRefreshMaskContentInsets) {
        // 更新刷新参数
        // 如果在刷新的过程中，调整了刷新高度，那么将差值合并到边距上以适配刷新高度的变化。
        CGFloat const oldRefreshHeight = _header.refreshHeight;
        CGFloat const newRefreshHeight = _refreshView.refreshHeight;
        if (newRefreshHeight != oldRefreshHeight) {
            // 调整 contentInset 可能会引起 UIScrollView 出现非预期的滚动，此处不处理，由修改 refreshHeight 的逻辑处理。
            _scrollView.contentInset = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, newRefreshHeight - oldRefreshHeight);
            _header.refreshHeight = newRefreshHeight;
        }
        _header.adjustment = _refreshView.adjustment;
        _header.offset     = _refreshView.offset;
        
        _bounds                = _scrollView.bounds;
        _adjustedContentInsets = _scrollView.adjustedContentInset;
        
        CGFloat const h = CGRectGetHeight(_refreshView.frame);
        
        // 因为在刷新状态下，刷新高度 refreshHeight 会添加到 .contentInset 属性中，
        // 而 layoutInsets 是适配后的值，所以直接使用 layoutInsets 来计算 y 坐标。
        CGFloat y = 0;
        switch (_header.adjustment) {
            case XZRefreshAdjustmentAutomatic:
                y = -(_adjustedContentInsets.top - _header.refreshHeight) - h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop;
                break;
            case XZRefreshAdjustmentNormal: {
                _contentInsets = _scrollView.contentInset;
                y = -(_contentInsets.top - _header.refreshHeight) - h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop | XZAxisContentInsetsTop;
                break;
            }
            case XZRefreshAdjustmentNone:
                y = -h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop;
                break;
        }
        CGRect  const frame = CGRectMake(CGRectGetMinX(_bounds), y - _header.offset, CGRectGetWidth(_bounds), h);
        
        _header.frame = frame;
        _header.contentOffsetY = -_adjustedContentInsets.top;
        _refreshView.frame = frame;
    } else {
        _header.refreshHeight = _refreshView.refreshHeight;
        _header.adjustment    = _refreshView.adjustment;
        _header.offset        = _refreshView.offset;
        
        _bounds                = _scrollView.bounds;
        _adjustedContentInsets = _scrollView.adjustedContentInset;
        
        CGFloat const h = CGRectGetHeight(_refreshView.frame);
        
        CGFloat y = 0;
        switch (_header.adjustment) {
            case XZRefreshAdjustmentAutomatic:
                y = -_adjustedContentInsets.top - h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop;
                break;
            case XZRefreshAdjustmentNormal: {
                _contentInsets = _scrollView.contentInset;
                y = -_contentInsets.top - h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop | XZAxisContentInsetsTop;
                break;
            }
            case XZRefreshAdjustmentNone:
                y = -h;
                _headerAxis = XZAxisBoundsX | XZAxisBoundsWidth | XZAxisAdjustedContentInsetsTop;
                break;
        }
        CGRect const frame = CGRectMake(CGRectGetMinX(_bounds), y - _header.offset, CGRectGetWidth(_bounds), h);
        
        _header.frame = frame;
        _header.contentOffsetY = -_adjustedContentInsets.top;
        _refreshView.frame = frame;
    }
}

- (void)layoutFooterRefreshViewIfNeeded {
    if (_footer.needsLayout) {
        [self layoutFooterRefreshView];
        _footer.needsLayout = NO;
    }
}

/// 尾部刷新视图的布局规则：
/// 一、不刷新时。
/// 刷新视图布局在页面底部之下，即，刷新视图的顶边，与可见区域的底边相同。
/// 因此可通过 scrollViewHeight 计算出撑满一屏为最小高度公式为
/// minHeight = scrollViewHeight - top - bottom 。
/// 二、正刷新时。
/// 在附加了底部刷新高度边距后，如果页面高度仍不满足一屏，刷新视图刷新放在底部，
/// 满足一屏，正常布局，放在页面尾部即可。
- (void)layoutFooterRefreshView {
    XZLog(@"布局 Footer");
    XZRefreshContext * const _footer      = self->_footer;
    XZRefreshView    * const _refreshView = _footer.refreshView;
    if (!_refreshView) {
        return;
    }
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_footer.state & XZRefreshMaskContentInsets) {
        // refreshHeight 已经合并到 bottom 中
        CGFloat const oldRefreshHeight = _footer.refreshHeight;
        CGFloat const newRefreshHeight = _refreshView.refreshHeight;
        if (newRefreshHeight != oldRefreshHeight) {
            _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, newRefreshHeight - oldRefreshHeight);
            _footer.refreshHeight = newRefreshHeight;
        }
        _footer.adjustment = _refreshView.adjustment;
        _footer.offset     = _refreshView.offset;
        
        _bounds      = _scrollView.bounds;
        _contentSize = _scrollView.contentSize;
        _adjustedContentInsets = _scrollView.adjustedContentInset;
        
        // 在刷新过程中 .contentInset.bottom 的值为“原始值 + 刷新高度”
        // 因此需要计算出原始值，然后再判断页面高度是否满足一屏。
        CGFloat      const minPageHeight = _bounds.size.height - _adjustedContentInsets.top - _adjustedContentInsets.bottom;
        BOOL         const isPageFilled  = _contentSize.height >= minPageHeight;
        CGFloat      const h = CGRectGetHeight(_refreshView.frame);
        
        _footerAxis = XZAxisBoundsHeight | XZAxisContentSizeHeight | XZAxisAdjustedContentInsetsTop | XZAxisAdjustedContentInsetsBottom;
        
        CGFloat y = 0;
        CGFloat contentOffsetY = 0;
        switch (_footer.adjustment) {
            case XZRefreshAdjustmentAutomatic:
                if (isPageFilled) {
                    y = _contentSize.height + _adjustedContentInsets.bottom - _footer.refreshHeight;
                    contentOffsetY = _contentSize.height + _adjustedContentInsets.bottom - _bounds.size.height;
                } else {
                    y = _bounds.size.height - _adjustedContentInsets.top - _footer.refreshHeight;
                    contentOffsetY = -_adjustedContentInsets.top;
                }
                break;
            case XZRefreshAdjustmentNormal: {
                _contentInsets = _scrollView.contentInset;
                if (isPageFilled) {
                    y = _contentSize.height + _contentInsets.bottom - _footer.refreshHeight;
                    contentOffsetY = _contentSize.height + _adjustedContentInsets.bottom - _bounds.size.height;
                } else {
                    y = _bounds.size.height - _adjustedContentInsets.top - _adjustedContentInsets.bottom + _contentInsets.bottom - _footer.refreshHeight;
                    contentOffsetY = -_adjustedContentInsets.top;
                }
                _footerAxis = _footerAxis | XZAxisContentInsetsBottom;
                break;
            }
            case XZRefreshAdjustmentNone:
                if (isPageFilled) {
                    y = _contentSize.height;
                    contentOffsetY = _contentSize.height + _adjustedContentInsets.bottom - _bounds.size.height;
                } else {
                    y = _bounds.size.height - _adjustedContentInsets.top - _adjustedContentInsets.bottom;
                    contentOffsetY = -_adjustedContentInsets.top;
                }
                break;
        }
        CGRect const frame = CGRectMake(CGRectGetMinX(_bounds), y + _footer.offset, CGRectGetWidth(_bounds), h);
        _footerAxis = _footerAxis | XZAxisBoundsX | XZAxisBoundsWidth;
        
        _footer.frame = frame;
        _footer.contentOffsetY = contentOffsetY;
        _footer.needsAnimatedTransitioning = (_adjustedContentInsets.top + _contentSize.height < _bounds.size.height); // ScrollingAnimation
        _refreshView.frame = frame;
    } else {
        _footer.refreshHeight = _refreshView.refreshHeight;
        _footer.adjustment    = _refreshView.adjustment;
        _footer.offset        = _refreshView.offset;
        
        _bounds      = _scrollView.bounds;
        _contentSize = _scrollView.contentSize;
        _adjustedContentInsets = _scrollView.adjustedContentInset;
        
        // 顶部在刷新时，顶部的边距需要减去刷新高度
        BOOL         const isHeaderRefreshing   = _header.state & XZRefreshMaskContentInsets;
        UIEdgeInsets const adjustedContentInset = isHeaderRefreshing ? UIEdgeInsetsIncreaseTop(_adjustedContentInsets, _header.refreshHeight) : _adjustedContentInsets;
        CGFloat      const minPageHeight        = _bounds.size.height - adjustedContentInset.top - adjustedContentInset.bottom;
        BOOL         const isPageFilled = _contentSize.height >= minPageHeight;
        
        _footerAxis = XZAxisBoundsHeight | XZAxisContentSizeHeight | XZAxisAdjustedContentInsetsTop | XZAxisAdjustedContentInsetsBottom;

        CGFloat y = 0;
        CGFloat contentOffsetY = 0;
        switch (_footer.adjustment) {
            case XZRefreshAdjustmentAutomatic:
                if (isPageFilled) {
                    y = _contentSize.height + adjustedContentInset.bottom;
                    contentOffsetY = _contentSize.height + adjustedContentInset.bottom - _bounds.size.height;
                } else {
                    y = minPageHeight + adjustedContentInset.bottom;
                    contentOffsetY = -adjustedContentInset.top;
                }
                break;
            case XZRefreshAdjustmentNormal: {
                _contentInsets = _scrollView.contentInset;
                UIEdgeInsets const contentInset = isHeaderRefreshing ? UIEdgeInsetsIncreaseTop(_contentInsets, _header.refreshHeight) : _contentInsets;
                if (isPageFilled) {
                    y = _contentSize.height + contentInset.bottom;
                    contentOffsetY = _contentSize.height + adjustedContentInset.bottom - _bounds.size.height;
                } else {
                    y = minPageHeight + contentInset.bottom;
                    contentOffsetY = -adjustedContentInset.top;
                }
                _footerAxis = _footerAxis | XZAxisContentInsetsBottom;
                break;
            }
            case XZRefreshAdjustmentNone:
                if (isPageFilled) {
                    y = _contentSize.height;
                    contentOffsetY = _contentSize.height + adjustedContentInset.bottom - _bounds.size.height;
                } else {
                    y = minPageHeight;
                    contentOffsetY = -adjustedContentInset.top;
                }
                break;
        }
        CGRect const frame = CGRectMake(CGRectGetMinX(_bounds), y + _footer.offset, CGRectGetWidth(_bounds), CGRectGetHeight(_refreshView.frame));
        _footerAxis = _footerAxis | XZAxisBoundsX | XZAxisBoundsWidth;
        
        _footer.frame = frame;
        _footer.contentOffsetY = contentOffsetY;
        _footer.needsAnimatedTransitioning = NO;
        _refreshView.frame = frame;
    }
}

/// 判断指定的 HeaderFooterView 是否在动画中。
- (BOOL)isRefreshViewAnimating:(XZRefreshView *)refreshingView {
    if (refreshingView == _header.refreshView) {
        return (_header.state & XZRefreshMaskRefreshing);
    }
    if (refreshingView == _footer.refreshView) {
        return (_footer.state & XZRefreshMaskRefreshing);
    }
    return NO;
}

- (void)refreshingView:(XZRefreshView *)refreshingView beginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (refreshingView == _header.refreshView) {
        [self beginHeaderRefreshing:animated completion:completion];
    } else if (refreshingView == _footer.refreshView) {
        [self beginFooterRefreshing:animated completion:completion];
    } else {
        dispatch_main_async(completion, NO);
    }
}

- (void)beginHeaderRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_header.state != XZRefreshStatePendinging || _footer.state != XZRefreshStatePendinging) {
        dispatch_main_async(completion, NO);
        return;
    }
    
    // 避免调用时，可能还没有同步 context 值
    [self layoutHeaderRefreshViewIfNeeded];
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_scrollView.isDragging) {
        _header.state = XZRefreshStateWillRefreshing;
        dispatch_main_async(completion, NO);
    } else {
        // 先修改状态，避免后续操作引起的 -scrollViewDidScroll: 代理方法错误判断状态问题。
        _header.state = XZRefreshStateRefreshing;
        
        // 将刷新高度 refreshHeight 增加到 .contentInset 属性中：
        // 1、增加到 contentInset 的边距会叠加到 adjustedContentInset 中
        // 2、改变 contentInset 会触发 didScroll 事件，且可能会改变 contentOffset 因此需要记录原始值，然后恢复
        // 3、设置 bounds 不会触发 didScroll 事件，但是子视图也不会更新，比如在 tableView 底部触发刷新，页面回到顶部时，没有加载cell
        CGPoint const contentOffset = _scrollView.contentOffset;
        _scrollView.contentInset = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, _header.refreshHeight);
        _scrollView.contentOffset = contentOffset;
        
        // 使用 UIView 动画直接进入刷新状态。
        // 因为动画的高度不一定是下拉刷新所需的距离，所以使用 -setContentOffset:animated: 滚动 UIScrollView 的方法可能不会触发刷新状态。
        UIViewAnimate(animated, ^{
            [self layoutHeaderRefreshView];
            _scrollView.contentOffset = CGPointMake(0, self->_header.contentOffsetY);
        }, completion);
    }
    
    // 通知刷新视图，进入刷新状态
    [_header.refreshView scrollView:_scrollView didBeginRefreshing:animated];
}

- (void)beginFooterRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_footer.state != XZRefreshStatePendinging || _header.state != XZRefreshStatePendinging) {
        dispatch_main_async(completion, NO);
        return;
    }
    [self layoutFooterRefreshViewIfNeeded];
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_scrollView.isDragging) {
        _footer.state = XZRefreshStateWillRefreshing;
        dispatch_main_async(completion, NO);
    } else {
        _footer.state = XZRefreshStateRefreshing;
        
        // 调整 contentInset
        CGPoint const contentOffset = _scrollView.contentOffset;
        _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, _footer.refreshHeight);
        _scrollView.contentOffset = contentOffset;
        
        // 滚动到 footer
        UIViewAnimate(animated, ^{
            [self layoutFooterRefreshView];
            _scrollView.contentOffset = CGPointMake(0, self->_footer.contentOffsetY);
        }, completion);
    }
    
    [_footer.refreshView scrollView:_scrollView didBeginRefreshing:animated];
}

- (void)refreshingView:(XZRefreshView *)refreshingView endAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (refreshingView == _header.refreshView) {
        [self endHeaderRefreshing:animated completion:completion];
    } else if (refreshingView == _footer.refreshView) {
        [self endFooterRefreshing:animated completion:completion];
    } else {
        dispatch_main_async(completion, NO);
    }
}

- (void)endHeaderRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    XZRefreshContext * const _header = self->_header;
    if (!(_header.state & XZRefreshMaskRefreshing)) {
        dispatch_main_async(completion, NO);
        return;
    }
    
    UIScrollView * const _scrollView   = self->_scrollView;
    CGPoint        const contentOffset = _scrollView.contentOffset;
    
    if (_scrollView.isDragging) {
        // 当拖拽时，结束刷新仅展示结束动画，布局调整在 -willEndDragging 中处理。
        _header.state = XZRefreshStateWillRecovering;
        // 使用 YES 标记，以通知刷新视图执行结束动画
        [_header.refreshView scrollView:_scrollView willEndRefreshing:YES];
        // NO 表示结束的动画在回调执行时没有完成
        dispatch_main_async(completion, NO);
    } else {
        // 恢复 contentInset
        // 理论上应该先改状态，然后再执行其它操作。
        // 但是由于修改 contentInset/contentOffset 属性会触发 -scrollViewDidScroll: 方法，
        // 所以在还处于 refreshing 时修改，可以避免 -scrollViewDidScroll: 中的操作逻辑。
        if (_header.state & XZRefreshMaskContentInsets) {
            _scrollView.contentInset = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, -_header.refreshHeight);
        }
        
        // 刷新视图不在展示区域内时，不需要展示结束刷新的动画
        if (contentOffset.y >= _header.contentOffsetY + _header.refreshHeight) {
            _scrollView.contentOffset = contentOffset;
            _header.state = XZRefreshStateRecovering;
            [_header.refreshView scrollView:_scrollView willEndRefreshing:NO];
            
            [self layoutHeaderRefreshView];
            
            _header.state = XZRefreshStatePendinging;
            [_header.refreshView scrollView:_scrollView didEndRefreshing:NO];
            dispatch_main_async(completion, NO);
        } else {
            // 使用 -setContentOffset:animated: 前结束滚动减速过程。
            // 在 XZRefreshStateRecovering 状态下，减速动画结束时，会执行清理操作，可能会提前移除退场动画。
            [_scrollView setContentOffset:contentOffset animated:NO];
            _header.state = XZRefreshStateRecovering;
            [_header.refreshView scrollView:_scrollView willEndRefreshing:animated];
            
            UIViewAnimate(animated, ^{
                [self layoutHeaderRefreshView];
                _scrollView.contentOffset = CGPointMake(contentOffset.x, self->_header.contentOffsetY);
            }, ^(BOOL finished) {
                _header.state = XZRefreshStatePendinging;
                [_header.refreshView scrollView:_scrollView didEndRefreshing:YES];
                dispatch_main_async(completion, finished);
            });
        }
    }
}

- (void)endFooterRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    XZRefreshContext * const _footer = self->_footer;
    if (!(_footer.state & XZRefreshMaskRefreshing)) {
        dispatch_main_async(completion, NO);
        return;
    }
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_scrollView.isDragging) {
        _footer.state = XZRefreshStateWillRecovering;
        [_footer.refreshView scrollView:_scrollView willEndRefreshing:YES];
        
        // 底部刷新往往发生在列表数据改变之后，即 contentSize 可能发生了改变。
        // 因此使用动画来调整刷新视图。
        UIViewAnimate(animated, ^{
            [self layoutFooterRefreshView];
        }, ^(BOOL finished) {
            dispatch_main_async(completion, NO);
        });
    } else {
        CGPoint const contentOffset = _scrollView.contentOffset;
        
        // 恢复边距
        if (_footer.state & XZRefreshMaskContentInsets) {
            _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, -_footer.refreshHeight);
        }
        
        if (contentOffset.y <= _footer.contentOffsetY - _footer.refreshHeight) {
            _scrollView.contentOffset = contentOffset;
            // 尾部刷新视图没有在展示区域内，页面不需要动
            // 下拉加载更多后，footer 已经不展示在可见范围，footer 的动画在 kvo 时处理了
            _footer.state = XZRefreshStateRecovering;
            [_footer.refreshView scrollView:_scrollView willEndRefreshing:NO];
            
            [self layoutFooterRefreshView];
            
            _footer.state = XZRefreshStatePendinging;
            [_footer.refreshView scrollView:_scrollView didEndRefreshing:NO];
            dispatch_main_async(completion, NO);
        } else {
            [_scrollView setContentOffset:contentOffset animated:NO];
            _footer.state = XZRefreshStateRecovering;
            [_footer.refreshView scrollView:_scrollView willEndRefreshing:animated];
            
            UIViewAnimate(animated, ^{
                [self layoutFooterRefreshView];
                
                if (_footer.contentOffsetY < contentOffset.y) {
                    _scrollView.contentOffset = CGPointMake(contentOffset.x, _footer.contentOffsetY);
                }
            }, ^(BOOL finished) {
                _footer.state = XZRefreshStatePendinging;
                [_footer.refreshView scrollView:_scrollView didEndRefreshing:animated];
                dispatch_main_async(completion, finished);
            });
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView * const)scrollView {
    XZLog(@"");
    if (scrollView != _scrollView) {
        return;
    }
    
    CGRect const bounds = scrollView.bounds;
    
    
    
    // 头部已处于刷新状态时，不响应页面滚动
    if (_header.state != XZRefreshStatePendinging) {
        return;
    }
    
    // 底部已处于刷新状态时，不响应页面滚动，但需处理底部的恢复动画。
    if (_footer.state != XZRefreshStatePendinging) {
        if (_footer.needsAnimatedTransitioning) {
            
            CGFloat const newY   = scrollView.contentOffset.y + bounds.size.height - _footer.refreshHeight + _footer.offset;
            CGRect newFrame = _footer.refreshView.frame;
            if (newY <= _footer.frame.origin.y) {
                _footer.refreshView.frame = _footer.frame;
                _footer.needsAnimatedTransitioning = NO;
            } else if (newY < newFrame.origin.y) {
                newFrame.origin.y = newY;
                _footer.refreshView.frame = newFrame;
            }
        }
        return;
    }
    
    CGPoint const contentOffset = scrollView.contentOffset;
    
    // iOS 18：当 adjustedContentInset 发生改变后，方法 -scrollViewDidScroll: 先于 -adjustedContentInsetDidChange: 调用。
    // 导致 XZRefreshManager 在 -scrollViewDidScroll: 方法中，因 header/footer 的 context 不正确而不能正确地判断下拉/上拉状态。
    // 现象：进入页面后 headerRefreshView 的初始状态不正确。
    // 因为初始化时，adjustedContentInset 为 zero，页面展示后，adjustedContentInset 更新先调用 -scrollViewDidScroll: 方法时，
    // 错误的将 .top 判断为下拉距离，从而展示了异常状态。
    if (XZAxisCompareBounds(_headerAxis, _bounds, bounds)
        || XZAxisCompareContentSize(_headerAxis, _contentSize, scrollView.contentSize)
        || XZAxisCompareContentInsets(_headerAxis, _contentInsets, scrollView.contentInset)
        || XZAxisCompareAdjustedContentInsets(_headerAxis, _adjustedContentInsets, scrollView.adjustedContentInset)) {
        [self layoutHeaderRefreshView];
    }
    
    if (XZAxisCompareBounds(_footerAxis, _bounds, bounds)
        || XZAxisCompareContentSize(_footerAxis, _contentSize, scrollView.contentSize)
        || XZAxisCompareContentInsets(_footerAxis, _contentInsets, scrollView.contentInset)
        || XZAxisCompareAdjustedContentInsets(_footerAxis, _adjustedContentInsets, scrollView.adjustedContentInset)) {
        [self layoutFooterRefreshView];
    }
//    if (!UIEdgeInsetsEqualToEdgeInsets(scrollView.adjustedContentInset, _adjustedContentInsets)) {
//        [self layoutFooterRefreshView];
//        [self layoutHeaderRefreshView];
//    } else if (!CGSizeEqualToSize(scrollView.contentSize, _contentSize)) {
//        [self layoutFooterRefreshView];
//    } else if (!CGSizeEqualToSize(scrollView.bounds.size, _frameSize)) {
//        [self layoutFooterRefreshView];
//    }
    
    // 进入了下拉刷新的区域
    if (contentOffset.y < _header.contentOffsetY) {
        
        // 如果上一个状态是上拉加载，通知 footer 上拉已经结束了。
        if (_distance > 0) {
            [_footer.refreshView scrollView:_scrollView didScrollRefreshing:0];
        }
        
        // 计算滚动距离
        _distance = contentOffset.y - _header.contentOffsetY;
        
        // 通知刷新视图下拉的距离
        [_header.refreshView scrollView:_scrollView didScrollRefreshing:-_distance];
        
        // 如果满足自动刷新，则进入刷新状态
        if (_header.isAutomatic && contentOffset.y - _header.contentOffsetY <= _header.automaticRefreshDistance) {
            // 自动刷新
            _header.isAutomatic = NO;
            [self _beginHeaderRefreshingAtContentOffset:NULL];
        } else {
            
        }
        return;
    }
    
    // 进入了上拉加载的区域
    // 如果满足自动刷新，则进入刷新状态，否则通知视图上拉进度
    if (contentOffset.y > _footer.contentOffsetY) {
        // 如果上一个状态是上拉加载，通知 header 下拉已经结束了。
        if (_distance < 0) {
            [_header.refreshView scrollView:_scrollView didScrollRefreshing:0];
        }
        
        // 上拉距离
        _distance = contentOffset.y - _footer.contentOffsetY;
        
        // 通知刷新视图上拉距离
        [_footer.refreshView scrollView:_scrollView didScrollRefreshing:_distance];
        
        // 如果满足自动刷新，则进入刷新状态
        if (_footer.isAutomatic && _footer.contentOffsetY - contentOffset.y <= _footer.automaticRefreshDistance) {
            _footer.isAutomatic = NO;
           [self _beginFooterRefreshingAtContentOffset:NULL];
        }
        return;
    }
    
    // 未在下拉或上拉区域，归零刷新状态
    if (_distance < 0) {
        _distance = 0;
        [_header.refreshView scrollView:_scrollView didScrollRefreshing:0];
    } else if (_distance > 0) {
        _distance = 0;
        [_footer.refreshView scrollView:_scrollView didScrollRefreshing:0];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)_scrollView {
    XZLog(@"");
    if (_scrollView != self->_scrollView) {
        return;
    }
    if (_header.refreshView.automaticRefreshDistance > 0) {
        CGFloat const y = _scrollView.contentOffset.y;
        _header.automaticRefreshDistance = _header.refreshView.automaticRefreshDistance;
        _header.isAutomatic = (y - _header.contentOffsetY > _header.automaticRefreshDistance);
    } else {
        _header.isAutomatic = NO;
    }
    if (_footer.refreshView.automaticRefreshDistance > 0) {
        CGFloat const y = _scrollView.contentOffset.y;
        _footer.automaticRefreshDistance = _footer.refreshView.automaticRefreshDistance;
        _footer.isAutomatic = (_footer.contentOffsetY - y > _footer.automaticRefreshDistance);
    } else {
        _footer.isAutomatic = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView * const)_scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    XZLog(@"");
    if (_scrollView != self->_scrollView) {
        return;
    }
    
    XZRefreshContext * const _header = self->_header;
    
    switch (_header.state) {
        case XZRefreshStatePendinging: {
            if (_distance < 0) {
                if ([_header.refreshView scrollView:_scrollView shouldBeginRefreshing:-_distance]) {
                    [self _beginHeaderRefreshingAtContentOffset:targetContentOffset];
                }
                return;
            }
            break;
        }
        case XZRefreshStateWillRefreshing: {
            _header.state = XZRefreshStateRefreshing;
            
            CGPoint const contentOffset = _scrollView.contentOffset;
            _scrollView.contentInset  = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, _header.refreshHeight);
            _scrollView.contentOffset = contentOffset;
            
            [self layoutHeaderRefreshView];
            
            targetContentOffset->y = _header.contentOffsetY;
            return;
        }
        case XZRefreshStateWillRecovering: {
            UIScrollView     * const _scrollView   = self->_scrollView;
            XZRefreshContext * const _header       = self->_header;
            CGPoint            const contentOffset = _scrollView.contentOffset;
            
            _scrollView.contentInset = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, -_header.refreshHeight);
            _scrollView.contentOffset = contentOffset;
            
            _header.state = XZRefreshStateRecovering;
            [self layoutHeaderRefreshView];
            
            if (contentOffset.y < _header.contentOffsetY) {
                targetContentOffset->y = _header.contentOffsetY;
            }
            return;
        }
        default:
            break;
    }
    
    XZRefreshContext * const _footer = self->_footer;
    
    switch (_footer.state) {
        case XZRefreshStatePendinging: {
            if (_distance > 0) {
                if ([_footer.refreshView scrollView:_scrollView shouldBeginRefreshing:+_distance]) {
                    [self _beginFooterRefreshingAtContentOffset:targetContentOffset];
                }
                return;
            }
            break;
        }
        case XZRefreshStateWillRefreshing: {
            _footer.state = XZRefreshStateRefreshing;
            
            CGPoint const contentOffset = _scrollView.contentOffset;
            _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, _footer.refreshHeight);
            _scrollView.contentOffset = contentOffset;
            
            [self layoutFooterRefreshView];
            
            targetContentOffset->y = _footer.contentOffsetY;
            return;
        }
        case XZRefreshStateWillRecovering: {
            UIScrollView     * const _scrollView   = self->_scrollView;
            XZRefreshContext * const _footer       = self->_footer;
            CGPoint            const contentOffset = _scrollView.contentOffset;
            
            // 恢复边距
            _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, -_footer.refreshHeight);
            _scrollView.contentOffset = contentOffset;
            
            _footer.state = XZRefreshStateRecovering;
            [self layoutFooterRefreshView];
            
            if (contentOffset.y > _footer.contentOffsetY) {
                targetContentOffset->y = _footer.contentOffsetY;
            }
            return;
        }
        default: {
            break;
        }
    }
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    XZLog(@"是否减速：%d", decelerate);
    if (decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    XZLog(@"");
    if (scrollView != _scrollView) {
        return;
    }
    
    switch (_header.state) {
        case XZRefreshStateRecovering:
            _header.state = XZRefreshStatePendinging;
            [_header.refreshView scrollView:scrollView didEndRefreshing:YES];
            return;
            
        default:
            break;
    }
    
    switch (_footer.state) {
        case XZRefreshStateRecovering:
            _footer.state = XZRefreshStatePendinging;
            [_footer.refreshView scrollView:scrollView didEndRefreshing:YES];
            break;
            
        default:
            break;
    }
}

- (void)_beginHeaderRefreshingAtContentOffset:(inout CGPoint * _Nullable)targetContentOffset {
    UIScrollView *     const _scrollView   = self->_scrollView;
    XZRefreshContext * const _header       = self->_header;
    CGPoint            const contentOffset = _scrollView.contentOffset;
    
    _distance = 0;
    _header.state = XZRefreshStateRefreshing;
    
    // 增加到 contentInset 的边距会叠加到 adjustedContentInset 中
    // 改变 contentInset 会触发 didScroll 方法，可能改变 contentOffset
    _scrollView.contentInset  = UIEdgeInsetsIncreaseTop(_scrollView.contentInset, _header.refreshHeight);
    _scrollView.contentOffset = contentOffset;
    
    [self layoutHeaderRefreshView];
    
    if (targetContentOffset) {
        targetContentOffset->y = _header.contentOffsetY;
    }
    
    [_header.refreshView scrollView:_scrollView didBeginRefreshing:NO];
    // [_header.view sendActionsForControlEvents:(UIControlEventValueChanged)];
    
    id<XZRefreshDelegate> const delegate = _header.refreshView.delegate ?: (id)_scrollView.delegate;
    if ([delegate respondsToSelector:@selector(scrollView:headerDidBeginRefreshing:)]) {
        // 由于结束刷新的动画是 UIView 动画，会立即设置 contentOffset 到目标位置，
        // 而当前方法可能处于手势结束，进入减速前的准备状态中，如果直接同步发送代理事件，
        // 那么在代理方法中立即结束刷新，会导致减速状态在此方法返回后立即完成，
        // 即 -scrollViewDidEndDecelerating: 方法在结束刷新的 UIView 动画结束前执行，
        // 从而导致退场动画被提前清理，丢失动画效果。
        dispatch_main_async_imp(^{
            [delegate scrollView:_scrollView headerDidBeginRefreshing:_header.refreshView];
        });
    }
}

- (void)_beginFooterRefreshingAtContentOffset:(inout CGPoint * _Nullable)targetContentOffset {
    XZRefreshContext * const _footer       = self->_footer;
    UIScrollView *     const _scrollView   = self->_scrollView;
    CGPoint            const contentOffset = _scrollView.contentOffset;
    
    _distance = 0;
    _footer.state = XZRefreshStateRefreshing;
    
    _scrollView.contentInset = UIEdgeInsetsIncreaseBottom(_scrollView.contentInset, _footer.refreshHeight);
    _scrollView.contentOffset = contentOffset;

    CGRect const oldFrame = _footer.refreshView.frame;
    [self layoutFooterRefreshView];
    
    // 回弹的目标位置
    if (targetContentOffset) {
        targetContentOffset->y = _footer.contentOffsetY;
    }
    
    if (_footer.needsAnimatedTransitioning) {
        _footer.refreshView.frame = oldFrame;
    }

    [_footer.refreshView scrollView:_scrollView didBeginRefreshing:NO];
    // [_footer.view sendActionsForControlEvents:(UIControlEventValueChanged)];
    
    id<XZRefreshDelegate> const delegate = _footer.refreshView.delegate ?: (id)_scrollView.delegate;
    if ([delegate respondsToSelector:@selector(scrollView:footerDidBeginRefreshing:)]) {
        dispatch_main_async_imp(^{
            [delegate scrollView:_scrollView footerDidBeginRefreshing:_footer.refreshView];
        });
    }
}

@end

@import ObjectiveC;

// Association keys.
static const void * const _manager = &_manager;

@implementation UIScrollView (XZRefreshManager)

- (XZRefreshManager *)xz_refreshManager {
    XZRefreshManager *refreshingManager = objc_getAssociatedObject(self, _manager);
    if (refreshingManager != nil) {
        return refreshingManager;
    }
    refreshingManager = [[XZRefreshManager alloc] initWithScrollView:self];
    objc_setAssociatedObject(self, _manager, refreshingManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return refreshingManager;
}

- (XZRefreshManager *)xz_refreshManagerIfLoaded {
    return objc_getAssociatedObject(self, _manager);
}

@end


