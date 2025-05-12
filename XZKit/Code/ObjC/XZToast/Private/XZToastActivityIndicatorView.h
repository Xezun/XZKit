//
//  XZToastActivityIndicatorView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZToastActivityIndicatorView : UIView

@property (nonatomic, copy, nullable) NSString *text;

- (void)startAnimating;
- (void)stopAnimating;

@property(nonatomic, readonly) BOOL isAnimating;

@end

NS_ASSUME_NONNULL_END
