//
//  XZKitTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/4/26.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZMacro.h>

#define Name(a, b) a+b

@interface XZKitTests : XCTestCase

@end

@implementation XZKitTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSArray *array1 = @[@"1", @"2"];
    NSArray *array2 = [[NSArray alloc] initWithArray:array1];
    
    NSLog(@"%p: %@, %p: %@", array1, array1, array2, array2);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
