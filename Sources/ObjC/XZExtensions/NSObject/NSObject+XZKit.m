//
//  NSObject+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/5/28.
//

#import "NSObject+XZKit.h"
#import "NSArray+XZKit.h"
#import "XZMacros.h"

typedef void (^_XZKeyPathEnumerator)(id _Nullable value, NSInteger idx, BOOL *stop);

@implementation NSObject (XZKeyPathEnumeration)

- (void)xz_enumerateValuesForKeyPaths:(nullable NSArray<NSArray<NSString *> *> *)keyPaths usingBlock:(NS_NOESCAPE _XZKeyPathEnumerator)enumerator stop:(BOOL *)stop index:(NSInteger)index {
    /// 记录当前层次已遍历过的 key 避免重复遍历。当然，如果只有一条路径，不需要避免重复。
    NSMutableSet * const enumeratedKeys = keyPaths.count > 1 ? [NSMutableSet setWithCapacity:keyPaths.count] : nil;
    
    for (NSInteger idx = 0; idx < keyPaths.count; idx++) {
        NSArray<NSString *> * const keyPath = keyPaths[idx];
        
        NSInteger const maxIndex = keyPath.count - 1;
        if (index > maxIndex) {
            continue;
        }
        
        NSString * const key = keyPath[index];
        if ([enumeratedKeys containsObject:key]) {
            continue;
        }
        [enumeratedKeys addObject:key];
        
        id nextObject = nil;
        @try {
            nextObject = [self valueForKey:key];
        } @catch (NSException *exception) {
            nextObject = nil;
        } @finally {
            
        }
        
        if (index == maxIndex) {
            enumerator(nextObject, idx, stop);
            if (*stop) {
                break;
            }
        } else {
            [nextObject xz_enumerateValuesForKeyPaths:keyPaths usingBlock:enumerator stop:stop index:index + 1];
        }
    }
}

@end

@implementation NSObject (XZKit)

- (void)xz_enumerateValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathEnumerator)enumerator {
    NSArray<NSArray<NSString *> *> *newPaths = [keyPaths xz_map:^id(NSString *keyPath, NSInteger index, BOOL *stop) {
        NSAssert([keyPath isKindOfClass:NSString.class], @"参数 keyPaths 的元素必须是字符串");
        return [keyPath componentsSeparatedByString:@"."];
    }];

    // 因为遍历是递归的，所要一个全局的标记来控制整个遍历的停止。
    // 否则可能出现外部调用，设置了 *stop = NO 只停止了某一个分支的遍历。
    BOOL stop = NO;
    
    [self xz_enumerateValuesForKeyPaths:newPaths usingBlock:^(id value, NSInteger idx, BOOL *stop) {
        enumerator(value, keyPaths[idx], stop);
    } stop:&stop index:0];
}

- (NSMutableArray *)xz_mapValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathTransformer)transformer {
    NSMutableArray *arrayM = [NSMutableArray array];
    [self xz_enumerateValuesForKeyPaths:keyPaths usingBlock:^(id  _Nullable value, NSString * _Nonnull keyPath, BOOL * _Nonnull stop) {
        id obj = transformer(value, keyPath, stop);
        if (obj) {
            [arrayM addObject:obj];
        }
    }];
    return arrayM;
}

- (BOOL)xz_containsValuesForKeyPaths:(NSArray<NSString *> *)keyPaths usingBlock:(NS_NOESCAPE XZKeyPathComparator)predicate {
    BOOL __block contains = NO;
    [self xz_enumerateValuesForKeyPaths:keyPaths usingBlock:^(id  _Nullable value, NSString * _Nonnull keyPath, BOOL * _Nonnull stop) {
        if (predicate(value, keyPath, stop)) {
            contains = YES;
            *stop = YES;
        }
    }];
    return contains;
}

@end

@implementation NSArray (XZKeyPathEnumeration)

- (void)xz_enumerateValuesForKeyPaths:(nullable NSArray<NSArray<NSString *> *> *)keyPaths usingBlock:(NS_NOESCAPE _XZKeyPathEnumerator)enumerator stop:(BOOL *)stop index:(NSInteger)index {
    for (id nextObject in self) {
        if (*stop) {
            break;
        }
        [nextObject xz_enumerateValuesForKeyPaths:keyPaths usingBlock:enumerator stop:stop index:index];
    }
}

@end

@implementation NSSet (XZKeyPathEnumeration)

- (void)xz_enumerateValuesForKeyPaths:(nullable NSArray<NSArray<NSString *> *> *)keyPaths usingBlock:(NS_NOESCAPE _XZKeyPathEnumerator)enumerator stop:(BOOL *)stop index:(NSInteger)index {
    for (id nextObject in self) {
        if (*stop) {
            break;
        }
        [nextObject xz_enumerateValuesForKeyPaths:keyPaths usingBlock:enumerator stop:stop index:index];
    }
}

@end



