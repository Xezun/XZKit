//
//  XZMocoaDiffTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/9/1.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZMocoaDiffTests : XCTestCase

@end

@implementation XZMocoaDiffTests

#pragma mark - LIS

- (void)testLongestIncreasingSubsequenceWithEmptyValues {
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[]);
    XCTAssertEqual(indexes.count, (NSUInteger)0);
}

- (void)testLongestIncreasingSubsequenceWithSingleValue {
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@5]);
    NSMutableIndexSet *expected = [NSMutableIndexSet indexSet];
    [expected addIndex:0];
    XCTAssertEqualObjects(indexes, expected);
}

- (void)testLongestIncreasingSubsequenceWithSortedValues {
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@0, @1, @2, @3]);
    XCTAssertEqual(indexes.count, (NSUInteger)4);
}

- (void)testLongestIncreasingSubsequenceWithReversedValues {
    // 严格递增，相等不算递增，因此最长子序列长度为 1。
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@2, @1, @0]);
    XCTAssertEqual(indexes.count, (NSUInteger)1);
}

- (void)testLongestIncreasingSubsequenceWithMixedValues {
    // [3,1,2,0] 的最长递增子序列为 [1,2]，索引为 {1, 2}。
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@3, @1, @2, @0]);
    NSMutableIndexSet *expected = [NSMutableIndexSet indexSet];
    [expected addIndexesInRange:NSMakeRange(1, 2)];
    XCTAssertEqualObjects(indexes, expected);
}

- (void)testLongestIncreasingSubsequenceWithCrossValues {
    // [1,3,2,4] 的最长递增子序列为 [1,2,4]，索引为 {0, 2, 3}。
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@1, @3, @2, @4]);
    NSMutableIndexSet *expected = [NSMutableIndexSet indexSet];
    [expected addIndex:0];
    [expected addIndex:2];
    [expected addIndex:3];
    XCTAssertEqualObjects(indexes, expected);
}

- (void)testLongestIncreasingSubsequenceWithDuplicatedValues {
    // [1,1,2] 相等不算递增，最长子序列为 [1,2]，索引为 {1, 2}。
    NSIndexSet *indexes = XZMocoaDiffLongestIncreasingSubsequenceIndexes(@[@1, @1, @2]);
    NSMutableIndexSet *expected = [NSMutableIndexSet indexSet];
    [expected addIndexesInRange:NSMakeRange(1, 2)];
    XCTAssertEqualObjects(indexes, expected);
}

#pragma mark - 差异分析

- (void)testDiffWithoutChanges {
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[@"a", @"b", @"c"], @[@"a", @"b", @"c"]);
    XCTAssertEqual(result.deletes.count, (NSUInteger)0);
    XCTAssertEqual(result.inserts.count, (NSUInteger)0);
    XCTAssertEqual(result.moves.count, (NSUInteger)0);
}

- (void)testDiffWithEmptyArrays {
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[], @[]);
    XCTAssertEqual(result.deletes.count, (NSUInteger)0);
    XCTAssertEqual(result.inserts.count, (NSUInteger)0);
    XCTAssertEqual(result.moves.count, (NSUInteger)0);
}

- (void)testDiffWithAllInserts {
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[], @[@"a", @"b"]);
    XCTAssertEqual(result.deletes.count, (NSUInteger)0);
    XCTAssertEqual(result.inserts.count, (NSUInteger)2);
    XCTAssertTrue([result.inserts containsIndex:0]);
    XCTAssertTrue([result.inserts containsIndex:1]);
    XCTAssertEqual(result.moves.count, (NSUInteger)0);
}

- (void)testDiffWithAllDeletes {
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[@"a", @"b"], @[]);
    XCTAssertEqual(result.deletes.count, (NSUInteger)2);
    XCTAssertTrue([result.deletes containsIndex:0]);
    XCTAssertTrue([result.deletes containsIndex:1]);
    XCTAssertEqual(result.inserts.count, (NSUInteger)0);
    XCTAssertEqual(result.moves.count, (NSUInteger)0);
}

- (void)testDiffWithSingleMove {
    // [a,b,c,d] -> [d,a,b,c]：只需要移动 d 一个元素（LIS 保证移动次数最少）。
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[@"a", @"b", @"c", @"d"], @[@"d", @"a", @"b", @"c"]);
    XCTAssertEqual(result.deletes.count, (NSUInteger)0);
    XCTAssertEqual(result.inserts.count, (NSUInteger)0);
    XCTAssertEqual(result.moves.count, (NSUInteger)1);
    XCTAssertEqual(result.moves.firstObject.from, (NSInteger)3);
    XCTAssertEqual(result.moves.firstObject.to, (NSInteger)0);
}

- (void)testDiffWithMoves {
    // [a,b,c] -> [c,a,b]：移动 c 即可。
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[@"a", @"b", @"c"], @[@"c", @"a", @"b"]);
    XCTAssertEqual(result.moves.count, (NSUInteger)1);
    XCTAssertEqual(result.moves.firstObject.from, (NSInteger)2);
    XCTAssertEqual(result.moves.firstObject.to, (NSInteger)0);
}

- (void)testDiffWithMixedChanges {
    // [a,b,c,d,e] -> [b,x,d,a]：删除 c、e，插入 x，移动 a（b、d 保持相对顺序）。
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(@[@"a", @"b", @"c", @"d", @"e"], @[@"b", @"x", @"d", @"a"]);
    
    XCTAssertEqual(result.deletes.count, (NSUInteger)2);
    XCTAssertTrue([result.deletes containsIndex:2]);
    XCTAssertTrue([result.deletes containsIndex:4]);
    
    XCTAssertEqual(result.inserts.count, (NSUInteger)1);
    XCTAssertTrue([result.inserts containsIndex:1]);
    
    XCTAssertEqual(result.moves.count, (NSUInteger)1);
    XCTAssertEqual(result.moves.firstObject.from, (NSInteger)0);
    XCTAssertEqual(result.moves.firstObject.to, (NSInteger)3);
}

- (void)testDiffConservation {
    // 守恒等式：旧数量 - 删除 + 插入 == 新数量。
    NSArray *oldIdentifiers = @[@"a", @"b", @"c", @"d", @"e", @"f"];
    NSArray *newIdentifiers = @[@"f", @"x", @"b", @"y", @"d"];
    XZMocoaDiffResult *result = XZMocoaDiffIdentifiers(oldIdentifiers, newIdentifiers);
    XCTAssertEqual((NSInteger)oldIdentifiers.count - (NSInteger)result.deletes.count + (NSInteger)result.inserts.count, (NSInteger)newIdentifiers.count);
    // 移动不改变数量：配对数 == 新数量 - 插入数。
    XCTAssertEqual((NSInteger)newIdentifiers.count - (NSInteger)result.inserts.count, (NSInteger)oldIdentifiers.count - (NSInteger)result.deletes.count);
}

@end
