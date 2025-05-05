//
//  XZToastManager.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastManager.h"
#import <objc/runtime.h>
#import "XZToastContainerView.h"
#import "XZToastItem.h"
#import "XZToast.h"

@implementation XZToastManager {
    UIViewController * __weak _viewController;
    
    /// 待展示的提示信息
    NSMutableArray<XZToastItem *> *_waitingItems;
    /// 展示中的提示信息
    NSMutableArray<XZToastItem *> *_showingItems;
    /// 待移除的提示信息
    NSMutableArray<XZToastItem *> *_hideingItems;
    
    
    BOOL _needsUpdateToasts;
    UIView *_containerView;
    
    XZToastHideCompletion _completion;
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
        
        _waitingItems = [NSMutableArray arrayWithCapacity:4];
        _showingItems = [NSMutableArray arrayWithCapacity:4];
        _hideingItems = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (void)showToast:(XZToastItem *)item {
    [_waitingItems addObject:item];
    [self setNeedsUpdateToasts];
}

- (void)addHideCompletion:(XZToastHideCompletion)hideCompletion {
    if (hideCompletion) {
        XZToastHideCompletion const oldValue = _completion;
        if (oldValue) {
            _completion = ^{
                oldValue();
                hideCompletion();
            };
        } else {
            _completion = hideCompletion;
        }
    }
}

- (void)hideToast:(nullable XZToastItem *)item completion:(XZToastHideCompletion)completion {
    if (item) {
        // 查询取消中的 toast
        NSUInteger index = [_hideingItems indexOfObject:item];
        if (index != NSNotFound) {
            [self addHideCompletion:completion];
            return;
        }
        
        // 查找显示中的 toast
        index = [_showingItems indexOfObject:item];
        if (index != NSNotFound) {
            [_showingItems removeObjectAtIndex:index];
            
            [item cancel];
            [self addHideCompletion:completion];
            [_hideingItems addObject:item];
            
            [self setNeedsUpdateToasts];
            return;
        }
        
        // 查找列队中的 toast
        index = [_waitingItems indexOfObject:item];
        if (index != NSNotFound) {
            [item cancel];
            [_waitingItems removeObject:item];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (item.showCompletion) {
                    item.showCompletion(NO);
                }
                if (completion) {
                    completion();
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    } else {
        BOOL flags = NO;
        
        if (_hideingItems.count > 0) {
            flags = YES;
        }
        
        if (_showingItems.count > 0) {
            flags = YES;
            while (_showingItems.count > 0) {
                XZToastItem *item = _showingItems.lastObject;
                [_showingItems removeLastObject];
                
                [item cancel];
                [_hideingItems addObject:item];
            }
        }
        
        if (_waitingItems.count > 0) {
            NSArray *waitingItems = [_waitingItems copy];
            [_waitingItems removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (XZToastItem *item in waitingItems) {
                    [item cancel];
                    if (item.showCompletion) {
                        item.showCompletion(NO);
                    }
                }
                
                if (!flags && completion) {
                    completion();
                }
            });
        }
        
        if (flags) {
            [self addHideCompletion:completion];
            [self setNeedsUpdateToasts];
        }
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
    
    if (_waitingItems.count == 0 && _hideingItems.count == 0) {
        if (_showingItems.count == 0) {
            [_containerView removeFromSuperview];
        }
        _needsUpdateToasts = NO;
        return;
    }
    
    // H:|-padding-spacing-[toast]-spacing-padding-|
    // V:|-padding-spacing-[toast]-spacing-[toast]-spacing-padding-|
    CGFloat const padding = 20.0; // 边距
    CGFloat const spacing = 10.0; // 间距
     
    // 初始化容器视图
    if (_containerView.superview == nil) {
        if (!_viewController.isViewLoaded) {
            NSLog(@"控制器尚未显示，无法展示提示信息");
            return;
        }
        CGRect const bounds = UIEdgeInsetsInsetRect(_viewController.view.bounds, _viewController.view.safeAreaInsets);
        CGFloat const w = CGRectGetWidth(bounds) - padding * 2.0;
        CGFloat const x = CGRectGetMinX(bounds) + padding;
        CGFloat const h = spacing;
        CGFloat const y = CGRectGetMaxY(bounds) - padding - h;
        _containerView.frame = CGRectMake(x, y, w, h);
        [_viewController.view addSubview:_containerView];
    }
    
    CGRect __block containerViewFrame = _containerView.frame;
    CGFloat const kMaxItemWidth = (containerViewFrame.size.width - spacing * 2.0);
    
    // 将等待中的 toast 出列一个显示。
    // 每次只展示一个，这样每个 toast 最少有 0.3 秒的展示时间。
    XZToastItem * const newToastItem = _waitingItems.firstObject;
    if (newToastItem) {
        [_waitingItems removeObjectAtIndex:0];
        
        newToastItem.task = dispatch_block_create(DISPATCH_BLOCK_NO_QOS_CLASS, ^{
            [self _hideToast:newToastItem completion:nil];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(newToastItem.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), newToastItem.task);
        [_showingItems addObject:newToastItem];
        
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
    if (_showingItems.count > 3) {
        XZToastItem *firstItem = _showingItems.firstObject;
        firstItem.isDone = NO;
        dispatch_block_cancel(firstItem.task);
        firstItem.task = nil;
        [_showingItems removeObjectAtIndex:0];
        
        [_hideingItems addObject:firstItem];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        // 重新调整
        CGFloat newHeight = spacing;
        for (XZToastItem *item in self->_showingItems) {
            item->_frame.origin.y = newHeight;
            item.toastView.frame = item->_frame;
            item.toastView.alpha = 1.0;
            newHeight += (item->_frame.size.height + spacing);
        }
        containerViewFrame.origin.y = CGRectGetMaxY(containerViewFrame) - newHeight;
        containerViewFrame.size.height = newHeight;
        self->_containerView.frame = containerViewFrame;
        // 待移除的隐藏
        for (XZToastItem *item in self->_hideingItems) {
            item.toastView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        // 向移除的 toast 发送消息
        for (XZToastItem *item in self->_hideingItems) {
            [item.toastView removeFromSuperview];
            if (item.showCompletion) {
                item.showCompletion(item.isDone);
            }
        }
        [self->_hideingItems removeAllObjects];
        
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

@end


@implementation XZToastTask {
    BOOL _isExecuting;
    BOOL _isFinished;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)setFinished:(BOOL)isFinished {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)main {
    [super main];
    [UIView animateWithDuration:0.3 animations:^{
            
    } completion:^(BOOL finished) {
        [self setFinished:YES];
    }];
}



@end


