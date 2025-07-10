//
//  XZToastView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZToast.h>
#else
#import "XZToast.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZToastView : UIView <XZToastView>

@property (nonatomic, copy, nullable) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, readonly, nullable) UIImage *image;
@property (nonatomic, readonly) XZToastStyle style;

- (void)setStyle:(XZToastStyle)style image:(nullable UIImage *)image progress:(CGFloat)progress;

@end

UIKIT_EXTERN UIImage * _Nullable XZToastStyleImage(XZToastStyle style);

NS_ASSUME_NONNULL_END
