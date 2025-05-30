//
//  XZMocoaGridModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/28.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGridModel.h"
#import "XZRuntime.h"
@import ObjectiveC;

@implementation NSObject (XZMocoaGridModel)

- (NSInteger)numberOfSectionModels {
    return 1;
}

- (id<XZMocoaGridViewSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return (id)self;
}

@end

@implementation NSArray (XZMocoaGridModel)

- (NSInteger)numberOfSectionModels {
    return self.count;
}

- (id<XZMocoaGridViewSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end

@implementation NSFetchedResultsController (XZMocoaGridModel)

- (NSInteger)numberOfSectionModels {
    return self.sections.count;
}

- (id<XZMocoaGridViewSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    id<XZMocoaGridViewSectionModel> model = (id)self.sections[index];
    
    Class const modelClass = object_getClass(model);
    if (class_addProtocol(modelClass, @protocol(XZMocoaGridViewSectionModel))) {
        {
            SEL const selector = @selector(numberOfCellModels);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^NSInteger(id<NSFetchedResultsSectionInfo> const self) {
                return self.numberOfObjects;
            };
            xz_objc_class_addMethodWithBlock(modelClass, selector, encoding, block, block, nil);
        }
        
        {
            SEL const selector = @selector(modelForCellAtIndex:);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^id(id<NSFetchedResultsSectionInfo> const self, NSInteger index) {
                return self.objects[index];
            };
            xz_objc_class_addMethodWithBlock(modelClass, selector, encoding, block, block, nil);
        }
    }
    
    return model;
}

@end
