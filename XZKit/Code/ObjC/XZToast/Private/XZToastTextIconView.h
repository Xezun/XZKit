//
//  XZToastTextIconView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastTextIconView : UIView <XZToastView>
@property (nonatomic, copy, nullable) NSString *text;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@end


@interface XZToastActivityIndicatorView : XZToastTextIconView
@property(nonatomic, readonly) BOOL isAnimating;
- (void)startAnimating;
- (void)stopAnimating;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

typedef NS_ENUM(NSUInteger, XZToastStatus) {
    XZToastStatusUnknown,
    XZToastStatusSuccess,
    XZToastStatusFailure,
    XZToastStatusWarning,
    XZToastStatusWaiting
};

typedef NSString *XZToastBase64Image;

@interface XZToastTextImageView : XZToastTextIconView

- (instancetype)initWithImage:(XZToastBase64Image)image NS_DESIGNATED_INITIALIZER;

@end


FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageSuccess;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageFailure;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageWarning;
FOUNDATION_EXPORT XZToastBase64Image const XZToastBase64ImageWaiting;

NS_ASSUME_NONNULL_END
