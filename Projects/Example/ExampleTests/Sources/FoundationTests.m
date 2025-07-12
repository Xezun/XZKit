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


@interface FoundationTests : XCTestCase

@property (nonatomic, copy) NSString *runtimeTest;

@end

@implementation FoundationTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testXZLog {
    XZPrint(@"\n查看控制台输出，不带额外字符：%@\n", self);
    XZLog(@"查看控制台输出，带额外字符文件、方法、时间信息：%@", self);
    DLOG(@"仅在 DEBUG 模式下才输出：%@", self);
}

- (void)testXZDefer {
    XZLog(@"请观察控制台输出顺序是否从小到大顺序递增");
    XZLog(@"[0] Order 0");
    
    defer(^{
        XZLog(@"[7] Order 1, defer 1");
    });
    
    defer(^{
        XZLog(@"[6] Order 2, defer 2");
    });
    
    {
        XZLog(@"[1] Order 3.1");
        
        defer(^{
            XZLog(@"[4] Order 3.2, defer 3.1");
        });
        
        defer(^{
            XZLog(@"[3] Order 3.3, defer 3.2");
        });
        
        XZLog(@"[2] Order 3.4");
    }
    
    XZLog(@"[5] Order 4");
}

- (void)testObjCTypeDescriptor {
#define ObjCTypeDescriptorTests(type) \
        {                                                                                       \
            XZObjcTypeDescriptor *d = [XZObjcTypeDescriptor descriptorForType:@encode(type)];   \
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
    
//    XZObjcTypeDescriptor *d = [XZObjcTypeDescriptor descriptorForType:@encode(TestBitField)];
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
    
    obj.runtimeTest = @"John Joe";
    XCTAssert([obj.runtimeTest isEqual:@"John Joe"]);
}

- (void)testXZGeometry {
    // 测试构造方法
    XZEdgeInsets insets1 = XZEdgeInsetsMake(10, 20, 30, 40);
    XCTAssert(insets1.top      == 10);
    XCTAssert(insets1.leading  == 20);
    XCTAssert(insets1.bottom   == 30);
    XCTAssert(insets1.trailing == 40);
    
    // 测试比较方法
    XCTAssert(!XZEdgeInsetsEqualToEdgeInsets(insets1, XZEdgeInsetsZero));
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, insets1));
    
    // 测试转换函数
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
    
    // 测试序列化函数
    NSString *string = NSStringFromXZEdgeInsets(insets1);
    XZLog(@"%@", string);
    XZLog(@"%@", NSStringFromXZRectEdge(XZRectEdgeTop|XZRectEdgeBottom|XZRectEdgeLeading|XZRectEdgeTrailing));
    
    // 测试反序列化函数
    XZEdgeInsets insets1_1 = XZEdgeInsetsFromString(string);
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, insets1_1));
    
    NSValue *value = [NSValue valueWithXZEdgeInsets:insets1];
    XCTAssert(XZEdgeInsetsEqualToEdgeInsets(insets1, [value XZEdgeInsetsValue]));
}

- (void)testHexEncoding {
    NSString *contentRAW = @"XZKit - iOS框架";
    NSString *contentHexLower = @"585a4b6974202d20694f53e6a186e69eb6";
    NSString *contentHexUpper = @"585A4B6974202D20694F53E6A186E69EB6";
    
    NSString *encodedStr = [contentRAW xz_stringByAddingHexEncoding];
    if (![encodedStr isEqual:contentHexLower]) {
        XCTFail("编码 16 进制失败");
    }
    
    NSString *decodedStr = [contentHexLower xz_stringByRemovingHexEncoding];
    if (![decodedStr isEqual:contentRAW]) {
        XCTFail("解码 16 进制失败");
    }
    
    encodedStr = [contentRAW xz_stringByAddingHexEncodingWithCharacterCase:(XZCharacterUppercase)];
    if (![encodedStr isEqual:contentHexUpper]) {
        XCTFail("编码 16 进制失败");
    }
    
    decodedStr = [contentHexLower xz_stringByRemovingHexEncoding];
    if (![decodedStr isEqual:contentRAW]) {
        XCTFail("解码 16 进制失败");
    }
}

- (void)testJSON {
    NSDictionary *dict = @{@"name": @"John"};
    XZLog(@"%@", [NSString xz_JSONWithObject:dict]);
    XZLog(@"%@", [NSString xz_JSONWithObject:dict options:(NSJSONWritingPrettyPrinted)]);
    XZLog(@"%@", [NSString xz_JSONWithObject:@"String to JSON."]);
    
    NSString *JSON = @"{\"name\":\"John\"}";
    XZLog(@"%@", [NSString xz_stringWithJSON:JSON]);
    XZLog(@"%@", [NSArray xz_arrayWithJSON:JSON]);
    XZLog(@"%@", [NSDictionary xz_dictionaryWithJSON:JSON]);
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
