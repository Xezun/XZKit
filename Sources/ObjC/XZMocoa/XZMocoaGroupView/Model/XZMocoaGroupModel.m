//
//  XZMocoaGroupModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/28.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGroupModel.h"
#import "XZRuntime.h"
@import ObjectiveC;

@implementation NSObject (XZMocoaGroupModel)

- (NSInteger)numberOfSectionModels {
    return 1;
}

- (id<XZMocoaGroupSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return (id)self;
}

@end

@implementation NSArray (XZMocoaGroupModel)

- (NSInteger)numberOfSectionModels {
    return self.count;
}

- (id<XZMocoaGroupSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end

@implementation NSFetchedResultsController (XZMocoaGroupModel)

- (NSInteger)numberOfSectionModels {
    return self.sections.count;
}

- (id<XZMocoaGroupSectionModel>)modelForSectionAtIndex:(NSInteger)index {
    id<XZMocoaGroupSectionModel> model = (id)self.sections[index];
    
    Class const modelClass = object_getClass(model);
    if (class_addProtocol(modelClass, @protocol(XZMocoaGroupSectionModel))) {
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
        
        {
            SEL const selector = @selector(numberOfModelsForSupplementaryElementOfKind:);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^NSInteger(id<NSFetchedResultsSectionInfo> const self, XZMocoaKind kind) {
                return 0;
            };
            xz_objc_class_addMethodWithBlock(modelClass, selector, encoding, block, block, nil);
        }
        
        {
            SEL const selector = @selector(modelForSupplementaryElementOfKind:atIndex:);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^id(id<NSFetchedResultsSectionInfo> const self, NSInteger index) {
                return nil;
            };
            xz_objc_class_addMethodWithBlock(modelClass, selector, encoding, block, block, nil);
        }
        
        {
            SEL const selector = @selector(isEqual:);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^BOOL(id<NSFetchedResultsSectionInfo> const self, id<NSFetchedResultsSectionInfo> const that) {
                if (self == that) {
                    return YES;
                }
                NSString * const thisName = self.name;
                NSString * const thatName = that.name;
                if (thisName == nil) {
                    if (thatName != nil) {
                        return NO;
                    }
                } else if (thatName == nil) {
                    return NO;
                } else if (![thisName isEqualToString:thatName]) {
                    return NO;
                }
                return YES;
            };
            xz_objc_class_addMethodWithBlock(modelClass, selector, encoding, block, block, nil);
        }
    }
    
    return model;
}

@end
