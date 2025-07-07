//
//  XZToastManager.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastManager.h"
#import <objc/runtime.h>
#import "XZToastWrapperView.h"
#import "XZToastTask.h"
#import "XZToast.h"
#import "UIKit+XZToast.h"

@implementation XZToastManager {
    UIViewController * __weak _viewController;
    
    CGFloat _offsets[3];
    /// 展示位置。
    XZToastPosition _position;
    /// 待展示。
    NSMutableArray<XZToastTask *> *_waitingToShowTasks;
    /// 展示中。仅在周期方法内才可以修改。
    NSMutableArray<XZToastTask *> *_showingTasks;
    /// 待隐藏。
    NSMutableArray<XZToastTask *> *_waitingToHideTasks;
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
    
    BOOL _needslayoutToasts;
}

- (void)dealloc {
    for (XZToastTask *task in _hideingTasks) {
        [task cancel];
        [task finish];
    }
    
    for (XZToastTask *task in _showingTasks) {
        [task cancel];
        [task finish];
    }
    
    for (XZToastTask *task in _waitingToHideTasks) {
        [task cancel];
        [task finish];
    }
    
    for (XZToastTask *task in _waitingToShowTasks) {
        [task cancel];
        [task finish];
    }
}

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController {
    static const void * const _manager = &_manager;
    XZToastManager *manager = objc_getAssociatedObject(viewController, _manager);
    if (manager) {
        return manager;
    }
    
    manager = [[XZToastManager alloc] initWithViewController:viewController];
    objc_setAssociatedObject(viewController, _manager, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return manager;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        
        _maximumNumberOfToasts = XZToast.maximumNumberOfToasts;
        _offsets[XZToastPositionTop]    = [XZToast offsetForPosition:(XZToastPositionTop)];
        _offsets[XZToastPositionMiddle] = [XZToast offsetForPosition:(XZToastPositionMiddle)];
        _offsets[XZToastPositionBottom] = [XZToast offsetForPosition:(XZToastPositionBottom)];
        
        _waitingToShowTasks = [NSMutableArray arrayWithCapacity:16];
        _showingTasks = [NSMutableArray arrayWithCapacity:16];
        _waitingToHideTasks = [NSMutableArray arrayWithCapacity:16];
        _hideingTasks = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

#pragma mark - override methods

- (CGRect)bounds {
    UIView     * const _rootView      = _viewController.view;
    UIEdgeInsets const safeAreaInsets = _rootView.safeAreaInsets;
    CGRect       const bounds         = _rootView.bounds;
    return CGRectInset(UIEdgeInsetsInsetRect(bounds, safeAreaInsets), XZToastMargin, 0);
}

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    NSParameterAssert(duration >= 0 && duration < DISPATCH_TIME_FOREVER);
    UIView<XZToastView> * const toastView = toast.view;
    
    XZToastTask * const newTask = [[XZToastTask alloc] initWithManager:self view:toastView duration:duration position:position exclusive:exclusive completion:completion];
    
    if ([toast isKindOfClass:[XZToastTask class]]) {
        XZToastTask * const oldTask = ((XZToastTask *)toast);
        // toast 被其它控制器使用
        if (oldTask.manager && oldTask.manager != self) {
            newTask.isViewReused = YES;
            [newTask cancel];
            [_waitingToHideTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
        newTask.wrapperView = ((XZToastTask *)toast).wrapperView;
    }
    
    // 待展示
    for (NSInteger index = _waitingToShowTasks.count - 1; index >= 0; index--) {
        XZToastTask * const oldTask = _waitingToShowTasks[index];
        // 独占式 toast 已经在列队中，后续的 toast 就不用展示了
        if (oldTask.isExclusive) {
            newTask.isViewReused = YES;
            [newTask cancel];
            [_waitingToHideTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
        // 视图复用
        if (oldTask.view == toastView) {
            [_waitingToShowTasks removeObjectAtIndex:index];
            oldTask.isViewReused = YES;
            [oldTask cancel];
            [_waitingToHideTasks addObject:oldTask];
            
            newTask.wrapperView = oldTask.wrapperView;
            [_waitingToShowTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
    }
    
    // 展示中
    for (NSInteger index = _showingTasks.count - 1; index >= 0; index--) {
        XZToastTask * const oldTask = _showingTasks[index];
        // 独占式 toast 正在展示中，不可展示新的
        if (oldTask.isExclusive) {
            newTask.isViewReused = YES;
            [newTask cancel];
            [_waitingToHideTasks addObject:newTask];
            if (oldTask.view == toastView) {
                oldTask->_needsUpdateFrame = YES;
            }
            [self setNeedsUpdateToasts];
            return newTask;
        }
        if (oldTask.view == toastView) {
            oldTask.isViewReused = YES;
            [oldTask cancel];
            [_waitingToHideTasks addObject:oldTask];
            
            newTask.wrapperView = oldTask.wrapperView;
            [_waitingToShowTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
    }
    
    // 待隐藏
    for (NSInteger index = _waitingToHideTasks.count - 1; index >= 0; index--) {
        XZToastTask * const oldTask = _waitingToHideTasks[index];
        if (oldTask.view == toastView) {
            oldTask.isViewReused = YES;
            
            newTask.wrapperView = oldTask.wrapperView;
            [_waitingToShowTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
    }
    
    // 隐藏中
    for (NSInteger index = _hideingTasks.count - 1; index >= 0; index--) {
        XZToastTask * const oldTask = _hideingTasks[index];
        if (oldTask.view == toastView) {
            oldTask.isViewReused = YES;
            
            // 隐藏效果反转
            XZToastWrapperView * const wrapperView = oldTask.wrapperView;
            CALayer * const presentationLayer = wrapperView.layer.presentationLayer;
            if (presentationLayer) {
                [wrapperView.layer removeAllAnimations];
                wrapperView.alpha = presentationLayer.opacity;
                wrapperView.transform = CATransform3DGetAffineTransform(presentationLayer.transform);
                // 维持动画速度不变，计算动画到当前状态所花的时间。
                // 因为 alpha 正好是 1.0 => 0.0 的动画，可以用作进度
                // 到周期开始后，当前恢复动画可能未完成，那么在复用时再处理。
                NSTimeInterval const duration = XZToastAnimationDuration * (1.0 - wrapperView.alpha);
                [UIView animateWithDuration:duration animations:^{
                    wrapperView.alpha = 1.0;
                    wrapperView.transform = CGAffineTransformIdentity;
                }];
            }
            
            newTask.wrapperView = wrapperView;
            [_waitingToShowTasks addObject:newTask];
            [self setNeedsUpdateToasts];
            return newTask;
        }
    }
    
    [_waitingToShowTasks addObject:newTask];
    [self setNeedsUpdateToasts];
    return newTask;
}

- (void)hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    if (toast == nil) {
        // 取消所有 toast
        if (_showingTasks.count > 0) {
            for (XZToastTask * const task in _showingTasks) {
                [task cancel];
                [_waitingToHideTasks addObject:task];
            }
        }
        if (_waitingToShowTasks.count > 0) {
            do {
                XZToastTask * const task = _waitingToShowTasks.lastObject;
                [_waitingToShowTasks removeLastObject];
                [task cancel];
                [_waitingToHideTasks addObject:task];
            } while (_waitingToShowTasks.count > 0);
        }
    } else {
        // 取消指定 toast
        if ([toast isKindOfClass:[XZToastTask class]]) {
            XZToastTask * const task = (id)toast;
            if ([_showingTasks containsObject:(XZToastTask *)toast]) {
                [task cancel];
                [_waitingToHideTasks addObject:task];
            } else if ([_waitingToShowTasks containsObject:task]) {
                [_waitingToShowTasks removeObject:task];
                [task cancel];
                [_waitingToHideTasks addObject:task];
            }
        } else {
            UIView * const toastView = toast.view;
            
            // 因为 toastView 可以复用，所以需要查找两个集合
            
            for (XZToastTask * const task in _showingTasks) {
                if (task.wrapperView.view == toastView) {
                    [task cancel];
                    [_waitingToHideTasks addObject:task];
                    break;
                }
            }
            
            [_waitingToShowTasks enumerateObjectsUsingBlock:^(XZToastTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
                if (task.wrapperView.view == toastView) {
                    [_waitingToShowTasks removeObjectAtIndex:idx];
                    [task cancel];
                    [_waitingToHideTasks addObject:task];
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

#pragma mark - <XZToastConfiguration>

@synthesize maximumNumberOfToasts = _maximumNumberOfToasts;
@synthesize textColor = _textColor;
@synthesize font = _font;
@synthesize backgroundColor = _backgroundColor;
@synthesize shadowColor = _shadowColor;
@synthesize color = _color;
@synthesize trackColor = _trackColor;

- (void)setMaximumNumberOfToasts:(NSInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(1, maximumNumberOfToasts);
    [self setNeedsUpdateToasts];
}

- (CGFloat)offsetForPosition:(XZToastPosition)position {
    return _offsets[position];
}

- (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    _offsets[position] = offset;
}

- (void)updateToastsIfNeeded {
    if (!_needsUpdateToasts) {
        return;
    }
    
    // 只要 _waitingItems 或 _hideingItems 不为空，当前方法就会一直执行，直到处理完所有 toast
    if (_waitingToShowTasks.count == 0 && _waitingToHideTasks.count == 0) {
        _needsUpdateToasts = NO;
        // 执行周期回调
        [self runUpdateCompletion];
        return;
    }
    
    UIViewController * const _viewController = self->_viewController;
    CGRect             const _bounds         = [self bounds];
    
    // 将等待中的 toast 出列一个显示。
    // 每次只展示一个，这样每个 toast 最少有 XZToastAnimationDuration * maxCount 的展示时间。
    XZToastTask * const newToastItem = _waitingToShowTasks.firstObject;
    if (newToastItem) {
        [_waitingToShowTasks removeObjectAtIndex:0];
        
        // 定时
        if (newToastItem.duration > 0) {
            [newToastItem resume:^(XZToastTask * _Nonnull task) {
                [self->_waitingToHideTasks addObject:task];
                [self setNeedsUpdateToasts];
            }];
        }
        
        // 独占
        if (newToastItem.isExclusive) {
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

        // 应用配置
        [newToastItem.wrapperView willShowInViewController:_viewController];
        
        // 大小：通过 sizeThatFits 计算大小
        newToastItem->_frame.size = [newToastItem.wrapperView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
        newToastItem->_frame.origin.x = (_bounds.size.width - newToastItem->_frame.size.width) * 0.5 + _bounds.origin.x;
        newToastItem->_needsUpdateFrame = NO;
        
        // 复用的视图不会从父视图移除，因此用来判断复用状态
        if (newToastItem.wrapperView.superview) {
            XZToastWrapperView * const view = newToastItem.wrapperView;
            CALayer * const layer = view.layer.presentationLayer;
            if (layer) {
                // 保存动画状态
                [view.layer removeAllAnimations];
                view.alpha = layer.opacity;
                view.transform = CATransform3DGetAffineTransform(layer.transform);
            }
            [_viewController.view bringSubviewToFront:view];
        } else {
            switch (_position) {
                case XZToastPositionTop:
                    // 顶部 toast 入场动画：渐显下移
                    newToastItem->_frame.origin.y = CGRectGetMinY(_bounds) - newToastItem->_frame.size.height + _offsets[XZToastPositionTop];
                    newToastItem.wrapperView.alpha = 0;
                    newToastItem.wrapperView.frame = newToastItem->_frame;
                    break;
                case XZToastPositionMiddle:
                    // 中部 toast 入场动画：弹性放大
                    newToastItem->_frame.origin.y = CGRectGetMidY(_bounds) - newToastItem->_frame.size.height * 0.5 + _offsets[XZToastPositionMiddle];
                    newToastItem.wrapperView.alpha = 1.0;
                    newToastItem.wrapperView.frame = newToastItem->_frame;
                    newToastItem.wrapperView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    break;
                case XZToastPositionBottom:
                    // 底部 toast 入场动画：渐显上移
                    newToastItem->_frame.origin.y = CGRectGetMaxY(_bounds) + _offsets[XZToastPositionBottom];
                    newToastItem.wrapperView.alpha = 0;
                    newToastItem.wrapperView.frame = newToastItem->_frame;
                    break;
            }
            [_viewController.view addSubview:newToastItem.wrapperView];
        }
        
        [_showingTasks addObject:newToastItem];
    }
    
    // 从正显示的集合中移除待隐藏的。
    while (_waitingToHideTasks.count > 0) {
        XZToastTask * const task = _waitingToHideTasks.lastObject;
        [_waitingToHideTasks removeLastObject];
        
        [_showingTasks removeObject:task];
        [_hideingTasks addObject:task];
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
    
    // 确定动画方向
    switch (_position) {
        case XZToastPositionTop:
            _showingTasks.lastObject.moveDirection = XZToastMoveDirectionLand;
            break;
        case XZToastPositionMiddle: {
            NSUInteger const count = _showingTasks.count;
            switch (count) {
                case 0:
                    break;
                case 1:
                    _showingTasks[0].moveDirection = XZToastMoveDirectionNone;
                    break;
                case 2: {
                    XZToastTask * const item = _showingTasks[0];
                    if (item.moveDirection == XZToastMoveDirectionNone) {
                        item.moveDirection = XZToastMoveDirectionRise;
                    }
                    break;
                }
                default: {
                    XZToastTask * const item = _showingTasks[count - 2];
                    if (item.moveDirection == XZToastMoveDirectionNone) {
                        item.moveDirection = _showingTasks[count - 3].moveDirection * (-1);;
                    }
                    break;
                }
            }
            break;
        }
        case XZToastPositionBottom:
            _showingTasks.lastObject.moveDirection = XZToastMoveDirectionRise;
            break;
    }
    
    for (XZToastTask * const item in _showingTasks) {
        if (item->_needsUpdateFrame) {
            item->_frame.size = [item.wrapperView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
            item->_frame.origin.x = (_bounds.size.width - item->_frame.size.width) * 0.5 + _bounds.origin.x;
            item->_needsUpdateFrame = NO;
        }
    }
    
    UIViewAnimationOptions const options = UIViewAnimationOptionLayoutSubviews;
    [UIView animateWithDuration:XZToastAnimationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.6 options:options animations:^{
        switch (self->_position) {
            case XZToastPositionTop: {
                CGFloat __block y = CGRectGetMinY(_bounds) + self->_offsets[XZToastPositionTop];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.wrapperView.transform = CGAffineTransformIdentity;
                    obj.wrapperView.alpha = 1.0;
                    obj->_frame.origin.y = y;
                    obj.wrapperView.frame = obj->_frame;
                    y = CGRectGetMaxY(obj->_frame);
                }];
                break;
            }
            case XZToastPositionMiddle: {
                // 最新的在中间，剩下的分居上下两侧
                XZToastTask * const lastTaskItem = self->_showingTasks.lastObject;
                if (lastTaskItem == nil) {
                    break;
                }
                
                lastTaskItem->_frame.origin.y = CGRectGetMidY(_bounds) - CGRectGetHeight(lastTaskItem->_frame) * 0.5 + self->_offsets[XZToastPositionMiddle];
                lastTaskItem.wrapperView.alpha = 1.0;
                lastTaskItem.wrapperView.transform = CGAffineTransformIdentity;
                lastTaskItem.wrapperView.frame = lastTaskItem->_frame;
                
                CGFloat minY = CGRectGetMinY(lastTaskItem->_frame);
                CGFloat maxY = CGRectGetMaxY(lastTaskItem->_frame);
                for (NSInteger index = (NSInteger)(self->_showingTasks.count) - 2; index >= 0; index--) {
                    XZToastTask * const item = self->_showingTasks[index];
                    if (item.moveDirection == XZToastMoveDirectionLand) {
                        item->_frame.origin.y = maxY;
                        item.wrapperView.frame = item->_frame;
                        maxY = CGRectGetMaxY(item->_frame);
                    } else {
                        item->_frame.origin.y = minY - CGRectGetHeight(item->_frame);
                        item.wrapperView.frame = item->_frame;
                        minY = CGRectGetMinY(item->_frame);
                    }
                }
                break;
            }
            case XZToastPositionBottom: {
                // 最新的在底部，从底部开始布局
                CGFloat __block y = CGRectGetMaxY(_bounds) + self->_offsets[XZToastPositionBottom];
                [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.wrapperView.transform = CGAffineTransformIdentity;
                    obj.wrapperView.alpha = 1.0;
                    obj->_frame.origin.y  = y - CGRectGetHeight(obj->_frame);
                    obj.wrapperView.frame = obj->_frame;
                    y = obj->_frame.origin.y;
                }];
                break;
            }
        }
        
        for (XZToastTask * const item in self->_hideingTasks) {
            if (item.isViewReused) {
                continue;
            }
            // 隐藏效果：渐隐，缩小，反向平移；在复用模式下，会有相反的动画处理。
            CGFloat const deltaY = item->_frame.size.height * (-item.moveDirection) * item.hideReason;
            item.wrapperView.alpha = 0.0;
            item.wrapperView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.66, 0.66), 0, deltaY);
        }
    } completion:^(BOOL finished) {
        // 向移除的 toast 发送消息
        while (self->_hideingTasks.count > 0) {
            XZToastTask * const item = self->_hideingTasks.lastObject;
            [self->_hideingTasks removeLastObject];
            
            [item finish];
            if (item.isViewReused) {
                continue;
            }
            item.wrapperView.transform = CGAffineTransformIdentity;
            [item.wrapperView removeFromSuperview];
        }
        
        [self runUpdateCompletion];
        
        [self updateToastsIfNeeded];
    }];
}

- (void)setNeedsLayoutToasts {
    if (_needslayoutToasts) {
        return;
    }
    _needslayoutToasts = YES;
    
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self layoutToastsIfNeeded];
    }];
}

- (void)layoutToastsIfNeeded {
    if (!_needslayoutToasts) {
        return;
    }
    [self layoutToastViews];
    _needslayoutToasts = NO;
}

- (void)layoutToastViews {
    if (_showingTasks.count == 0) {
        return;
    }
    
    CGRect const _bounds = [self bounds];
    
    // 重新调整 toast 大小
    for (XZToastTask * const item in _showingTasks) {
        UIView * const itemView = item.wrapperView;
        if (item->_needsUpdateFrame || item->_frame.size.width > _bounds.size.width) {
            item->_needsUpdateFrame = NO;
            item->_frame.size = [itemView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
            item->_frame.origin.x = (_bounds.size.width - item->_frame.size.width) * 0.5 + _bounds.origin.x;
        }
    }
    
    // 重新调整位置
    switch (_position) {
        case XZToastPositionTop: {
            CGFloat __block y = CGRectGetMinY(_bounds) + _offsets[XZToastPositionTop];
            [_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask *obj, NSUInteger idx, BOOL *stop) {
                obj.wrapperView.alpha = 1.0;
                obj->_frame.origin.y  = y;
                obj.wrapperView.frame = obj->_frame;
                y = CGRectGetMaxY(obj->_frame);
            }];
            break;
        }
        case XZToastPositionMiddle: {
            XZToastTask * const item = _showingTasks.lastObject;
            if (item == nil) {
                break;
            }
            item.wrapperView.alpha = 1.0;
            item->_frame.origin.y = CGRectGetMidY(_bounds) - CGRectGetHeight(item->_frame) * 0.5 + _offsets[XZToastPositionMiddle];
            item.wrapperView.frame = item->_frame;
            CGFloat minY = CGRectGetMinY(item->_frame);
            CGFloat maxY = CGRectGetMaxY(item->_frame);
            for (NSInteger i = (NSInteger)(_showingTasks.count) - 2; i >= 0; i--) {
                XZToastTask * const item = _showingTasks[i];
                if (item.moveDirection == XZToastMoveDirectionLand) {
                    item->_frame.origin.y = maxY;
                    item.wrapperView.frame = item->_frame;
                    maxY = CGRectGetMaxY(item->_frame);
                } else {
                    item->_frame.origin.y = minY - CGRectGetHeight(item->_frame);
                    item.wrapperView.frame = item->_frame;
                    minY = CGRectGetMinY(item->_frame);
                }
            }
            break;
        }
        case XZToastPositionBottom: {
            CGFloat __block y = CGRectGetMaxY(_bounds) + _offsets[XZToastPositionBottom];
            [self->_showingTasks enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZToastTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.wrapperView.alpha = 1.0;
                obj->_frame.origin.y  = y - CGRectGetHeight(obj->_frame);
                obj.wrapperView.frame = obj->_frame;
                y = obj->_frame.origin.y;
            }];
            break;
        }
    }
}

@end
