//
//  XZHexEncodingTests.m
//  XZKitTests
//
//  Created by Xezun on 2021/7/25.
//

#import <XCTest/XCTest.h>
#import <XZKit/XZKit.h>

@interface XZHexEncodingTests : XCTestCase

@end

@implementation XZHexEncodingTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testExample {
    // 测试十六进制编码/解码
    NSString *rawStr = @"中华人民共和国万岁 - 2021年07月25日";
    NSString *hexStr = @"e4b8ade58d8ee4babae6b091e585b1e5928ce59bbde4b887e5b281202d2032303231e5b9b43037e69c883235e697a5";
    XCTAssert([rawStr.xz_stringByAddingHexEncoding isEqual:hexStr]);
    XCTAssert([hexStr.xz_stringByRemovingHexEncoding isEqual:rawStr]);
    
    const char *buffer = [rawStr cStringUsingEncoding:NSUTF8StringEncoding];
    const NSUInteger length = [rawStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSString *decStr = [NSString xz_stringWithBytes:buffer length:length hexEncoding:(XZHexEncodingLowercase)];
    XCTAssert([decStr isEqual:hexStr]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
