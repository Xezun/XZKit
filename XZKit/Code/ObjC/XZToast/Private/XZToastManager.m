//
//  XZToastManager.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastManager.h"
#import <objc/runtime.h>
#import "XZToastContainerView.h"
#import "XZToastTask.h"
#import "XZToast.h"

static void * _context = NULL;

@implementation XZToastManager {
    /// 视图控制器。
    UIView *_containerView;
    UIView *_blurView;
    
    /// 展示位置。
    XZToastPosition _position;
    /// 待展示的。
    NSMutableArray<XZToastTask *> *_waitingTasks;
    /// 展示中待。该集合仅在周期内才可以修改。
    NSMutableArray<XZToastTask *> *_showingTasks;
    /// 待移除的。
    NSMutableArray<XZToastTask *> *_hideingTasks;
    
    /// 此值为 YES 表明当前还有待展示或待隐藏的 toast 需要处理。
    /// @discussion 每个动画周期为一个 toast 更新周期。
    /// @discussion 当此值被标记为 YES 时，每个周期内，最多展示一个 toast 视图并移除所有到期的 toast 视图，直到没有待显示或待隐藏的 toast 视图。
    /// @discussion 请使用 `-setNeedsUpdateToasts` 方法，而不能直接修改此实例变量。
    BOOL _needsUpdateToasts;
    /// 每个 toast 周期执行的回调。
    /// 不要直接使用此变量设置值，而是使用 `-addUpdateCompletion:` 和 `-runUpdateCompletion` 方法。
    void (^_updateCompletion)(void);
    
    /// 布局的范围。
    CGRect _bounds;
    
    BOOL _needsLayoutToastViews;
    
}

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController {
    if (viewController == nil || !viewController.isViewLoaded) {
        return nil;
    }
    
    static const void * const _manager = &_manager;
    XZToastManager *manager = objc_getAssociatedObject(viewController, _manager);
    if (manager) {
        return manager;
    }
    
    UIView *_containerView = viewController.view;
    while ([_containerView isKindOfClass:UIScrollView.class]) {
        _containerView = _containerView.superview;
    }
    if (_containerView == nil) {
        _containerView = viewController.view;
    }
    
    // H:|-padding-spacing-[toast]-spacing-padding-|
    // V:|-padding-spacing-[toast]-spacing-[toast]-spacing-padding-|
    
    manager = [[XZToastManager alloc] initWithViewController:viewController];
    objc_setAssociatedObject(viewController, _manager, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return manager;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _containerView = viewController.view;
        
        _maximumNumberOfToasts = 3;
        _offsets = calloc(3, sizeof(XZToastPosition));
        
        UIEdgeInsets const safeAreaInsets = _containerView.safeAreaInsets;
        CGRect       const bounds         = _containerView.bounds;
        _bounds = CGRectInset(UIEdgeInsetsInsetRect(bounds, safeAreaInsets), XZToastMargin, XZToastMargin);
        [_containerView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:&_context];
        
        _waitingTasks = [NSMutableArray arrayWithCapacity:16];
        _showingTasks = [NSMutableArray arrayWithCapacity:16];
        _hideingTasks = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

- (void)dealloc {
    free(_offsets);
    _offsets = NULL;
    
    [_containerView removeObserver:self forKeyPath:@"bounds" context:&_context];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (&_context != context) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    UIEdgeInsets const safeAreaInsets = _containerView.safeAreaInsets;
    CGRect       const bounds         = _containerView.bounds;
    CGRect const newBounds = CGRectInset(UIEdgeInsetsInsetRect(bounds, safeAreaInsets), XZToastMargin, XZToastMargin);
    _blurView.frame = bounds;
    if (CGRectEqualToRect(_bounds, newBounds)) {
        return;
    }
    _bounds = newBounds;
    [self setNeedsLayoutToastViews];
}

- (void)setMaximumNumberOfToasts:(NSUInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(1, maximumNumberOfToasts);
    [self setNeedsUpdateToasts];
}

- (void)showToast:(XZToastTask *)task {
    [_waitingTasks addObject:task];
    [self setNeedsUpdateToasts];
}

- (void)hideToast:(nullable XZToastTask * const)task completion:(void (^const)(void))updateCompletion {
    if (task) {
        if ([_showingTasks containsObject:task]) {
            // 正在显示中，添加到待隐藏列队中
            [task cancel];
            [_hideingTasks addObject:task];
        } else if ([_waitingTasks containsObject:task]) {
            // 正在等待显示中，因为没有显示，直接取消
            [_waitingTasks removeObject:task];
            [task cancel];
            [_hideingTasks addObject:task];
        }
    } else {
        if (_showingTasks.count > 0) {
            for (XZToastTask * const task in _showingTasks) {
                [task cancel];
                [_hideingTasks addObject:task];
            }
        }
        if (_waitingTasks.count > 0) {
            do {
                XZToastTask * const task = _waitingTasks.lastObject;
                [_waitingTasks removeLastObject];
                [task cancel];
                [_hideingTasks addObject:task];
            } while (_waitingTasks.count > 0);
        }
    }
    
    [self addUpdateCompletion:updateCompletion];
    [self setNeedsUpdateToasts];
}

- (void)addUpdateCompletion:(void (^const)(void))updateCompletion {
    if (updateCompletion) {
        void (^const oldValue)(void) = _updateCompletion;
        if (oldValue) {
            _updateCompletion = ^{
                oldValue();
                updateCompletion();
            };
        } else {
            _updateCompletion = updateCompletion;
        }
    }
}

- (void)runUpdateCompletion {
    if (_updateCompletion) {
        _updateCompletion();
        _updateCompletion = nil;
    }
}

- (void)setNeedsUpdateToasts {
    if (_needsUpdateToasts) {
        return;
    }
    _needsUpdateToasts = YES;
    [self updateToastsIfNeeded];
}

- (void)updateToastsIfNeeded {
    if (!_needsUpdateToasts) {
        return;
    }
    
    // 只要 _waitingItems 或 _hideingItems 不为空，当前方法就会一直执行，直到处理完所有 toast
    if (_waitingTasks.count == 0 && _hideingTasks.count == 0) {
        if (_showingTasks.count == 0) {
            [_blurView removeFromSuperview];
            _blurView = nil;
        }
        _needsUpdateToasts = NO;
        // 执行周期回调
        [self runUpdateCompletion];
        return;
    }
    
    // 将等待中的 toast 出列一个显示。
    // 每次只展示一个，这样每个 toast 最少有 XZToastAnimationDuration * maxCount 的展示时间。
    XZToastTask * const newToastItem = _waitingTasks.firstObject;
    if (newToastItem) {
        [_waitingTasks removeObjectAtIndex:0];
        
        // 独占清屏
        if (newToastItem.isExclusive) {
            while (_showingTasks.count > 0) {
                XZToastTask *item = _showingTasks.lastObject;
                [_showingTasks removeLastObject];
                
                [item cancel];
                [_hideingTasks addObject:item];
            }
            if (_blurView == nil) {
                _blurView = [[XZToastBlurView alloc] initWithFrame:_containerView.bounds];
            }
            [_containerView addSubview:_blurView];
        } else {
            [_blurView removeFromSuperview];
            _blurView = nil;
        }
        
        // 展示位置不同，移除当前所有 toast
        if (_position != newToastItem.position) {
            _position = newToastItem.position;
            while (_showingTasks.count > 0) {
                XZToastTask *item = _showingTasks.lastObject;
                [_showingTasks removeLastObject];
                
                [item cancel];
                [_hideingTasks addObject:item];
            }
        }
        newToastItem.direction = !_showingTasks.lastObject.direction;
        [_showingTasks addObject:newToastItem];
        
        // 定时
        if (newToastItem.duration > 0) {
            [newToastItem resume:^(XZToastTask * _Nonnull task) {
                [self->_hideingTasks addObject:task];
                [self setNeedsUpdateToasts];
            }];
        }
        
        // toast 自适应大小
        UIView * const newToastView = newToastItem.view;
        newToastItem->_frame.size = [newToastView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
        newToastItem->_frame.origin.x = (_bounds.size.width - newToastItem->_frame.size.width) * 0.5 + _bounds.origin.x;
        switch (_position) {
            case XZToastPositionTop:
                newToastItem->_frame.origin.y = CGRectGetMinY(_bounds) - newToastItem->_frame.size.height;
                break;
            case XZToastPositionMiddle:
                newToastItem->_frame.origin.y = CGRectGetMidY(_bounds) - newToastItem->_frame.size.height * 0.5;
                break;
            case XZToastPositionBottom:
                newToastItem->_frame.origin.y = CGRectGetMaxY(_bounds);
                break;
        }
        newToastItem->_frame.origin.y += _offsets[_position];
        newToastView.frame = newToastItem->_frame;
        newToastView.alpha = 0;
        [_containerView addSubview:newToastView];
    }
    
    // 从正显示的集合中移除待隐藏的。
    NSMutableArray * const _hideingTasks = [self->_hideingTasks mutableCopy];
    for (XZToastTask *task in _hideingTasks) {
        [_showingTasks removeObject:task];
    }
    [self->_hideingTasks removeAllObjects];
    
    // 检查数量限制，超出就直接移除
    while (_showingTasks.count > _maximumNumberOfToasts) {
        XZToastTask *firstItem = _showingTasks.firstObject;
        [_showingTasks removeObjectAtIndex:0];
        
        [firstItem cancel];
        [_hideingTasks addObject:firstItem];
    }
    
    [UIView animateWithDuration:XZToastAnimationDuration animations:^{
        switch (self->_position) {
            case XZToastPositionTop: {
                CGFloat __block y = CGRectGetMinY(self->_bounds) + self->_offsets[XZToastPositionTop];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.view.alpha = 1.0;
                    obj->_frame.origin.y = y;
                    obj.view.frame = obj->_frame;
                    y = CGRectGetMaxY(obj->_frame);
                }];
                
                // 隐藏动画
                for (XZToastTask *item in _hideingTasks) {
                    item.view.alpha = 0.0;
                    item.view.frame = CGRectOffset(item->_frame, 0, -item->_frame.size.height);
                }
                break;
            }
            case XZToastPositionMiddle: {
                // 最新的在中间，剩下的分居上下两侧
                if (self->_showingTasks.count > 0) {
                    XZToastTask *item = self->_showingTasks.lastObject;
                    item.view.alpha = 1.0;
                    item->_frame.origin.y = CGRectGetMidY(self->_bounds) - CGRectGetHeight(item->_frame) * 0.5 + self->_offsets[XZToastPositionMiddle];
                    item.view.frame = item->_frame;
                    CGFloat __block minY = CGRectGetMinY(item->_frame);
                    CGFloat __block maxY = CGRectGetMaxY(item->_frame);
                    for (NSInteger i = (NSInteger)(self->_showingTasks.count) - 2; i >= 0; i--) {
                        XZToastTask *item = self->_showingTasks[i];
                        if (item.direction) {
                            item->_frame.origin.y = maxY;
                            item.view.frame = item->_frame;
                            maxY = CGRectGetMaxY(item->_frame);
                        } else {
                            item->_frame.origin.y = minY - CGRectGetHeight(item->_frame);
                            item.view.frame = item->_frame;
                            minY = CGRectGetMinY(item->_frame);
                        }
                    }
                }
                for (XZToastTask *item in _hideingTasks) {
                    item.view.alpha = 0.0;
                }
                break;
            }
            case XZToastPositionBottom: {
                // 最新的在底部，从底部开始布局
                CGFloat __block y = CGRectGetMaxY(self->_bounds) + self->_offsets[XZToastPositionBottom];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.view.alpha = 1.0;
                    obj->_frame.origin.y = y - CGRectGetHeight(obj->_frame);
                    obj.view.frame = obj->_frame;
                    y = obj->_frame.origin.y;
                }];
                
                // 隐藏动画
                for (XZToastTask *item in _hideingTasks) {
                    item.view.alpha = 0.0;
                    item.view.frame = CGRectOffset(item->_frame, 0, item->_frame.size.height);
                }
                break;
            }
        }
    } completion:^(BOOL finished) {
        // 向移除的 toast 发送消息
        for (XZToastTask *item in _hideingTasks) {
            [item.view removeFromSuperview];
            [item finish];
        }
        
        [self runUpdateCompletion];
        
        [self updateToastsIfNeeded];
    }];
}

- (void)setNeedsLayoutToastViews {
    if (_needsLayoutToastViews) {
        return;
    }
    _needsLayoutToastViews = YES;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self layoutToastViewsIfNeeded];
    }];
}

- (void)layoutToastViewsIfNeeded {
    if (!_needsLayoutToastViews) {
        return;
    }
    [self layoutToastViews];
    _needsLayoutToastViews = NO;
}

- (void)layoutToastViews {
    if (_showingTasks.count == 0) {
        return;
    }
    
    // 重新调整 toast 大小
    for (XZToastTask *item in _showingTasks) {
        UIView * const itemView = item.view;
        if (item->_frame.size.width <= _bounds.size.width) {
            continue;
        }
        item->_frame.size = [itemView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
        item->_frame.origin.x = (_bounds.size.width - item->_frame.size.width) * 0.5 + _bounds.origin.x;
        itemView.frame = item->_frame;
    }
    
    // 重新调整位置
    switch (_position) {
        case XZToastPositionTop: {
            CGFloat __block y = CGRectGetMinY(self->_bounds) + self->_offsets[XZToastPositionTop];
            [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.view.alpha = 1.0;
                obj->_frame.origin.y = y;
                obj.view.frame = obj->_frame;
                y = CGRectGetMaxY(obj->_frame);
            }];
            break;
        }
        case XZToastPositionMiddle: {
            XZToastTask *item = self->_showingTasks.lastObject;
            item.view.alpha = 1.0;
            item->_frame.origin.y = CGRectGetMidY(self->_bounds) - CGRectGetHeight(item->_frame) * 0.5 + self->_offsets[XZToastPositionMiddle];
            item.view.frame = item->_frame;
            CGFloat __block minY = CGRectGetMinY(item->_frame);
            CGFloat __block maxY = CGRectGetMaxY(item->_frame);
            for (NSInteger i = (NSInteger)(self->_showingTasks.count) - 2; i >= 0; i--) {
                XZToastTask *item = self->_showingTasks[i];
                if (item.direction) {
                    item->_frame.origin.y = maxY;
                    item.view.frame = item->_frame;
                    maxY = CGRectGetMaxY(item->_frame);
                } else {
                    item->_frame.origin.y = minY - CGRectGetHeight(item->_frame);
                    item.view.frame = item->_frame;
                    minY = CGRectGetMinY(item->_frame);
                }
            }
            break;
        }
        case XZToastPositionBottom: {
            CGFloat __block y = CGRectGetMaxY(self->_bounds) + self->_offsets[XZToastPositionBottom];
            [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.view.alpha = 1.0;
                obj->_frame.origin.y = y - CGRectGetHeight(obj->_frame);
                obj.view.frame = obj->_frame;
                y = obj->_frame.origin.y;
            }];
            break;
        }
    }
}

@end
