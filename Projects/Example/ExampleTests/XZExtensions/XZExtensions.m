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
    NSString *string = [NSString xz_stringWithBracesFormat:@"", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"");
    
    string = [NSString xz_stringWithBracesFormat:@"{1}{2}{3}{2}{1}", @"A", @"B", @"C"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"ABCBA");
    
    string = [NSString xz_stringWithBracesFormat:@"{", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"");
    
    string = [NSString xz_stringWithBracesFormat:@"}", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"");
    
    string = [NSString xz_stringWithBracesFormat:@"1", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"1");
    
    string = [NSString xz_stringWithBracesFormat:@"{}", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"$@");
    
    string = [NSString xz_stringWithBracesFormat:@"{1", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"1");
    
    string = [NSString xz_stringWithBracesFormat:@"1}", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"1");
    
    string = [NSString xz_stringWithBracesFormat:@"{1}{2}{1}", @"A", @"B"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"ABA");
    
    string = [NSString xz_stringWithBracesFormat:@"{1%.2f}", M_PI];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"3.14");
    
    string = [NSString xz_stringWithBracesFormat:@"{1%.2f} {1}", M_PI];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"3.14 3.14");
    
    string = [NSString xz_stringWithBracesFormat:@"{1%.2f} {1} {1%.5f} {1}", M_PI];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"3.14 3.14 3.14159 3.14159");
    
    string = [NSString xz_stringWithBracesFormat:@"{{1}}", @"abc"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"{1}");
    
    string = [NSString xz_stringWithBracesFormat:@"{{{1}}}", @"abc"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"{abc}");
    
    string = [NSString xz_stringWithBracesFormat:@"{123{1}", @"abc"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"123abc");
    
    string = [NSString xz_stringWithBracesFormat:@"{1}123}", @"abc"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"abc123");
    
    CGFloat value = M_PI;
    string = [NSString xz_stringWithBracesFormat:@"{1%.2f}", value];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"3.14");
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f}", value];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"M_PI = 3.14");
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f} {1%.3f}", value];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"M_PI = 3.14 3.142");
    
    string = [NSString xz_stringWithBracesFormat:@"M_PI = {1%.2f} {1%.3f} {1} {1}", value];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"M_PI = 3.14 3.142 3.142 3.142");
    
    string = [NSString xz_stringWithBracesFormat:@"中国{1}银行，中国{1}很行", @"工商"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"中国工商银行，中国工商很行");
    
    string = [NSString xz_stringWithBracesFormat:@"{2}中国{1}银行{2}中国{1}很行{2}", @"工商", @"|"];
    NSLog(@"%@", string);
    XCTAssertEqualObjects(string, @"|中国工商银行|中国工商很行|");
}

// Qwen3-32B 写的测试案例

typedef XZMarkupPredicate Predicate;

static NSString *replace(NSString *self, Predicate predicate, NSString *(^transform)(NSString *)) {
    return [self xz_stringByReplacingMatchesOfPredicate:predicate usingBlock:transform];
}

// 1. **空字符串或长度不足**

- (void)testEmptyString {
    NSString *input = @"";
    XZMarkupPredicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"");

    input = @"ab";
    result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"ab");
}


// 2. **无匹配情况**

- (void)testNoMatch {
    NSString *input = @"abcdef";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"abcdef");
}

// 3. **单个匹配**

- (void)testSingleMatch {
    NSString *input = @"[abc]def";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"X";
    });
    XCTAssertEqualObjects(result, @"Xdef");
}

// 4. **多个匹配**

- (void)testMultipleMatches {
    NSString *input = @"[abc][def]ghi";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"X";
    });
    XCTAssertEqualObjects(result, @"XXghi");
}

// 5. **嵌套匹配**

- (void)testNestedMatches {
    NSString *input = @"[a[b]c]d";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"X";
    });
    XCTAssertEqualObjects(result, @"aXcd");
}

// 6. **偶数个开始字符**

- (void)testEvenStartChars {
    NSString *input = @"[[abc]]";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"[abc]");
}

// 7. **奇数个开始字符**

- (void)testOddStartChars {
    NSString *input = @"[abc[";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"abc");
}

// 8. **偶数个结束字符**

- (void)testEvenEndChars {
    NSString *input = @"abc]]";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"abc]");
}

// 9. **奇数个结束字符**

- (void)testOddEndChars {
    NSString *input = @"]abc]";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"abc");
}

// 10. **混合开始和结束字符**

- (void)testMixedStartAndEnd {
    NSString *input = @"[a[bc]d]";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"ad");
}

// 11. **transform 应用正确**

- (void)testTransformApplied {
    NSString *input = @"[abc]";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return [match stringByAppendingString:@"_X"];
    });
    XCTAssertEqualObjects(result, @"abc_X");
}

// 12. **状态转换边界处理**

- (void)testStateTransitionAtEnd {
    NSString *input = @"[abc";
    Predicate predicate = {'[', ']'};
    NSString *result = replace(input, predicate, ^NSString *(NSString *match) {
        return @"";
    });
    XCTAssertEqualObjects(result, @"abc");
}

@end
