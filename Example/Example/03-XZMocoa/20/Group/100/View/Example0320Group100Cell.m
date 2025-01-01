//
//  Example0320Group100Cell.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group100Cell.h"
#import "Example0320Group100CellViewModel.h"
@import SDWebImage;

@implementation Example0320Group100Cell

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/20/table/100/:/").viewNibClass = self;
}

@synthesize imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewModelDidChange {
    Example0320Group100CellViewModel *viewModel = self.viewModel;
    self.titleLabel.text = viewModel.title;
    [self.imageView sd_setImageWithURL:viewModel.image];
    self.detailsLabel.text = viewModel.details;
}

@end
