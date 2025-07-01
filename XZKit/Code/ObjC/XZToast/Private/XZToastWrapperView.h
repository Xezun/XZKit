//
//  XZToastWrapperView.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

@class XZToastTask;

NS_ASSUME_NONNULL_BEGIN

/// toast 距离边缘的距离，为了避免 toast 贴边。
#define XZToastMargin 20.0

@interface XZToastWrapperView : UIView <XZToastView>

@property (nonatomic, readonly) UIView<XZToastView> *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView<XZToastView> *)view NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) XZToastTask *task;

@end

NS_ASSUME_NONNULL_END
