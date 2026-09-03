//
//  Example21TableViewCell.m
//  Example
//
//  Created by Xezun on 2025/1/30.
//

#import "Example21TableViewCell.h"
@import XZKit;

@implementation Example21TableViewCell

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").cell.viewReuseIdentifier = @"cell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    XZMocoaViewModel *viewModel = self.viewModel;
    if ([viewModel.model isKindOfClass:[XZObjcMethod class]]) {
        XZObjcMethod *descriptor = viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    } else if ([viewModel.model isKindOfClass:[XZObjcProperty class]]) {
        XZObjcProperty *descriptor = viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    } else if ([viewModel.model isKindOfClass:[XZObjcIvar class]]) {
        XZObjcIvar *descriptor = viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    } else if ([viewModel.model isKindOfClass:[XZObjcClass class]]) {
        XZObjcClass *descriptor = viewModel.model;
        self.textLabel.text = descriptor.name;
        self.detailTextLabel.text = descriptor.type.name;
    }
    
}

@end
