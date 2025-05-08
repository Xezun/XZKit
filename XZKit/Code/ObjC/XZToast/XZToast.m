//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

NSTimeInterval const XZToastAnimationDuration = 2.35;

@interface XZToastLabel : UILabel

@end

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
//    static UIButton *button = nil;
//    if (button == nil) {
//        button = [UIButton buttonWithType:(UIButtonTypeSystem)];
//    }
//    [button setTitle:text forState:(UIControlStateNormal)];
//    button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
//    button.layer.cornerRadius = 6.0;
//    button.clipsToBounds = true;
//    [button setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
//    return [[self alloc] initWithView:button];
    
    static UILabel *label = nil;
    if (label == nil) {
        label = [[XZToastLabel alloc] init];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        label.layer.cornerRadius = 6.0;
        label.clipsToBounds = true;
        label.textColor = UIColor.whiteColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.text = text;
    
    return [[self alloc] initWithView:label];
}

@end

@implementation XZToastLabel

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    return CGSizeMake(size.width + 20.0, size.height + 20.0);
}

@end



