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

+ (void)load {
    if (self == [NSObject class]) {
        // 已经实现 XZMocoaGroupModel 就不添加默认实现。
        if ([self conformsToProtocol:@protocol(XZMocoaGroupModel)]) {
            return;
        }
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa:numberOfSections:),
                                 self, @selector(mocoa:numberOfSections:));
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa:numberOfCellsInSection:),
                                 self, @selector(mocoa:numberOfCellsInSection:));
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa:modelForCellAtIndexPath:),
                                 self, @selector(mocoa:modelForCellAtIndexPath:));
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa:numberOfSupplementsOfKind:inSection:),
                                 self, @selector(mocoa:kind:numberOfSupplementsInSection:));
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa:modelForSupplementOfKind:atIndexPath:),
                                 self, @selector(mocoa:kind:modelForSupplementAtIndexPath:));
    }
}

- (NSInteger)__xz_mocoa:(id)context numberOfSections:(id)null {
    return [self __xz_numberOfElements];
}

- (NSInteger)__xz_mocoa:(id)context numberOfCellsInSection:(NSInteger)section {
    return [[self __xz_modelForElementAtIndex:section] __xz_numberOfElements];
}

- (nullable id)__xz_mocoa:(id)context modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSObject * const element = [self __xz_modelForElementAtIndex:indexPath.section];
    return [element __xz_modelForElementAtIndex:indexPath.item];
}

- (NSInteger)__xz_mocoa:(id)context numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section {
    NSObject * const element = [self __xz_modelForElementAtIndex:section];
    return [element __xz_numberOfSupplementsOfKind:kind];
}

- (nullable id)__xz_mocoa:(id)context modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    NSObject * const element = [self __xz_modelForElementAtIndex:indexPath.section];
    return [element __xz_modelForSupplementOfKind:kind atIndex:indexPath.item];
}

- (NSInteger)__xz_numberOfElements {
    return 1;
}

- (nullable id)__xz_modelForElementAtIndex:(NSInteger)index {
    return self;
}

- (NSInteger)__xz_numberOfSupplementsOfKind:(XZMocoaKind)kind {
    return 1;
}

- (nullable id)__xz_modelForSupplementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return self;
}

@end

@implementation NSArray (XZMocoaGroupModel)

- (NSInteger)__xz_numberOfElements {
    return self.count;
}

- (id)__xz_modelForElementAtIndex:(NSInteger)index {
    return [self objectAtIndex:index];
}

@end

@implementation NSFetchedResultsController (XZMocoaGroupModel)

- (NSInteger)__xz_numberOfElements {
    return self.sections.count;
}

- (nullable id)__xz_modelForElementAtIndex:(NSInteger)index {
    id const model = (id)self.sections[index];
    
    Class const ModelClass = object_getClass(model);
    static const void * const _supports = &_supports;
    
    if (objc_getAssociatedObject(ModelClass, _supports) == nil) {
        objc_setAssociatedObject(ModelClass, _supports, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
        {
            SEL const selector = @selector(__xz_numberOfElements);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^NSInteger(id<NSFetchedResultsSectionInfo> const self) {
                return self.numberOfObjects;
            };
            xz_objc_class_addMethodWithBlock(ModelClass, selector, encoding, block, block, nil);
        }
        
        {
            SEL const selector = @selector(__xz_modelForElementAtIndex:);
            const char * const encoding = xz_objc_class_getMethodTypeEncoding([NSObject class], selector);
            id const block = ^id(id<NSFetchedResultsSectionInfo> const self, NSInteger index) {
                return self.objects[index];
            };
            xz_objc_class_addMethodWithBlock(ModelClass, selector, encoding, block, block, nil);
        }
    }
    
    return model;
}

@end
