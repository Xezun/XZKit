//
//  XZMocoaGroupReusableViewModel.m
//  XZKit
//
//  Created by 徐臻 on 2026/9/3.
//

#import "XZMocoaGroupReusableViewModel.h"

@implementation XZMocoaGroupReusableViewModel

- (instancetype)initWithModel:(NSObject<XZMocoaModel> *)model {
    self = [super initWithModel:model];
    if (self) {
        _reuseIdentifier = XZMocoaReuseIdentifier(XZMocoaKindDefault, model.mocoaName);
        _indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

@end
