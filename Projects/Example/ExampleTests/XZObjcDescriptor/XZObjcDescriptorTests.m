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
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor == nil);
        descriptor = [XZObjcType typeForEncoding:""];
        XCTAssert(descriptor == nil);
    } { // 带修饰符的编码
        const char * const objcType = "ri";
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeInt);
        XCTAssert(descriptor.modifiers == XZStdcModifierConst);
    } {
        const char * const objcType = "rnNoORVi";
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeInt);
        XCTAssert(descriptor.modifiers & XZStdcModifierConst);
        XCTAssert(descriptor.modifiers & XZStdcModifierIn);
        XCTAssert(descriptor.modifiers & XZStdcModifierInout);
        XCTAssert(descriptor.modifiers & XZStdcModifierByCopy);
        XCTAssert(descriptor.modifiers & XZStdcModifierByRef);
        XCTAssert(descriptor.modifiers & XZStdcModifierOneway);
    } {
        XZObjcType *descriptor1 = [XZObjcType typeForEncoding:@encode(int)];
        XZObjcType *descriptor2 = [XZObjcType typeForEncoding:@encode(int)];
        XZObjcType *descriptor3 = [XZObjcType typeForEncoding:"ri"];
        XCTAssert(descriptor1 == descriptor2);
        XCTAssert(descriptor1 != descriptor3);
    } { // 未知类型
        typedef void (Foobar)(void);
        const char * const objcType = @encode(Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeUnknown);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Foobar));
    } { // char
        const char * const objcType = @encode(char);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char));
        XCTAssert(descriptor.sizeInBit == (sizeof(char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(char));
    } { // unsigned char
        const char * const objcType = @encode(unsigned char);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeUnsignedChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned char));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned char));
    } { // int
        const char * const objcType = @encode(int);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int));
        XCTAssert(descriptor.sizeInBit == (sizeof(int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(int));
    } { // unsigned int
        const char * const objcType = @encode(unsigned int);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeUnsignedInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned int));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned int));
    } {
        const char * const objcType = @encode(short);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(short));
        XCTAssert(descriptor.sizeInBit == (sizeof(short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(short));
    } {
        const char * const objcType = @encode(unsigned short);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeUnsignedShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned short));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned short));
    } {
        const char * const objcType = @encode(long long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long long));
    } {
        const char * const objcType = @encode(unsigned long long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeUnsignedLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long long));
    } {
        const char * const objcType = @encode(long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == (XZ_TYPE_LLONG_IS_LONG ? XZStdcTypeLongLong : XZStdcTypeLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long));
    } {
        const char * const objcType = @encode(unsigned long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == (XZ_TYPE_LLONG_IS_LONG ? XZStdcTypeUnsignedLongLong : XZStdcTypeUnsignedLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long));
    } {
        const char * const objcType = @encode(float);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeFloat);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(float));
        XCTAssert(descriptor.sizeInBit == (sizeof(float) * 8));
        XCTAssert(descriptor.alignment == _Alignof(float));
    } {
        const char * const objcType = @encode(double);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeDouble);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(double));
        XCTAssert(descriptor.sizeInBit == (sizeof(double) * 8));
        XCTAssert(descriptor.alignment == _Alignof(double));
    } {
        const char * const objcType = @encode(bool);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeBool);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(bool));
        XCTAssert(descriptor.sizeInBit == (sizeof(bool) * 8));
        XCTAssert(descriptor.alignment == _Alignof(bool));
    } {
        const char * const objcType = @encode(void);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeVoid);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(void));
        XCTAssert(descriptor.sizeInBit == (sizeof(void) * 8));
        XCTAssert(descriptor.alignment == _Alignof(void));
    } { // c string
        const char * const objcType = @encode(char *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeString);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char *));
        XCTAssert(descriptor.alignment == _Alignof(char *));
    } { // class
        const char * const objcType = @encode(Class);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeClass);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Class));
        XCTAssert(descriptor.sizeInBit == (sizeof(Class) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Class));
    } {
        const char * const objcType = @encode(SEL);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeSelector);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(SEL));
        XCTAssert(descriptor.sizeInBit == (sizeof(SEL) * 8));
        XCTAssert(descriptor.alignment == _Alignof(SEL));
    } { // int pointer
        const char * const objcType = @encode(int *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int *));
        XCTAssert(descriptor.alignment == _Alignof(int *));
    } { // CGRect point
        const char * const objcType = @encode(CGRect *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect *));
        XCTAssert(descriptor.alignment == _Alignof(CGRect *));
    } {
        // bit field could not be test
    } { // int c array
        const char * const objcType = @encode(int[10]);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int[10]));
        XCTAssert(descriptor.alignment == _Alignof(int[10]));
        XCTAssert(descriptor.members.firstObject.raw == XZStdcTypeInt);
    } { // CGRect c array
        const char * const objcType = @encode(CGRect[10]);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.raw == XZStdcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect[10]));
        XCTAssert(descriptor.alignment == _Alignof(CGRect[10]));
        XCTAssert(descriptor.members.firstObject.raw == XZStdcTypeStruct);
    } { // union
        union Foobar {
            int a: 1;
            char b: 2;
            BOOL c;
        };
        XZObjcTypeRegister(union Foobar);
        const char * const objcType = @encode(union Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.raw == XZStdcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].raw == XZStdcTypeBitField);
    } {
        union Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(union Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.raw == XZStdcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].raw == XZStdcTypeInt);
        XCTAssert(descriptor.members[1].raw == XZStdcTypeFloat);
        XCTAssert(descriptor.members[2].raw == XZStdcTypeBool);
    } { // struct
        struct Foobar {
            int a: 1;
            int b: 2;
            BOOL c: 1;
        };
        XZObjcTypeRegister(struct Foobar);
        const char * const objcType = @encode(struct Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.raw == XZStdcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].raw == XZStdcTypeBitField);
    } {
        struct Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(struct Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.raw == XZStdcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].raw == XZStdcTypeInt);
        XCTAssert(descriptor.members[1].raw == XZStdcTypeFloat);
        XCTAssert(descriptor.members[2].raw == XZStdcTypeBool);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@"];
        XCTAssert(descriptor.raw == XZStdcTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject && descriptor.subtype == NSObject.class);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject);
        XCTAssert(descriptor.subtype == NSObject.class);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject<UIScrollViewDelegate><UITableViewDataSource>\""];
        XCTAssert(descriptor.raw == XZStdcTypeObject);
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
