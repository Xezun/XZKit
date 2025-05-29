//
//  XZMocoaGridViewCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGridViewCellViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMocoaGridViewSectionViewModel.h"

@interface XZMocoaGridViewCellViewModel ()
@end

@implementation XZMocoaGridViewCellViewModel

- (instancetype)initWithModel:(NSObject<NSObject> *)model {
    self = [super initWithModel:model];
    if (self) {
        _frame      = CGRectZero;
        _identifier = XZMocoaReuseIdentifier(XZMocoaNameDefault, XZMocoaKindCell, XZMocoaNameDefault);
    }
    return self;
}

- (void)cell:(id<XZMocoaView>)cell didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath {
    [self view:cell didUpdateForKey:key value:indexPath];
}

@end




