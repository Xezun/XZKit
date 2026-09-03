//
//  XZToastView.h
//  XZToast
//
//  Created by Xezun on 2025/5/9.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastView : UIView <XZToastView>

@property (nonatomic) XZToastStyle style;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) CGFloat progress;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
