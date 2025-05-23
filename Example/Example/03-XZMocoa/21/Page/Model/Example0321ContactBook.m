//
//  Example0321ContactBook.m
//  Example
//
//  Created by Xezun on 2021/4/26.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactBook.h"
#import "Example0321Contact.h"

@implementation Example0321ContactBook

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:10];
        for (NSInteger i = 0; i < 10; i++) {
            [arrayM addObject:[Example0321Contact contactForIndex:i]];
        }
        _contacts = arrayM.copy;
    }
    return self;
}

#pragma mark - XZMocoaTableModel

- (NSInteger)numberOfSectionModels {
    return 1;
}

- (id<XZMocoaGridSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return self;
}

#pragma mark - XZMocoaTableViewSectionModel

- (id)headerModel {
    return nil;
}

- (id)footerModel {
    return nil;
}

- (NSInteger)numberOfCellModels {
    return _contacts.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return _contacts[index];
}

@end
