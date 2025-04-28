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

@interface XZToast : NSObject

@property (nonatomic, readonly) UIView *contentView;

/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

//@property (nonatomic, readonly) NSTimeInterval duration;
//@property (nonatomic, readonly) NSDirectionalRectEdge edge;
//@property (nonatomic, readonly) CGFloat offset;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;

//@property (nonatomic, readonly) XZToastType type;
//@property (nonatomic, readonly) NSString *text;
//@property (nonatomic, readonly, nullable) UIImage *image;
//@property (nonatomic, readonly, nullable) UIView *view;
//@property (nonatomic, readonly) BOOL isExclusive;
//
//- (instancetype)init NS_UNAVAILABLE;
//- (instancetype)initWithType:(XZToastType)type text:(NSString *)text image:(nullable UIImage *)image view:(nullable UIView *)view isExclusive:(BOOL)isExclusive NS_DESIGNATED_INITIALIZER;
//
//+ (XZToast *)messageToast:(NSString *)text;
//+ (XZToast *)loadingToast:(NSString *)text;

@end

@interface UIResponder (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^_Nullable)(BOOL finished))completion;
- (void)xz_hideToast:(void (^_Nullable)(BOOL finished))completion;
@end

NS_ASSUME_NONNULL_END
