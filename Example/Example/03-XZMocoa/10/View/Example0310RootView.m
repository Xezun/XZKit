//
//  Example0310RootView.m
//  Example
//
//  Created by Xezun on 2023/7/25.
//

#import "Example0310RootView.h"

@implementation Example0310RootView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        self.backgroundColor = UIColor.systemGray5Color;
        
        UIView *wrapperView = [[UIView alloc] init];
        [self addSubview:wrapperView];
        
        wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [wrapperView.widthAnchor constraintEqualToAnchor:self.frameLayoutGuide.widthAnchor],
            [wrapperView.topAnchor constraintEqualToAnchor:self.contentLayoutGuide.topAnchor],
            [wrapperView.leadingAnchor constraintEqualToAnchor:self.contentLayoutGuide.leadingAnchor],
            [wrapperView.trailingAnchor constraintEqualToAnchor:self.contentLayoutGuide.trailingAnchor],
            [wrapperView.bottomAnchor constraintEqualToAnchor:self.contentLayoutGuide.bottomAnchor],
        ]];
        
        _contactView = [Example0310ContactView contactView];
        [wrapperView addSubview:_contactView];
        
        _contentView = [[Example0310ContentView alloc] init];
        [wrapperView addSubview:_contentView];
        
        _contactView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_contactView.topAnchor constraintEqualToAnchor:wrapperView.topAnchor],
            [_contactView.leadingAnchor constraintEqualToAnchor:wrapperView.leadingAnchor],
            [_contactView.trailingAnchor constraintEqualToAnchor:wrapperView.trailingAnchor],
            
            [_contentView.topAnchor constraintEqualToAnchor:_contactView.bottomAnchor constant:20],
            
            [_contentView.leadingAnchor constraintEqualToAnchor:wrapperView.leadingAnchor],
            [_contentView.trailingAnchor constraintEqualToAnchor:wrapperView.trailingAnchor],
            [_contentView.bottomAnchor constraintEqualToAnchor:wrapperView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
