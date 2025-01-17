//
//  Example0320Group101Cell.m
//  Example
//
//  Created by Xezun on 2023/7/24.
//

#import "Example0320Group101Cell.h"
#import "Example0320Group101CellViewModel.h"
@import SDWebImage;

@implementation Example0320Group101Cell

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/101/:/").viewNibClass = self;
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
    Example0320Group101CellViewModel *viewModel = self.viewModel;
    
    self.titleLabel.text = viewModel.title;
    self.detailsLabel.text = viewModel.details;
    [viewModel.images enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        [self.imageViews[idx] sd_setImageWithURL:url];
        *stop = (idx == (self.imageViews.count - 1));
    }];
}


@end
