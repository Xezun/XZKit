//
//  XZImageCarouselView.m
//  XZImageCarousel
//
//  Created by mlibai on 2017/12/27.
//  Copyright © 2017年 mlibai. All rights reserved.
//

#import "XZImageCarouselView.h"
#import <objc/runtime.h>

@implementation XZImageCarouselView

- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation {
    self = [super initWithFrame:frame pagingOrientation:pagingOrientation];
    if (self) {
        [super setReusingModeEnabled:YES];
        [super setDataSource:self];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [super setReusingModeEnabled:YES];
        [super setDataSource:self];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if ( self.window != nil && self.numberOfViews == 0 && (_images.count > 0 || _imageURLs.count > 0) ) {
        [self reloadData];
    }
}

- (void)setImages:(NSArray<UIImage *> *)images {
    [self setImages:images imageURLs:_imageURLs];
}

- (void)setImageURLs:(NSArray<NSURL *> *)imageURLs {
    [self setImages:_images imageURLs:imageURLs];
}

- (void)setDelegate:(id<XZCarouselViewDelegate>)delegate {
    NSAssert((delegate == nil || [delegate conformsToProtocol:@protocol(XZImageCarouselViewDelegate)]), @"The delegate for XZImageCarouselView must conform to the XZImageCarouselViewDelegate protocol!");
    if (self.delegate != delegate) {
        [super setDelegate:delegate];
    }
}

- (void)setImages:(NSArray<UIImage *> *)images imageURLs:(NSArray<NSURL *> *)imageURLs {
    if ([_images isEqualToArray:images]) {
        if ([_imageURLs isEqualToArray:imageURLs]) {
            return;
        }
        _imageURLs = imageURLs.copy;
    } else {
        _images = images.copy;
        if (![_imageURLs isEqualToArray:imageURLs]) {   
            _imageURLs = imageURLs.copy;
        }
    }
    if (self.window == nil) {
        return;
    }
    return [self reloadData];
}

- (NSInteger)numberOfViewsInCarouselView:(XZCarouselView *)carouselView {
    return _images.count + _imageURLs.count;
}

- (UIView *)carouselView:(XZCarouselView *)carouselView viewForIndex:(NSInteger)index reusingView:(UIImageView *)imageView {
    if (imageView == nil) {
        CGRect const kBounds = self.bounds;
        imageView = [[UIImageView alloc] initWithFrame:kBounds];
    }
    
    // 展示本地图片，按图片实际大小显示。
    if (index < _images.count) {
        UIImage *image = _images[index];
        imageView.image = image;
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        return imageView;
    }
    
    // 展示网络图片。
    imageView.frame = CGRectMake(0, 0, 68, 68);
    
    NSURL               * const  imageURL      = _imageURLs[index - _images.count];
    UIImageView         * __weak weakImageView = imageView;
    XZImageCarouselView * __weak weakThisView  = self;
    
    // 自定义图片下载方式。
    id<XZImageCarouselViewDelegate> const delegate = (id<XZImageCarouselViewDelegate>)[self delegate];
    if ([delegate respondsToSelector:@selector(imageCarouselView:imageView:loadImageFromURL:completion:)]) {
        BOOL __block isBlockSynchronized = YES;
        [delegate imageCarouselView:self imageView:imageView loadImageFromURL:imageURL completion:^(CGSize preferredImageSize, BOOL animated) {
            UIImageView         *imageView = weakImageView;
            XZImageCarouselView *thisView  = weakThisView;
            if ( thisView == nil || imageView == nil ) {
                return;
            }
            // 处理动画。
            if (isBlockSynchronized) {
                imageView.frame = CGRectMake(0, 0, preferredImageSize.width, preferredImageSize.height);
            } else {
                [thisView setPreferredSize:preferredImageSize forViewAtIndex:index animated:animated];
            }
        }];
        isBlockSynchronized = NO;
    }
    
    return imageView;
}

- (BOOL)carouselView:(XZCarouselView *)carouselView shouldEnqueueView:(UIImageView *)view atIndex:(NSInteger)index {
    view.image = nil;
    return YES;
}

@end
