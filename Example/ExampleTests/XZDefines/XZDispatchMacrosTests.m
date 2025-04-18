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
    _queue = dispatch_queue_create("com.xezun.XZDefines.dispatchMacros", DISPATCH_QUEUE_CONCURRENT);
    
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
    NSLog(@"测试无参数的 dispatch_queue_ 宏函数");
    
    dispatch_queue_t const queue = _queue;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        dispatch_queue_async(queue, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]);
        });
        
        dispatch_queue_sync(queue, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]);
        });
        
        dispatch_main_async(^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]);
        });
        
        dispatch_main_sync(^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]);
        });
        
        dispatch_global_async(QOS_CLASS_DEFAULT, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]);
        });
        
        dispatch_global_sync(QOS_CLASS_DEFAULT, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]);
        });
    });
    
}

- (void)testDispatchMacros2 {
    NSLog(@"测试有参数的 dispatch_queue_ 宏函数");
    
    dispatch_queue_t const queue = _queue;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{    
        void (^block)(NSString *, BOOL) = ^(NSString *queueName, BOOL finished) {
            XCTAssert(finished && [(__bridge NSString *)dispatch_get_specific(key) isEqualToString:queueName]);
        };
        
        dispatch_queue_async(queue, block, kQueueNameTest, YES);
        dispatch_queue_sync(queue, block, kQueueNameTest, YES);
        dispatch_main_async(block, kQueueNameMain, YES);
        dispatch_main_sync(block, kQueueNameMain, YES);
        dispatch_global_async(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
        dispatch_global_sync(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
    });
}

- (void)testDispatchMacros3 {
    NSLog(@"测试无参数的 dispatch_queue_safe 宏函数");
    
    dispatch_queue_t const queue = _queue;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        dispatch_queue_async_safe(queue, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]);
        });
        
        dispatch_queue_sync_safe(queue, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameTest]);
        });
        
        dispatch_main_async_safe(^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]);
        });
        
        dispatch_main_sync_safe(^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameMain]);
        });
        
        dispatch_global_async_safe(QOS_CLASS_DEFAULT, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]);
        });
        
        dispatch_global_sync_safe(QOS_CLASS_DEFAULT, ^{
            XCTAssert([(__bridge NSString *)dispatch_get_specific(key) isEqualToString:kQueueNameDefault]);
        });
        
        dispatch_block_t block = nil;
        
        dispatch_queue_sync_safe(queue, block);
        
        dispatch_main_async_safe(block);
        
        dispatch_main_sync_safe(block);
        
        dispatch_global_async_safe(QOS_CLASS_DEFAULT, block);
        
        dispatch_global_sync_safe(QOS_CLASS_DEFAULT, block);
    });
    
}

- (void)testDispatchMacros4 {
    NSLog(@"测试有参数的 dispatch_queue_safe 宏函数");
    
    dispatch_queue_t const queue = _queue;
    atoi("");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        void (^block)(NSString *, BOOL) = ^(NSString *queueName, BOOL finished) {
            XCTAssert(finished && [(__bridge NSString *)dispatch_get_specific(key) isEqualToString:queueName]);
        };
        
        dispatch_queue_async_safe(queue, block, kQueueNameTest, YES);
        dispatch_queue_sync_safe(queue, block, kQueueNameTest, YES);
        dispatch_main_async_safe(block, kQueueNameMain, YES);
        dispatch_main_sync_safe(block, kQueueNameMain, YES);
        dispatch_global_async_safe(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
        dispatch_global_sync_safe(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
        
        block = nil;
        
        dispatch_queue_async_safe(queue, block, kQueueNameTest, YES);
        dispatch_queue_sync_safe(queue, block, kQueueNameTest, YES);
        dispatch_main_async_safe(block, kQueueNameMain, YES);
        dispatch_main_sync_safe(block, kQueueNameMain, YES);
        dispatch_global_async_safe(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
        dispatch_global_sync_safe(QOS_CLASS_DEFAULT, block, kQueueNameDefault, YES);
    });
}

@end
