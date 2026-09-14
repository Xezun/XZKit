//
//  XZObjcTests.m
//  ExampleTests
//
//  Created by Xezun on 2025/4/21.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZObjcTests : XCTestCase

@end

@implementation XZObjcTests

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
    }
    { // 带修饰符的编码
        const char * const objcType = @encode(const int);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeInt);
    }
    {
        const char * const objcType = "rnNoORVi";
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeInt);
    }
    {
        XZObjcType *descriptor1 = [XZObjcType typeForEncoding:@encode(int)];
        XZObjcType *descriptor2 = [XZObjcType typeForEncoding:@encode(int)];
        XZObjcType *descriptor3 = [XZObjcType typeForEncoding:"ri"];
        XCTAssert(descriptor1 == descriptor2);
        XCTAssert(descriptor1 == descriptor3);
    }
    { // 未知类型
        typedef void (Foobar)(void);
        const char * const objcType = @encode(Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeUnknown);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // char
        const char * const objcType = @encode(char);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // unsigned char
        const char * const objcType = @encode(unsigned char);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeUnsignedChar);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // int
        const char * const objcType = @encode(int);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // unsigned int
        const char * const objcType = @encode(unsigned int);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeUnsignedInt);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(short);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(unsigned short);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeUnsignedShort);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(long long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(unsigned long long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeUnsignedLongLong);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == (XZ_TYPE_LLONG_IS_LONG ? XZStdcTypeLongLong : XZStdcTypeLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(unsigned long);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == (XZ_TYPE_LLONG_IS_LONG ? XZStdcTypeUnsignedLongLong : XZStdcTypeUnsignedLong));
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(float);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeFloat);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(double);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeDouble);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(bool);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeBool);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(void);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeVoid);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // c string
        const char * const objcType = @encode(char *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeString);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // class
        const char * const objcType = @encode(Class);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeClass);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        const char * const objcType = @encode(SEL);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeSelector);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // int pointer
        const char * const objcType = @encode(int *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } { // CGRect point
        const char * const objcType = @encode(CGRect *);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
    } {
        // bit field could not be test
    } { // int c array
        const char * const objcType = @encode(int[10]);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.elementType.type == XZStdcTypeInt);
    } { // CGRect c array
        const char * const objcType = @encode(CGRect[10]);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        XCTAssert(descriptor.type == XZStdcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.elementType.type == XZStdcTypeStruct);
    } { // union
        union Foobar {
            int a: 1;
            char b: 2;
            BOOL c;
        };
        const char * const objcType = @encode(union Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.type == XZStdcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.members[0].type == XZStdcTypeBitField);
    } {
        union Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(union Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.type == XZStdcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.members[0].type == XZStdcTypeInt);
        XCTAssert(descriptor.members[1].type == XZStdcTypeFloat);
        XCTAssert(descriptor.members[2].type == XZStdcTypeBool);
    } { // struct
        struct Foobar {
            int a: 1;
            int b: 2;
            BOOL c: 1;
        };
        const char * const objcType = @encode(struct Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.type == XZStdcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.members[0].type == XZStdcTypeBitField);
    } {
        struct Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(struct Foobar);
        XZObjcType *descriptor = [XZObjcType typeForEncoding:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.type == XZStdcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.encoding cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.members[0].type == XZStdcTypeInt);
        XCTAssert(descriptor.members[1].type == XZStdcTypeFloat);
        XCTAssert(descriptor.members[2].type == XZStdcTypeBool);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@"];
        XCTAssert(descriptor.type == XZStdcTypeObject && [descriptor.encoding isEqualToString:@"@"]);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\""];
        XCTAssert(descriptor == nil);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"\""];
        XCTAssert(descriptor == nil);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject\""];
        XCTAssert(descriptor.type == XZStdcTypeObject && descriptor.classType == NSObject.class);
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.type == XZStdcTypeObject);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.type == XZStdcTypeObject);
        XCTAssert(descriptor.classType == NSObject.class);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcType *descriptor = [XZObjcType typeForEncoding:"@\"NSObject<UIScrollViewDelegate><UITableViewDataSource>\""];
        XCTAssert(descriptor.type == XZStdcTypeObject);
        XCTAssert(descriptor.classType == NSObject.class);
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
