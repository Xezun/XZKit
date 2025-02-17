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
        
        _contactView = [Example0310ContactView contactView];
        [self addSubview:_contactView];
        _contentView = [[Example0310ContentView alloc] init];
        [self addSubview:_contentView];
        
        _contactView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_contactView.widthAnchor constraintEqualToAnchor:self.frameLayoutGuide.widthAnchor],
            [_contactView.topAnchor constraintEqualToAnchor:self.contentLayoutGuide.topAnchor],
            [_contactView.leadingAnchor constraintEqualToAnchor:self.contentLayoutGuide.leadingAnchor],
            [_contactView.trailingAnchor constraintEqualToAnchor:self.contentLayoutGuide.trailingAnchor],
            
            [_contentView.topAnchor constraintEqualToAnchor:_contactView.bottomAnchor constant:20],
            [_contentView.leadingAnchor constraintEqualToAnchor:self.contentLayoutGuide.leadingAnchor],
            [_contentView.trailingAnchor constraintEqualToAnchor:self.contentLayoutGuide.trailingAnchor],
            [_contentView.bottomAnchor constraintEqualToAnchor:self.contentLayoutGuide.bottomAnchor],
        ]];
    }
    return self;
}

@end
