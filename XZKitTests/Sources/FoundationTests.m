//
//  FoundationTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/2/8.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>
@import CoreGraphics;


typedef struct TestObjCTypeStruct {
    int a;
    NSInteger b;
    char c;
} TestObjCTypeStruct;

typedef struct TestObjCTypePackedStruct {
    int a;
    NSInteger b;
    char c;
} TestObjCTypePackedStruct;

typedef struct {
    NSInteger i;
    char c;
} TestObjCTypeNonameStruct;

typedef union TestObjCTypeUnion {
    int a;
    NSInteger b;
    char c;
} TestObjCTypeUnion;

typedef struct TestObjCTypeBitField {
    unsigned char a: 1;
    unsigned char b: 1;
//    NSInteger age;
} TestObjCTypeBitField;


@interface FoundationTests : XCTestCase {
    NSString *_name;
}

@end

@implementation FoundationTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testXZLog {
    XZPrint(@"XZPrint: %@", self);
    XZLog(@"XZLog: %@", self);
}

- (void)testXZDefer {
    XZLog(@"[0] Order 0");
    
    defer(^{
        XZLog(@"[7] Order 1: defer 1");
    });
    
    defer(^{
        XZLog(@"[6] Order 2: defer 2");
    });
    
    {
        XZLog(@"[1] Order 3.1");
        
        defer(^{
            XZLog(@"[4] Order 3.2: defer 3.1");
        });
        
        defer(^{
            XZLog(@"[3] Order 3.3: defer 3.2");
        });
        
        XZLog(@"[2] Order 3.4");
    }
    
    XZLog(@"[5] Order 4");
}

- (void)testObjCTypeDescriptor {
#define ObjCTypeDescriptorTests(type) \
        {                                                                                       \
            XZObjCTypeDescriptor *d = [XZObjCTypeDescriptor descriptorForType:@encode(type)];   \
            XCTAssert(d.size == sizeof(type));                                                  \
            XCTAssert(d.alignment == _Alignof(type));                                           \
            XCTAssert(strcmp(@encode(type), d.encoding.UTF8String) == 0);                       \
            XZLog(@"%@", d);                                                                    \
        }
    
    ObjCTypeDescriptorTests(char);
    ObjCTypeDescriptorTests(int);
    ObjCTypeDescriptorTests(short);
    ObjCTypeDescriptorTests(long);
    ObjCTypeDescriptorTests(long long);
    ObjCTypeDescriptorTests(unsigned char);
    ObjCTypeDescriptorTests(unsigned int);
    ObjCTypeDescriptorTests(unsigned short);
    ObjCTypeDescriptorTests(unsigned long);
    ObjCTypeDescriptorTests(unsigned long long);
    ObjCTypeDescriptorTests(float);
    ObjCTypeDescriptorTests(double);
    
    ObjCTypeDescriptorTests(bool);
    ObjCTypeDescriptorTests(_Bool);
    ObjCTypeDescriptorTests(BOOL);
    
    ObjCTypeDescriptorTests(void);
    ObjCTypeDescriptorTests(char *);
    
    ObjCTypeDescriptorTests(id);
    ObjCTypeDescriptorTests(NSObject *);
    
    ObjCTypeDescriptorTests(Class);
    
    ObjCTypeDescriptorTests(SEL);
    
    ObjCTypeDescriptorTests(char[20]);
    ObjCTypeDescriptorTests(char *[20]);
    ObjCTypeDescriptorTests(int[20]);
    
    ObjCTypeDescriptorTests(CGRect);
    ObjCTypeDescriptorTests(TestObjCTypeStruct);
    ObjCTypeDescriptorTests(TestObjCTypePackedStruct);
    ObjCTypeDescriptorTests(TestObjCTypeNonameStruct);
    
    ObjCTypeDescriptorTests(TestObjCTypeUnion);
    ObjCTypeDescriptorTests(TestObjCTypeBitField);
    ObjCTypeDescriptorTests(int *);
    
    ObjCTypeDescriptorTests(void (*)(int));
    
//    XZObjCTypeDescriptor *d = [XZObjCTypeDescriptor descriptorForType:@encode(TestBitField)];
//    XZLog(@"%s", @encode(TestBitField));
//    XZLog(@"%lu - %lu", d.size, sizeof(TestBitField));
//    XZLog(@"%hhu - %lu", d.alignment, _Alignof(TestBitField));
}

- (void)testRuntime {
    Class newClass = xz_objc_class_create(NSObject.class, ^(Class  _Nonnull __unsafe_unretained newClass) {
        xz_objc_class_addMethods(newClass, self.class);
        xz_objc_class_addVariables(newClass, self.class);
    });
    
    XZLog(@"%@: %@", newClass, xz_objc_class_getMethodSelectors(newClass));
    
    typeof(self) obj = [[newClass alloc] init];
    
    obj->_name = @"John Joe";
    XZLog(@"%@", obj->_name);
    
    [obj sayHello];
}

- (void)sayHello {
    XZLog(@"%@: Hello!", _name);
}

- (void)testXZGeometry {
    XZEdgeInsets insets1 = XZEdgeInsetsMake(10, 20, 30, 40);
    XCTAssert(insets1.top      == 10);
    XCTAssert(insets1.leading  == 20);
    XCTAssert(insets1.bottom   == 30);
    XCTAssert(insets1.trailing == 40);
    
    XCTAssert(!XZEdgeInsetsEqualToEdgeInsets(insets1, XZEdgeInsetsZero));
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, insets1));
    
    UIEdgeInsets insets2 = UIEdgeInsetsMake(10, 20, 30, 40);
    
    XZEdgeInsets insets2_1 = XZEdgeInsetsFromUIEdgeInsets(insets2, UIUserInterfaceLayoutDirectionLeftToRight);
    XZEdgeInsets insets2_2 = XZEdgeInsetsFromUIEdgeInsets(insets2, UIUserInterfaceLayoutDirectionRightToLeft);
    
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, insets2_1));
    XCTAssert(insets2.left == insets2_2.trailing
              && insets2.right == insets2_2.leading
              && insets2.top == insets2_2.top
              && insets2.bottom == insets2_2.bottom);
    
    CGRect rect = CGRectMake(0, 0, 100, 100);
    XCTAssert(CGRectContainsPointInEdgeInsets(rect, insets2, CGPointMake(5, 5)));
    XCTAssert(!CGRectContainsPointInEdgeInsets(rect, insets2, CGPointMake(20, 50)));
    
    NSString *string = NSStringFromXZEdgeInsets(insets1);
    XZLog(@"%@", string);
    XZLog(@"%@", NSStringFromXZRectEdge(XZRectEdgeTop|XZRectEdgeBottom|XZRectEdgeLeading|XZRectEdgeTrailing));
    
    XZEdgeInsets insets1_1 = XZEdgeInsetsFromString(string);
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, insets1_1));
}

- (void)testHexEncoding {
    NSString *contentUTF = @"XZKit - iOS框架";
    NSString *contentLowerHex = @"585a4b6974202d20694f53e6a186e69eb6";
    NSString *contentUpperHex = @"585A4B6974202D20694F53E6A186E69EB6";
    
    NSString *encodedStr = [contentUTF xz_stringByAddingHexEncoding];
    if (![encodedStr isEqual:contentLowerHex]) {
        XCTFail("编码 16 进制失败");
    }
    
    NSString *decodedStr = [contentLowerHex xz_stringByRemovingHexEncoding];
    if (![decodedStr isEqual:contentUTF]) {
        XCTFail("解码 16 进制失败");
    }
    
    encodedStr = [contentUTF xz_stringByAddingHexEncoding:(XZCharacterUppercase)];
    if (![encodedStr isEqual:contentUpperHex]) {
        XCTFail("编码 16 进制失败");
    }
    
    decodedStr = [contentLowerHex xz_stringByRemovingHexEncoding];
    if (![decodedStr isEqual:contentUTF]) {
        XCTFail("解码 16 进制失败");
    }
}

- (void)testPerformanceNSTimestamp {
    [self measureBlock:^{

    }];
}

- (void)testPerformanceXZTimestamp {
    [self measureBlock:^{
        
    }];
}

@end
