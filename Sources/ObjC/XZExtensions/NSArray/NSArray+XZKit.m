//
//  NSArray+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/3/12.
//

#import "NSArray+XZKit.h"

@implementation NSArray (XZKit)

- (BOOL)xz_containsEqualObjects {
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

- (NSInteger)xz_lastIndex:(BOOL (^NS_NOESCAPE)(id _Nonnull))predicate {
    NSInteger const count = self.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        id object = self[i];
        if (predicate(object)) {
            return i;
        }
    }
    return NSNotFound;
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

- (void)xz_differenceFromArray:(NSArray * const)oldArray inserts:(NSMutableIndexSet * const)inserts deletes:(NSMutableIndexSet * const)deletes changes:(NSMutableDictionary<NSNumber *, NSNumber *> * const)changes remains:(NSMutableIndexSet * const)remains {
    // 当前数组为新数组、oldArray 为旧数组
    NSInteger const oldCount = oldArray.count;
    NSInteger const newCount = self.count;
    
    // 如果旧数组为空，那么所有元素都为新添加的。
    if (oldCount == 0) {
        [inserts addIndexesInRange:NSMakeRange(0, newCount)];
        return;
    }
    
    // 如果新旧数组为同一对象，那么所有元素的位置保持不变。
    if (oldArray == self) {
        [remains addIndexesInRange:NSMakeRange(0, oldCount)];
        return;
    }
    
    // 先假定旧数组中的元素都被删除了，然后在遍历时去掉还保留着的。
    [deletes addIndexesInRange:NSMakeRange(0, oldCount)];
    
    // 如果新数组为空，那么所有元素都为被删除的。
    if (newCount == 0) {
        return;
    }
    
    // 构建「旧数组元素 -> 首次出现的索引」查找表，将逐元素查找从 O(n) 线性搜索降为 O(1)。
    // 使用 NSMapTable：只 retain 不 copy 键对象，且按 -hash/-isEqual: 匹配，与 -indexOfObject: 语义一致；
    // 重复元素仅记录首个索引，与 -indexOfObject: 返回首个匹配位置的行为保持一致。
    NSMapTable<id, NSNumber *> * const oldIndexes = [[NSMapTable alloc] initWithKeyOptions:(NSMapTableStrongMemory) valueOptions:(NSMapTableStrongMemory) capacity:oldCount];
    for (NSInteger oldIndex = 0; oldIndex < oldCount; oldIndex++) {
        id const oldItem = oldArray[oldIndex];
        if ([oldIndexes objectForKey:oldItem] == nil) {
            [oldIndexes setObject:@(oldIndex) forKey:oldItem];
        }
    }
    
    // 遍历新数组的元素，然后通过查找表获取其在旧数组中的索引：
    // 1、找到了，比较元素在新旧数组的中索引，添加到 remains 或 changes 集合中；
    // 2、没找到，则表示该元素为新添加的，添加到 inserts 集合中。
    NSMutableIndexSet * const matchedIndexes = [NSMutableIndexSet indexSet];
    for (NSInteger newIndex = 0; newIndex < newCount; newIndex++) {
        id         const newItem = self[newIndex];
        NSNumber * const number  = [oldIndexes objectForKey:newItem];
        
        if (number == nil) {
            // 在 oldArray 中没有，说明是新添加的。
            [inserts addIndex:newIndex];
        } else {
            NSInteger const oldIndex = number.integerValue;
            // 元素没有被删除，先记录，最后统一从 deletes 中移除。
            [matchedIndexes addIndex:oldIndex];
            // 比较索引是否发生了变化
            if (newIndex == oldIndex) {
                [remains addIndex:oldIndex];
            } else {
                changes[@(newIndex)] = @(oldIndex);
            }
        }
    }
    [deletes removeIndexes:matchedIndexes];
}

@end


@implementation NSMutableArray (XZKit)

- (id)xz_removeFirstObject {
    if (self.count == 0) {
        return nil;
    }
    id const object = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return object;
}

- (id)xz_removeLastObject {
    NSUInteger const count = self.count;
    if (count == 0) {
        return nil;
    }
    NSUInteger const index = count - 1;
    id const object = [self objectAtIndex:index];
    [self removeObjectAtIndex:index];
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
