//
//  XZMacroTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/24.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZMacro.h>

@interface XZMacroTests : XCTestCase

@end

@implementation XZMacroTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMeta {
    NSInteger a = XZ_META_PASTE(1, 2);
    XCTAssert(a == 12);
    
    NSInteger b = XZ_META_ARGS_AT(0, 1, 2, 3, 4);
    XCTAssert(b == 1);
    
    NSInteger c = XZ_META_ARGS_AT(3, 1, 2, 3, 4);
    XCTAssert(c == 4);
    
    NSInteger d = XZ_META_ARGS_COUNT();
    XCTAssert(d == 0);
    
    NSInteger e = XZ_META_ARGS_COUNT(0);
    XCTAssert(e == 1);
    
    NSInteger f = XZ_META_ARGS_COUNT(0, 1);
    XCTAssert(f == 2);
    
    NSInteger g = XZ_META_ARGS_COUNT(0, 1, 3);
    XCTAssert(g == 3);
    
    NSInteger h = XZ_META_ARGS_COUNT(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
    XCTAssert(h == 10);
}

- (void)testWeakCoding {
    NSObject *obj = NSObject.new;
    
    void *    const objPtr = (__bridge void *)obj;
    NSInteger const objRC = CFGetRetainCount(objPtr);
    
    @enweak(self, obj);
    void (^block)(void) = ^ {
        @deweak(self, obj);
        // 引用计数增加，表明 deweak 强引用了对象。
        XCTAssert(CFGetRetainCount(objPtr) - objRC == 1);
        NSLog(@"%@, %@", self, obj);
    };
    
    // 引用计数没有增加，表明 block 对 obj 没有强引用。
    XCTAssert(CFGetRetainCount(objPtr) == objRC);
    block();
}

- (void)testXcodeVersion {
    XCTAssert(XZ_XCODE_VERSION >= XZ_XCODE_12_0);
    NSLog(@"Xcode 版本：%d", XZ_XCODE_VERSION);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
