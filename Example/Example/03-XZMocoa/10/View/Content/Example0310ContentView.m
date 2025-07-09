//
//  Example0310ContentView.m
//  Example
//
//  Created by Xezun on 2023/7/25.
//

#import "Example0310ContentView.h"
@import XZKit;

@implementation Example0310ContentView {
    UILabel *_titleLabel;
    UILabel *_contentLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = self.bounds;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 20.0)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleLabel.textColor = UIColor.systemGrayColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0, bounds.size.width, 0)];
        _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentLabel.textAlignment = NSTextAlignmentJustified;
        _contentLabel.textColor = UIColor.systemGrayColor;
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
        
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:+20],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
            
            [_contentLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:20],
            
            [_contentLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:+20],
            [_contentLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
            [_contentLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20],
        ]];
    }
    return self;
}

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString *)content {
    return _contentLabel.text;
}

- (void)setContent:(NSString *)content {
    NSString *xzml = [NSString stringWithFormat:@"<30H3A^%@>", content];
    [_contentLabel setXZMLText:xzml];
}

@end
