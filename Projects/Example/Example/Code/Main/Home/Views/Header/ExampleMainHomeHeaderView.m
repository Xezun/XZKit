//
//  ExampleMainHomeHeaderView.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "ExampleMainHomeHeaderView.h"

@implementation ExampleMainHomeHeaderView {
    UILabel *_titleLabel;
}

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").header.viewClass = self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:14.0 weight:(UIFontWeightRegular)];
        _titleLabel.textColor = UIColor.grayColor;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    _titleLabel.frame = CGRectMake(16.0, 0, bounds.size.width - 40.0, bounds.size.height);
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    _titleLabel.text = self.viewModel.model;
}

@end
