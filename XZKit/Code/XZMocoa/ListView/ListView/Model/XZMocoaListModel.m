//
//  XZMocoaListModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/28.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaListModel.h"

@interface NSObject (XZMocoaListModel) <XZMocoaListModel>
@end

@implementation NSObject (XZMocoaListModel)

- (NSInteger)numberOfSectionModels {
    return 1;
}

- (id<XZMocoaListSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return (id)self;
}

@end


@interface NSArray (XZMocoaListModel)
@end

@implementation NSArray (XZMocoaListModel)

- (NSInteger)numberOfSectionModels {
    return self.count;
}

- (id<XZMocoaListSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end
