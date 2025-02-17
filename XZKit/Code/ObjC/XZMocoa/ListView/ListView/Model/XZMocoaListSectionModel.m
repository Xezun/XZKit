//
//  XZMocoaListSectionModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/21.
//

#import "XZMocoaListSectionModel.h"

@interface NSObject (XZMocoaListSectionModel) <XZMocoaListSectionModel>
@end

@implementation NSObject (XZMocoaListSectionModel)

- (NSInteger)numberOfCellModels {
    return 1;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return self;
}

- (NSInteger)numberOfModelsForSupplementaryKind:(XZMocoaKind)kind {
    return 1;
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


@interface NSArray (XZMocoaListSectionModel)
@end

@implementation NSArray (XZMocoaListSectionModel)

- (NSInteger)numberOfCellModels {
    return self.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end
