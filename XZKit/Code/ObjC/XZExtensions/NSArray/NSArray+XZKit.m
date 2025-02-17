//
//  NSArray+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/3/12.
//

#import "NSArray+XZKit.h"

@implementation NSArray (XZKit)

- (BOOL)xz_containsDuplicateObjects {
    NSInteger const count = self.count;
    for (NSInteger i = 0; i < count - 1; i++) {
        NSObject * const obj = self[i];
        for (NSInteger j = i + 1; j < count; j++) {
            if ([obj isEqual:self[j]]) {
                return YES;
            }
        }
    }
    return NO;
}

- (id)xz_reduce:(id)initialValue next:(id (^NS_NOESCAPE)(id, id, NSInteger, BOOL *))next {
    id __block result = initialValue;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = next(result, obj, idx, stop);
    }];
    return result;
}

- (NSMutableArray *)xz_map:(id (^NS_NOESCAPE)(id, NSInteger, BOOL *))transform {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:transform(obj, idx, stop)];
    }];
    return array;
}

- (NSMutableArray *)xz_compactMap:(id (^NS_NOESCAPE)(id, NSInteger, BOOL *))transform {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id const value = transform(obj, idx, stop);
        if (value == nil) {
            return;
        }
        [array addObject:value];
    }];
    return array;
}

- (NSMutableArray *)xz_filter:(BOOL (^NS_NOESCAPE)(id, NSInteger))isIncluded {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (isIncluded(obj, idx)) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (id)xz_first:(BOOL (^NS_NOESCAPE)(id _Nonnull, NSInteger))isIncluded {
    id __block ret = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isIncluded(obj, idx)) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (id)xz_last:(BOOL (^NS_NOESCAPE)(id _Nonnull, NSInteger))isIncluded {
    id __block ret = nil;
    [self enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isIncluded(obj, idx)) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (BOOL)xz_contains:(BOOL (^NS_NOESCAPE)(id _Nonnull, NSInteger))isIncluded {
    NSInteger index = 0;
    for (id object in self) {
        if (isIncluded(object, index++)) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)xz_firstIndex:(BOOL (^NS_NOESCAPE)(id _Nonnull))predicate {
    NSInteger index = 0;
    for (id object in self) {
        if (predicate(object)) {
            return index;
        }
        index += 1;
    }
    return NSNotFound;
}

- (void)xz_differenceFromArray:(NSArray * const)oldArray inserts:(NSMutableIndexSet * const)inserts deletes:(NSMutableIndexSet * const)deletes changes:(NSMutableDictionary<NSNumber *, NSNumber *> * const)changes remains:(NSMutableIndexSet * const)remains {
    // 当前数组为新数组、oldArray 为旧数组
    NSInteger const oldCount = oldArray.count;
    NSInteger const newCount = self.count;
    
    // 如果旧数组为空，那么所有元素都为新添加的。
    if (oldCount == 0) {
        [inserts addIndexesInRange:NSMakeRange(0, newCount)];
        return;
    }
    
    // 先假定旧数组中的元素都被删除了，然后在遍历时去掉还保留着的。
    [deletes addIndexesInRange:NSMakeRange(0, oldCount)];
    
    // 如果新数组为空，那么所有元素都为被删除的。
    if (newCount == 0) {
        return;
    }
    
    // 遍历新数组的元素，然后在旧数组中查找该元素：
    // 1、找到了，比较元素在新旧数组的中索引，添加到 remains 或 changes 集合中；
    // 2、没找到，则表示该元素为新添加的，添加到 inserts 集合中。
    for (NSInteger newIndex = 0; newIndex < newCount; newIndex++) {
        id        const newItem  = self[newIndex];
        NSInteger const oldIndex = [oldArray indexOfObject:newItem];

        if (oldIndex == NSNotFound) {
            // 在 oldArray 中没有，说明是新添加的。
            [inserts addIndex:newIndex];
        } else {
            // 元素没有被删除，从 deletes 中移除。
            [deletes removeIndex:oldIndex];
            // 比较索引是否发生了变化
            if (newIndex == oldIndex) {
                [remains addIndex:oldIndex];
            } else {
                changes[@(newIndex)] = @(oldIndex);
            }
        }
    }
}

@end


@implementation NSMutableArray (XZKit)

- (id)xz_removeLastObject {
    id const object = self.lastObject;
    [self removeLastObject];
    return object;
}

- (id)xz_removeObjectAtIndex:(NSUInteger)index {
    id const object = [self objectAtIndex:index];
    [self removeObjectAtIndex:index];
    return object;
}

@end


@implementation NSArray (XZJSON)

+ (NSArray *)xz_arrayWithJSON:(id const)json options:(NSJSONReadingOptions const)options {
    if (json == nil) {
        return nil;
    }
    NSParameterAssert([json isKindOfClass:NSString.class] || [json isKindOfClass:NSData.class]);
    NSData *data = json;
    if ([json isKindOfClass:NSString.class]) {
        data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (![data isKindOfClass:NSData.class]) {
        return nil;
    }
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error.code != noErr) {
        return nil;
    }
    if ([array isKindOfClass:NSArray.class]) {
        return array;
    }
    return nil;
}


+ (instancetype)xz_arrayWithJSON:(id)json {
    return [self xz_arrayWithJSON:json options:(NSJSONReadingAllowFragments)];
}

@end

@implementation NSMutableArray (XZJSON)

+ (instancetype)xz_arrayWithJSON:(id)json options:(NSJSONReadingOptions)options {
    return [super xz_arrayWithJSON:json options:(options | NSJSONReadingMutableContainers)];
}

@end
