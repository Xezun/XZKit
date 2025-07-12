//
//  XZImageViewerItemView.m
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import "XZImageViewerItemView.h"
#import "XZImageViewer.h"
#import "XZImageViewerItemViewZoomingView.h"
#import "XZGeometry.h"

@interface XZImageViewerItemView ()
/// 提供缩放功能的滚动视图。
@property (nonatomic, readonly, nonnull) UIScrollView *zoomingView;
@property (nonatomic, readonly, nonnull) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation XZImageViewerItemView

@synthesize zoomingView = _zoomingView; // 处理缩放的视图。

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
    [self insertSubview:_zoomingView atIndex:0];
    
    [_zoomingView addSubview:_imageView];
    [_zoomingView setDelegate:self];
    return _zoomingView;
}

- (CGRect)imageFrame {
    if (_zoomingView) {
        CGRect const bounds = self.bounds;
        CGSize const contentSize = _zoomingView.contentSize;
        
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

        CGPoint const contentOffset = _zoomingView.contentOffset;
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
    if (_zoomingView) {
        [_zoomingView addSubview:_imageView];
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
    return _zoomingView.bouncesZoom;
}

- (void)setBouncesZoom:(BOOL)bouncesZoom {
    [self.zoomingView setBouncesZoom:bouncesZoom];
}

- (BOOL)isZoomed {
    return _zoomingView.zoomScale != 1.0;
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
    if (minimumZoomScale != maximumZoomScale) {
        UIScrollView * const zoomingView = self.zoomingView;
        zoomingView.minimumZoomScale = minimumZoomScale;
        zoomingView.maximumZoomScale = maximumZoomScale;
    }
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    [_zoomingView zoomToRect:rect animated:animated];
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated {
    [_zoomingView setZoomScale:scale animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds       = self.bounds;
    CGRect const contentFrame = [self imageRectForBounds:bounds];
    
    if (_zoomingView) {
        _zoomingView.frame = bounds;
        if (_zoomingView.zoomScale == 1.0) {
            _zoomingView.contentSize = contentFrame.size;
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
    _zoomingView.bounces = YES;
    
    if ([_imageViewer.delegate respondsToSelector:@selector(imageViewer:willBeginZoomingImageAtIndex:)]) {
        [_imageViewer.delegate imageViewer:_imageViewer willBeginZoomingImageAtIndex:_index];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect const bounds = self.bounds;
    CGSize const contentSize = _zoomingView.contentSize;
    
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
    _zoomingView.bounces = (scale != 1.0);
    
    if ([_imageViewer.delegate respondsToSelector:@selector(imageViewer:didEndZoomingImageAtIndex:atScale:)]) {
        [_imageViewer.delegate imageViewer:_imageViewer didEndZoomingImageAtIndex:_index atScale:scale];
    }
}

@end
