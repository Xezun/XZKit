//
//  Example21BasicTableViewCell.m
//  Example
//
//  Created by 徐臻 on 2026/2/2.
//

#import "Example21BasicTableViewCell.h"

@implementation Example21BasicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.font = [UIFont monospacedSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
    self.detailTextLabel.font = [UIFont monospacedSystemFontOfSize:15.0 weight:(UIFontWeightRegular)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
