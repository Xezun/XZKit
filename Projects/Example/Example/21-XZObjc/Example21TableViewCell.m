//
//  Example21TableViewCell.m
//  Example
//
//  Created by 徐臻 on 2025/1/30.
//

#import "Example21TableViewCell.h"
@import XZKit;

@implementation Example21TableViewCell

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").section.cell.viewReuseIdentifier = @"cell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelDidChange:newValue];
    
    if ([self.viewModel.model isKindOfClass:[XZObjcMethod class]]) {
        XZObjcMethod *descriptor = self.viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    } else if ([self.viewModel.model isKindOfClass:[XZObjcProperty class]]) {
        XZObjcProperty *descriptor = self.viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    } else if ([self.viewModel.model isKindOfClass:[XZObjcIvar class]]) {
        XZObjcIvar *descriptor = self.viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    }
    
}

@end
