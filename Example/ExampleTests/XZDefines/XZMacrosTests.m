//
//  XZMacrosTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/10/1.
//

#import <XCTest/XCTest.h>
// 模块导入（@import）不会导出底层宏定义，需要文本方式引入 XZDefines 才能使用 __XZX_* 系列宏
#if __has_include(<XZKit/XZDefines.h>)
#import <XZKit/XZDefines.h>
#elif __has_include("XZDefines.h")
// SPM 集成时，头文件自 Sources/Header/XZKit/Public（已在头文件搜索路径中）
#import "XZDefines.h"
#else
@import XZKit;
#endif

@interface XZMacrosTests : XCTestCase

@end

@implementation XZMacrosTests

#pragma mark - __XZX_KEYIZE__ / __XZX_PASTE__

- (void)testMacroPaste {
    // 拼接后应形成合法标识符，可直接作为变量名使用
    int __XZX_PASTE__(ab, c) = 5;
    XCTAssertEqual(abc, 5);
    // 拼接结果参与 defer 变量的命名，同一作用域多次 defer 不应重名
    __block int deferOrder = 0;
    @autoreleasepool {
        defer(^{ deferOrder += 1; });
        defer(^{ deferOrder += 2; });
    }
    XCTAssertEqual(deferOrder, 3);
}

#pragma mark - __XZX_ARGS_FIRST__ / __XZX_ARGS_AT__

- (void)testMacroArgsFirst {
    XCTAssertEqualObjects(__XZX_ARGS_FIRST__(@"a", @"b", @"c"), @"a");
    XCTAssertEqualObjects(__XZX_ARGS_FIRST__(@"only"), @"only");
}

- (void)testMacroArgsAt {
    // 第 0 到第 2 个参数依次取出
    XCTAssertEqualObjects(__XZX_ARGS_AT__(0, @"a", @"b", @"c"), @"a");
    XCTAssertEqualObjects(__XZX_ARGS_AT__(1, @"a", @"b", @"c"), @"b");
    XCTAssertEqualObjects(__XZX_ARGS_AT__(2, @"a", @"b", @"c"), @"c");
    
    // 超出参数个数时，命中的是补位的数字
    __XZX_ARGS_AT__(3, @"a", @"b", @"c")
    XCTAssertEqualObjects(__XZX_ARGS_AT__(3, @"a", @"b", @"c", @"0"), @"0");
}

- (void)testMacroArgsCount {
    XCTAssertEqual(__XZX_ARGS_COUNT__(), 0);
    XCTAssertEqual(__XZX_ARGS_COUNT__(@"a"), 1);
    XCTAssertEqual(__XZX_ARGS_COUNT__(@"a", @"b"), 2);
    XCTAssertEqual(__XZX_ARGS_COUNT__(@"a", @"b", @"c"), 3);
    XCTAssertEqual(__XZX_ARGS_COUNT__(@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"), 8);
    XCTAssertEqual(__XZX_ARGS_COUNT__(@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"), 9);
    // 注：超过支持上限（>9）时结果未定义，不属于宏的设计契约，不在测试范围内
}

#pragma mark - __XZX_ARGS_MAP__

#define __test_args_map_collect__(INDEX, ARG) [self _collectArg:ARG index:INDEX into:results];

- (void)testMacroArgsMap {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    __XZX_ARGS_MAP__(__test_args_map_collect__, , @"a", @"b", @"c");
    XCTAssertEqualObjects(results, (@[@"0:a", @"1:b", @"2:c"]));

    // 单参数场景
    [results removeAllObjects];
    __XZX_ARGS_MAP__(__test_args_map_collect__, , @"only");
    XCTAssertEqualObjects(results, (@[@"0:only"]));

    // 索引应从 0 开始逐个递增
    [results removeAllObjects];
    __XZX_ARGS_MAP__(__test_args_map_collect__, , @"x", @"y");
    XCTAssertEqualObjects(results, (@[@"0:x", @"1:y"]));
}

- (void)_collectArg:(NSString *)arg index:(NSInteger)index into:(NSMutableArray<NSString *> *)results {
    [results addObject:[NSString stringWithFormat:@"%ld:%@", (long)index, arg]];
}

#undef __test_args_map_collect__

#pragma mark - defer

- (void)testDeferOrder {
    // 同一作用域内的 defer 按书写顺序倒序执行
    NSMutableArray<NSNumber *> *order = [NSMutableArray array];
    @autoreleasepool {
        defer(^{ [order addObject:@1]; });
        defer(^{ [order addObject:@2]; });
        defer(^{ [order addObject:@3]; });
    }
    XCTAssertEqualObjects(order, (@[@3, @2, @1]));
}

- (void)testXZDeferSimDB {
    BOOL __block isOpen = NO;
    {
        isOpen = YES;
        NSLog(@"The database state: %@", isOpen ? @"open" : @"close");
        defer(^{
            isOpen = NO;
            NSLog(@"The database state: %@", isOpen ? @"open" : @"close");
        });
        
        NSLog(@"Insert data");
        NSLog(@"Update data");
        NSLog(@"Search data");
    }
    XCTAssert(isOpen == NO);
}

- (void)testDeferExecutedOnScopeExit {
    // defer 在作用域结束即执行，而非方法结束
    __block BOOL executed = NO;
    if (YES) {
        defer(^{ executed = YES; });
        XCTAssertFalse(executed, @"defer 不应在作用域内执行");
    }
    XCTAssertTrue(executed, @"defer 应在作用域结束时执行");
}

- (void)testDeferExecutedOnEarlyReturn {
    // 提前 return 也应触发 defer
    NSMutableArray<NSString *> *logs = [NSMutableArray array];
    [self _deferEarlyReturnTo:logs];
    XCTAssertEqualObjects(logs, (@[@"body", @"defer"]));
}

- (void)testDeferWithMultipleStatements {
    // defer 块函数内可包含多条语句（含分号）
    __block int a = 0;
    __block int b = 0;
    @autoreleasepool {
        defer(^{
            a = 1;
            b = 2;
        });
    }
    XCTAssertEqual(a, 1);
    XCTAssertEqual(b, 2);
}

- (void)_deferEarlyReturnTo:(NSMutableArray<NSString *> *)logs {
    defer(^{ [logs addObject:@"defer"]; });
    [logs addObject:@"body"];
    return;
}

#pragma mark - enweak / deweak

- (void)testEnweakDeweakWithAliveObject {
    NSObject *foo = [NSObject new];
    NSObject *bar = [NSObject new];
    __block BOOL pass = NO;
    @enweak(foo, bar);
    XCTestExpectation *expectation = [self expectationWithDescription:@"enweak/deweak 存活对象"];
    dispatch_async(dispatch_get_main_queue(), ^{
        @deweak(foo, bar);
        pass = (foo != nil && bar != nil && foo != bar);
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:2.0];
    XCTAssertTrue(pass);
}

- (void)testEnweakDeweakWithDeallocatedObject {
    __block BOOL decodedNil = NO;
    NSObject *temp = nil;
    @enweak(temp);
    @autoreleasepool {
        temp = [NSObject new];
        // 作用域结束、对象释放后，弱引用自动置 nil
    }
    XCTestExpectation *expectation = [self expectationWithDescription:@"enweak/deweak 释放对象"];
    dispatch_async(dispatch_get_main_queue(), ^{
        @deweak(temp);
        decodedNil = (temp == nil);
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:2.0];
    XCTAssertTrue(decodedNil);
}

#pragma mark - dispatch_macros（带参 block 的补充场景）

- (void)testDispatchMacrosWithNilBlockVariable {
    // 带参数的 block 变量为 nil 时，dispatch_queue_* 系列宏不应调度执行
    void (^block)(NSInteger) = nil;
    __block BOOL called = NO;
    dispatch_queue_t const queue = dispatch_get_main_queue();

    dispatch_queue_async(queue, block, 1);
    dispatch_main_async(block, 2);
    dispatch_global_async(QOS_CLASS_DEFAULT, block, 3);

    // 异步调度队列保持空闲，稍后确认始终未调用
    XCTestExpectation *expectation = [self expectationWithDescription:@"nil block 不被调度"];
    dispatch_main_async(^{
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:2.0];
    XCTAssertFalse(called);
}

- (void)testDispatchMacrosWithBlockArguments {
    // 先将带参 block 赋值给变量，再通过宏透传实参
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch 宏带参调度"];
    __block NSInteger received = 0;
    void (^block)(NSInteger, NSString *) = ^(NSInteger value, NSString *label) {
        received = value;
        XCTAssertEqualObjects(label, @"args");
        [expectation fulfill];
    };
    dispatch_async_queue(dispatch_get_main_queue(), block, 42, @"args");
    [self waitForExpectations:@[expectation] timeout:2.0];
    XCTAssertEqual(received, 42);
}

@end
