//
//  XZImageViewerItemView.m
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import "XZImageViewerItemView.h"

@interface XZImageViewerItemViewTransitionView : UIView
@end
@interface XZImageViewerItemViewZoomingView : UIScrollView
@end
@interface XZImageViewerItemViewWrapperView : UIView
@end
@implementation XZImageViewerItemViewTransitionView
@end
@implementation XZImageViewerItemViewZoomingView
@end
@implementation XZImageViewerItemViewWrapperView
@end

@interface XZImageViewerItemView ()
/// 提供缩放功能的滚动视图。
@property (nonatomic, readonly, nonnull) UIScrollView *zoomingView;
/// 内容视图容器，内容在此视图上按照内容模式布局；此视图大小不会超过缩放视图，以方便控制缩放。
@property (nonatomic, readonly, nonnull) UIView *wrapperView;
@end

@implementation XZImageViewerItemView

@synthesize contentView = _contentView; // 内容视图
@synthesize wrapperView = _wrapperView; // 盛放内容视图的视图，缩放时，实际缩放的是此视图（根据适配规则，可能只显示内容视图的部分区域）。
@synthesize zoomingView = _zoomingView; // 处理缩放的视图。
@synthesize minimumZoomScale = _minimumZoomScale;
@synthesize maximumZoomScale = _maximumZoomScale;
@synthesize contentOffset    = _contentOffset;
@synthesize zoomScale        = _zoomScale;
@synthesize contentMode      = _contentMode;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        _index = NSNotFound;
        _zoomScale  = 1.0;
//        _transition = 0.0;
        _contentOffset = CGPointZero;
        _minimumZoomScale = 1.0;
        _maximumZoomScale = 1.0;
        _interitemSpacing = 0.0;
//        _pagingOrientation = pagingOrientation;
    }
    return self;
}

- (UIScrollView *)zoomingView {
    if (_zoomingView != nil) {
        return _zoomingView;
    }
    _zoomingView = [[XZImageViewerItemViewZoomingView alloc] initWithFrame:self.bounds];
    _zoomingView.backgroundColor        = self.backgroundColor;
    _zoomingView.bounces                = NO;
    _zoomingView.bouncesZoom            = YES;
    _zoomingView.clipsToBounds          = YES;
    _zoomingView.alwaysBounceVertical   = YES;
    _zoomingView.alwaysBounceHorizontal = YES;
    _zoomingView.showsVerticalScrollIndicator   = NO;
    _zoomingView.showsHorizontalScrollIndicator = NO;
    _zoomingView.minimumZoomScale = _minimumZoomScale;
    _zoomingView.maximumZoomScale = _maximumZoomScale;
    _zoomingView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self addSubview:_zoomingView];
    
    self.wrapperView.clipsToBounds = NO;
    [_zoomingView addSubview:_wrapperView];
    
    _zoomingView.delegate = self;
    
    // 布局 _wrapperView 和 _contentView
    [self XZImageViewerItemViewLayoutSubviews];
    
    _zoomingView.zoomScale        = _zoomScale;
    _zoomingView.contentOffset    = _contentOffset;
    
    return _zoomingView;
}

- (UIView *)wrapperView {
    if (_wrapperView != nil) {
        return _wrapperView;
    }
    _wrapperView = [[XZImageViewerItemViewWrapperView alloc] initWithFrame:self.bounds];
    _wrapperView.backgroundColor = self.backgroundColor;
    
    if (_zoomingView == nil) {
        _wrapperView.clipsToBounds = YES;
        [self addSubview:_wrapperView];
    }
    
    return _wrapperView;
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize animated:(BOOL)animated {
    if (!CGSizeEqualToSize(preferredContentSize, _preferredContentSize)) {
        _preferredContentSize = preferredContentSize;
        if (animated) {
            return [UIView animateWithDuration:0.3 animations:^{
                [self setIndex:self->_index contentView:self->_contentView preferredContentSize:self->_preferredContentSize zoomScale:1.0 contentOffset:CGPointZero];
            }];
        }
        return [self setIndex:self->_index contentView:self->_contentView preferredContentSize:self->_preferredContentSize zoomScale:1.0 contentOffset:CGPointZero];
    }
}

- (BOOL)bouncesZoom {
    return _zoomingView.bouncesZoom;
}

- (void)setBouncesZoom:(BOOL)bouncesZoom {
    [self.zoomingView setBouncesZoom:bouncesZoom];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    _minimumZoomScale = MAX(0, MIN(1.0, minimumZoomScale));
    _maximumZoomScale = MAX(1.0, maximumZoomScale);
    
    if (_minimumZoomScale != _maximumZoomScale) {
        if (_zoomingView == nil) {
            [self zoomingView];
        } else {
            _zoomingView.minimumZoomScale = _minimumZoomScale;
            _zoomingView.maximumZoomScale = _maximumZoomScale;
        }
    }
}

- (CGPoint)contentOffset {
    if (_zoomingView == nil) {
        return _contentOffset;
    }
    return _zoomingView.contentOffset;
}

- (CGFloat)zoomScale {
    if (_zoomingView == nil) {
        return _zoomScale;
    }
    return _zoomingView.zoomScale;
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [_zoomingView zoomToRect:rect animated:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    _contentOffset = contentOffset;
    [_zoomingView setContentOffset:contentOffset animated:animated];
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated {
    _zoomScale = scale;
    [_zoomingView setZoomScale:scale animated:animated];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [_wrapperView setBackgroundColor:backgroundColor];
    [_zoomingView setBackgroundColor:backgroundColor];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    if (_contentMode != contentMode) {
        _contentMode = contentMode;
        // contentMode 改变，重置缩放。
        _zoomScale = 1.0;
        _contentOffset = CGPointZero;
        [_zoomingView setZoomScale:1.0 animated:NO];
        [_zoomingView setContentOffset:(CGPointZero) animated:NO];
        [self setNeedsLayout];
    }
}

- (UIViewContentMode)contentMode {
    return _contentMode;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 重置缩放：当 _XZCarouselView 的 layoutSubviews 方法执行时，会先重置缩放；因为横向滚动时，会调用其子视图的 layoutSubviews 方法，即此方法会被调用，故不能在这里重置缩放，否则只要横向滚动就会重置缩放。
    // 因此，只有在缩放比为 1.0 时，才需要执行布局。
    // 需要重新布局时，不需要调整 _zoomingView 的位置，其由 autosizing 控制。
    
    if (_zoomingView == nil || _zoomingView.zoomScale == 1.0) {
        [self XZImageViewerItemViewLayoutSubviews];
    }
}

- (void)XZImageViewerItemViewLayoutSubviews {
    // 如果 _transitionView 不在当前视图上，不处理。
    CGRect const kBounds      = self.bounds;
    CGRect const contentFrame = CGRectZero;//XZCarouselViewFittingContentWithMode(kBounds, _preferredContentSize, self.contentMode);
    
    // 调整间距，会改变 _zoomingView 或 _wrapperView 的 frame 。
    // 因为 _contentView 的 autosizingMask 未知，所以如果先更新了 _contentView ，那么在设置 _wrapperView 的 frame 时，
    // _contentView 可能因其 autosizingMask 而自动改变了 frame ，达不到预期目的。
    [self XZImageViewerItemViewUpdateInteritemSpacing:kBounds];
    
    // 缩放视图存在时，计算规则要根据 _wrapperView 计算。
    if (_zoomingView != nil) {
        CGFloat const zoomScale = _zoomingView.zoomScale;
        CGPoint const contentOffset = _zoomingView.contentOffset;
        
        _zoomingView.zoomScale = 1.0;
        _zoomingView.contentOffset = CGPointZero;
        
        CGSize const zoomingSize  = CGSizeMake(MIN(kBounds.size.width, contentFrame.size.width), MIN(kBounds.size.height, contentFrame.size.height));
        CGRect const wrapperFrame = XZCarouselViewFittingContentWithMode(kBounds, zoomingSize, self.contentMode);
        
        _zoomingView.contentSize = zoomingSize;
        _wrapperView.frame = wrapperFrame;
        _contentView.frame = CGRectMake(contentFrame.origin.x - wrapperFrame.origin.x, contentFrame.origin.y - wrapperFrame.origin.y, contentFrame.size.width, contentFrame.size.height);
        
        _zoomingView.zoomScale = zoomScale;
        _zoomingView.contentOffset = contentOffset;
        _zoomingView.bouncesZoom = zoomScale != 1.0;
        return;
    }
    
    // 如果 _wrapperView 不存在，则说明 _contentView 也没有。
    if (_wrapperView == nil) {
        return;
    }
    
    // 没有缩放视图，且存在内容视图。
    if (_zoomScale == 1.0) {
        _contentView.frame = contentFrame;
        return;
    }
    
    // 没有缩放视图，但是缩放倍率不为 1 需模拟缩放情况来布局 _contentView 。
    CGSize const zoomedSize = CGSizeMake(contentFrame.size.width * _zoomScale, contentFrame.size.height * _zoomScale);
    CGRect frame = CGRectMake(contentFrame.origin.x * _zoomScale, contentFrame.origin.y * _zoomScale, zoomedSize.width, zoomedSize.height);
    if (zoomedSize.width <= kBounds.size.width) {
        frame.origin.x = (kBounds.size.width - zoomedSize.width) * 0.5;
    } else if (frame.origin.x > 0) {
        frame.origin.x = 0;
    }
    if (zoomedSize.height <= kBounds.size.height) {
        frame.origin.y = (kBounds.size.height - zoomedSize.height) * 0.5;
    } else if (frame.origin.y > 0) {
        frame.origin.y = 0;
    }
    frame = CGRectOffset(frame, -_contentOffset.x, -_contentOffset.y);
    _contentView.frame = frame;
}

- (void)XZImageViewerItemViewUpdateInteritemSpacing:(CGRect const)kBounds {
    switch (_pagingOrientation) {
        case XZCarouselViewOrientationHorizontal:
            (_zoomingView ?: _wrapperView).frame = CGRectOffset(kBounds, _transition * _interitemSpacing, 0);
            break;
            
        case XZCarouselViewOrientationVertical:
            (_zoomingView ?: _wrapperView).frame = CGRectOffset(kBounds, 0, _transition * _interitemSpacing);
            break;
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    if (_interitemSpacing != interitemSpacing) {
        _interitemSpacing = interitemSpacing;
        [self XZImageViewerItemViewUpdateInteritemSpacing:self.bounds];
    }
}

- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        [self XZImageViewerItemViewUpdateInteritemSpacing:self.bounds];
    }
}

- (void)setPagingOrientation:(XZCarouselViewOrientation)pagingOrientation {
    if (_pagingOrientation != pagingOrientation) {
        _pagingOrientation = pagingOrientation;
        [self XZImageViewerItemViewUpdateInteritemSpacing:self.bounds];
    }
}

- (void)setIndex:(NSInteger)index contentView:(UIView *)contentView preferredContentSize:(CGSize)preferredContentSize zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset {
    // 记录新值。
    _index = index;
    
    if (_contentView != contentView) {
        // 旧视图移除。
        if (_contentView.superview == _wrapperView) {
            [_contentView removeFromSuperview];
        }
        _contentView = contentView;
        // 如果新视图不为 nil ，则添加新视图。
        if (_contentView != nil) {
            [self.wrapperView addSubview:_contentView];
        }
    } else if (_contentView != nil) {
        [_wrapperView addSubview:_contentView];
    }
    
    _preferredContentSize = preferredContentSize;
    
    _zoomScale = zoomScale;
    _contentOffset = contentOffset;
    
    if (_zoomingView) {
        _zoomingView.zoomScale = zoomScale;
        _zoomingView.bounces   = zoomScale != 1.0;
        _zoomingView.contentOffset = contentOffset;
    }
    // 布局视图。
    [self XZImageViewerItemViewLayoutSubviews];
}

#pragma mark - <UIScrollViewDelegate.拖动>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_delegate XZImageViewerItemViewWillBeginDragging:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_delegate XZImageViewerItemViewDidEndDragging:self willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_delegate XZImageViewerItemViewDidEndDecelerating:self];
}

#pragma mark - <UIScrollViewDelegate.缩放>

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _wrapperView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    _zoomingView.bounces = YES;
    
    [_delegate XZImageViewerItemViewWillBeginZooming:self];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    // 在缩放的过程中，contentSize 也会同步缩放，且 contentSize 应该与被缩放的视图保持一致。
    // 如果轮播图改变了大小，那么视图应该同步调整内容视图，以保持最佳显示状态。
    // UIScrollView 在缩放的过程中，其 layoutSubviews 也会被调用。
    // 同时轮播图应该在改变大小时，应重置缩放状态，因为在缩放状态下，被缩放的视图的位置无优化参考。
    // 最佳显示状态：如果内容视图比轮播图下，那么内容视图居中显示；如果比轮播图大，那么等比缩放到正好完全显示整个内容视图。
    // 调用 zoomScale 属性会触发查询缩放视图的代理方法。
    // scrollView 滚动会触发子视图 layoutSubviews 方法。
    
    // contentSize 是从 (0, 0) 坐标开始算起的，所以如果 contentSize 比可视区域小，那么视图就不会居中。
    // 在缩放时，contentSize 变成与被缩放的视图一般大。这里只做位置修正，使视图在可视区域居中。
    CGRect const kBounds = self.bounds;
    CGSize const displaySize = kBounds.size;
    
    CGPoint offset = scrollView.contentOffset;
    CGRect zoomedViewFrame = CGRectOffset(_wrapperView.frame, -offset.x, -offset.y);
    
    switch (self.contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
        case UIViewContentModeRedraw:
        case UIViewContentModeCenter:
        __KeepZoomingViewInCenter:
            if (zoomedViewFrame.size.width < displaySize.width) {
                zoomedViewFrame.origin.x = (displaySize.width - zoomedViewFrame.size.width) * 0.5;
            } else {
                zoomedViewFrame.origin.x = 0;
            }
            if (zoomedViewFrame.size.height < displaySize.height) {
                zoomedViewFrame.origin.y = (displaySize.height - zoomedViewFrame.size.height) * 0.5;
            } else {
                zoomedViewFrame.origin.y = 0;
            }
            break;
        case UIViewContentModeTop:
        case UIViewContentModeBottom:
        case UIViewContentModeLeft:
        case UIViewContentModeRight:
        case UIViewContentModeTopLeft:
        case UIViewContentModeTopRight:
        case UIViewContentModeBottomLeft:
        case UIViewContentModeBottomRight:
        default:
            if (zoomedViewFrame.size.width <= displaySize.width) {
                zoomedViewFrame = XZCarouselViewFittingContentWithMode(CGRectMake(0, 0, kBounds.size.width, MAX(kBounds.size.height, zoomedViewFrame.size.height)), zoomedViewFrame.size, self.contentMode);
            } else if (zoomedViewFrame.size.height <= displaySize.height) {
                zoomedViewFrame = XZCarouselViewFittingContentWithMode(CGRectMake(0, 0, MAX(kBounds.size.width, zoomedViewFrame.size.width), kBounds.size.height), zoomedViewFrame.size, self.contentMode);
            } else {
                goto __KeepZoomingViewInCenter;
            }
            break;
    }
    
    _wrapperView.frame = zoomedViewFrame;
    
    [_delegate XZImageViewerItemViewDidZoom:self];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    _zoomingView.bounces = (scale != 1.0);
    
    [_delegate XZImageViewerItemViewDidEndZooming:self atScale:scale];
}

@end
