//
//  XZExtensions.m
//  ExampleTests
//
//  Created by 徐臻 on 2025/7/14.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZExtensionsTests : XCTestCase

@end

@implementation XZExtensionsTests

- (void)testExample {
    NSString *string = [NSString xz_stringWithBracesFormat:@"{1}{2}{3}{2}{1}", @"1", @"2", @"3"];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"12321"]);
    
    CGFloat value = M_PI;
    string = [NSString xz_stringWithBracesFormat:@"{1%.2f}", value];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"3.14"]);
    
    string = [NSString xz_stringWithBracesFormat:@"{{123}"];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"{123}"]);
    
    string = [NSString xz_stringWithBracesFormat:@"{1{1}", @"abc"];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"{1abc"]);
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f}", value];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"M_PI = 3.14"]);
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f} {1%.3f}", value];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"M_PI = 3.14 3.142"]);
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f} {1%.3f} {1} {1}", value];
    NSLog(@"%@", string);
    XCTAssert([string isEqualToString:@"M_PI = 3.14 3.142 3.142 3.142"]);
}

@end
