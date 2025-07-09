//
//  Example0310ContactView.h
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import <UIKit/UIKit.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0310ContactView : UIView <XZMocoaView>

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

+ (Example0310ContactView *)contactView;

@end

NS_ASSUME_NONNULL_END
