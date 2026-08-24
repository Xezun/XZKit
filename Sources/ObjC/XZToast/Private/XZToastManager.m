//
//  XZToastManager.m
//  XZToast
//
//  Created by Xezun on 2025/4/30.
//

#import "XZToastManager.h"
#import <objc/runtime.h>
#import "XZToastView.h"
#import "XZToastWrapperView.h"
#import "XZToastTask.h"
#import "XZToast.h"
#import "UIKit+XZToast.h"

@implementation XZToastManager {
    UIViewController * __weak _viewController;
    
    NSInteger _textAlignment;
    CGFloat _offsets[3];
    /// 展示位置。
    XZToastPosition _position;
    /// 待展示。
    NSMutableArray<XZToastTask *> *_waitingToShowTasks;
    /// 可见的。仅在周期方法内才可以修改。
    NSMutableArray<XZToastTask *> *_showingTasks;
    /// 待隐藏。仍在显示中，也在 `_showingTasks` 集合中，已发送 cancel 消息。
    NSMutableArray<XZToastTask *> *_waitingToHideTasks;
    
    /// 此值为 YES 表明当前还有待展示或待隐藏的 toast 需要处理。
    /// - 每个动画周期为一个 toast 更新周期。
    /// - 当此值被标记为 YES 时，每个周期内，最多展示一个 toast 视图并移除所有到期的 toast 视图，直到没有待显示或待隐藏的 toast 视图。
    /// - 请使用 `-setNeedsUpdateToasts` 方法，而不能直接修改此实例变量。
    BOOL _needsUpdateToasts;
    
    /// 每个 toast 周期执行的回调。
    /// 不要直接访问此变量，而是使用 `-addUpdateCompletion:` 和 `-runUpdateCompletion` 方法。
    NSMutableArray<dispatch_block_t> *_updateCompletions;
    /// 是否需要重新调整 toast 布局的标记。
    BOOL _needsLayoutToasts;
}

- (void)dealloc {
    for (XZToastTask * const waitingTask in _waitingToHideTasks) {
        [waitingTask finish];
        [_showingTasks removeObject:waitingTask];
    }
    
    for (XZToastTask * const showingTask in _showingTasks) {
        [showingTask cancel];
        [showingTask finish];
    }
    
    for (XZToastTask * const watingTask in _waitingToShowTasks) {
        [watingTask cancel];
        [watingTask finish];
    }
    
    for (dispatch_block_t const completion in _updateCompletions) {
        completion();
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
        
        _lineSpacing                    = -1;  // 负数表示使用 XZToast.lineSpacing
        _textAlignment                  = -1;  // 负数表示使用 XZToast.textAlignment
        _duration                       = 0.0; // 0.0 表示使用 XZToast.duration
        _viewClass                      = Nil; // nil 表示使用 XZToast.viewClass
        _maximumNumberOfToasts          = -1;  // -1  表示使用 XZToast.maximumNumberOfToasts
        _offsets[XZToastPositionTop]    = NAN; // NAN 表示使用 XZToast.offset
        _offsets[XZToastPositionMiddle] = NAN;
        _offsets[XZToastPositionBottom] = NAN;
        
        _waitingToShowTasks = [NSMutableArray arrayWithCapacity:16];
        _showingTasks       = [NSMutableArray arrayWithCapacity:16];
        _waitingToHideTasks = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

- (XZToastTask *)showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    if (isnan(duration) || duration < 0) {
        duration = self.duration;
    }
    
    XZToastTask * const newTask = [[XZToastTask alloc] initWithManager:self toast:toast duration:duration position:position exclusive:exclusive completion:completion];
    [_waitingToShowTasks addObject:newTask];
    [self setNeedsUpdateToasts];
    
    return newTask;
}

- (void)setNeedsUpdateToasts {
    // 已经标记在刷新中
    if (_needsUpdateToasts) {
        return;
    }
    // 标记进入刷新状态
    _needsUpdateToasts = YES;
    // 开始执行刷新周期
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self updateToastsIfNeeded];
    }];
}

- (void)updateToastsIfNeeded {
    if (!_needsUpdateToasts) {
        return;
    }
    
    // 只要 _waitingItems 或 _hideingItems 不为空，当前方法就会一直执行，直到处理完所有 toast
    if (_waitingToShowTasks.count == 0 && _waitingToHideTasks.count == 0) {
        // 结束刷新周期
        _needsUpdateToasts = NO;
        // 执行周期回调
        [self runUpdateCompletion];
        return;
    }
    
    UIViewController * const _viewController = self->_viewController;
    UIView           * const _rootView       = _viewController.view;
    CGRect             const _bounds         = CGRectInset(UIEdgeInsetsInsetRect(_rootView.bounds, _rootView.safeAreaInsets), XZToastMargin, 0);
    
    NSMutableArray<XZToastTask *> * const _hideingTasks = [NSMutableArray arrayWithCapacity:16.0];
    NSArray<XZToastTask *>        * const _visibleTasks = _showingTasks.copy;
    
    // 从正显示的集合中移除待隐藏的。
    while (_waitingToHideTasks.count > 0) {
        XZToastTask * const waitingTask = _waitingToHideTasks[0];
        [_showingTasks removeObject:waitingTask];
        [_waitingToHideTasks removeObjectAtIndex:0];
        // 添加到移除列表
        [_hideingTasks addObject:waitingTask];
    }
    
    typeof(self) __weak weakSelf = self;
    
    // 将待显列队中的 toast 出列一个显示。
    // 每次只处理一个，这样每个 toast 最少有 XZToastAnimationDuration * maxCount 的展示时间。
    XZToastTask *newTask = nil;
    if (!_showingTasks.firstObject.isExclusive) {
        newTask = _waitingToShowTasks.firstObject;
        if (newTask) {
            [_waitingToShowTasks removeObjectAtIndex:0];
            
            // 开始显示，启动定时器
            if (newTask.duration > 0) {
                [newTask resume:^(XZToastTask * _Nonnull task) {
                    [weakSelf task:task didFinishPresentation:YES];
                }];
            }
            
            // 独占类型，结束正在显示的
            if (newTask.isExclusive) {
                while (_showingTasks.count > 0) {
                    XZToastTask * const showingTask = _showingTasks[0];
                    [_showingTasks removeObjectAtIndex:0];
                    [_hideingTasks addObject:showingTask];
                    
                    [showingTask cancel];
                }
            }
            
            // 更换了展示位置，移除所有
            if (_position != newTask.position) {
                _position = newTask.position;
                while (_showingTasks.count > 0) {
                    XZToastTask * const showingTask = _showingTasks[0];
                    [_showingTasks removeObjectAtIndex:0];
                    [_hideingTasks addObject:showingTask];
                    
                    [showingTask cancel];
                }
            }
            
            // 检查数量限制，超出就直接移除
            NSInteger const _maximumNumberOfToasts = self.maximumNumberOfToasts;
            if (_maximumNumberOfToasts > 0) {
                while (_showingTasks.count >= _maximumNumberOfToasts) {
                    XZToastTask * const showingTask = _showingTasks[0];
                    [_showingTasks removeObjectAtIndex:0];
                    [_hideingTasks addObject:showingTask];
                    
                    showingTask.hideReason = XZToastHideReasonExceed;
                    [showingTask cancel];
                }
            }
            
            // 复用视图
            XZToastTask *reusingTask = nil;
            if (!newTask.wrapperView) {
                for (XZToastTask * const hideingTask in _hideingTasks) {
                    if (hideingTask.isViewReusable) {
                        hideingTask.isViewReused = YES;
                        hideingTask.toast->_view = nil;
                        // 复用视图
                        newTask.wrapperView    = hideingTask.wrapperView;
                        newTask.isViewReusable = YES;
                        // 记录一下
                        reusingTask = hideingTask;
                        break;
                    }
                }
                // 没有复用，创建容器
                if (!reusingTask) {
                    newTask.wrapperView = [[XZToastWrapperView alloc] init];
                }
            }
            
            // 创建视图
            UIView *toastView = newTask.toast.view;
            if (toastView) {
                // 有自定义视图
                newTask.wrapperView.view = toastView;
                newTask.isViewReusable = NO;
            } else {
                // 无自定义视图
                toastView = newTask.wrapperView.view;
                // 已有复用视图
                if (!toastView) {
                    Class const ViewClass = self.viewClass;
                    toastView = [[ViewClass alloc] init];
                    newTask.wrapperView.view = toastView;
                    newTask.isViewReusable = YES;
                }
                // 将 toast 与视图关联
                newTask.toast->_view = toastView;
            }
            
            // 向视图发送事件，配置视图
            newTask.wrapperView.shadowColor = self.shadowColor;
            if ([toastView conformsToProtocol:@protocol(XZToastView)] && [toastView respondsToSelector:@selector(toast:willShowInViewController:)]) {
                [(id<XZToastView>)toastView toast:newTask.toast willShowInViewController:_viewController];
            }
            
            // 如果是复用的视图，则将 newTask 插入到复用视图当前的位置，避免视图的顺序改变。
            NSInteger newIndex = NSNotFound;
            if (reusingTask) {
                NSInteger const oldIndex = [_visibleTasks indexOfObject:reusingTask];
                if (oldIndex != NSNotFound) {
                    for (NSInteger i = oldIndex - 1; i >= 0; i--) {
                        XZToastTask * const visibleTask = _visibleTasks[i];
                        newIndex = [_showingTasks indexOfObject:visibleTask];
                        if (newIndex != NSNotFound) {
                            newIndex += 1;
                            break;
                        }
                    }
                    // reusingTask 前面的在当前循环中都移除了
                    if (newIndex == NSNotFound) {
                        newIndex = 0;
                    }
                }
            }
            
            // 动画方向
            if (newIndex != NSNotFound) {
                newTask.moveDirection = reusingTask.moveDirection;
                [_showingTasks insertObject:newTask atIndex:newIndex];
            } else {
                switch (_position) {
                    case XZToastPositionTop: {
                        newTask.moveDirection = XZToastMoveDirectionLand;
                        break;
                    }
                    case XZToastPositionMiddle: {
                        XZToastTask * const lastTask = _showingTasks.lastObject;
                        newTask.moveDirection = lastTask ? (lastTask.moveDirection * (-1)) : XZToastMoveDirectionRise;
                        break;
                    }
                    case XZToastPositionBottom: {
                        newTask.moveDirection = XZToastMoveDirectionRise;
                        break;
                    }
                }
                [_showingTasks addObject:newTask];
            }
        }
    }
    
    // 没有新消息，也没有需要隐藏的消息
    if (newTask == nil && _hideingTasks.count == 0) {
        _needsUpdateToasts = NO;
        [self runUpdateCompletion];
        return;
    }
    
    CGFloat const offset = [self offsetForPosition:_position];
    
    // MARK: - 视图入场：准备动画
    if (newTask) {
        UIView * const wrapperView = newTask.wrapperView;
        // 计算大小
        newTask->_frame.size = [wrapperView sizeThatFits:CGSizeMake(_bounds.size.width, 0)];
        newTask->_frame.origin.x = (_bounds.size.width - newTask->_frame.size.width) * 0.5 + _bounds.origin.x;
        // 复用的视图，可能已经处于显示状态
        if (wrapperView.superview) {
            // 显示中：执行从当前状态到目标状态的动画。
            CALayer * const presentationLayer = wrapperView.layer.presentationLayer;
            if (presentationLayer) {
                // 正在动画中，复制当前状态
                wrapperView.alpha = presentationLayer.opacity;
                if (wrapperView.superview != _rootView) {
                    wrapperView.frame = [wrapperView.superview convertRect:presentationLayer.frame toView:_rootView];
                    [_rootView addSubview:wrapperView];
                }
            } else if (wrapperView.superview != _rootView) {
                // 未在动画中，转移视图即可
                wrapperView.frame = [wrapperView.superview convertRect:wrapperView.frame toView:_rootView];
                [_rootView addSubview:wrapperView];
            }
        } else {
            [_rootView addSubview:wrapperView];
            // 未显示：展示入场动画
            // 入场效果：渐显
            wrapperView.alpha = 0.0;
            // 入场效果：平移
            switch (_position) {
                case XZToastPositionTop: {
                    // 在顶部，新的 toast 从顶部往目标位置平移，所以初始位置向上平移一个高度。
                    newTask->_frame.origin.y = (CGRectGetMinY(_bounds) + offset) - newTask->_frame.size.height;
                    break;
                }
                case XZToastPositionMiddle: {
                    // 在中部，新的 toast 从中间渐显，不平移，初始位置就是目标位置
                    CGFloat const height = newTask->_frame.size.height;
                    newTask->_frame.origin.y = CGRectGetMidY(_bounds) + offset - height * 0.5;
                    break;
                }
                case XZToastPositionBottom: {
                    // 在顶部，新的 toast 从底部往目标位置平移，所以初始位置向下平移一个高度。
                    newTask->_frame.origin.y = CGRectGetMaxY(_bounds) + offset;
                    break;
                }
            }
            wrapperView.frame = newTask->_frame;
        }
    }
    
    // MARK: - 视图入场：执行动画
    UIViewKeyframeAnimationOptions const options = UIViewKeyframeAnimationOptionLayoutSubviews;
    [UIView animateKeyframesWithDuration:XZToastAnimationDuration delay:0 options:options animations:^{
        // 添加一个缩放动画，解决在复用时，若视图没有任何动画，动画回调会被立即执行的问题。
        if (newTask && newTask.wrapperView.alpha == 1.0 && CGSizeEqualToSize(newTask->_frame.size, newTask.wrapperView.frame.size)) {
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                CGFloat scale = newTask.wrapperView.frame.size.width;
                scale = (scale + 10.0) / scale;
                newTask.wrapperView.transform = CGAffineTransformMakeScale(scale, scale);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:1.0 animations:^{
                newTask.wrapperView.transform = CGAffineTransformIdentity;
            }];
        }
        
        [self layoutToastsInBounds:_bounds offset:offset];
        
        for (XZToastTask * const hidedingTask in _hideingTasks) {
            if (hidedingTask.isViewReused) {
                continue;
            }
            // MARK: - 视图退场：执行动画，渐隐、平移
            // 如果此处新增动画效果，也需要在复用处添加相应的反向效果。
            // 在复用模式下，上述这些动画，需要执行相反的动画处理，即隐藏包含 alpha/frame 两种动画，复用逻辑则这两种动画的反向动画。
            CGFloat direction = 0.0;
            switch (hidedingTask.position) {
                case XZToastPositionTop:
                case XZToastPositionBottom: {
                    switch (hidedingTask.hideReason) {
                        case XZToastHideReasonNormal:
                            // 正常隐藏，反向平移
                            direction = -hidedingTask.moveDirection;
                            break;
                        case XZToastHideReasonExceed:
                            // 溢出隐藏，正向平移
                            direction = +hidedingTask.moveDirection;
                            break;
                    }
                    break;
                }
                case XZToastPositionMiddle:
                    switch (hidedingTask.hideReason) {
                        case XZToastHideReasonNormal:
                            // 正常隐藏，渐隐
                            direction = 0;
                            break;
                        case XZToastHideReasonExceed:
                            // 溢出隐藏，正向平移
                            direction = +hidedingTask.moveDirection;
                            break;
                    }
            }
            CGFloat const deltaY = (hidedingTask->_frame.size.height + 20) * direction;
            hidedingTask.wrapperView.alpha = 0.0;
            hidedingTask.wrapperView.frame = CGRectOffset(hidedingTask.wrapperView.frame, 0, deltaY);
        }
    } completion:^(BOOL finished) {
        [weakSelf task:newTask hideingTask:_hideingTasks didFinishAnimation:finished];
    }];
}

- (void)task:(XZToastTask *)newTask hideingTask:(NSArray<XZToastTask *> *)_hideingTasks didFinishAnimation:(BOOL)finished {
    UIViewController * const _viewController = self->_viewController;
    
    if (newTask) {
        id<XZToastView> const toastView = (id)newTask.wrapperView.view;
        if ([toastView conformsToProtocol:@protocol(XZToastView)] && [toastView respondsToSelector:@selector(toast:didShowInViewController:)]) {
            [toastView toast:newTask.toast didShowInViewController:_viewController];
        }
    }
    
    // 执行操作回调
    [self runUpdateCompletion];
    
    // 向移除的 toast 发送消息
    for (NSInteger i = 0; i < _hideingTasks.count; i++) {
        XZToastTask * const hideingTask = _hideingTasks[i];
        // 完成周期
        [hideingTask finish];
        // 视图已被复用
        if (hideingTask.isViewReused) {
            continue;
        }
        // 复用视图
        [hideingTask.wrapperView removeFromSuperview];
        if (!hideingTask.isViewReusable) {
            continue;
        }
        // 因为在 finish 回调中，可能会修改 _waitingToShowTasks 集合，所以每次都重新遍历。
        for (XZToastTask * const waitingTask in _waitingToShowTasks) {
            if (waitingTask.wrapperView) {
                continue;
            }
            // 复用视图
            waitingTask.wrapperView = hideingTask.wrapperView;
            waitingTask.isViewReusable = YES;
            
            // 重置状态
            hideingTask.toast->_view = nil;
            hideingTask.isViewReused = YES;
            break;
        }
    }
    
    [self updateToastsIfNeeded];
}

- (void)task:(XZToastTask *)task didFinishPresentation:(BOOL)flag {
    [_waitingToHideTasks addObject:task];
    [self setNeedsUpdateToasts];
}

- (void)hideToastWithTask:(XZToastTask *)task completion:(void (^)(void))completion {
    if (task == nil) {
        for (XZToastTask * const task in _showingTasks) {
            [task cancel];
            [_waitingToHideTasks addObject:task];
        }
        
        for (XZToastTask * const task in _waitingToShowTasks) {
            [task cancel];
            [_waitingToHideTasks addObject:task];
        }
        [_waitingToShowTasks removeAllObjects];
    } else if (![_waitingToHideTasks containsObject:task]) {
        NSInteger index = NSNotFound;
        if ((index = [_showingTasks indexOfObject:task]) != NSNotFound) {
            [_showingTasks removeObjectAtIndex:index];
            [task cancel];
            [_waitingToHideTasks addObject:task];
        } else if ((index = [_waitingToShowTasks indexOfObject:task]) != NSNotFound) {
            [_waitingToShowTasks removeObjectAtIndex:index];
            [task cancel];
            [_waitingToHideTasks addObject:task];
        }
    }
    
    [self addUpdateCompletion:completion];
    [self setNeedsUpdateToasts];
}

- (void)hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    if (toast == nil) {
        for (XZToastTask * const showingTask in _showingTasks) {
            [showingTask cancel];
            [_waitingToHideTasks addObject:showingTask];
        }
        for (XZToastTask * const waitingTask in _waitingToShowTasks) {
            [waitingTask cancel];
            [_waitingToHideTasks addObject:waitingTask];
        }
        [_waitingToShowTasks removeAllObjects];
    } else {
        for (XZToastTask * const showingTask in _showingTasks) {
            if (showingTask.toast == toast) {
                [showingTask cancel];
                [_waitingToHideTasks addObject:showingTask];
            }
        }
        
        for (NSInteger index = _waitingToShowTasks.count - 1; index >= 0; index--) {
            XZToastTask * const waitingTask = _waitingToShowTasks[index];
            if (waitingTask.toast == toast) {
                [waitingTask cancel];
                [_waitingToHideTasks addObject:waitingTask];
                [_waitingToShowTasks removeObjectAtIndex:index];
            }
        }
    }
    
    [self addUpdateCompletion:completion];
    [self setNeedsUpdateToasts];
}

- (void)addUpdateCompletion:(void (^const)(void))updateCompletion {
    if (updateCompletion) {
        if (!_updateCompletions) {
            _updateCompletions = [NSMutableArray array];
        }
        [_updateCompletions addObject:updateCompletion];
    }
}

- (void)runUpdateCompletion {
    for (dispatch_block_t completion in _updateCompletions) {
        completion();
    }
    [_updateCompletions removeAllObjects];
}

#pragma mark - 公开方法

@synthesize viewClass = _viewClass;
@synthesize maximumNumberOfToasts = _maximumNumberOfToasts;
@synthesize textColor = _textColor;
@synthesize font = _font;
@synthesize backgroundColor = _backgroundColor;
@synthesize shadowColor = _shadowColor;
@synthesize color = _color;
@synthesize tintColor = _tintColor;

- (UIViewController *)viewController {
    return _viewController;
}

- (Class)viewClass {
    return _viewClass ?: XZToast.viewClass;
}

- (void)setViewClass:(Class)viewClass {
    if (_viewClass != viewClass) {
        NSParameterAssert(viewClass == Nil || [viewClass isKindOfClass:UIView.class]);
        _viewClass = viewClass;
    }
}

- (NSInteger)maximumNumberOfToasts {
    return _maximumNumberOfToasts < 0 ? XZToast.maximumNumberOfToasts : _maximumNumberOfToasts;
}

- (void)setMaximumNumberOfToasts:(NSInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = maximumNumberOfToasts;
    [self setNeedsUpdateToasts];
}

- (UIColor *)textColor {
    return _textColor ?: XZToast.textColor;
}

- (UIFont *)font {
    return _font ?: XZToast.font;
}

- (UIColor *)backgroundColor {
    return _backgroundColor ?: XZToast.backgroundColor;
}

- (UIColor *)shadowColor {
    return _shadowColor ?: XZToast.shadowColor;
}

- (UIColor *)color {
    return _color ?: XZToast.color;
}

- (UIColor *)tintColor {
    return _tintColor ?: XZToast.tintColor;
}

- (CGFloat)lineSpacing {
    return _lineSpacing >= 0 ? _lineSpacing : XZToast.lineSpacing;
}

- (NSTextAlignment)textAlignment {
    return _textAlignment >= 0 ? (NSTextAlignment)_textAlignment : XZToast.textAlignment;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
}

- (NSTimeInterval)duration {
    return _duration > 0 ? _duration : XZToast.duration;
}

- (CGFloat)offsetForPosition:(XZToastPosition)position {
    CGFloat const offset = _offsets[position];
    return isnan(offset) ? [XZToast offsetForPosition:position] : offset;
}

- (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    _offsets[position] = offset;
}

- (void)setNeedsLayoutToasts {
    if (_needsLayoutToasts) {
        return;
    }
    _needsLayoutToasts = YES;
    
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self layoutToastsIfNeeded];
    }];
}

- (void)layoutToastsIfNeeded {
    if (!_needsLayoutToasts) {
        return;
    }
    UIView * const rootView = _viewController.view;
    CGRect   const bounds   = CGRectInset(UIEdgeInsetsInsetRect(rootView.bounds, rootView.safeAreaInsets), XZToastMargin, 0);
    CGFloat  const offset   = [self offsetForPosition:_position];
    
    // 计算大小
    for (XZToastTask * const showingTask in _showingTasks) {
        UIView * const wrapperView = showingTask.wrapperView;
        showingTask->_frame.size     = [wrapperView sizeThatFits:CGSizeMake(bounds.size.width, 0)];
        showingTask->_frame.origin.x = (bounds.size.width - showingTask->_frame.size.width) * 0.5 + bounds.origin.x;
    }
    
    [UIView animateWithDuration:XZToastAnimationDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self layoutToastsInBounds:bounds offset:offset];
    } completion:nil];
    
    _needsLayoutToasts = NO;
}

- (void)layoutToastsInBounds:(CGRect const)bounds offset:(CGFloat const)offset {
    NSInteger const count = _showingTasks.count;
    if (count == 0) {
        return;
    }
    
    // 调整布局
    switch (self->_position) {
        case XZToastPositionTop: {
            // 最新的在上面，向下排列
            CGFloat minY = CGRectGetMinY(bounds) + offset;
            for (NSInteger index = count - 1; index >= 0; index--) {
                XZToastTask * const showingTask = self->_showingTasks[index];
                showingTask->_frame.origin.y = minY;
                
                UIView * const wrapperView = showingTask.wrapperView;
                wrapperView.alpha = 1.0;
                wrapperView.frame = showingTask->_frame;
                
                minY = CGRectGetMaxY(showingTask->_frame);
            }
            break;
        }
        case XZToastPositionMiddle: {
            // 最新的在中间，上下排列
            XZToastTask * const lastTask = self->_showingTasks[count - 1];
            lastTask->_frame.origin.y = CGRectGetMidY(bounds) + offset - lastTask->_frame.size.height * 0.5;
            
            UIView * const wrapperView = lastTask.wrapperView;
            wrapperView.alpha = 1.0;
            wrapperView.frame = lastTask->_frame;
            
            CGFloat minY = CGRectGetMinY(lastTask->_frame);
            CGFloat maxY = CGRectGetMaxY(lastTask->_frame);
            
            for (NSInteger index = count - 2; index >= 0; index--) {
                XZToastTask * const showingTask = self->_showingTasks[index];
                if (showingTask.moveDirection == XZToastMoveDirectionRise) {
                    showingTask->_frame.origin.y = minY - CGRectGetHeight(showingTask->_frame);
                    showingTask.wrapperView.frame = showingTask->_frame;
                    minY = CGRectGetMinY(showingTask->_frame);
                } else {
                    showingTask->_frame.origin.y = maxY;
                    showingTask.wrapperView.frame = showingTask->_frame;
                    maxY = CGRectGetMaxY(showingTask->_frame);
                }
            }
            break;
        }
        case XZToastPositionBottom: {
            // 最新的在底部，向上排列
            CGFloat maxY = CGRectGetMaxY(bounds) + offset;
            for (NSInteger index = count - 1; index >= 0; index--) {
                XZToastTask * const showingTask = self->_showingTasks[index];
                showingTask->_frame.origin.y = maxY - CGRectGetHeight(showingTask->_frame);
                
                UIView * const wrapperView = showingTask.wrapperView;
                wrapperView.alpha = 1.0;
                wrapperView.frame = showingTask->_frame;
                
                maxY = CGRectGetMinY(showingTask->_frame);
            }
            break;
        }
    }
}

@end
