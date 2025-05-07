//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

@implementation XZToast

@synthesize view = _view;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

+ (XZToast *)messageToast:(NSString *)text {
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button setTitle:text forState:(UIControlStateNormal)];
    button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    button.layer.cornerRadius = 6.0;
    button.clipsToBounds = true;
    [button setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
    return [[self alloc] initWithView:button];
}

@end



