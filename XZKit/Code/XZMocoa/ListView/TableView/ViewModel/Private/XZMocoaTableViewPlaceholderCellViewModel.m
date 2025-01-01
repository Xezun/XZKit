//
//  XZMocoaTableViewPlaceholderCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableViewPlaceholderCellViewModel.h"

#if DEBUG
@implementation XZMocoaTableViewPlaceholderCellViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        [super setFrame:CGRectMake(0, 0, 0, 125.0)];
    }
    return self;
}

@end
#endif
