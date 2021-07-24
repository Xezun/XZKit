//
//  XZDeferTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/24.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZDeferTests : XCTestCase {
    BOOL _isOpen;
}

@end

@implementation XZDeferTests

- (void)setUp {
    _isOpen = NO;
}

- (void)tearDown {
    // 结束时，必须已关闭。
    XCTAssert(!_isOpen);
}

- (void)open {
    _isOpen = YES;
}

- (void)work {
    // 必须在 _isOpen 时才能执行。
    XCTAssert(_isOpen);
}

- (void)close {
    _isOpen = NO;
}

- (void)testDefer {
    [self open];
    defer(^{
        [self close];
    });
    
    [self work];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
