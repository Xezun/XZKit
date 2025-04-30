//
//  XZToastItem.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastItem.h"

@implementation XZToastItem

- (instancetype)initWithToastView:(UIView *)toastView duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^)(BOOL))completion {
    self = [super init];
    if (self) {
        _toastView = toastView;
        _duration = duration;
        _position = position;
        _offset = offset;
        _isExclusive = isExclusive;
        _completion = completion;
    }
    return self;
}

@end
