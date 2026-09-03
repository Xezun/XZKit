//
//  XZToastWrapperView.h
//  XZToast
//
//  Created by Xezun on 2025/4/30.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

@class XZToastTask;

NS_ASSUME_NONNULL_BEGIN

/// toast 距离边缘的距离，为了避免 toast 贴边。
#define XZToastMargin 20.0

@interface XZToastWrapperView : UIView 

/// 呈现内容的视图，若没有，自动创建默认视图。
@property (nonatomic, strong, nullable) UIView *view;

/// 由于投影是 CGColor 不能自动适配 Dark 模式切换，需要记录下来，以便在切换时使用。
@property (nonatomic, strong) UIColor *shadowColor;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, weak) XZToastTask *task;

- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
