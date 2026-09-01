//
//  XZMocoaDiff.h
//  XZMocoa
//
//  Created by Xezun on 2026/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 差异分析中，一个元素的移动行为。
@interface XZMocoaDiffMove : NSObject

/// 元素在旧数组中的索引。
@property (nonatomic, readonly) NSInteger from;

/// 元素在新数组中的索引。
@property (nonatomic, readonly) NSInteger to;

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

/// 两个数组的差异分析结果。
/// @discussion 基于哈希配对与 LIS（最长递增子序列）算法：
/// 配对元素中，处于 LIS 内的保持相对顺序不变，不产生移动行为；
/// 仅 LIS 之外的配对元素产生移动，因此移动次数是最少的。
@interface XZMocoaDiffResult : NSObject

/// 只存在于旧数组中的元素的索引，即应该删除的元素。
@property (nonatomic, copy, readonly) NSIndexSet *deletes;

/// 只存在于新数组中的元素的索引，即应该插入的元素。
@property (nonatomic, copy, readonly) NSIndexSet *inserts;

/// 同时存在于两个数组，但是相对顺序发生改变的元素，即应该移动的元素。
@property (nonatomic, copy, readonly) NSArray<XZMocoaDiffMove *> *moves;

- (instancetype)initWithDeletes:(NSIndexSet *)deletes inserts:(NSIndexSet *)inserts moves:(NSArray<XZMocoaDiffMove *> *)moves NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

/// 计算两个元素数组的差异。
/// @discussion 元素以标识符进行身份判定：标识符相等的两个元素，视为同一元素。
/// 数组内的标识符必须是唯一的，如果存在重复标识符，结果是不确定的。
/// @param oldIdentifiers 旧元素的标识符数组。
/// @param newIdentifiers 新元素的标识符数组。
/// @return 差异分析结果。
FOUNDATION_EXPORT XZMocoaDiffResult *XZMocoaDiffIdentifiers(NSArray<id<NSCopying>> *oldIdentifiers, NSArray<id<NSCopying>> *newIdentifiers);

/// 计算一个数值序列的最长递增子序列（LIS）所经过的元素索引。
/// @discussion 用于差异分析时：将配对成功元素的旧索引，按新顺序排列后作为输入，
/// 索引处于返回结果中的元素，相对顺序保持不变，无需移动；
/// 索引不在返回结果中的元素，则需要移动。以此方式可以让移动次数最少。
/// @param values 数值数组，例如按新顺序排列的旧索引。
/// @return LIS 所经过的元素索引集合，索引值相对于参数 values。
FOUNDATION_EXPORT NSIndexSet *XZMocoaDiffLongestIncreasingSubsequenceIndexes(NSArray<NSNumber *> *values);

NS_ASSUME_NONNULL_END
