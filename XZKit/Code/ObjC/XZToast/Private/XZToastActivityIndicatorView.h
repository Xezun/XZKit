//
//  XZToastActivityIndicatorView.h
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZToastTextIconView : UIView {
    @package
    UILabel *_textLabel;
    UIView *_iconView;
}

@property (nonatomic, copy, nullable) NSString *text;
- (instancetype)initWithFrame:(CGRect)frame iconView:(UIView *)iconView;
@end

@interface XZToastActivityIndicatorView : XZToastTextIconView

@property(nonatomic, readonly) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end


@interface XZToastSuccessView : UIView

@end

@interface XZToastFailureView : UIView

@end

NS_ASSUME_NONNULL_END
