//
//  XZMocoaDiff.m
//  XZMocoa
//
//  Created by Xezun on 2026/9/1.
//

#import "XZMocoaDiff.h"

@implementation XZMocoaDiffMove

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to {
    self = [super init];
    if (self) {
        _from = from;
        _to = to;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> %ld => %ld", self, (long)_from, (long)_to];
}

@end

@implementation XZMocoaDiffResult

- (instancetype)initWithDeletes:(NSIndexSet *)deletes inserts:(NSIndexSet *)inserts moves:(NSArray<XZMocoaDiffMove *> *)moves {
    self = [super init];
    if (self) {
        _deletes = [deletes copy];
        _inserts = [inserts copy];
        _moves   = [moves copy];
    }
    return self;
}

@end

NSIndexSet *XZMocoaDiffLongestIncreasingSubsequenceIndexes(NSArray<NSNumber *> * const values) {
    NSInteger const count = values.count;
    if (count == 0) {
        return [NSIndexSet indexSet];
    }
    
    // tails[i] 是长度为 i + 1 的递增子序列中，最小的末尾元素值；
    // tailIndexes[i] 是 tails[i] 对应的 values 中的元素索引；
    // parentIndexes[i] 记录 values[i] 在 LIS 中的前驱元素索引，用于回溯完整路径。
    NSInteger      tails[count];
    NSInteger      tailIndexes[count];
    NSInteger      parentIndexes[count];
    NSInteger      length = 0;
    
    for (NSInteger index = 0; index < count; index++) {
        NSInteger const value = values[index].integerValue;
        
        // 二分查找第一个大于等于 value 的位置（严格递增，相等不算递增）。
        NSInteger lowerBound = 0;
        NSInteger upperBound = length;
        while (lowerBound < upperBound) {
            NSInteger const middle = (lowerBound + upperBound) / 2;
            if (tails[middle] < value) {
                lowerBound = middle + 1;
            } else {
                upperBound = middle;
            }
        }
        
        parentIndexes[index] = (lowerBound > 0) ? tailIndexes[lowerBound - 1] : NSNotFound;
        tails[lowerBound]      = value;
        tailIndexes[lowerBound] = index;
        if (lowerBound == length) {
            length++;
        }
    }
    
    // 从最长递增子序列的末尾元素开始，回溯完整路径。
    NSMutableIndexSet * const indexes = [NSMutableIndexSet indexSet];
    NSInteger index = tailIndexes[length - 1];
    while (index != NSNotFound) {
        [indexes addIndex:index];
        index = parentIndexes[index];
    }
    return indexes;
}

XZMocoaDiffResult *XZMocoaDiffIdentifiers(NSArray<id<NSCopying>> * const oldIdentifiers, NSArray<id<NSCopying>> * const newIdentifiers) {
    NSInteger const oldCount = oldIdentifiers.count;
    NSInteger const newCount = newIdentifiers.count;
    
    // 旧元素标识符 -> 旧索引
    NSMutableDictionary<id<NSCopying>, NSNumber *> * const oldIndexByIdentifier = [NSMutableDictionary dictionaryWithCapacity:oldCount];
    for (NSInteger oldIndex = 0; oldIndex < oldCount; oldIndex++) {
        oldIndexByIdentifier[oldIdentifiers[oldIndex]] = @(oldIndex);
    }
    
    // 按新顺序配对：配对成功的元素，记录其旧索引；未配对的为新元素。
    NSMutableArray<NSNumber *> * const pairedOldIndexes = [NSMutableArray array];
    NSMutableArray<NSNumber *> * const pairedNewIndexes = [NSMutableArray array];
    NSMutableIndexSet          * const inserts          = [NSMutableIndexSet indexSet];
    NSMutableIndexSet          * const consumedOldIndexes = [NSMutableIndexSet indexSet];
    
    for (NSInteger newIndex = 0; newIndex < newCount; newIndex++) {
        NSNumber * const oldIndex = oldIndexByIdentifier[newIdentifiers[newIndex]];
        if (oldIndex == nil) {
            [inserts addIndex:newIndex];
            continue;
        }
        [oldIndexByIdentifier removeObjectForKey:newIdentifiers[newIndex]];
        [consumedOldIndexes addIndex:oldIndex.unsignedIntegerValue];
        [pairedOldIndexes addObject:oldIndex];
        [pairedNewIndexes addObject:@(newIndex)];
    }
    
    // 旧数组中未被配对的元素，即为删除。
    NSMutableIndexSet * const deletes = [NSMutableIndexSet indexSet];
    for (NSInteger oldIndex = 0; oldIndex < oldCount; oldIndex++) {
        if (![consumedOldIndexes containsIndex:oldIndex]) {
            [deletes addIndex:oldIndex];
        }
    }
    
    // 配对元素中，旧索引构成递增子序列的，相对顺序不变，无需移动；
    // 其余配对元素则需要移动。
    NSIndexSet    * const keptPositions = XZMocoaDiffLongestIncreasingSubsequenceIndexes(pairedOldIndexes);
    NSMutableArray<XZMocoaDiffMove *> * const moves = [NSMutableArray array];
    [pairedNewIndexes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull pairedPosition, NSUInteger position, BOOL * _Nonnull stop) {
        if ([keptPositions containsIndex:position]) {
            return;
        }
        NSInteger const from = pairedOldIndexes[position].integerValue;
        NSInteger const to   = pairedNewIndexes[position].integerValue;
        [moves addObject:[[XZMocoaDiffMove alloc] initWithFrom:from to:to]];
    }];
    
    return [[XZMocoaDiffResult alloc] initWithDeletes:deletes inserts:inserts moves:moves];
}
