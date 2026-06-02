//
//  XZImageViewerAnimationController.h
//  XZPageView
//
//  Created by Xezun on 2025/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageViewerItemView;

typedef NS_ENUM(NSUInteger, XZImageViewerTransitionType) {
    XZImageViewerTransitionTypeShow,
    XZImageViewerTransitionTypeHide,
};

/// 转场动画控制器。
@interface XZImageViewerAnimationController : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (id<UIViewControllerAnimatedTransitioning>)animationControllerForType:(XZImageViewerTransitionType)type sourceView:(nullable UIView *)sourceView itemView:(nullable XZImageViewerItemView *)itemView;
@end

/// 交互式转场。
@interface XZImageViewerInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonatomic, readonly) XZImageViewerItemView *itemView;
/// 当前对象初始化时，图片视图 itemView.imageView 在 itemView 中的区位。
@property (nonatomic, readonly) CGRect imageViewInitialRect;
- (instancetype)initWithItemView:(XZImageViewerItemView *)itemView;
@end

NS_ASSUME_NONNULL_END
