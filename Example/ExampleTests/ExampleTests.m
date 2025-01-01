//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Xezun on 2023/7/27.
//

#import <XCTest/XCTest.h>
@import XZDefines;
@import ObjectiveC;

@interface Foo : NSObject
- (void)foo;
- (NSString *)speakFoo:(NSString *)name;
- (NSString *)speakTwo:(NSString *)name;
@end

@interface Bar : Foo
- (void)bar;
- (NSString *)speakBar:(NSString *)name;
- (NSString *)speakTwo:(NSString *)name;
- (NSString *)exchange_speakTwo:(NSString *)name;
@end

@interface Foobar : NSObject
- (NSString *)speakNew:(NSString *)name;

- (NSString *)speakFoo:(NSString *)name;
- (NSString *)override_speakFoo:(NSString *)name;
- (NSString *)exchange_speakFoo:(NSString *)name;

- (NSString *)speakBar:(NSString *)name;
- (NSString *)override_speakBar:(NSString *)name;
- (NSString *)exchange_speakBar:(NSString *)name;

- (NSString *)speakTwo:(NSString *)name;
- (NSString *)override_speakTwo:(NSString *)name;
- (NSString *)exchange_speakTwo:(NSString *)name;
- (NSString *)__xz_exchange_0_speakTwo:(NSString *)name;
@end

@interface ExampleTests : XCTestCase

@end

@implementation ExampleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
}


- (void)testXZDefer {
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

- (void)testXZEmpty {
    {
        NSString *aString = nil;
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = (id)NSNull.null;
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = @"";
        XCTAssert(isNonEmpty(aString) == NO);
        
        aString = @"String";
        XCTAssert(isNonEmpty(aString) == YES);
        
        NSLog(@"isNonEmpty(NSString *) => Pass");
    } {
        NSArray *anArray = nil;
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = (id)NSNull.null;
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = @[];
        XCTAssert(isNonEmpty(anArray) == NO);
        
        anArray = @[@"Array"];
        XCTAssert(isNonEmpty(anArray) == YES);
        
        NSLog(@"isNonEmpty(NSArray *) => Pass");
    } {
        NSMutableArray *aMutableArray = nil;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = NSMutableArray.array;
        XCTAssert(isNonEmpty(aMutableArray) == NO);
        
        aMutableArray = [NSMutableArray arrayWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aMutableArray) == YES);
        
        NSLog(@"isNonEmpty(NSMutableArray *) => Pass");
    } {
        NSSet *aSet = nil;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = (id)NSNull.null;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = NSSet.set;
        XCTAssert(isNonEmpty(aSet) == NO);
        
        aSet = [NSSet setWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aSet) == YES);
        
        NSLog(@"isNonEmpty(NSSet *) => Pass");
    } {
        NSMutableSet *aMutableSet = nil;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = NSMutableSet.set;
        XCTAssert(isNonEmpty(aMutableSet) == NO);
        
        aMutableSet = [NSMutableSet setWithObject:@"MutableArray"];
        XCTAssert(isNonEmpty(aMutableSet) == YES);
        
        NSLog(@"isNonEmpty(NSMutableSet *) => Pass");
    } {
        NSDictionary *aDictionary = nil;
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = (id)NSNull.null;
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = @{ };
        XCTAssert(isNonEmpty(aDictionary) == NO);
        
        aDictionary = @{ @"Key": @"Value" };
        XCTAssert(isNonEmpty(aDictionary) == YES);
        
        NSLog(@"isNonEmpty(NSDictionary *) => Pass");
    } {
        NSMutableDictionary *aMutableDictionary = nil;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = (id)NSNull.null;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = NSMutableDictionary.dictionary;
        XCTAssert(isNonEmpty(aMutableDictionary) == NO);
        
        aMutableDictionary = [NSMutableDictionary dictionaryWithObject:@"Value" forKey:@"Key"];
        XCTAssert(isNonEmpty(aMutableDictionary) == YES);
        
        NSLog(@"isNonEmpty(NSMutableDictionary *) => Pass");
    } {
        NSNumber *aNumber = nil;
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = (id)NSNull.null;
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithBool:false];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithInt:0];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithDouble:0];
        XCTAssert(isNonEmpty(aNumber) == NO);
        
        aNumber = [NSNumber numberWithInt:10];
        XCTAssert(isNonEmpty(aNumber) == YES);
        
        NSLog(@"isNonEmpty(NSNumber *) => Pass");
    } {
        UIView *anObject = nil;
        XCTAssert(isNonEmpty(anObject) == NO);
        
        anObject = (id)NSNull.null;
        XCTAssert(isNonEmpty(anObject) == NO);
        
        anObject = [[UIView alloc] init];
        XCTAssert(isNonEmpty(anObject) == YES);
        
        anObject = (id)NSUUID.UUID;
        XCTAssert(isNonEmpty(anObject) == YES);
        
        NSLog(@"isNonEmpty(UIView *) => Pass");
    }
    
    {
        id value = nil;
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"123"]);
        XCTAssert(asNonEmpty(value, (NSString *)nil) == nil);
        
        value = @"";
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"123"]);
        XCTAssert(asNonEmpty(value, (NSString *)nil) == nil);
        
        value = @"456";
        XCTAssert([asNonEmpty(value, @"123") isEqualToString:@"456"]);
        XCTAssert([asNonEmpty(value, (NSString *)nil) isEqualToString:@"456"]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"123"]]);
        XCTAssert(asNonEmpty(value, (NSArray *)nil) == nil);
        
        value = @[];
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"123"]]);
        XCTAssert(asNonEmpty(value, (NSArray *)nil) == nil);
        
        value = @[@"456"];
        XCTAssert([asNonEmpty(value, @[@"123"]) isEqualToArray:@[@"456"]]);
        XCTAssert([asNonEmpty(value, (NSArray *)nil) isEqualToArray:@[@"456"]]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"123"]]);
        XCTAssert(asNonEmpty(value, (NSSet *)nil) == nil);
        
        value = [NSSet set];
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"123"]]);
        XCTAssert(asNonEmpty(value, (NSSet *)nil) == nil);
        
        value = [NSSet setWithObject:@"456"];
        XCTAssert([asNonEmpty(value, [NSSet setWithObject:@"123"]) isEqualToSet:[NSSet setWithObject:@"456"]]);
        XCTAssert([asNonEmpty(value, (NSSet *)nil) isEqualToSet:[NSSet setWithObject:@"456"]]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key": @"Value"}]);
        XCTAssert(asNonEmpty(value, (NSDictionary *)nil) == nil);
        
        value = @{};
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key": @"Value"}]);
        XCTAssert(asNonEmpty(value, (NSDictionary *)nil) == nil);
        
        value = @{@"Key1": @"Value1"};
        XCTAssert([asNonEmpty(value, @{@"Key": @"Value"}) isEqualToDictionary:@{@"Key1": @"Value1"}]);
        XCTAssert([asNonEmpty(value, (NSDictionary *)nil) isEqualToDictionary:@{@"Key1": @"Value1"}]);
    } {
        id value = nil;
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(10)]);
        XCTAssert(asNonEmpty(value, (NSNumber *)nil) == nil);
        
        value = [NSNumber numberWithInt:0];
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(10)]);
        XCTAssert(asNonEmpty(value, (NSNumber *)nil) == nil);
        
        value = [NSNumber numberWithInt:20];
        XCTAssert([asNonEmpty(value, @(10)) isEqualToNumber:@(20)]);
        XCTAssert([asNonEmpty(value, (NSNumber *)nil) isEqualToNumber:@(20)]);
    } {
        id value = nil;
        NSURL * const defaultValue = [NSURL URLWithString:@"https://www.xezun.com/"];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (NSURL *)nil) == nil);
        
        value = [NSURL URLWithString:@""];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (NSURL *)nil) == nil);
        
        value = [NSURL URLWithString:@"http://xzkit.xezun.com/"];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:[NSURL URLWithString:@"http://xzkit.xezun.com/"]]);
        XCTAssert([asNonEmpty(value, (NSURL *)nil) isEqual:[NSURL URLWithString:@"http://xzkit.xezun.com/"]]);
    }{
        id value = nil;
        UIView * const defaultValue = [[UIView alloc] init];
        
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (UIView *)nil) == nil);
        
        value = NSNull.null;
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:defaultValue]);
        XCTAssert(asNonEmpty(value, (UIView *)nil) == nil);
        
        value = [NSUUID UUID];
        XCTAssert([asNonEmpty(value, defaultValue) isEqual:value]);
        XCTAssert([asNonEmpty(value, (UIView *)nil) isEqual:value]);
    }
}

- (void)testXZUtils {
    XCTAssert(XZVersionStringCompare(@"1.2.3", @"1.2.4") == NSOrderedAscending);
    XCTAssert(XZVersionStringCompare(@"1.2.3", @"1.2") == NSOrderedDescending);
    XCTAssert(XZVersionStringCompare(@"1.2.3", @"1.2.3") == NSOrderedSame);
    XCTAssert(XZVersionStringCompare(@"1.2", @"1.2.3") == NSOrderedAscending);
    XCTAssert(XZVersionStringCompare(@"2.2", @"1.2.3") == NSOrderedDescending);
    NSLog(@"Timestamp: %f", XZTimestamp());
}

- (void)testXZRuntime {
    XCTAssert(xz_objc_class_getMethod([Foo class], @selector(foo)) != nil);
    XCTAssert(xz_objc_class_getMethod([Foo class], @selector(bar)) == nil);
    
    XCTAssert(xz_objc_class_getMethod([Bar class], @selector(foo)) == nil);
    XCTAssert(xz_objc_class_getMethod([Bar class], @selector(bar)) != nil);
    
    xz_objc_class_enumerateMethods([Foo class], ^BOOL(Method  _Nonnull method, NSInteger index) {
        NSLog(@"-[Foo %@]", NSStringFromSelector(method_getName(method)));
        return YES;
    });
    xz_objc_class_enumerateMethods([Bar class], ^BOOL(Method  _Nonnull method, NSInteger index) {
        NSLog(@"-[Bar %@]", NSStringFromSelector(method_getName(method)));
        return YES;
    });
    xz_objc_class_enumerateVariables([Foo class], ^BOOL(Ivar  _Nonnull ivar) {
        NSLog(@"Foo->%s", ivar_getName(ivar));
        return YES;
    });
    xz_objc_class_enumerateVariables([Bar class], ^BOOL(Ivar  _Nonnull ivar) {
        NSLog(@"Bar->%s", ivar_getName(ivar));
        return YES;
    });
    
    NSString * const name = @"Xezun";
    Bar *bar = [[Bar alloc] init];
    
    XCTAssert([[bar speakFoo:name] isEqualToString:@"foo"]);
    XCTAssert([[bar speakBar:name] isEqualToString:@"bar"]);
    xz_objc_class_exchangeMethods([Bar class], @selector(speakFoo:), @selector(speakBar:));
    XCTAssert([[bar speakFoo:name] isEqualToString:@"bar"]);
    XCTAssert([[bar speakBar:name] isEqualToString:@"foo"]);
}

- (void)testXZRuntime_addMethod {
    NSString * const name = @"Xezun";
    Bar      * const bar  = [[Bar alloc] init];
    
    NSLog(@"添加方法：目标类没有待添加的方法");
    xz_objc_class_addMethod([Bar class], @selector(speakNew:), [Foobar class], @selector(speakNew:), nil, nil);
    XCTAssert([[(Foobar*)bar speakNew:name] isEqualToString:@"foobar new"]);
    
    NSLog(@"重写方法：父类已实现，子类未实现");
    xz_objc_class_addMethod([Bar class], @selector(speakFoo:), [Foobar class], nil, @selector(override_speakFoo:), nil);
    XCTAssert([[bar speakFoo:name] isEqualToString:@"foobar override foo"]);
    
    NSLog(@"交换方法：目标类没有待交换的方法");
    xz_objc_class_addMethod([Bar class], @selector(speakBar:), [Foobar class], @selector(speakBar:), @selector(override_speakBar:), @selector(exchange_speakBar:));
    XCTAssert([[bar speakBar:name] isEqualToString:@"foobar exchange bar"]);
    
    NSLog(@"交换方法：目标类已有待交换的方法");
    BOOL success = xz_objc_class_addMethod([Bar class], @selector(speakTwo:), [Foobar class], @selector(speakTwo:), @selector(override_speakTwo:), @selector(exchange_speakTwo:));
    XCTAssert(success == NO);
}

- (void)testXZRuntime_addMethodWithBlock {
    NSString * const name = @"Xezun";
    Bar      * const bar  = [[Bar alloc] init];
    
    NSLog(@"添加方法：目标类没有待添加的方法");
    const char *encoding = xz_objc_class_getMethodTypeEncoding([Foobar class], @selector(speakNew:));
    xz_objc_class_addMethodWithBlock([Bar class], @selector(speakNew:), encoding, ^NSString *(Bar *self, NSString *name) {
        return @"block new";
    }, nil, nil);
    XCTAssert([[(Foobar*)bar speakNew:name] isEqualToString:@"block new"]);
    
    NSLog(@"重写方法：父类已实现，子类未实现");
    xz_objc_class_addMethodWithBlock([Bar class], @selector(speakFoo:), NULL, nil, ^NSString *(Bar *self, NSString *name) {
        struct objc_super super = {
                 .receiver = self,
                 .super_class = class_getSuperclass(object_getClass(self))
             };
        NSString *word = ((NSString *(*)(struct objc_super *, SEL, NSString *))objc_msgSendSuper)(&super, @selector(speakFoo:), name);
        NSLog(@"block override foo super: %@", word);
        return @"block override foo";
    }, nil);
    XCTAssert([[bar speakFoo:name] isEqualToString:@"block override foo"]);
    
    NSLog(@"交换方法：目标类没有待交换的方法");
    xz_objc_class_addMethodWithBlock([Bar class], @selector(speakBar:), NULL, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(Bar *self, NSString *name) {
            NSString *word = ((NSString *(*)(Bar *, SEL, NSString *))objc_msgSend)(self, selector, name);
            NSLog(@"block exchange bar self: %@", word);
            return @"block exchange bar";
        };
    });
    XCTAssert([[bar speakBar:name] isEqualToString:@"block exchange bar"]);
    
    NSLog(@"交换方法：目标类有待交换的方法");
    xz_objc_class_addMethodWithBlock([Bar class], @selector(speakTwo:), NULL, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
        return ^NSString *(Bar *self, NSString *name) {
            NSString *word = ((NSString *(*)(Bar *, SEL, NSString *))objc_msgSend)(self, selector, name);
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


@implementation Foo {
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

@end

@implementation Bar {
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
@end


@implementation Foobar

- (NSString *)speakNew:(NSString *)name {
    NSLog(@"foobar new: %@", name);
    return @"foobar new";
}

- (NSString *)speakFoo:(NSString *)name {
    NSLog(@"foobar foo: %@", name);
    return @"foobar foo";
}
- (NSString *)override_speakFoo:(NSString *)name {
    NSLog(@"foobar override foo: %@", name);
    return @"foobar override foo";
}
- (NSString *)exchange_speakFoo:(NSString *)name {
    NSLog(@"foobar exchange foo: %@", name);
    return @"foobar exchange foo";
}

- (NSString *)speakBar:(NSString *)name {
    NSLog(@"foobar bar: %@", name);
    return @"foobar bar";
}
- (NSString *)override_speakBar:(NSString *)name {
    NSLog(@"foobar override bar: %@", name);
    return @"foobar override bar";
}
- (NSString *)exchange_speakBar:(NSString *)name {
    NSLog(@"foobar exchange bar: %@", name);
    return @"foobar exchange bar";
}

- (NSString *)speakTwo:(NSString *)name {
    NSLog(@"foobar two: %@", name);
    return @"foobar two";
}
- (NSString *)override_speakTwo:(NSString *)name {
    NSLog(@"foobar override two: %@", name);
    return @"foobar override two";
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
@end
