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

+ (instancetype)messageToast:(NSString *)text NS_SWIFT_NAME(init(message:));

+ (instancetype)loadingToast:(NSString *)text NS_SWIFT_NAME(init(loading:));

@end

NS_ASSUME_NONNULL_END
