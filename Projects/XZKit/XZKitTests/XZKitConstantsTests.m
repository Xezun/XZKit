//
//  XZKitConstantsTests.m
//  XZKitTests
//
//  Created by 徐臻 on 2020/1/28.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>
@import ObjectiveC;

@interface XZKitConstantsTests : XCTestCase

@end

@implementation XZKitConstantsTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testDefer {
    XZLog(@"normal: 1");
    
    defer(^{
        XZLog(@"defer: 1");
    });
    
    XZLog(@"normal: 2");
    
    defer(^{
        XZLog(@"defer: 2");
    });
    
    XZLog(@"normal: 3");
}

- (void)testGeometry {
    XZEdgeInsets const edgeInsets = XZEdgeInsetsMake(10, 20, 30, 40);
    NSString * edgeInsetsString = NSStringFromXZEdgeInsets(edgeInsets);
    XZLog(@"1.1: %@", edgeInsetsString);
    XZLog(@"1.2: %@", NSStringFromXZEdgeInsets(XZEdgeInsetsFromString(edgeInsetsString)));
    
    XZRectEdge rectEdge = XZRectEdgeBottom | XZRectEdgeLeading | XZRectEdgeTrailing | XZRectEdgeTop;
    NSString *rectEdgeString = NSStringFromXZRectEdge(rectEdge);
    XZLog(@"2.1: %@", rectEdgeString);
    XZLog(@"2.2: %@", NSStringFromXZRectEdge(XZRectEdgeFromString(rectEdgeString)));
    
    XZLog(@"3.1: %@", NSStringFromXZEdgeInsets([@(edgeInsets) XZEdgeInsetsValue]));
}

- (void)testEncoding {
    NSString *string1 = @"XZKit 教程"; // 585A4B697420E69599E7A88B
    NSData *data1 = [string1 dataUsingEncoding:NSUTF8StringEncoding];
    
    XZLog(@"1.1: %@", [data1 xz_hexadecimalEncodedString]);
    XZLog(@"1.2: %@", [data1 xz_hexadecimalEncodedStringWithCharacterCase:(XZCharacterLowercase)]);
    XZLog(@"1.3: %@", [NSString xz_stringHexadecimalEncodedWithBytes:string1.UTF8String length:[string1 lengthOfBytesUsingEncoding:(NSUTF8StringEncoding)] characterCase:(XZCharacterUppercase)]);
    
    NSString *string2 = @"585A4B697420E69599E7A88B";
    NSData *data2 = [NSData xz_dataWithHexadecimalEncodedString:string2];
    
    XZLog(@"2.1: %@", [[NSString alloc] initWithData:data2 encoding:(NSUTF8StringEncoding)]);
}

- (void)testRuntime {
    XZLog(@"1: %@", xz_objc_class_name_create(self.class));
    XZLog(@"2: %@", xz_objc_class_name_create(@"XZKitTestClass"));
    
    xz_objc_class_enumerateInstanceMethods(self.class, ^(Method  _Nonnull method) {
        XZLog(@"3: %@", NSStringFromSelector(method_getName(method)));
    });
    
    xz_objc_class_enumerateInstanceVariables(NSObject.class, ^(Ivar  _Nonnull ivar) {
        XZLog(@"4: %s", ivar_getName(ivar));
    });
    
    xz_objc_class_exchangeMethodImplementations(self.class, @selector(method1), @selector(method2));
    XZLog(@"call method1: %@", [self method1]);
    XZLog(@"call method2: %@", [self method2]);
}

- (NSString *)method1 {
    return @"method1";
}

- (NSString *)method2 {
    return @"method2";
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
