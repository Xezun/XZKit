//
//  XZMocoaTablePlaceholderSectionHeaderFooterViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTablePlaceholderSectionHeaderFooterViewModel.h"

#if DEBUG
@implementation XZMocoaTablePlaceholderSectionHeaderFooterViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        [super setFrame:CGRectMake(0, 0, 0, 125.0)];
    }
    return self;
}

@end
#endif
