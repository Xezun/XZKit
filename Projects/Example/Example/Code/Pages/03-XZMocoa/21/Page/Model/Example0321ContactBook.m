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

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _contacts.count;
}

- (id)modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return self;
}

- (NSInteger)numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section {
    return 0;
}

- (id)modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - XZMocoaTableSectionModel

- (id)headerModel {
    return nil;
}

- (id)footerModel {
    return nil;
}

@end
