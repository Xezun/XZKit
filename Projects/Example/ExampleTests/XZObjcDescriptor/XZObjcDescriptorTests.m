//
//  XZObjcDescriptorTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/4/21.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZObjcDescriptorTests : XCTestCase

@end

@implementation XZObjcDescriptorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    { // 测试空值
        const char * const objcType = NULL;
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor == nil);
        descriptor = [XZOBJCType typeWithEncoding:""];
        XCTAssert(descriptor == nil);
    } { // 带修饰符的编码
        const char * const objcType = "ri";
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeInt);
        XCTAssert(descriptor.modifiers == XZISOCModifierConst);
    } {
        const char * const objcType = "rnNoORVi";
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeInt);
        XCTAssert(descriptor.modifiers & XZISOCModifierConst);
        XCTAssert(descriptor.modifiers & XZISOCModifierIn);
        XCTAssert(descriptor.modifiers & XZISOCModifierInout);
        XCTAssert(descriptor.modifiers & XZISOCModifierByCopy);
        XCTAssert(descriptor.modifiers & XZISOCModifierByRef);
        XCTAssert(descriptor.modifiers & XZISOCModifierOneway);
    } {
        XZOBJCType *descriptor1 = [XZOBJCType typeWithEncoding:@encode(int)];
        XZOBJCType *descriptor2 = [XZOBJCType typeWithEncoding:@encode(int)];
        XZOBJCType *descriptor3 = [XZOBJCType typeWithEncoding:"ri"];
        XCTAssert(descriptor1 == descriptor2);
        XCTAssert(descriptor1 != descriptor3);
    } { // 未知类型
        typedef void (Foobar)(void);
        const char * const objcType = @encode(Foobar);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeUnknown);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Foobar));
    } { // char
        const char * const objcType = @encode(char);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char));
        XCTAssert(descriptor.sizeInBit == (sizeof(char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(char));
    } { // unsigned char
        const char * const objcType = @encode(unsigned char);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeUnsignedChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned char));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned char));
    } { // int
        const char * const objcType = @encode(int);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int));
        XCTAssert(descriptor.sizeInBit == (sizeof(int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(int));
    } { // unsigned int
        const char * const objcType = @encode(unsigned int);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeUnsignedInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned int));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned int));
    } {
        const char * const objcType = @encode(short);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(short));
        XCTAssert(descriptor.sizeInBit == (sizeof(short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(short));
    } {
        const char * const objcType = @encode(unsigned short);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeUnsignedShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned short));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned short));
    } {
        const char * const objcType = @encode(long long);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long long));
    } {
        const char * const objcType = @encode(unsigned long long);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeUnsignedLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long long));
    } {
        const char * const objcType = @encode(long);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == (XZ_LONG_IS_LLONG ? XZISOCTypeLongLong : XZISOCTypeLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long));
    } {
        const char * const objcType = @encode(unsigned long);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == (XZ_LONG_IS_LLONG ? XZISOCTypeUnsignedLongLong : XZISOCTypeUnsignedLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long));
    } {
        const char * const objcType = @encode(float);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeFloat);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(float));
        XCTAssert(descriptor.sizeInBit == (sizeof(float) * 8));
        XCTAssert(descriptor.alignment == _Alignof(float));
    } {
        const char * const objcType = @encode(double);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeDouble);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(double));
        XCTAssert(descriptor.sizeInBit == (sizeof(double) * 8));
        XCTAssert(descriptor.alignment == _Alignof(double));
    } {
        const char * const objcType = @encode(bool);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeBool);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(bool));
        XCTAssert(descriptor.sizeInBit == (sizeof(bool) * 8));
        XCTAssert(descriptor.alignment == _Alignof(bool));
    } {
        const char * const objcType = @encode(void);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeVoid);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(void));
        XCTAssert(descriptor.sizeInBit == (sizeof(void) * 8));
        XCTAssert(descriptor.alignment == _Alignof(void));
    } { // c string
        const char * const objcType = @encode(char *);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeString);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char *));
        XCTAssert(descriptor.alignment == _Alignof(char *));
    } { // class
        const char * const objcType = @encode(Class);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeClass);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Class));
        XCTAssert(descriptor.sizeInBit == (sizeof(Class) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Class));
    } {
        const char * const objcType = @encode(SEL);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeSEL);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(SEL));
        XCTAssert(descriptor.sizeInBit == (sizeof(SEL) * 8));
        XCTAssert(descriptor.alignment == _Alignof(SEL));
    } { // int pointer
        const char * const objcType = @encode(int *);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int *));
        XCTAssert(descriptor.alignment == _Alignof(int *));
    } { // CGRect point
        const char * const objcType = @encode(CGRect *);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect *));
        XCTAssert(descriptor.alignment == _Alignof(CGRect *));
    } {
        // bit field could not be test
    } { // int c array
        const char * const objcType = @encode(int[10]);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int[10]));
        XCTAssert(descriptor.alignment == _Alignof(int[10]));
        XCTAssert(descriptor.members.firstObject.raw == XZISOCTypeInt);
    } { // CGRect c array
        const char * const objcType = @encode(CGRect[10]);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        XCTAssert(descriptor.raw == XZISOCTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect[10]));
        XCTAssert(descriptor.alignment == _Alignof(CGRect[10]));
        XCTAssert(descriptor.members.firstObject.raw == XZISOCTypeStruct);
    } { // union
        union Foobar {
            int a: 1;
            char b: 2;
            BOOL c;
        };
        XZOBJCTypeRegister(union Foobar);
        const char * const objcType = @encode(union Foobar);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.raw == XZISOCTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].raw == XZISOCTypeBitField);
    } {
        union Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(union Foobar);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.raw == XZISOCTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].raw == XZISOCTypeInt);
        XCTAssert(descriptor.members[1].raw == XZISOCTypeFloat);
        XCTAssert(descriptor.members[2].raw == XZISOCTypeBool);
    } { // struct
        struct Foobar {
            int a: 1;
            int b: 2;
            BOOL c: 1;
        };
        XZOBJCTypeRegister(struct Foobar);
        const char * const objcType = @encode(struct Foobar);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.raw == XZISOCTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].raw == XZISOCTypeBitField);
    } {
        struct Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(struct Foobar);
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.raw == XZISOCTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].raw == XZISOCTypeInt);
        XCTAssert(descriptor.members[1].raw == XZISOCTypeFloat);
        XCTAssert(descriptor.members[2].raw == XZISOCTypeBool);
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@"];
        XCTAssert(descriptor.raw == XZISOCTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\"\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\"NSObject\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject && descriptor.subtype == NSObject.class);
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\"<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\"NSObject<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject);
        XCTAssert(descriptor.subtype == NSObject.class);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZOBJCType *descriptor = [XZOBJCType typeWithEncoding:"@\"NSObject<UIScrollViewDelegate><UITableViewDataSource>\""];
        XCTAssert(descriptor.raw == XZISOCTypeObject);
        XCTAssert(descriptor.subtype == NSObject.class);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
        XCTAssert(protocol_isEqual(descriptor.protocols.lastObject, @protocol(UITableViewDataSource)));
    }
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
