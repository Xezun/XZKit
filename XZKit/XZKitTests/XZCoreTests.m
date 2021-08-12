//
//  XZCoreTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/25.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZCoreDataBase : NSObject
- (void)open;
- (void)update;
- (void)close;
@end

@interface XZCoreTests : XCTestCase
@end

@implementation XZCoreTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDebugMode {
    NSLog(@"XZKitDebugMode: %@", XZKitDebugMode ? @"true" : @"false");
}

- (void)testMetaMacro {
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

- (void)testDefer {
    XZCoreDataBase *db = [XZCoreDataBase new];
    [db open];
    defer(^{
        [db close];
    });
    
    [db update];
}

- (void)testLog {
    NSLog(@"%@", self);
    XZLog(@"%@", self);
    
    XZLog(@"静夜思 - 李白");
    XZDebugPrint(@"窗前明月光，");
    XZDebugPrint(@"疑是地上霜。");
    XZDebugPrint(@"举头望明月，");
    XZDebugPrint(@"低头思故乡。");
}

- (void)testPerformanceXZLog {
    // 平均耗时 0.057
    [self measureBlock:^{
        for (NSInteger i = 0; i < 1000; i++) {
            XZLog(@"%@", self);
        }
    }];
}

- (void)testPerformanceNSLog {
    // 平均耗时 0.242
    [self measureBlock:^{
        for (NSInteger i = 0; i < 1000; i++) {
            NSLog(@"%@", self);
        }
    }];
}

@end

@implementation XZCoreDataBase {
    BOOL _isOpen;
}

- (void)dealloc {
    XCTAssert(!_isOpen);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isOpen = NO;
    }
    return self;
}

- (void)open {
    _isOpen = YES;
}

- (void)update {
    // 必须在 _isOpen 时才能执行。
    XCTAssert(_isOpen);
}

- (void)close {
    _isOpen = NO;
}

@end
