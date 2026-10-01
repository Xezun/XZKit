//
//  XZUtilsTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/10/1.
//

#import <XCTest/XCTest.h>
@import XZKit;

@interface XZUtilsTests : XCTestCase

@end

@implementation XZUtilsTests

- (void)testXZUtils {
    XCTAssert(XZVersionCompare(@"1.2.3", @"1.2.4") == NSOrderedAscending);
    XCTAssert(XZVersionCompare(@"1.2.3", @"1.2") == NSOrderedDescending);
    XCTAssert(XZVersionCompare(@"1.2.3", @"1.2.3") == NSOrderedSame);
    XCTAssert(XZVersionCompare(@"1.2", @"1.2.3") == NSOrderedAscending);
    XCTAssert(XZVersionCompare(@"2.2", @"1.2.3") == NSOrderedDescending);
    NSLog(@"Timestamp: %f", XZTimestamp());
}

#pragma mark - XZEmpty - isNonEmpty

- (void)testIsNonEmptyString {
    XCTAssertTrue(isNonEmpty((NSString *)@"abc"));
    XCTAssertFalse(isNonEmpty((NSString *)@""));
    XCTAssertFalse(isNonEmpty((NSString *)nil));
    // 实际类型与强转类型不符时，按实际类型命中对应重载
    XCTAssertFalse(isNonEmpty((NSString *)@[@1]));
}

- (void)testIsNonEmptyArray {
    XCTAssertTrue(isNonEmpty((NSArray *)@[@1]));
    XCTAssertFalse(isNonEmpty((NSArray *)@[]));
    XCTAssertFalse(isNonEmpty((NSArray *)nil));
    XCTAssertFalse(isNonEmpty((NSArray *)@"abc"));
}

- (void)testIsNonEmptySet {
    XCTAssertTrue(isNonEmpty((NSSet *)[NSSet setWithObject:@1]));
    XCTAssertFalse(isNonEmpty((NSSet *)NSSet.set));
    XCTAssertFalse(isNonEmpty((NSSet *)nil));
}

- (void)testIsNonEmptyDictionary {
    XCTAssertTrue(isNonEmpty((NSDictionary *)@{@"k": @"v"}));
    XCTAssertFalse(isNonEmpty((NSDictionary *)@{}));
    XCTAssertFalse(isNonEmpty((NSDictionary *)nil));
}

- (void)testIsNonEmptyNumber {
    XCTAssertTrue(isNonEmpty((NSNumber *)@1));
    XCTAssertTrue(isNonEmpty((NSNumber *)@(-1)));
    XCTAssertTrue(isNonEmpty((NSNumber *)@(0.5)));
    XCTAssertFalse(isNonEmpty((NSNumber *)@0));
    XCTAssertFalse(isNonEmpty((NSNumber *)nil));
}

- (void)testIsNonEmptyObject {
    XCTAssertTrue(isNonEmpty((id)[NSObject new]));
    XCTAssertFalse(isNonEmpty((id)nil));
    XCTAssertFalse(isNonEmpty((id)NSNull.null));
}

#pragma mark - XZEmpty - asNonEmpty

- (void)testAsNonEmptyString {
    XCTAssertEqualObjects(asNonEmpty((NSString *)@"abc", @"def"), @"abc");
    XCTAssertEqualObjects(asNonEmpty((NSString *)@"", @"def"), @"def");
    XCTAssertEqualObjects(asNonEmpty((id)NSNull.null, @"Visitor"), @"Visitor");
    // 类型不符时回退默认值
    XCTAssertEqualObjects(asNonEmpty((NSString *)@[@1], @"def"), @"def");
    XCTAssertNil(asNonEmpty((NSString *)@"", (NSString *)nil));
}

- (void)testAsNonEmptyArrayAndDictionary {
    XCTAssertEqualObjects(asNonEmpty((NSArray *)@[@1], @[@2]), @[@1]);
    XCTAssertEqualObjects(asNonEmpty((NSArray *)@[], @[@2]), @[@2]);
    XCTAssertEqualObjects(asNonEmpty((NSDictionary *)@{}, @{@"k": @"v"}), @{@"k": @"v"});
}

- (void)testAsNonEmptyNumber {
    XCTAssertEqualObjects(asNonEmpty((NSNumber *)@0, @1), @1);
    XCTAssertEqualObjects(asNonEmpty((NSNumber *)@2, @1), @2);
}

- (void)testAsNonEmptyObject {
    NSObject *obj = [NSObject new];
    XCTAssertEqual(asNonEmpty((id)obj, (id)NSNull.null), obj);
    XCTAssertEqualObjects(asNonEmpty((id)nil, (id)NSNull.null), NSNull.null);
    XCTAssertEqualObjects(asNonEmpty((id)NSNull.null, (id)obj), obj);
}

- (void)testAsNonEmptyURLWithStringValue {
    // 合法的 URL 字符串应返回构造出的 NSURL 对象
    NSURL *url = asNonEmpty((NSString *)@"https://www.xezun.com", (NSURL *)nil);
    XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://www.xezun.com"]);

    // 空字符串回退默认值
    NSURL * const fallback = [NSURL URLWithString:@"https://xezun.com"];
    XCTAssertEqualObjects(asNonEmpty((NSString *)@"", fallback), fallback);

    // 非法字符串回退默认值
    XCTAssertEqualObjects(asNonEmpty((NSString *)@"ht tp://中文", fallback), fallback);
}

- (void)testAsNonEmptyURLWithNSURLValue {
    NSURL * const url = [NSURL URLWithString:@"https://www.xezun.com"];
    NSURL * const fallback = [NSURL URLWithString:@"https://xezun.com"];
    // 文档约定：value 为 NSURL 对象时应返回 value，当前实现返回 defaultValue（已知缺陷，见审查报告）
    XCTAssertEqualObjects(asNonEmpty(url, fallback), url);
    // value 为 nil 时返回默认值
    XCTAssertEqualObjects(asNonEmpty((NSURL *)nil, fallback), fallback);
}

#pragma mark - XZUtils - XZVersionCompare

- (void)testVersionCompareBasic {
    XCTAssertEqual(XZVersionCompare(@"1.0.0", @"1.0.1"), NSOrderedAscending);
    XCTAssertEqual(XZVersionCompare(@"1.0.1", @"1.0.0"), NSOrderedDescending);
    XCTAssertEqual(XZVersionCompare(@"1.0.0", @"1.0.0"), NSOrderedSame);
}

- (void)testVersionCompareNumeric {
    // 数值比较而非字典序比较
    XCTAssertEqual(XZVersionCompare(@"1.9.0", @"1.10.0"), NSOrderedAscending);
    XCTAssertEqual(XZVersionCompare(@"2.0", @"10.0"), NSOrderedAscending);
}

- (void)testVersionCompareDifferentDigits {
    // 缺失的版本段按 0 处理，位数任意
    XCTAssertEqual(XZVersionCompare(@"1.0", @"1.0.0"), NSOrderedSame);
    XCTAssertEqual(XZVersionCompare(@"1.0.1", @"1.0"), NSOrderedDescending);
    XCTAssertEqual(XZVersionCompare(@"1", @"1.0.0.0"), NSOrderedSame);
}

- (void)testVersionCompareEdgeCases {
    // 指针相同（含同为 nil），认为版本号相同
    XCTAssertEqual(XZVersionCompare(nil, nil), NSOrderedSame);
    NSString * const same = @"1.0";
    XCTAssertEqual(XZVersionCompare(same, same), NSOrderedSame);
    // nil 比合法版本号低
    XCTAssertEqual(XZVersionCompare(nil, @"1.0"), NSOrderedAscending);
    XCTAssertEqual(XZVersionCompare(@"1.0", nil), NSOrderedDescending);
    // 空字符串
    XCTAssertEqual(XZVersionCompare(@"", @"1.0"), NSOrderedAscending);
    XCTAssertEqual(XZVersionCompare(@"1.0", @""), NSOrderedDescending);
    XCTAssertEqual(XZVersionCompare(@"", @""), NSOrderedSame);
    // 非字符串参数：字符串比非字符串更高，两个非字符串相等
    XCTAssertEqual(XZVersionCompare(@"1.0", (id)@1.0), NSOrderedDescending);
    XCTAssertEqual(XZVersionCompare((id)@1.0, @"1.0"), NSOrderedAscending);
    XCTAssertEqual(XZVersionCompare((id)@1, (id)@2), NSOrderedSame);
}

#pragma mark - XZUtils - XZTimestamp

- (void)testTimestamp {
    NSTimeInterval const ts = XZTimestamp();
    // 应为当前纪元时间（2020 年之后），且包含小数部分（微秒精度）
    XCTAssertGreaterThan(ts, 1577836800.0); // 2020-01-01
    XCTAssertTrue(ts != floor(ts), @"时间戳应精确到微秒，不应为整数秒");

    // 单调不回退（同一时刻连续取值）
    NSTimeInterval const ts2 = XZTimestamp();
    XCTAssertGreaterThanOrEqual(ts2, ts);
}

- (void)testAnimationDuration {
    XCTAssertEqualWithAccuracy(XZAnimationDuration, 0.35, 0.0001);
}

#pragma mark - XZUtils - NSURLFromString / NSURLMake

- (void)testURLFromStringWithValidURL {
    XCTAssertEqualObjects(NSURLFromString(@"https://www.xezun.com"), [NSURL URLWithString:@"https://www.xezun.com"]);
}

- (void)testURLFromStringWithInvalidCharacters {
    // 含空格与中文的字符串无法直接构造 NSURL，应自动编码后构造
    NSURL *url = NSURLFromString(@"https://www.xezun.com/a b/中文");
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.absoluteString.stringByRemovingPercentEncoding, @"https://www.xezun.com/a b/中文");

    // 已编码的 % 不应被二次编码
    NSURL * const encoded = NSURLFromString(@"https://www.xezun.com/%E4%B8%AD?a=1%202");
    XCTAssertEqualObjects(encoded.absoluteString, @"https://www.xezun.com/%E4%B8%AD?a=1%202");
}

- (void)testURLFromStringWithNilAndEmpty {
    XCTAssertNil(NSURLFromString(nil));
    // 空字符串是合法的相对 URL，返回非 nil 的空 URL 对象
    XCTAssertEqualObjects(NSURLFromString(@"").absoluteString, @"");
    // 非字符串对象（运行期非法入参）应安全返回 nil
    XCTAssertNil(NSURLFromString((NSString *)@123));
}

- (void)testURLMake {
    NSURL *url = NSURLMake(@"https://%@.com/%ld", @"xezun", 100L);
    XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://xezun.com/100"]);

    // 格式化后仍无法构造合法 URL 时返回 nil
    XCTAssertNil(NSURLMake(@"%@:%@", @"ht tp", @"//中文中文"));
}

@end
