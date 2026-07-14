//
//  XZImageViewerItemView.m
//  XZKit
//
//  Created by Xezun on 2025/6/24.
//

#import "XZImageViewerItemView.h"
#import "XZImageViewer.h"
#import "XZImageViewerZoomView.h"
#import "XZGeometry.h"

@interface XZImageViewerItemView ()
/// 提供缩放功能的滚动视图。
@property (nonatomic, readonly, nonnull) UIScrollView *zoomView;
@property (nonatomic, readonly, nonnull) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation XZImageViewerItemView

@synthesize zoomView = _zoomView; // 处理缩放的视图。

- (instancetype)initWithImageViewer:(XZImageViewer *)imageViewer {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
    if (self) {
        self.clipsToBounds = YES;
        
        _imageViewer = imageViewer;
        _index = NSNotFound;
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

- (UIScrollView *)zoomView {
    if (_zoomView != nil) {
        return _zoomView;
    }
    _zoomView = [[XZImageViewerZoomView alloc] initWithFrame:self.bounds];
    _zoomView.bounces                = NO;
    _zoomView.bouncesZoom            = YES;
    _zoomView.clipsToBounds          = YES;
    _zoomView.alwaysBounceVertical   = YES;
    _zoomView.alwaysBounceHorizontal = YES;
    _zoomView.showsVerticalScrollIndicator   = NO;
    _zoomView.showsHorizontalScrollIndicator = NO;
    _zoomView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _zoomView.delegate = self;
    [self insertSubview:_zoomView atIndex:0];
    
    [_zoomView addSubview:_imageView];
    [_zoomView setDelegate:self];
    return _zoomView;
}

- (CGRect)imageFrame {
    if (_zoomView) {
        CGRect const bounds = self.bounds;
        CGSize const contentSize = _zoomView.contentSize;
        
        CGRect frame = _imageView.frame;
        if (contentSize.width < bounds.size.width) {
            frame.origin.x = (bounds.size.width - contentSize.width) * 0.5;
        } else {
            frame.origin.x = 0;
        }
        if (contentSize.height < bounds.size.height) {
            frame.origin.y = (bounds.size.height - contentSize.height) * 0.5;
        } else {
            frame.origin.y = 0;
        }
        frame.size = contentSize;

        CGPoint const contentOffset = _zoomView.contentOffset;
        frame.origin.x -= contentOffset.x;
        frame.origin.y -= contentOffset.y;
        return frame;
    }
    return _imageView.frame;
}

@synthesize imageView = _imageView;

- (void)setImageView:(UIImageView *)imageView {
    if (_imageView != imageView) {
        return;
    }
    if ([_imageView isDescendantOfView:self]) {
        return;
    }
    if (_zoomView) {
        [_zoomView addSubview:_imageView];
        [self setNeedsLayout];
    } else {
        [self addSubview:_imageView];
    }
}

- (CGRect)imageRectForBounds:(CGRect)bounds {
    CGSize const imageSize = _imageView.image.size;
    return CGRectScaleAspectRatioInsideWithMode(bounds, imageSize, UIViewContentModeScaleAspectFit);
}

- (BOOL)bouncesZoom {
    return _zoomView.bouncesZoom;
}

- (void)setBouncesZoom:(BOOL)bouncesZoom {
    [self.zoomView setBouncesZoom:bouncesZoom];
}

- (BOOL)isZoomed {
    return (_zoomView ? _zoomView.zoomScale != 1.0 : NO);
}

- (CGFloat)zoomScale {
    return (_zoomView ? _zoomView.zoomScale : 1.0);
}

- (CGFloat)minimumZoomScale {
    return (_zoomView ? _zoomView.minimumZoomScale : 1.0);
}

- (CGFloat)maximumZoomScale {
    return (_zoomView ? _zoomView.maximumZoomScale : 1.0);
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    if (minimumZoomScale != maximumZoomScale) {
        UIScrollView * const zoomingView = self.zoomView;
        zoomingView.minimumZoomScale = minimumZoomScale;
        zoomingView.maximumZoomScale = maximumZoomScale;
    }
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [_zoomView zoomToRect:rect animated:animated];
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated {
    [_zoomView setZoomScale:scale animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds       = self.bounds;
    CGRect const contentFrame = [self imageRectForBounds:bounds];
    
    if (_zoomView) {
        _zoomView.frame = bounds;
        if (_zoomView.zoomScale == 1.0) {
            _zoomView.contentSize = contentFrame.size;
        }
    }
    
    if ([_imageView isDescendantOfView:self]) {
        _imageView.frame = contentFrame;
    }
    
    if (CGSizeEqualToSize(contentFrame.size, CGSizeZero)) {
        [self.activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
    }
    if (_activityIndicatorView) {
        _activityIndicatorView.frame = CGRectInset(bounds, (bounds.size.width - 100) * 0.5, (bounds.size.height - 100) * 0.5);
    }
}

@synthesize activityIndicatorView = _activityIndicatorView;

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
        _activityIndicatorView.color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.lightGrayColor;
            }
            return UIColor.whiteColor;
        }];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
}

#pragma mark - <UIScrollViewDelegate.拖动>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

#pragma mark - <UIScrollViewDelegate.缩放>

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    _zoomView.bounces = YES;
    
    if ([_imageViewer.delegate respondsToSelector:@selector(imageViewer:willBeginZoomingImageAtIndex:)]) {
        [_imageViewer.delegate imageViewer:_imageViewer willBeginZoomingImageAtIndex:_index];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect const bounds = self.bounds;
    CGSize const contentSize = _zoomView.contentSize;
    
    CGRect frame = _imageView.frame;
    if (contentSize.width < bounds.size.width) {
        frame.origin.x = (bounds.size.width - contentSize.width) * 0.5;
    } else {
        frame.origin.x = 0;
    }
    if (contentSize.height < bounds.size.height) {
        frame.origin.y = (bounds.size.height - contentSize.height) * 0.5;
    } else {
        frame.origin.y = 0;
    }
    _imageView.frame = frame;
    
    if ([_imageViewer.delegate respondsToSelector:@selector(imageViewer:didZoomImageAtIndex:)]) {
        [_imageViewer.delegate imageViewer:_imageViewer didZoomImageAtIndex:_index];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    _zoomView.bounces = (scale != 1.0);
    
    if ([_imageViewer.delegate respondsToSelector:@selector(imageViewer:didEndZoomingImageAtIndex:atScale:)]) {
        [_imageViewer.delegate imageViewer:_imageViewer didEndZoomingImageAtIndex:_index atScale:scale];
    }
}

@end
