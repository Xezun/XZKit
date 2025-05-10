//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>
#import "XZToastDefines.h"
#import "XZToastActivityIndicatorView.h"
#import "XZToastTextView.h"
#import "UIKit+XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToast : NSObject

@property (nonatomic, readonly) __kindof UIView *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

+ (XZToast *)messageToast:(NSString *)text NS_SWIFT_NAME(message(_:));

+ (XZToast *)loadingToast:(NSString *)text NS_SWIFT_NAME(loading(_:));

@end

NS_ASSUME_NONNULL_END
