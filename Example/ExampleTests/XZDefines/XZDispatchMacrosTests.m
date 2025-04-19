//
//  XZDispatchMacrosTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/4/18.
//

#import <XCTest/XCTest.h>
@import XZDefines;

static void *key = &key;

#define kQueueNameDefault    @"default"
#define kQueueNameBackground @"background"
#define kQueueNameMain       @"main"
#define kQueueNameTest       @"test"

@interface XZDispatchMacrosTests : XCTestCase {
    dispatch_queue_t _queue;
}

@end

@implementation XZDispatchMacrosTests

- (void)setUp {
    _queue = dispatch_queue_create("com.xezun.Tests.dispatchMacros", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_set_specific(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), key, kQueueNameDefault, NULL);
    dispatch_queue_set_specific(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), key, kQueueNameBackground, NULL);
    dispatch_queue_set_specific(dispatch_get_main_queue(), key, kQueueNameMain, NULL);
    dispatch_queue_set_specific(_queue, key, kQueueNameTest, NULL);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDispatchMacros1 {
    dispatch_queue_t const queue = _queue;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"测试无参数的 dispatch_queue_imp 宏函数"];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_async_v"];
            dispatch_queue_async_v(queue, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_queue_async_v");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_queue_sync_v(queue, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_queue_sync_v");
                    }
                }
            });
            a++; b++;
        }
        
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_async_v"];
            dispatch_main_async_v(^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_main_async_v");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_main_sync_v(^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_main_sync_v");
                    }
                }
            });
            a++; b++;
        }
        
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_async_v"];
            dispatch_global_async_v(QOS_CLASS_DEFAULT, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_global_async_v");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_global_sync_v(QOS_CLASS_DEFAULT, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_global_sync_v");
                    }
                }
            });
            a++; b++;
        }
        
        NSLog(@"✅ %@通过", expectation.expectationDescription);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testDispatchMacros2 {
    XCTestExpectation *expectation = [self expectationWithDescription:@"测试有参数的 dispatch_queue_imp 宏函数"];
    
    dispatch_queue_t const queue = _queue;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSInteger __block a = 0;
        void (^block)(NSString *, NSInteger, XCTestExpectation *) = ^(NSString *queueName, NSInteger _a, XCTestExpectation *expectation) {
            if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:queueName]) {
                if (a == _a) {
                    NSLog(@"✅ 宏函数测试通过：%@", expectation.expectationDescription);
                    [expectation fulfill];
                }
            }
        };
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_async_v"];
            dispatch_queue_async_v(queue, block, kQueueNameTest, 1, expectation);
            a = 1;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_sync_v"];
            dispatch_queue_sync_v(queue, block, kQueueNameTest, 1, expectation);
            a = 2;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_async_v"];
            dispatch_main_async_v(block, kQueueNameMain, 3, expectation);
            a = 3;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_sync_v"];
            dispatch_main_sync_v(block, kQueueNameMain, 3, expectation);
            a = 4;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_async_v"];
            dispatch_global_async_v(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 5, expectation);
            a = 5;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_sync_v"];
            dispatch_global_sync_v(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 5, expectation);
            a = 6;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        NSLog(@"✅ %@通过", expectation.expectationDescription);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testDispatchMacros3 {
    
    dispatch_queue_t const queue = _queue;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"测试无参数的 dispatch_queue 宏函数"];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_async"];
            dispatch_queue_async(queue, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_queue_async");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_queue_sync(queue, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_queue_sync");
                    }
                }
            });
            a++; b++;
        }
        
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_async"];
            dispatch_main_async(^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_main_async");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_main_sync(^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_main_sync");
                    }
                }
            });
            a++; b++;
        }
        
        {
            NSInteger a = 0, b __block = 0;
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_async"];
            dispatch_global_async(QOS_CLASS_DEFAULT, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]) {
                    if (a == 0 && b == 1) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_global_async");
                        [expectation fulfill];
                    }
                }
            });
            a++; b++;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            NSInteger a = 0, b __block = 0;
            dispatch_global_sync(QOS_CLASS_DEFAULT, ^{
                if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]) {
                    if (a == 0 && b == 0) {
                        NSLog(@"✅ 宏函数测试通过：dispatch_global_sync");
                    }
                }
            });
            a++; b++;
        }
        
        dispatch_block_t block = nil;
        
        dispatch_queue_sync(queue, block);
        
        dispatch_main_async(block);
        
        dispatch_main_sync(block);
        
        dispatch_global_async(QOS_CLASS_DEFAULT, block);
        
        dispatch_global_sync(QOS_CLASS_DEFAULT, block);
        
        NSLog(@"✅ %@通过", expectation.expectationDescription);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testDispatchMacros4 {
    XCTestExpectation *expectation = [self expectationWithDescription:@"测试有参数的 dispatch_queue 宏函数"];
    
    dispatch_queue_t const queue = _queue;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSInteger __block a = 0;
        void (^block)(NSString *, NSInteger, XCTestExpectation *) = ^(NSString *queueName, NSInteger _a, XCTestExpectation *expectation) {
            if ([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:queueName]) {
                if (a == _a) {
                    NSLog(@"✅ 宏函数测试通过：%@", expectation.expectationDescription);
                    [expectation fulfill];
                }
            }
        };
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_async"];
            dispatch_queue_async(queue, block, kQueueNameTest, 1, expectation);
            a = 1;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_queue_sync"];
            dispatch_queue_sync(queue, block, kQueueNameTest, 1, expectation);
            a = 2;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_async"];
            dispatch_main_async(block, kQueueNameMain, 3, expectation);
            a = 3;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_main_sync"];
            dispatch_main_sync(block, kQueueNameMain, 3, expectation);
            a = 4;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_async"];
            dispatch_global_async(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 5, expectation);
            a = 5;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        {
            XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch_global_sync"];
            dispatch_global_sync(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 5, expectation);
            a = 6;
            [self waitForExpectations:@[expectation] timeout:1.0];
        }
        
        block = nil;
        
        dispatch_queue_async(queue, block, kQueueNameTest, 0, nil);
        dispatch_queue_sync(queue, block, kQueueNameTest, 0, nil);
        dispatch_main_async(block, kQueueNameMain, 0, nil);
        dispatch_main_sync(block, kQueueNameMain, 0, nil);
        dispatch_global_async(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 0, nil);
        dispatch_global_sync(QOS_CLASS_DEFAULT, block, kQueueNameDefault, 0, nil);
        
        NSLog(@"✅ %@通过", expectation.expectationDescription);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

@end
