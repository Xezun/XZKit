//
//  XZImageViewerItemView.m
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import "XZImageViewerItemView.h"
@import XZGeometry;
@import XZExtensions;

@interface XZImageViewerItemViewTransitionView : UIView
@end
@interface XZImageViewerItemViewZoomingView : UIScrollView
@end
@interface XZImageViewerItemViewContentView : UIView
@end
@implementation XZImageViewerItemViewTransitionView
@end
@implementation XZImageViewerItemViewZoomingView
@end
@implementation XZImageViewerItemViewContentView
@end

@interface XZImageViewerItemView ()
/// 提供缩放功能的滚动视图。
@property (nonatomic, readonly, nonnull) UIScrollView *zoomingView;
@end

@implementation XZImageViewerItemView

@synthesize zoomingView = _zoomingView; // 处理缩放的视图。

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _index = NSNotFound;
        _interitemSpacing = 0.0;
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

- (UIScrollView *)zoomingView {
    if (_zoomingView != nil) {
        return _zoomingView;
    }
    _zoomingView = [[XZImageViewerItemViewZoomingView alloc] initWithFrame:self.bounds];
    _zoomingView.bounces                = NO;
    _zoomingView.bouncesZoom            = YES;
    _zoomingView.clipsToBounds          = YES;
    _zoomingView.alwaysBounceVertical   = YES;
    _zoomingView.alwaysBounceHorizontal = YES;
    _zoomingView.showsVerticalScrollIndicator   = NO;
    _zoomingView.showsHorizontalScrollIndicator = NO;
    _zoomingView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _zoomingView.delegate = self;
    [self addSubview:_zoomingView];
    
    [_zoomingView addSubview:_imageView];
    [_zoomingView setDelegate:self];
    return _zoomingView;
}

- (BOOL)bouncesZoom {
    return _zoomingView.bouncesZoom;
}

- (void)setBouncesZoom:(BOOL)bouncesZoom {
    [self.zoomingView setBouncesZoom:bouncesZoom];
}

- (CGFloat)zoomScale {
    if (_zoomingView == nil) {
        return 1.0;
    }
    return _zoomingView.zoomScale;
}

- (CGFloat)minimumZoomScale {
    return (_zoomingView ? _zoomingView.minimumZoomScale : 1.0);
}

- (CGFloat)maximumZoomScale {
    return (_zoomingView ? _zoomingView.maximumZoomScale : 1.0);
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    UIScrollView * const zoomingView = self.zoomingView;
    zoomingView.minimumZoomScale = minimumZoomScale;
    zoomingView.maximumZoomScale = maximumZoomScale;
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [self.zoomingView zoomToRect:rect animated:animated];
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated {
    [self.zoomingView setZoomScale:scale animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect            const kBounds      = self.bounds;
    CGSize            const imageSize    = [_imageView.image xz_sizeInScale:self.window.windowScene.screen.scale];
    CGRect            const contentFrame = CGRectScaleAspectRatioInsideWithMode(kBounds, imageSize, UIViewContentModeScaleAspectFit);
    
    if (_zoomingView) {
        _zoomingView.frame = kBounds;
        if (_zoomingView.zoomScale == 1.0) {
            _zoomingView.contentSize = contentFrame.size;
            _imageView.frame = contentFrame;
        }
    } else {
        _imageView.frame = contentFrame;
    }
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
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    _zoomingView.bounces = YES;
    [_delegate XZImageViewerItemViewWillBeginZooming:self];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect const kBounds = self.bounds;
    CGSize const contentSize = _zoomingView.contentSize;
    
    CGRect frame = _imageView.frame;
    if (contentSize.width < kBounds.size.width) {
        frame.origin.x = (kBounds.size.width - contentSize.width) * 0.5;
    } else {
        frame.origin.x = 0;
    }
    if (contentSize.height < kBounds.size.height) {
        frame.origin.y = (kBounds.size.height - contentSize.height) * 0.5;
    } else {
        frame.origin.y = 0;
    }
    _imageView.frame = frame;
    
    [_delegate XZImageViewerItemViewDidZoom:self];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    _zoomingView.bounces = (scale != 1.0);
    
    [_delegate XZImageViewerItemViewDidEndZooming:self atScale:scale];
}

@end
