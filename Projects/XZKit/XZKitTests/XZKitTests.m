//
//  XZKitTests.m
//  XZKitTests
//
//  Created by 徐臻 on 2020/1/28.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZKitTests : XCTestCase

@end

@implementation XZKitTests

- (void)setUp {
    XZKitDebugMode = YES;
}

- (void)tearDown {
    XZKitDebugMode = NO;
}

- (void)testExample {
    
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        
    }];
}

@end
