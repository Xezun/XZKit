//
//  XZMocoaListViewCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaListViewCellViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaListViewSectionViewModel.h"

@interface XZMocoaListViewCellViewModel ()
@end

@implementation XZMocoaListViewCellViewModel

- (instancetype)initWithModel:(NSObject<NSObject> *)model {
    self = [super initWithModel:model];
    if (self) {
        _frame      = CGRectZero;
        _identifier = XZMocoaReuseIdentifier(XZMocoaNameDefault, XZMocoaKindCell, XZMocoaNameDefault);
    }
    return self;
}

@end




