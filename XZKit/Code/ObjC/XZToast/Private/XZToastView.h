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

- (void)applyConfiguration:(id<XZToastConfiguration>)configuration;

@property (nonatomic) XZToastStyle style;

@property(nonatomic, readonly) BOOL isAnimating;
- (void)startAnimating;
- (void)stopAnimating;

@property (nonatomic, strong, nullable) UIImage *image;

@end

typedef NSString *XZToastBase64Image NS_STRING_ENUM;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageSuccess;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageFailure;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageWarning;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageWaiting;
UIKIT_EXTERN UIImage *UIImageFromXZToastBase64Image(XZToastBase64Image base64Image);

NS_ASSUME_NONNULL_END
