//
//  XZMocoaGridModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/28.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGridModel.h"

@interface NSObject (XZMocoaGridModel) <XZMocoaGridModel>
@end

@implementation NSObject (XZMocoaGridModel)

- (NSInteger)numberOfSectionModels {
    return 1;
}

- (id<XZMocoaGridSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return (id)self;
}

@end


@interface NSArray (XZMocoaGridModel)
@end

@implementation NSArray (XZMocoaGridModel)

- (NSInteger)numberOfSectionModels {
    return self.count;
}

- (id<XZMocoaGridSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end
