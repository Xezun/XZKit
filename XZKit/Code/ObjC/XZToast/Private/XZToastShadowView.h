//
//  XZToastShadowView.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// toast 距离边缘的距离，为了避免 toast 贴边。
#define XZToastMargin 20.0

@interface XZToastShadowView : UIView

@property (nonatomic, readonly) UIView *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
