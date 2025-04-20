//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZToastType) {
    XZToastTypeMessage,
    XZToastTypeLoading,
} NS_REFINED_FOR_SWIFT;

@class XZToast;

NS_REFINED_FOR_SWIFT @interface XZToast : NSObject

@property (nonatomic, readonly) XZToastType type;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly, nullable) UIImage *image;
@property (nonatomic, readonly, nullable) UIView *view;
@property (nonatomic, readonly) BOOL isExclusive;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(XZToastType)type text:(NSString *)text image:(nullable UIImage *)image view:(nullable UIView *)view isExclusive:(BOOL)isExclusive NS_DESIGNATED_INITIALIZER;

+ (XZToast *)messageToast:(NSString *)text;
+ (XZToast *)loadingToast:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
