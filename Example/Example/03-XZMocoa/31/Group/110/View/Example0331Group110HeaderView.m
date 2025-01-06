//
//  Example0331Group110HeaderView.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0331Group110HeaderView.h"
@import XZExtensions;

@interface Example0331Group110HeaderView ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@end

@implementation Example0331Group110HeaderView

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/110/header:/").viewClass = self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = rgb(6, 82, 121);
        
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:_textLabel];
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:_detailTextLabel];
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_textLabel]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_detailTextLabel]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_detailTextLabel)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:-10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_detailTextLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:+10.0]];
    }
    return self;
}

- (void)viewModelDidChange {
    self.textLabel.text = @"Header视图";
    self.detailTextLabel.text = self.viewModel.model;
}

@end
