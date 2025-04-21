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
    {
        const char * objcType = @encode(char);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeChar);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char));
        XCTAssert(descriptor.alignment == _Alignof(char));
    }
    {
        const char * objcType = @encode(int);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeInt);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int));
        XCTAssert(descriptor.alignment == _Alignof(int));
    }
    {
        const char * objcType = @encode(short);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeShort);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(short));
        XCTAssert(descriptor.alignment == _Alignof(short));
    }
    
    {
        const char * objcType = @encode(long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long));
        XCTAssert(descriptor.alignment == _Alignof(long));
    } {
        LLONG_MAX;__LLONG_WIDTH__;
        const char * objcType = @encode(long long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeLongLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(long));
        XCTAssert(descriptor.alignment == _Alignof(long));
    } {
        const char * objcType = @encode(unsigned char);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedChar);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned char));
        XCTAssert(descriptor.alignment == _Alignof(unsigned char));
    } {
        const char * objcType = @encode(unsigned int);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedInt);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned int));
        XCTAssert(descriptor.alignment == _Alignof(unsigned int));
    } {
        const char * objcType = @encode(unsigned short);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedShort);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned short));
        XCTAssert(descriptor.alignment == _Alignof(unsigned short));
    } {
        const char * objcType = @encode(unsigned long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long));
    } {
        const char * objcType = @encode(unsigned long long);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeUnsignedLongLong);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(unsigned long long));
        XCTAssert(descriptor.alignment == _Alignof(unsigned long long));
    }
    
    {
        const char * objcType = @encode(float);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeFloat);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(float));
        XCTAssert(descriptor.alignment == _Alignof(float));
    } {
        const char * objcType = @encode(double);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeDouble);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(double));
        XCTAssert(descriptor.alignment == _Alignof(double));
    } {
        const char * objcType = @encode(bool);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeBool);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(bool));
        XCTAssert(descriptor.alignment == _Alignof(bool));
    } {
        const char * objcType = @encode(void);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeVoid);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(void));
        XCTAssert(descriptor.alignment == _Alignof(void));
    } {
        const char * objcType = @encode(char *);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeString);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(char *));
        XCTAssert(descriptor.alignment == _Alignof(char *));
    }
    
    {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@"];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    }
    {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    }
    {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && [descriptor.raw isEqualToString:@"@"]);
    }
    {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"NSObject\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && descriptor.subtype == NSObject.class);
    }
    {
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:"@\"<UIScrollViewDelegate>\""];
        XCTAssert(descriptor.type == XZObjcTypeObject && descriptor.protocols.firstObject == @protocol(UIScrollViewDelegate));
    }
    
    {
        const char * objcType = @encode(Class);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeClass);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(Class));
        XCTAssert(descriptor.alignment == _Alignof(Class));
    } {
        const char * objcType = @encode(SEL);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeSEL);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(SEL));
        XCTAssert(descriptor.alignment == _Alignof(SEL));
    }
    
    {
        const char * objcType = @encode(int[10]);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int[10]));
        XCTAssert(descriptor.alignment == _Alignof(int[10]));
        XCTAssert(descriptor.members.firstObject.type == XZObjcTypeInt);
    }
    
    {
        const char * objcType = @encode(int[10][2]);
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForObjcType:objcType];
        XCTAssert(descriptor.type == XZObjcTypeArray);
        XCTAssert(strcmp(objcType, [descriptor.raw cStringUsingEncoding:NSASCIIStringEncoding]) == 0);
        XCTAssert(descriptor.size == sizeof(int[10][2]));
        XCTAssert(descriptor.alignment == _Alignof(int[10][2]));
    }
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
