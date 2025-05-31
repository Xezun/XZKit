//
//  XZMocoaGridViewSectionModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/21.
//

#import "XZMocoaGridViewSectionModel.h"

@implementation NSObject (XZMocoaGridViewSectionModel)

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return self;
}

- (NSInteger)numberOfModelsForSupplementaryKind:(XZMocoaKind)kind {
    return 0;
}

- (id)modelForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    if (index == 0) {
        if ([kind isEqualToString:XZMocoaKindHeader]) {
            return self.headerModel;
        }
        if ([kind isEqualToString:XZMocoaKindFooter]) {
            return self.footerModel;
        }
    }
    return nil;
}

- (id)headerModel {
    return nil;
}

- (id)footerModel {
    return nil;
}

@end


@implementation NSArray (XZMocoaGridViewSectionModel)

- (NSInteger)numberOfCellModels {
    return self.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end
