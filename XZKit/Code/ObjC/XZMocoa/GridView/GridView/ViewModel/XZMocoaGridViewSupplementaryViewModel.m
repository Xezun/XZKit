//
//  XZMocoaGridViewSupplementaryViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGridViewSupplementaryViewModel.h"

@implementation XZMocoaGridViewSupplementaryViewModel

- (instancetype)initWithModel:(id<NSObject>)model {
    self = [super initWithModel:model];
    if (self) {
        _frame      = CGRectZero;
        _identifier = XZMocoaReuseIdentifier(XZMocoaNameDefault, XZMocoaKindDefault, XZMocoaNameDefault);
    }
    return self;
}

@end
