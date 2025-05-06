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

@implementation XZToastManager {
    /// 视图控制器。
    UIViewController * __weak _viewController;
    
    /// toast 视图所在的容器。
    UIView *_containerView;
    
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
}

+ (XZToastManager *)managerForViewController:(UIViewController *)viewController {
    if (viewController == nil) {
        return nil;
    }
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
        
        _containerView = [[XZToastContainerView alloc] init];
        _containerView.layer.shadowColor = UIColor.blackColor.CGColor;
        _containerView.layer.shadowOffset = CGSizeZero;
        _containerView.layer.shadowOpacity = 0.6;
        _containerView.layer.shadowRadius = 5;
        
        _waitingTasks = [NSMutableArray arrayWithCapacity:4];
        _showingTasks = [NSMutableArray arrayWithCapacity:4];
        _hideingTasks = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (void)showToast:(XZToastTask *)item {
    [_waitingTasks addObject:item];
    [self setNeedsUpdateToasts];
}

- (void)hideToast:(nullable XZToastTask *)item completion:(void (^const)(void))updateCompletion {
    if (item) {
        if ([_showingTasks containsObject:item]) {
            // 正在显示中，添加到待隐藏列队中
            [item cancel];
            [_hideingTasks addObject:item];
        } else if ([_waitingTasks containsObject:item]) {
            // 正在等待显示中，因为没有显示，直接取消
            [_waitingTasks removeObject:item];
            [item cancel];
            [_hideingTasks addObject:item];
        }
    } else {
        if (_showingTasks.count > 0) {
            for (XZToastTask * const task in _showingTasks) {
                [task cancel];
                [_hideingTasks addObject:item];
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
        // 判断是否还有 toast 在展示
        if (_showingTasks.count == 0) {
            [_containerView removeFromSuperview];
        }
        _needsUpdateToasts = NO;
        // 执行周期回调
        [self runUpdateCompletion];
        return;
    }
    
    // H:|-padding-spacing-[toast]-spacing-padding-|
    // V:|-padding-spacing-[toast]-spacing-[toast]-spacing-padding-|
    CGFloat const padding = 20.0; // 边距
    CGFloat const spacing = 10.0; // 间距
     
    // 初始化容器视图
    if (_containerView.superview == nil) {
        UIView * const rootView = _viewController.viewIfLoaded;
        if (rootView == nil) {
            return;
        }
        CGRect const bounds = UIEdgeInsetsInsetRect(_viewController.view.bounds, _viewController.view.safeAreaInsets);
        CGFloat const w = CGRectGetWidth(bounds) - padding * 2.0;
        CGFloat const x = CGRectGetMinX(bounds) + padding;
        CGFloat const h = spacing;
        CGFloat const y = CGRectGetMaxY(bounds) - padding - h;
        _containerView.frame = CGRectMake(x, y, w, h);
        [rootView addSubview:_containerView];
    }
    
    CGRect __block containerViewFrame = _containerView.frame;
    CGFloat const kMaxItemWidth = (containerViewFrame.size.width - spacing * 2.0);
    
    // 将等待中的 toast 出列一个显示。
    // 每次只展示一个，这样每个 toast 最少有 XZToastAnimationDuration * 3 的展示时间。
    XZToastTask * const newToastItem = _waitingTasks.firstObject;
    if (newToastItem) {
        [_waitingTasks removeObjectAtIndex:0];
        
        [_showingTasks addObject:newToastItem];
        [newToastItem resume:^(XZToastTask * _Nonnull task) {
            [self->_hideingTasks addObject:task];
            [self setNeedsUpdateToasts];
        }];
        
        // toast 自适应大小
        UIView * const newToastView = newToastItem.toastView;
        CGSize itemSize = [newToastView sizeThatFits:CGSizeMake(kMaxItemWidth, 0)];
        if (itemSize.width <= 0 || itemSize.height <= 0) {
            itemSize = newToastView.frame.size;
        }
        
        // 新添加的 item 添加到末尾
        newToastItem->_frame.size.width = MIN(itemSize.width, kMaxItemWidth);
        newToastItem->_frame.size.height = itemSize.height;
        newToastItem->_frame.origin.x = (containerViewFrame.size.width - newToastItem->_frame.size.width) * 0.5;
        newToastItem->_frame.origin.y = containerViewFrame.size.height;
        newToastView.frame = newToastItem->_frame;
        newToastView.alpha = 0;
        [_containerView addSubview:newToastView];
    }
    
    // 最多展示三个，超出就强制移除最早的
    if (_showingTasks.count > 3) {
        XZToastTask *firstItem = _showingTasks.firstObject;
        
        [firstItem cancel];
        [_hideingTasks addObject:firstItem];
    }
    
    // 从正显示的集合中移除待隐藏的。
    NSArray * const _hideingTasks = [self->_hideingTasks copy];
    for (XZToastTask *task in _hideingTasks) {
        [_showingTasks removeObject:task];
    }
    [self->_hideingTasks removeAllObjects];
    
    [UIView animateWithDuration:XZToastAnimationDuration animations:^{
        // 重新调整
        CGFloat newHeight = spacing;
        for (XZToastTask *item in self->_showingTasks) {
            item->_frame.origin.y = newHeight;
            item.toastView.frame = item->_frame;
            item.toastView.alpha = 1.0;
            newHeight += (item->_frame.size.height + spacing);
        }
        containerViewFrame.origin.y = CGRectGetMaxY(containerViewFrame) - newHeight;
        containerViewFrame.size.height = newHeight;
        self->_containerView.frame = containerViewFrame;
        // 隐藏待移除的
        for (XZToastTask *item in _hideingTasks) {
            item.toastView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        // 向移除的 toast 发送消息
        for (XZToastTask *item in _hideingTasks) {
            [item.toastView removeFromSuperview];
            [item finish];
        }
        
        [self runUpdateCompletion];
        
        [self updateToastsIfNeeded];
    }];
    
    
    
    // 查询 toastView 是否处于展示中：
    // - 未展示：新的 toastView 添加到末尾
    // - 展示中：已有 toastView 移动到末尾
//    NSUInteger const index = [_containerView.subviews indexOfObject:toastView];
//
//    if (index == NSNotFound) {
//
//
//
//    } else {
//        [_containerView bringSubviewToFront:toastView];
//
//        [UIView animateWithDuration:0.3 animations:^{
//            CGFloat oldHeight = toastView.frame.size.height;
//
//            for (NSUInteger i = index; i < _toastViews.count - 1; i++) {
//                UIView *toastView = _containerView.subviews[i];
//                toastView.frame = CGRectOffset(toastView.frame, 0, -10.0 - oldHeight);
//            }
//
//            CGSize const newSize = [toastView sizeThatFits:CGSizeZero];
//
//            CGRect const bounds = _containerView.bounds;
//
//            CGRect frame = toastView.frame;
//            frame.origin.x = (CGRectGetWidth(bounds) - newSize.width) * 0.5;
//            frame.origin.y = CGRectGetMaxY(bounds) - 10.0 - oldHeight;
//            frame.size = newSize;
//            toastView.frame = frame;
//
//            CGFloat const deltaHeight = newSize.height - oldHeight;
//            CGRect containerFrame = _containerView.frame;
//            containerFrame.origin.y -= deltaHeight;
//            containerFrame.size.height += deltaHeight;
//            _containerView.frame = containerFrame;
//        } completion:^(BOOL finished) {
//            [self displayToastsIfNeeded];
//        }];
//    }
    
}

- (void)setNeedsLayoutToastViews {
    
}

@end
