//
//  NSIndexSet+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/8/7.
//

#import "NSIndexSet+XZKit.h"

@implementation NSIndexSet (XZKit)

- (id)xz_reduce:(id)initial next:(id  _Nonnull (^NS_NOESCAPE)(id _Nonnull, NSInteger, BOOL * _Nonnull))next {
    NSParameterAssert(next != nil);
    
    id __block result = initial;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        result = next(result, idx, stop);
    }];
    return result;
}

- (NSMutableArray *)xz_map:(id  _Nonnull (^NS_NOESCAPE)(NSInteger, BOOL * _Nonnull))transform {
    NSParameterAssert(transform != nil);
    
    NSMutableArray * const result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:transform(idx, stop)];
    }];
    return result;
}

- (NSMutableArray *)xz_compactMap:(id  _Nullable (^NS_NOESCAPE)(NSInteger, BOOL * _Nonnull))transform {
    NSParameterAssert(transform != nil);
    
    NSMutableArray * const result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        id obj = transform(idx, stop);
        if (obj != nil) {
            [result addObject:obj];
        }
    }];
    return result;
}

@end
