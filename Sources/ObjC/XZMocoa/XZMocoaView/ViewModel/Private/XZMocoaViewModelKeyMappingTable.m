//
//  XZMocoaViewModelKeyMappingTable.m
//  XZMocoa
//
//  Created by Xezun on 2025/6/17.
//

#import "XZMocoaViewModelKeyMappingTable.h"
#import "XZMocoaViewModel.h"
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaTableViewModel.h"
#import "XZMocoaCollectionViewModel.h"
@import ObjectiveC;
#import "XZRuntime.h"
#import "XZObjc.h"

static inline void XZMocoaMappingKeyToMethod(NSMutableDictionary * const keyToMethods, NSString * const key, NSString * const methodName) {
    NSMutableSet *selectors = keyToMethods[key];
    if (selectors == nil) {
        selectors = [NSMutableSet set];
        keyToMethods[key] = selectors;
    }
    [selectors addObject:methodName];
}

static inline void XZMocoaMappingModelKeys(Class const VMClass, NSMutableDictionary * const methodToKeys, NSMutableDictionary * const keyToMethods, NSMutableDictionary * const namedMethods) {
    Method const method = xz_objc_class_getMethod(object_getClass(VMClass), @selector(mappingModelKeys));
    if (method == nil) {
        return;
    }
    NSDictionary<NSString *, id> * const mappingModelKeys = [VMClass mappingModelKeys];
    if (mappingModelKeys.count == 0) {
        return;
    }
    
    [mappingModelKeys enumerateKeysAndObjectsUsingBlock:^(NSString * const methodName, id keyOrKeys, BOOL * _Nonnull stop) {
        SEL const selector = NSSelectorFromString(methodName);
        if (selector == NULL) {
            return;
        }
        // 方法是否已实现
        if (!class_respondsToSelector(VMClass, selector)) {
            return;
        }
        
        // 方法已存在映射
        if (methodToKeys[methodName]) {
            return;
        }
        
        XZObjcClass * const descriptor = [XZObjcClass classWithClass:VMClass];
        namedMethods[methodName] = descriptor.methods[methodName];
        
        if ([keyOrKeys isKindOfClass:NSString.class]) {
            methodToKeys[methodName] = @[keyOrKeys];
            XZMocoaMappingKeyToMethod(keyToMethods, keyOrKeys, methodName);
        } else {
            methodToKeys[methodName] = keyOrKeys;
            for (NSString *key in keyOrKeys) {
                XZMocoaMappingKeyToMethod(keyToMethods, key, methodName);
            }
        }
    }];
}

@implementation XZMocoaViewModelKeyMappingTable

- (instancetype)initWithMethodToKeys:(NSDictionary *)methodToKeys keyToMethods:(NSDictionary *)keyToMethods namedMethods:(NSDictionary *)namedMethods {
    self = [super init];
    if (self) {
        _methodToKeys = methodToKeys;
        _keyToMethods = keyToMethods;
        _namedMethods = namedMethods;
    }
    return self;
}

+ (XZMocoaViewModelKeyMappingTable *)tableForClass:(Class)VMClass {
    if (VMClass == nil
        || VMClass == [XZMocoaViewModel class]
        || VMClass == [XZMocoaGroupViewModel class]
        || VMClass == [XZMocoaTableViewModel class]
        || VMClass == [XZMocoaCollectionViewModel class]
        ) {
        return nil;
    }
    
    static void * _mapTable = NULL;
    
    XZMocoaViewModelKeyMappingTable *mapTable = objc_getAssociatedObject(VMClass, &_mapTable);
    
    if (mapTable) {
        return ((mapTable == (id)kCFNull) ? nil : mapTable);
    }
    
    NSMutableDictionary * const methodToKeys = [NSMutableDictionary dictionary];
    NSMutableDictionary * const keyToMethods = [NSMutableDictionary dictionary];
    NSMutableDictionary * const namedMethods = [NSMutableDictionary dictionary];
    
    XZMocoaViewModelKeyMappingTable * const superMapTable = [XZMocoaViewModelKeyMappingTable tableForClass:class_getSuperclass(VMClass)];
    
    if ( superMapTable ) {
        [methodToKeys addEntriesFromDictionary:superMapTable.methodToKeys];
        [keyToMethods addEntriesFromDictionary:superMapTable.keyToMethods];
        [namedMethods addEntriesFromDictionary:superMapTable.namedMethods];
    }
    
    XZMocoaMappingModelKeys(VMClass, methodToKeys, keyToMethods, namedMethods);
    
    if (methodToKeys.count == 0) {
        objc_setAssociatedObject(VMClass, &_mapTable, (id)kCFNull, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return nil;
    }
    
    mapTable = [[XZMocoaViewModelKeyMappingTable alloc] initWithMethodToKeys:methodToKeys keyToMethods:keyToMethods namedMethods:namedMethods];
    objc_setAssociatedObject(VMClass, &_mapTable, mapTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return mapTable;
}

@end
