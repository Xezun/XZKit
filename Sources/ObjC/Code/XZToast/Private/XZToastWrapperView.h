//
//  XZToastWrapperView.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZToast.h>
#else
#import "XZToast.h"
#endif

@class XZToastTask;

NS_ASSUME_NONNULL_BEGIN

/// toast 距离边缘的距离，为了避免 toast 贴边。
#define XZToastMargin 20.0

@interface XZToastWrapperView : UIView 

/// 呈现内容的视图，若没有，自动创建默认视图。
@property (nonatomic, strong, nullable) UIView *view;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, weak) XZToastTask *task;

- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
