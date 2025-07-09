//
//  Example0320Group101Cell.h
//  Example
//
//  Created by Xezun on 2023/7/24.
//

#import <UIKit/UIKit.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group101Cell : UITableViewCell <XZMocoaTableViewCell>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

NS_ASSUME_NONNULL_END
