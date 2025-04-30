//
//  UIKit+XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZToast;

@interface UIResponder (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(showToast(_:duration:position:offset:isExclusive:completion:));

- (void)xz_showToast:(XZToast *)toast NS_SWIFT_NAME(showToast(_:));
- (void)xz_hideToast:(void (^_Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
