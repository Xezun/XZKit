//
//  XZToastContainerView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastContainerView.h"

@implementation XZToastContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

@end
