//
//  XZLogTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/24.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZLogTests : XCTestCase

@end

@implementation XZLogTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testLog {
    NSLog(@"%@", self);
    XZLog(@"%@", self);
    
    XZLog(@"静夜思 - 李白");
    XZLog(@"窗前明月光，");
    XZLog(@"疑是地上霜。");
    XZLog(@"举头望明月，");
    XZLog(@"低头思故乡。");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
