//
//  XZToastView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastView : UIView <XZToastView>

@property (nonatomic, copy, nullable) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, readonly, nullable) UIImage *image;
@property (nonatomic, readonly) XZToastStyle style;

- (void)setStyle:(XZToastStyle)style image:(nullable UIImage *)image;

@end

UIKIT_EXTERN UIImage * _Nullable XZToastStyleImage(XZToastStyle style);

NS_ASSUME_NONNULL_END
