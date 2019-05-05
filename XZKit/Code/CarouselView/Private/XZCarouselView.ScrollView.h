//
//  XZCarouselView.ScrollView.h
//  XZKit
//
//  Created by 徐臻 on 2019/4/25.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef XZKIT_FRAMEWORK
#import <XZKit/XZCarouselView.h>
#import <XZKit/XZCarouselView.ItemView.h>
#else
#import "XZCarouselView.h"
#import "XZCarouselView.ItemView.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface _XZCarouselViewScrollView : UIScrollView {
    @package
    XZCarouselView * __unsafe_unretained _Nonnull _carouselView;
    _XZCarouselViewItemView * _Nullable _itemView0;
    _XZCarouselViewItemView * _Nonnull  _itemView1;
    _XZCarouselViewItemView * _Nonnull  _itemView2;
    _XZCarouselViewItemView * _Nonnull  _itemView3;
    _XZCarouselViewItemView * _Nullable _itemView4;
    XZCarouselViewPagingOrientation _pagingOrientation;
}

@property (nonatomic, readonly, nonnull) _XZCarouselViewItemView *itemView0;
@property (nonatomic, readonly, nonnull) _XZCarouselViewItemView *itemView1;
@property (nonatomic, readonly, nonnull) _XZCarouselViewItemView *itemView2;
@property (nonatomic, readonly, nonnull) _XZCarouselViewItemView *itemView3;
@property (nonatomic, readonly, nonnull) _XZCarouselViewItemView *itemView4;

@property (nonatomic) XZCarouselViewTransitionViewHierarchy itemViewHierarchy;

@property (nonatomic, readonly, getter=isPrevItemViewVisiable) BOOL prevItemViewVisiable;
@property (nonatomic, readonly, getter=isNextItemViewVisiable) BOOL nextItemViewVisiable;
/// 如果返回 YES 表示调整了显示区域，且自动调整 contentOffset 以保持当前的显示状态（会触发 scrollViewDidScroll 方法）。
- (BOOL)setPrevItemViewVisiable:(BOOL)isPrevItemViewVisiable nextItemViewVisiable:(BOOL)isNextItemViewVisiable;
/// 改变方向时，可能会触发 scrollViewDidScroll: 代理事件。
@property (nonatomic) XZCarouselViewPagingOrientation pagingOrientation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame carouselView:(XZCarouselView *)carouselView pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;
/// 更新所有 _itemView 的 transition 属性。
- (void)updateTransitionForItemViews:(CGFloat const)transition;

@end

NS_ASSUME_NONNULL_END
