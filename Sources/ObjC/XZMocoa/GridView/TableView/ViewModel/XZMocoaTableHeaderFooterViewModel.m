//
//  XZMocoaTableHeaderFooterViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaTableHeaderFooterViewModel.h"

@implementation XZMocoaTableHeaderFooterViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        [super setFrame:CGRectMake(0, 0, 0, XZMocoaMinimumViewDimension)];
    }
    return self;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    if (self.frame.size.height == height) {
        return;
    }
    frame.size.height = height;
    self.frame = frame;
}

@end


@implementation XZMocoaTableHeaderViewModel
@end

@implementation XZMocoaTableFooterViewModel
@end
