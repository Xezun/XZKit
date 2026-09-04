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

- (NSInteger)numberOfSectionsInMocoa:(id)context {
    return 1;
}

- (NSInteger)mocoa:(id)context numberOfCellsInSection:(NSInteger)section {
    return _contacts.count;
}

- (id)mocoa:(id)context modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _contacts[indexPath.item];
}

- (NSInteger)mocoa:(id)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section {
    return 0;
}

- (id)mocoa:(id)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
