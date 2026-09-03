//
//  XZMocoaGroupCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGroupCellViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaGroupCellModel.h"

@interface XZMocoaGroupCellViewModel ()
@end

@implementation XZMocoaGroupCellViewModel

- (instancetype)initWithModel:(NSObject<XZMocoaGroupCellModel> *)model {
    self = [super initWithModel:model];
    if (self) {
        _frame      = CGRectZero;
        _identifier = XZMocoaReuseIdentifier(XZMocoaKindDefault, model.mocoaName);
    }
    return self;
}

@end




