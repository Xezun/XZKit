//
//  XZMocoaCollectionPlaceholderSupplementViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaCollectionPlaceholderSupplementViewModel.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderSupplementViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        [super setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 125.0)];
    }
    return self;
}

@end
#endif
