//
//  XZObjcDescriptorTests.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/4/21.
//

#import <XCTest/XCTest.h>
@import XZObjcDescriptor;

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
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor == nil);
        descriptor = [XZObjcTypeDescriptor descriptorForObjcType:""];
        XCTAssert(descriptor == nil);
    } { // 带修饰符的编码
        const char * const objcType = "ri";
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeInt);
        XCTAssert(descriptor.qualifiers == XZObjcQualifierConst);
    } {
        const char * const objcType = "rnNoORVi";
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeInt);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierConst);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierIn);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierInout);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierByCopy);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierByRef);
        XCTAssert(descriptor.qualifiers & XZObjcQualifierOneway);
    } {
        XZObjcTypeDescriptor *descriptor1 = [XZObjcTypeDescriptor descriptorForObjcType:@encode(int)];
        XZObjcTypeDescriptor *descriptor2 = [XZObjcTypeDescriptor descriptorForObjcType:@encode(int)];
        XZObjcTypeDescriptor *descriptor3 = [XZObjcTypeDescriptor descriptorForObjcType:"ri"];
        XCTAssert(descriptor1 == descriptor2);
        XCTAssert(descriptor1 != descriptor3);
    } { // 未知类型
        typedef void (Foobar)(void);
        const char * const objcType = @encode(Foobar);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnknown);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Foobar));
    } { // char
        const char * const objcType = @encode(char);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeChar);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char));
        XCTAssert(descriptor.sizeInBit == (sizeof(char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(char));
    } { // unsigned char
        const char * const objcType = @encode(unsigned char);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedChar);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned char));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned char) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned char));
    } { // int
        const char * const objcType = @encode(int);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeInt);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int));
        XCTAssert(descriptor.sizeInBit == (sizeof(int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(int));
    } { // unsigned int
        const char * const objcType = @encode(unsigned int);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedInt);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned int));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned int) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned int));
    } {
        const char * const objcType = @encode(short);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeShort);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(short));
        XCTAssert(descriptor.sizeInBit == (sizeof(short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(short));
    } {
        const char * const objcType = @encode(unsigned short);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedShort);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned short));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned short) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned short));
    } {
        const char * const objcType = @encode(long long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeLongLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long long));
    } {
        const char * const objcType = @encode(unsigned long long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedLongLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long long));
    } {
        const char * const objcType = @encode(long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == (XZ_LONG_IS_LLONG ? XZObjcTypeLongLong : XZObjcTypeLong));
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long));
        XCTAssert(descriptor.sizeInBit == (sizeof(long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(long));
    } {
        const char * const objcType = @encode(unsigned long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == (XZ_LONG_IS_LLONG ? XZObjcTypeUnsignedLongLong : XZObjcTypeUnsignedLong));
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long));
        XCTAssert(descriptor.sizeInBit == (sizeof(unsigned long) * 8));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long));
    } {
        const char * const objcType = @encode(float);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeFloat);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(float));
        XCTAssert(descriptor.sizeInBit == (sizeof(float) * 8));
        XCTAssert(descriptor.alignment == _Alignof(float));
    } {
        const char * const objcType = @encode(double);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeDouble);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(double));
        XCTAssert(descriptor.sizeInBit == (sizeof(double) * 8));
        XCTAssert(descriptor.alignment == _Alignof(double));
    } {
        const char * const objcType = @encode(bool);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeBool);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(bool));
        XCTAssert(descriptor.sizeInBit == (sizeof(bool) * 8));
        XCTAssert(descriptor.alignment == _Alignof(bool));
    } {
        const char * const objcType = @encode(void);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeVoid);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(void));
        XCTAssert(descriptor.sizeInBit == (sizeof(void) * 8));
        XCTAssert(descriptor.alignment == _Alignof(void));
    } { // c string
        const char * const objcType = @encode(char *);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeString);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char *));
        XCTAssert(descriptor.alignment == _Alignof(char *));
    } { // class
        const char * const objcType = @encode(Class);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeClass);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Class));
        XCTAssert(descriptor.sizeInBit == (sizeof(Class) * 8));
        XCTAssert(descriptor.alignment == _Alignof(Class));
    } {
        const char * const objcType = @encode(SEL);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeSEL);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(SEL));
        XCTAssert(descriptor.sizeInBit == (sizeof(SEL) * 8));
        XCTAssert(descriptor.alignment == _Alignof(SEL));
    } { // int pointer
        const char * const objcType = @encode(int *);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int *));
        XCTAssert(descriptor.alignment == _Alignof(int *));
    } { // CGRect point
        const char * const objcType = @encode(CGRect *);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypePointer);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect *));
        XCTAssert(descriptor.alignment == _Alignof(CGRect *));
    } {
        // bit field could not be test
    } { // int c array
        const char * const objcType = @encode(int[10]);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int[10]));
        XCTAssert(descriptor.alignment == _Alignof(int[10]));
        XCTAssert(descriptor.members.firstObject.type == XZObjcTypeInt);
    } { // CGRect c array
        const char * const objcType = @encode(CGRect[10]);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(CGRect[10]));
        XCTAssert(descriptor.alignment == _Alignof(CGRect[10]));
        XCTAssert(descriptor.members.firstObject.type == XZObjcTypeStruct);
    } { // union
        union Foobar {
            int a: 1;
            char b: 2;
            BOOL c;
        };
        XZObjcTypeRegister(union Foobar);
        const char * const objcType = @encode(union Foobar);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.type == XZObjcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].type == XZObjcTypeBitField);
    } {
        union Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(union Foobar);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(union Foobar), _Alignof(union Foobar));
        XCTAssert(descriptor.type == XZObjcTypeUnion);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(union Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(union Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(union Foobar));
        XCTAssert(descriptor.members[0].type == XZObjcTypeInt);
        XCTAssert(descriptor.members[1].type == XZObjcTypeFloat);
        XCTAssert(descriptor.members[2].type == XZObjcTypeBool);
    } { // struct
        struct Foobar {
            int a: 1;
            int b: 2;
            BOOL c: 1;
        };
        XZObjcTypeRegister(struct Foobar);
        const char * const objcType = @encode(struct Foobar);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.type == XZObjcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].type == XZObjcTypeBitField);
    } {
        struct Foobar {
            int a;
            float b;
            BOOL c;
        };
        const char * const objcType = @encode(struct Foobar);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        NSLog(@"%@, %lu, %lu", descriptor, sizeof(struct Foobar), _Alignof(struct Foobar));
        XCTAssert(descriptor.type == XZObjcTypeStruct);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(struct Foobar));
        XCTAssert(descriptor.sizeInBit == (sizeof(struct Foobar) * 8));
        XCTAssert(descriptor.alignment == _Alignof(struct Foobar));
        XCTAssert(descriptor.members[0].type == XZObjcTypeInt);
        XCTAssert(descriptor.members[1].type == XZObjcTypeFloat);
        XCTAssert(descriptor.members[2].type == XZObjcTypeBool);
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@"];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"NSObject\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && descriptor.subtype == NSObject.class);
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.type == XZObjcTypeObject);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"NSObject<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.type == XZObjcTypeObject);
        XCTAssert(descriptor.subtype == NSObject.class);
        XCTAssert(protocol_isEqual(descriptor.protocols.firstObject, @protocol(UIScrollViewDelegate)));
    } {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"NSObject<UIScrollViewDelegate><UITableViewDataSource>\""];
        XCTAssert(descriptor.type == XZObjcTypeObject);
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
