//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

@implementation XZToast

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

@end



