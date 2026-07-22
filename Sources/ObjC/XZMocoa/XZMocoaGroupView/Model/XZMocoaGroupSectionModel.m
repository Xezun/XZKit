//
//  XZMocoaGroupSectionModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/21.
//

#import "XZMocoaGroupSectionModel.h"

@implementation NSObject (XZMocoaGroupSectionModel)

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return self;
}

- (NSInteger)numberOfModelsForSupplementaryElementOfKind:(XZMocoaKind)kind {
    if ([kind isEqualToString:XZMocoaKindHeader]) {
        return self.headerModel ? 1 : 0;
    }
    if ([kind isEqualToString:XZMocoaKindFooter]) {
        return self.footerModel ? 1 : 0;
    }
    return 0;
}

- (id)modelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    if (index != 0) {
        return nil;
    }
    if ([kind isEqualToString:XZMocoaKindHeader]) {
        return self.headerModel;
    }
    if ([kind isEqualToString:XZMocoaKindFooter]) {
        return self.footerModel;
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


@implementation NSArray (XZMocoaGroupSectionModel)

- (NSInteger)numberOfCellModels {
    return self.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end
