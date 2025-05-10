//
//  XZToastManager.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastManager.h"
#import <objc/runtime.h>
#import "XZToastShadowView.h"
#import "XZToastContainerView.h"
#import "XZToastTask.h"
#import "XZToast.h"

static void * _context = NULL;

typedef NS_ENUM(NSUInteger, XZToastLayoutType) {
    XZToastLayoutTypeNone = 0,
    XZToastLayoutTypeAuto,
    XZToastLayoutTypeUser,
};

@implementation XZToastManager {
    /// 视图控制器。
    UIView *_containerView;
    
    /// 展示位置。
    XZToastPosition _position;
    /// 待展示。
    NSMutableArray<XZToastTask *> *_waitingTasks;
    /// 展示中。仅在周期方法内才可以修改。
    NSMutableArray<XZToastTask *> *_showingTasks;
    /// 待隐藏。
    NSMutableArray<XZToastTask *> *_planingTasks;
    /// 隐藏中。仅在周期方法内才可以修改。
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
    
    XZToastLayoutType _layoutType;
    
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
        
        UIEdgeInsets const safeAreaInsets = _containerView.safeAreaInsets;
        CGRect       const bounds         = _containerView.bounds;
        _bounds = CGRectInset(UIEdgeInsetsInsetRect(bounds, safeAreaInsets), XZToastMargin, XZToastMargin);
        [_containerView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:&_context];
        
        _maximumNumberOfToasts = 3;
        _offsets = calloc(3, sizeof(XZToastPosition));
        
        _waitingTasks = [NSMutableArray arrayWithCapacity:16];
        _showingTasks = [NSMutableArray arrayWithCapacity:16];
        _planingTasks = [NSMutableArray arrayWithCapacity:16];
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
    
    CGRect const bounds = _containerView.bounds;
    UIEdgeInsets const safeAreaInsets = _containerView.safeAreaInsets;
    CGRect const newBounds = CGRectInset(UIEdgeInsetsInsetRect(bounds, safeAreaInsets), XZToastMargin, XZToastMargin);
    if (CGRectEqualToRect(_bounds, newBounds)) {
        return;
    }
    _bounds = newBounds;
    // 立即调整 toast 位置
    _layoutType = XZToastLayoutTypeAuto;
    [self layoutToastsIfNeeded];
}

- (void)setMaximumNumberOfToasts:(NSUInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(1, maximumNumberOfToasts);
    [self setNeedsUpdateToasts];
}

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nonnull void (^)(BOOL))completion {
    UIView * const toastView = toast.view;
    [toastView layoutIfNeeded];
    
    // 待展示
    for (NSInteger i = _waitingTasks.count - 1; i >= 0; i--) {
        XZToastTask * const task = _waitingTasks[i];
        if (task.view.view == toastView) {
            [_waitingTasks removeObjectAtIndex:i];
            task.isViewReused = YES;
            [task cancel];
            [_planingTasks addObject:task];
            return [self _showToast:task.view duration:duration position:position exclusive:exclusive completion:completion];
        }
    }
    
    // 展示中
    for (NSInteger i = _showingTasks.count - 1; i >= 0; i--) {
        XZToastTask * const task = _showingTasks[i];
        if (task.view.view == toastView) {
            task.isViewReused = YES;
            [task cancel];
            [_planingTasks addObject:task];
            return [self _showToast:task.view duration:duration position:position exclusive:exclusive completion:completion];
        }
    }
    
    // 待隐藏
    for (NSInteger i = _planingTasks.count - 1; i >= 0; i--) {
        XZToastTask * const task = _planingTasks[i];
        if (task.view.view == toastView) {
            task.isViewReused = YES;
            return [self _showToast:task.view duration:duration position:position exclusive:exclusive completion:completion];
        }
    }
    
    // 隐藏中
    for (NSInteger i = _hideingTasks.count - 1; i >= 0; i--) {
        XZToastTask * const task = _hideingTasks[i];
        if (task.view.view == toastView) {
            task.isViewReused = YES;
            
            // 隐藏效果反转
            XZToastShadowView * const view = task.view;
            CALayer * const layer = view.layer.presentationLayer;
            if (layer) {
                [view.layer removeAllAnimations];
                view.alpha = layer.opacity;
                view.transform = CATransform3DGetAffineTransform(layer.transform);
                // 维持动画速度不变，计算动画到当前状态所花的时间。
                // 因为 alpha 正好是 1.0 => 0.0 的动画，可以用作进度
                // 到周期开始后，当前恢复动画可能未完成，那么在复用时再处理。
                NSTimeInterval const duration = XZToastAnimationDuration * (1.0 - view.alpha);
                [UIView animateWithDuration:duration animations:^{
                    view.alpha = 1.0;
                    view.transform = CGAffineTransformIdentity;
                }];
            }
            return [self _showToast:view duration:duration position:position exclusive:exclusive completion:completion];
        }
    }
    
    XZToastShadowView * const view = [[XZToastShadowView alloc] initWithView:toastView];
    return [self _showToast:view duration:duration position:position exclusive:exclusive completion:completion];
}

- (XZToastTask *)_showToast:(XZToastShadowView *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nonnull void (^)(BOOL))completion {
    XZToastTask * const task = [[XZToastTask alloc] initWithView:view duration:duration position:position exclusive:exclusive completion:completion];
    if (_isExclusive) {
        [task cancel];
        [_planingTasks addObject:task];
    } else {
        [_waitingTasks addObject:task];
    }
    [self setNeedsUpdateToasts];
    return task;
}

- (void)hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    if (toast == nil) {
        // 取消所有 toast
        if (_showingTasks.count > 0) {
            for (XZToastTask * const task in _showingTasks) {
                [task cancel];
                [_planingTasks addObject:task];
            }
        }
        if (_waitingTasks.count > 0) {
            do {
                XZToastTask * const task = _waitingTasks.lastObject;
                [_waitingTasks removeLastObject];
                [task cancel];
                [_planingTasks addObject:task];
            } while (_waitingTasks.count > 0);
        }
    } else {
        // 取消指定 toast
        if ([toast isKindOfClass:[XZToastTask class]]) {
            XZToastTask * const task = (id)toast;
            if ([_showingTasks containsObject:(XZToastTask *)toast]) {
                [task cancel];
                [_planingTasks addObject:task];
            } else if ([_waitingTasks containsObject:task]) {
                [_waitingTasks removeObject:task];
                [task cancel];
                [_planingTasks addObject:task];
            }
        } else {
            UIView * const toastView = toast.view;
            
            // 因为 toastView 可以复用，所以需要查找两个集合
            
            for (XZToastTask * const task in _showingTasks) {
                if (task.view.view == toastView) {
                    [task cancel];
                    [_planingTasks addObject:task];
                    break;
                }
            }
            
            [_waitingTasks enumerateObjectsUsingBlock:^(XZToastTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
                if (task.view.view == toastView) {
                    [_waitingTasks removeObjectAtIndex:idx];
                    [task cancel];
                    [_planingTasks addObject:task];
                }
            }];
        }
    }
    
    [self addUpdateCompletion:completion];
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
    if (_waitingTasks.count == 0 && _planingTasks.count == 0) {
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
        
        // 定时
        if (newToastItem.duration > 0) {
            [newToastItem resume:^(XZToastTask * _Nonnull task) {
                [self->_planingTasks addObject:task];
                [self setNeedsUpdateToasts];
            }];
        }
        
        // 独占
        if (newToastItem.isExclusive) {
            _isExclusive = YES;
            while (_showingTasks.count > 0) {
                XZToastTask *item = _showingTasks.lastObject;
                [_showingTasks removeLastObject];
                
                [item cancel];
                [_hideingTasks addObject:item];
            }
        }
        
        // 位置：如果更换了展示位置，则移除当前所有 toast
        if (_position != newToastItem.position) {
            _position = newToastItem.position;
            while (_showingTasks.count > 0) {
                XZToastTask *item = _showingTasks.lastObject;
                [_showingTasks removeLastObject];
                
                [item cancel];
                [_hideingTasks addObject:item];
            }
        }
        
        // 大小：通过 sizeThatFits 计算大小
        newToastItem->_frame.size = [newToastItem.view sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
        newToastItem->_frame.origin.x = (_bounds.size.width - newToastItem->_frame.size.width) * 0.5 + _bounds.origin.x;
        
        // 复用的视图不会从移除，因此用来判断复用状态
        if (newToastItem.view.superview) {
            XZToastShadowView * const view = newToastItem.view;
            CALayer * const layer = view.layer.presentationLayer;
            if (layer) {
                // 保存动画状态
                [view.layer removeAllAnimations];
                view.alpha = layer.opacity;
                view.transform = CATransform3DGetAffineTransform(layer.transform);
            }
            [_containerView bringSubviewToFront:view];
        } else {
            switch (_position) {
                case XZToastPositionTop:
                    // 顶部 toast 入场动画：渐显下移
                    newToastItem->_frame.origin.y = CGRectGetMinY(_bounds) - newToastItem->_frame.size.height;
                    newToastItem->_frame.origin.y += _offsets[_position];
                    newToastItem.view.alpha = 0;
                    newToastItem.view.frame = newToastItem->_frame;
                    break;
                case XZToastPositionMiddle:
                    // 中部 toast 入场动画：弹性放大
                    newToastItem->_frame.origin.y = CGRectGetMidY(_bounds) - newToastItem->_frame.size.height * 0.5;
                    newToastItem->_frame.origin.y += _offsets[_position];
                    newToastItem.view.alpha = 1.0;
                    newToastItem.view.frame = newToastItem->_frame;
                    newToastItem.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    break;
                case XZToastPositionBottom:
                    // 底部 toast 入场动画：渐显上移
                    newToastItem->_frame.origin.y = CGRectGetMaxY(_bounds);
                    newToastItem->_frame.origin.y += _offsets[_position];
                    newToastItem.view.alpha = 0;
                    newToastItem.view.frame = newToastItem->_frame;
                    break;
            }
            [_containerView addSubview:newToastItem.view];
        }
        
        switch (_position) {
            case XZToastPositionTop:
                newToastItem.moveDirection = XZToastMoveDirectionLand;
                break;
            case XZToastPositionMiddle: {
                newToastItem.moveDirection = XZToastMoveDirectionNone;
                NSUInteger const count = _showingTasks.count;
                switch (count) {
                    case 0:
                        break;
                    case 1:
                        _showingTasks[0].moveDirection = XZToastMoveDirectionRise;
                        break;
                    default:
                        _showingTasks[count - 1].moveDirection = _showingTasks[count - 2].moveDirection * (-1);
                        break;
                }
                break;
            }
            case XZToastPositionBottom:
                newToastItem.moveDirection = XZToastMoveDirectionRise;
                break;
        }
        
        [_showingTasks addObject:newToastItem];
    }
    
    // 从正显示的集合中移除待隐藏的。
    while (_planingTasks.count > 0) {
        XZToastTask * const task = _planingTasks.lastObject;
        [_planingTasks removeLastObject];
        [_hideingTasks addObject:task];
        [_showingTasks removeObject:task];
    }
    
    // 检查数量限制，超出就直接移除
    while (_showingTasks.count > _maximumNumberOfToasts) {
        XZToastTask *firstItem = _showingTasks.firstObject;
        [_showingTasks removeObjectAtIndex:0];
        
        // 标记是被顶掉的
        firstItem.hideReason = XZToastHideReasonExceed;
        [firstItem cancel];
        [_hideingTasks addObject:firstItem];
    }
    
    UIViewAnimationOptions const options = UIViewAnimationOptionLayoutSubviews;
    [UIView animateWithDuration:XZToastAnimationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.6 options:options animations:^{
        switch (self->_position) {
            case XZToastPositionTop: {
                CGFloat __block y = CGRectGetMinY(self->_bounds) + self->_offsets[XZToastPositionTop];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.view.transform = CGAffineTransformIdentity;
                    obj.view.alpha = 1.0;
                    obj->_frame.origin.y = y;
                    obj.view.frame = obj->_frame;
                    y = CGRectGetMaxY(obj->_frame);
                }];
                break;
            }
            case XZToastPositionMiddle: {
                // 最新的在中间，剩下的分居上下两侧
                if (self->_showingTasks.count > 0) {
                    XZToastTask *item = self->_showingTasks.lastObject;
                    item.view.alpha = 1.0;
                    item->_frame.origin.y = CGRectGetMidY(self->_bounds) - CGRectGetHeight(item->_frame) * 0.5 + self->_offsets[XZToastPositionMiddle];
                    item.view.transform = CGAffineTransformIdentity;
                    item.view.frame = item->_frame;
                    
                    CGFloat minY = CGRectGetMinY(item->_frame);
                    CGFloat maxY = CGRectGetMaxY(item->_frame);
                    for (NSInteger i = (NSInteger)(self->_showingTasks.count) - 2; i >= 0; i--) {
                        XZToastTask *item = self->_showingTasks[i];
                        if (item.moveDirection == XZToastMoveDirectionLand) {
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
                break;
            }
            case XZToastPositionBottom: {
                // 最新的在底部，从底部开始布局
                CGFloat __block y = CGRectGetMaxY(self->_bounds) + self->_offsets[XZToastPositionBottom];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.view.transform = CGAffineTransformIdentity;
                    obj.view.alpha = 1.0;
                    obj->_frame.origin.y = y - CGRectGetHeight(obj->_frame);
                    obj.view.frame = obj->_frame;
                    y = obj->_frame.origin.y;
                }];
                break;
            }
        }
        
        for (XZToastTask *item in self->_hideingTasks) {
            if (item.isViewReused) {
                continue;
            }
            // 隐藏效果：渐隐，缩小，反向平移；在复用模式下，会有相反的动画处理。
            CGFloat const deltaY = item->_frame.size.height * (-item.moveDirection) * item.hideReason;
            item.view.alpha = 0.0;
            item.view.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.66, 0.66), 0, deltaY);
        }
    } completion:^(BOOL finished) {
        if (self->_showingTasks.count == 0) {
            self->_isExclusive = NO;
        }
        
        // 向移除的 toast 发送消息
        while (self->_hideingTasks.count > 0) {
            XZToastTask * const item = self->_hideingTasks.lastObject;
            [self->_hideingTasks removeLastObject];
            
            [item finish];
            if (item.isViewReused) {
                continue;
            }
            item.view.transform = CGAffineTransformIdentity;
            [item.view removeFromSuperview];
        }
        
        [self runUpdateCompletion];
        
        [self updateToastsIfNeeded];
    }];
}

- (void)setNeedsLayoutToasts {
    if (_layoutType != XZToastLayoutTypeUser) {
        return;
    }
    _layoutType = XZToastLayoutTypeUser;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self layoutToastsIfNeeded];
    }];
}

- (void)layoutToastsIfNeeded {
    if (_layoutType == XZToastLayoutTypeNone) {
        return;
    }
    [self layoutToastViews];
    _layoutType = XZToastLayoutTypeNone;
}

- (void)layoutToastViews {
    if (_showingTasks.count == 0) {
        return;
    }
    
    // 重新调整 toast 大小
    for (XZToastTask *item in _showingTasks) {
        UIView * const itemView = item.view;
        if (_layoutType == XZToastLayoutTypeUser || item->_frame.size.width > _bounds.size.width) {
            item->_needsLayoutView = NO;
            item->_frame.size = [itemView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
            item->_frame.origin.x = (_bounds.size.width - item->_frame.size.width) * 0.5 + _bounds.origin.x;
            itemView.frame = item->_frame;
        }
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
                if (item.moveDirection) {
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
