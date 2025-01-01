//
//  Example0331Group106Cell.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group106Cell.h"
#import "Example0331Group106CellViewModel.h"

@interface Example0331Group106Cell ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@end

@implementation Example0331Group106Cell

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/31/collection/106/:/").viewClass = self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.systemTealColor;
        
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_textLabel];
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:_detailTextLabel];
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_textLabel]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_detailTextLabel]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_detailTextLabel)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self.contentView attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:-10.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_detailTextLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self.contentView attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:+10.0]];
    }
    return self;
}

- (void)viewModelDidChange {
    Example0331Group106CellViewModel *viewModel = self.viewModel;
    self.textLabel.text = @"Cell视图";
    self.detailTextLabel.text = viewModel.text;
}

@end
