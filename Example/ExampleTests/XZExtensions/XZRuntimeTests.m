//
//  XZRuntimeTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2026/10/2.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZRuntimeTestsFoo : NSObject
- (void)foo;
- (NSString *)speakFoo:(NSString *)name;
- (NSString *)speakTwo:(NSString *)name;

- (void)sel_foo;
- (NSString *)sel_speakFoo:(NSString *)name;
- (NSString *)sel_speakTwo:(NSString *)name;

@end

@interface XZRuntimeTestsBar : XZRuntimeTestsFoo
- (void)bar;
- (NSString *)speakBar:(NSString *)name;
- (NSString *)speakTwo:(NSString *)name;
- (NSString *)exchange_speakTwo:(NSString *)name;

- (void)sel_bar;
- (NSString *)sel_speakBar:(NSString *)name;
- (NSString *)sel_speakTwo:(NSString *)name;
- (NSString *)sel_exchange_speakTwo:(NSString *)name;
@end

@interface XZRuntimeTestsFoobar : NSObject
- (NSString *)speakNew:(NSString *)name;
- (NSString *)speakFoo:(NSString *)name;
- (NSString *)speakTwo:(NSString *)name;
- (NSString *)speakBar:(NSString *)name;

- (NSString *)override_speakFoo:(NSString *)name;
- (NSString *)override_speakBar:(NSString *)name;
- (NSString *)override_speakTwo:(NSString *)name;

- (NSString *)exchange_speakFoo:(NSString *)name;
- (NSString *)exchange_speakBar:(NSString *)name;
- (NSString *)exchange_speakTwo:(NSString *)name;

- (NSString *)__xz_exchange_0_speakTwo:(NSString *)name;

- (NSString *)sel_speakNew:(NSString *)name;
- (NSString *)sel_speakFoo:(NSString *)name;
- (NSString *)sel_speakTwo:(NSString *)name;
- (NSString *)sel_speakBar:(NSString *)name;

- (NSString *)sel_override_speakFoo:(NSString *)name;
- (NSString *)sel_override_speakBar:(NSString *)name;
- (NSString *)sel_override_speakTwo:(NSString *)name;

- (NSString *)sel_exchange_speakFoo:(NSString *)name;
- (NSString *)sel_exchange_speakBar:(NSString *)name;
- (NSString *)sel_exchange_speakTwo:(NSString *)name;

@end

@interface XZRuntimeTests : XCTestCase

@end

@implementation XZRuntimeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testXZRuntime {
    XCTAssert(xz_objc_class_getMethod([XZRuntimeTestsFoo class], @selector(foo)) != nil);
    XCTAssert(xz_objc_class_getMethod([XZRuntimeTestsFoo class], @selector(bar)) == nil);
    
    XCTAssert(xz_objc_class_getMethod([XZRuntimeTestsBar class], @selector(foo)) == nil);
    XCTAssert(xz_objc_class_getMethod([XZRuntimeTestsBar class], @selector(bar)) != nil);
    
    xz_objc_class_enumerateMethods([XZRuntimeTestsFoo class], ^BOOL(Method  _Nonnull method, NSInteger index) {
        NSLog(@"-[Foo %@]", NSStringFromSelector(method_getName(method)));
        return YES;
    });
    xz_objc_class_enumerateMethods([XZRuntimeTestsBar class], ^BOOL(Method  _Nonnull method, NSInteger index) {
        NSLog(@"-[Bar %@]", NSStringFromSelector(method_getName(method)));
        return YES;
    });
    xz_objc_class_enumerateVariables([XZRuntimeTestsFoo class], ^BOOL(Ivar  _Nonnull ivar) {
        NSLog(@"Foo->%s", ivar_getName(ivar));
        return YES;
    });
    xz_objc_class_enumerateVariables([XZRuntimeTestsBar class], ^BOOL(Ivar  _Nonnull ivar) {
        NSLog(@"Bar->%s", ivar_getName(ivar));
        return YES;
    });
    
    NSString * const name = @"Xezun";
    XZRuntimeTestsBar *bar = [[XZRuntimeTestsBar alloc] init];
    
    XCTAssert([[bar speakFoo:name] isEqualToString:@"foo"]);
    XCTAssert([[bar speakBar:name] isEqualToString:@"bar"]);
    xz_objc_class_exchangeMethods([XZRuntimeTestsBar class], @selector(speakFoo:), @selector(speakBar:));
    XCTAssert([[bar speakFoo:name] isEqualToString:@"bar"]);
    XCTAssert([[bar speakBar:name] isEqualToString:@"foo"]);
}

- (void)testXZRuntime_addMethodWithSelector {
    NSString          * const name = @"Xezun";
    XZRuntimeTestsBar * const bar  = [[XZRuntimeTestsBar alloc] init];
    
    NSLog(@"添加方法：目标类没有待添加的方法");
    xz_objc_class_addMethod([XZRuntimeTestsBar class], @selector(sel_speakNew:), [XZRuntimeTestsFoobar class], @selector(sel_speakNew:), nil, nil);
    XCTAssert([[(XZRuntimeTestsFoobar*)bar sel_speakNew:name] isEqualToString:@"foobar new"]);
    
    NSLog(@"重写方法：父类已实现，子类未实现");
    xz_objc_class_addMethod([XZRuntimeTestsBar class], @selector(sel_speakFoo:), [XZRuntimeTestsFoobar class], nil, @selector(sel_override_speakFoo:), nil);
    XCTAssert([[bar sel_speakFoo:name] isEqualToString:@"foobar override foo"]);
    
    NSLog(@"交换方法：目标类没有待交换的方法");
    xz_objc_class_addMethod([XZRuntimeTestsBar class], @selector(sel_speakBar:), [XZRuntimeTestsFoobar class], @selector(sel_speakBar:), @selector(sel_override_speakBar:), @selector(sel_exchange_speakBar:));
    XCTAssert([[bar sel_speakBar:name] isEqualToString:@"foobar exchange bar"]);
    
    NSLog(@"交换方法：目标类已有待交换的方法");
    BOOL success = xz_objc_class_addMethod([XZRuntimeTestsBar class], @selector(sel_speakTwo:), [XZRuntimeTestsFoobar class], @selector(sel_speakTwo:), @selector(sel_override_speakTwo:), @selector(sel_exchange_speakTwo:));
    XCTAssert(success == NO);
}

- (void)testXZRuntime_addMethodWithBlock {
    NSString * const name = @"Xezun";
    XZRuntimeTestsBar      * const bar  = [[XZRuntimeTestsBar alloc] init];
    
    NSLog(@"添加方法：目标类没有待添加的方法");
    const char *encoding = xz_objc_class_getMethodTypeEncoding([XZRuntimeTestsFoobar class], @selector(speakNew:));
    xz_objc_class_addMethodWithBlock([XZRuntimeTestsBar class], @selector(speakNew:), encoding, ^NSString *(XZRuntimeTestsBar *self, NSString *name) {
        return @"block new";
    }, nil, nil);
    XCTAssert([[(XZRuntimeTestsFoobar*)bar speakNew:name] isEqualToString:@"block new"]);
    
    NSLog(@"重写方法：父类已实现，子类未实现");
    xz_objc_class_addMethodWithBlock([XZRuntimeTestsBar class], @selector(speakFoo:), NULL, nil, ^NSString *(XZRuntimeTestsBar *self, NSString *name) {
        struct objc_super super = {
            .receiver = self,
            .super_class = class_getSuperclass([XZRuntimeTestsBar class])
        };
        NSString *word = ((NSString *(*)(struct objc_super *, SEL, NSString *))objc_msgSendSuper)(&super, @selector(speakFoo:), name);
        NSLog(@"block override foo super: %@", word);
        return @"block override foo";
    }, nil);
    XCTAssert([[bar speakFoo:name] isEqualToString:@"block override foo"]);
    
    NSLog(@"交换方法：目标类没有待交换的方法");
    xz_objc_class_addMethodWithBlock([XZRuntimeTestsBar class], @selector(speakBar:), NULL, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(XZRuntimeTestsBar *self, NSString *name) {
            NSString *word = ((NSString *(*)(XZRuntimeTestsBar *, SEL, NSString *))objc_msgSend)(self, selector, name);
            NSLog(@"block exchange bar self: %@", word);
            return @"block exchange bar";
        };
    });
    XCTAssert([[bar speakBar:name] isEqualToString:@"block exchange bar"]);
    
    NSLog(@"交换方法：目标类有待交换的方法");
    xz_objc_class_addMethodWithBlock([XZRuntimeTestsBar class], @selector(speakTwo:), NULL, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(XZRuntimeTestsBar *self, NSString *name) {
            NSString *word = ((NSString *(*)(XZRuntimeTestsBar *, SEL, NSString *))objc_msgSend)(self, selector, name);
            NSLog(@"block exchange two self: %@", word);
            return @"block exchange two";
        };
    });
    XCTAssert([[bar speakTwo:name] isEqualToString:@"block exchange two"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end


@implementation XZRuntimeTestsFoo {
    NSInteger _foo;
}

- (void)foo {
    NSLog(@"method foo");
}

- (NSString *)speakFoo:(NSString *)name {
    NSLog(@"foo: %@", name);
    return @"foo";
}

- (NSString *)speakTwo:(NSString *)name {
    NSLog(@"foo two: %@", name);
    return @"foo two";
}

- (void)sel_foo {
    NSLog(@"method foo");
}

- (NSString *)sel_speakFoo:(NSString *)name {
    NSLog(@"foo: %@", name);
    return @"foo";
}

- (NSString *)sel_speakTwo:(NSString *)name {
    NSLog(@"foo two: %@", name);
    return @"foo two";
}
@end

@implementation XZRuntimeTestsBar {
    NSInteger _bar;
}

- (void)bar {
    NSLog(@"method bar");
}

- (NSString *)speakBar:(NSString *)name {
    NSLog(@"bar: %@", name);
    return @"bar";
}

- (NSString *)speakTwo:(NSString *)name {
    NSLog(@"bar two: %@", name);
    return @"bar two";
}

- (NSString *)exchange_speakTwo:(NSString *)name {
    NSLog(@"bar exchange two: %@", name);
    return @"bar exchange two";
}
- (NSString *)__xz_exchange_0_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two 0: %@", name);
    [self __xz_exchange_0_speakTwo:name];
    return @"foobar exchange two 0";
}

- (void)sel_bar {
    NSLog(@"method bar");
}

- (NSString *)sel_speakBar:(NSString *)name {
    NSLog(@"bar: %@", name);
    return @"bar";
}

- (NSString *)sel_speakTwo:(NSString *)name {
    NSLog(@"bar two: %@", name);
    return @"bar two";
}

- (NSString *)sel_exchange_speakTwo:(NSString *)name {
    NSLog(@"bar exchange two: %@", name);
    return @"bar exchange two";
}
- (NSString *)__sel_xz_exchange_0_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two 0: %@", name);
    [self __xz_exchange_0_speakTwo:name];
    return @"foobar exchange two 0";
}
@end


@implementation XZRuntimeTestsFoobar

- (NSString *)speakNew:(NSString *)name {
    NSLog(@"foobar new: %@", name);
    return @"foobar new";
}
- (NSString *)speakFoo:(NSString *)name {
    NSLog(@"foobar foo: %@", name);
    return @"foobar foo";
}
- (NSString *)speakBar:(NSString *)name {
    NSLog(@"foobar bar: %@", name);
    return @"foobar bar";
}
- (NSString *)speakTwo:(NSString *)name {
    NSLog(@"foobar two: %@", name);
    return @"foobar two";
}

- (NSString *)override_speakFoo:(NSString *)name {
    NSLog(@"foobar override foo: %@", name);
    return @"foobar override foo";
}
- (NSString *)override_speakBar:(NSString *)name {
    NSLog(@"foobar override bar: %@", name);
    return @"foobar override bar";
}
- (NSString *)override_speakTwo:(NSString *)name {
    NSLog(@"foobar override two: %@", name);
    return @"foobar override two";
}

- (NSString *)exchange_speakFoo:(NSString *)name {
    NSLog(@"foobar exchange foo: %@", name);
    return @"foobar exchange foo";
}
- (NSString *)exchange_speakBar:(NSString *)name {
    NSLog(@"foobar exchange bar: %@", name);
    return @"foobar exchange bar";
}
- (NSString *)exchange_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two: %@", name);
    [self exchange_speakTwo:name];
    return @"foobar exchange two";
}

- (NSString *)__xz_exchange_0_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two 0: %@", name);
    [self exchange_speakTwo:name];
    return @"foobar exchange two 0";
}


- (NSString *)sel_speakNew:(NSString *)name {
    NSLog(@"foobar new: %@", name);
    return @"foobar new";
}
- (NSString *)sel_speakFoo:(NSString *)name {
    NSLog(@"foobar foo: %@", name);
    return @"foobar foo";
}
- (NSString *)sel_speakBar:(NSString *)name {
    NSLog(@"foobar bar: %@", name);
    return @"foobar bar";
}
- (NSString *)sel_speakTwo:(NSString *)name {
    NSLog(@"foobar two: %@", name);
    return @"foobar two";
}

- (NSString *)sel_override_speakFoo:(NSString *)name {
    NSLog(@"foobar override foo: %@", name);
    return @"foobar override foo";
}
- (NSString *)sel_override_speakBar:(NSString *)name {
    NSLog(@"foobar override bar: %@", name);
    return @"foobar override bar";
}
- (NSString *)sel_override_speakTwo:(NSString *)name {
    NSLog(@"foobar override two: %@", name);
    return @"foobar override two";
}

- (NSString *)sel_exchange_speakFoo:(NSString *)name {
    NSLog(@"foobar exchange foo: %@", name);
    return @"foobar exchange foo";
}
- (NSString *)sel_exchange_speakBar:(NSString *)name {
    NSLog(@"foobar exchange bar: %@", name);
    return @"foobar exchange bar";
}
- (NSString *)sel_exchange_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two: %@", name);
    [self exchange_speakTwo:name];
    return @"foobar exchange two";
}

- (NSString *)__sel_xz_exchange_0_speakTwo:(NSString *)name {
    NSLog(@"foobar exchange two 0: %@", name);
    [self exchange_speakTwo:name];
    return @"foobar exchange two 0";
}
@end
