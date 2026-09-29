//
//  XZDataDigesterTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/9/29.
//

#import <XCTest/XCTest.h>
#include <errno.h>
@import XZKit;

/// XZDataDigester 全覆盖单元测试。
/// 已知向量来源：MD2 取自 RFC 1319，MD4/MD5 取自 RFC 1320/RFC 1321 测试套件，
/// SHA 系列取自 FIPS 180 附录示例，均与本机 shasum/openssl 结果核对一致。
@interface XZDataDigesterTests : XCTestCase
@end

@implementation XZDataDigesterTests

#pragma mark - 辅助方法

/// RFC 测试套件统一使用的输入 "abc"。
- (NSData *)abcData {
    return [@"abc" dataUsingEncoding:NSUTF8StringEncoding];
}

/// 断言错误对象属于 XZDataDigesterErrorDomain 且携带预期的 POSIX 错误码。
- (void)assertError:(NSError *)error code:(NSInteger)code file:(NSString *)file line:(NSUInteger)line {
    XCTAssertEqualObjects(error.domain, XZDataDigesterErrorDomain, @"%@:%lu 错误域不符", file, (unsigned long)line);
    XCTAssertEqual(error.code, code, @"%@:%lu 错误码不符", file, (unsigned long)line);
}
// 宏形参名不能与宏体内 selector 片段（assertError:/code:/file:/line:）同名，否则预处理器会替换 selector 片段
#define AssertDigesterError(_err_, _code_) [self assertError:(_err_) code:(_code_) file:[NSString stringWithUTF8String:__FILE__] line:__LINE__]

/// 各算法对 "abc" 的期望摘要（小写十六进制）。
- (NSDictionary<NSNumber *, NSString *> *)expectedHexForABC {
    return @{
        @(XZDataDigesterAlgorithmMD2):    @"da853b0d3f88d99b30283a69e6ded6bb",
        @(XZDataDigesterAlgorithmMD4):    @"a448017aaf21d8525fc10ae87aa6729d",
        @(XZDataDigesterAlgorithmMD5):    @"900150983cd24fb0d6963f7d28e17f72",
        @(XZDataDigesterAlgorithmSHA1):   @"a9993e364706816aba3e25717850c26c9cd0d89d",
        @(XZDataDigesterAlgorithmSHA224): @"23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7",
        @(XZDataDigesterAlgorithmSHA256): @"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
        @(XZDataDigesterAlgorithmSHA384): @"cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7",
        @(XZDataDigesterAlgorithmSHA512): @"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f",
    };
}

/// 各算法的摘要字节长度。
- (NSDictionary<NSNumber *, NSNumber *> *)digestLengths {
    return @{
        @(XZDataDigesterAlgorithmMD2):    @16,
        @(XZDataDigesterAlgorithmMD4):    @16,
        @(XZDataDigesterAlgorithmMD5):    @16,
        @(XZDataDigesterAlgorithmSHA1):   @20,
        @(XZDataDigesterAlgorithmSHA224): @28,
        @(XZDataDigesterAlgorithmSHA256): @32,
        @(XZDataDigesterAlgorithmSHA384): @48,
        @(XZDataDigesterAlgorithmSHA512): @64,
    };
}

#pragma mark - 一次性摘要

- (void)testOneTimeDigestKnownVectors {
    NSData *abc = [self abcData];
    [[self expectedHexForABC] enumerateKeysAndObjectsUsingBlock:^(NSNumber *algorithm, NSString *expected, BOOL *stop) {
        NSData *digest = [XZDataDigester digest:abc algorithm:algorithm.integerValue error:NULL];
        XCTAssertEqual(digest.length, self.digestLengths[algorithm].unsignedIntegerValue,
                       @"算法 %@ 的摘要长度不符", algorithm);
        XCTAssertEqualObjects([digest xz_hexEncodedString:XZLowercaseHexEncoding], expected,
                              @"算法 %@ 对 \"abc\" 的摘要与已知向量不符", algorithm);
    }];
}

- (void)testOneTimeDigestOfEmptyData {
    NSData *empty = [NSData data];
    XCTAssertEqualObjects([[XZDataDigester digest:empty algorithm:XZDataDigesterAlgorithmMD5 error:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"d41d8cd98f00b204e9800998ecf8427e");
    XCTAssertEqualObjects([[XZDataDigester digest:empty algorithm:XZDataDigesterAlgorithmMD4 error:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"31d6cfe0d16ae931b73c59d7e0c089c0");
    XCTAssertEqualObjects([[XZDataDigester digest:empty algorithm:XZDataDigesterAlgorithmSHA1 error:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"da39a3ee5e6b4b0d3255bfef95601890afd80709");
    XCTAssertEqualObjects([[XZDataDigester digest:empty algorithm:XZDataDigesterAlgorithmSHA256 error:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
}

- (void)testHexEncodingCase {
    NSData *abc = [self abcData];
    NSString *lower = [XZDataDigester digest:abc algorithm:XZDataDigesterAlgorithmSHA256 hexEncoding:XZLowercaseHexEncoding error:NULL];
    NSString *upper = [XZDataDigester digest:abc algorithm:XZDataDigesterAlgorithmSHA256 hexEncoding:XZUppercaseHexEncoding error:NULL];
    XCTAssertEqualObjects(lower, @"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    XCTAssertEqualObjects(upper, lower.uppercaseString);
}

#pragma mark - 非法算法（问题 2 回归）

- (void)testUnknownAlgorithmFailsOnAllPaths {
    NSData *abc = [self abcData];
    NSArray<NSNumber *> *invalids = @[@(XZDataDigesterAlgorithmUnknown), @(-1), @99];
    for (NSNumber *algorithm in invalids) {
        // 一次性接口此前会调用空函数指针直接段错误，现应返回可诊断错误而非 nil 且无错误信息
        NSError *error = nil;
        XCTAssertNil([XZDataDigester digest:abc algorithm:algorithm.integerValue error:&error],
                     @"digest:algorithm: 未对非法算法 %@ 失败", algorithm);
        AssertDigesterError(error, EINVAL);

        error = nil;
        XCTAssertNil([XZDataDigester digest:abc algorithm:algorithm.integerValue hexEncoding:XZLowercaseHexEncoding error:&error],
                     @"digest:algorithm:hexEncoding: 未对非法算法 %@ 失败", algorithm);
        AssertDigesterError(error, EINVAL);

        // 流式接口与一次性接口策略必须一致
        error = nil;
        XCTAssertNil([XZDataDigester digesterWithAlgorithm:algorithm.integerValue error:&error],
                     @"digesterWithAlgorithm: 未对非法算法 %@ 失败", algorithm);
        AssertDigesterError(error, EINVAL);
    }
}

#pragma mark - 流式摘要

- (void)testFactoryAndProperties {
    for (NSNumber *algorithm in self.digestLengths.allKeys) {
        XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:algorithm.integerValue error:NULL];
        XCTAssertNotNil(digester);
        XCTAssertEqual(digester.algorithm, algorithm.integerValue, @"algorithm 属性与构造参数不符");
        XCTAssertEqual(digester.length, self.digestLengths[algorithm].unsignedIntegerValue, @"length 属性不符");
    }
}

- (void)testStreamingMultiPartsEqualsOneTime {
    // 分段喂入 "a"、"b"、"c" 的结果必须与一次性摘要 "abc" 完全一致（全部 8 种算法）
    NSData *abc = [self abcData];
    [[self expectedHexForABC] enumerateKeysAndObjectsUsingBlock:^(NSNumber *algorithm, NSString *expected, BOOL *stop) {
        XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:algorithm.integerValue error:NULL];
        [digester digestString:@"a" error:NULL];
        [digester digestData:[@"b" dataUsingEncoding:NSUTF8StringEncoding] error:NULL];
        const char bytes[] = "c";
        [digester digestBytes:bytes length:1 error:NULL];
        XCTAssertEqualObjects([[digester final:NULL] xz_hexEncodedString:XZLowercaseHexEncoding], expected,
                              @"流式 %@ 与已知向量不符", algorithm);
        XCTAssertEqualObjects([[XZDataDigester digest:abc algorithm:algorithm.integerValue error:NULL] xz_hexEncodedString:XZLowercaseHexEncoding], expected,
                              @"一次性 %@ 与已知向量不符", algorithm);
    }];
}

- (void)testZeroLengthFeedIsNoOp {
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmMD5 error:NULL];
    const char dummy = 'x';
    [digester digestBytes:&dummy length:0 error:NULL];
    [digester digestData:[self abcData] error:NULL];
    [digester digestBytes:"" length:0 error:NULL];
    XCTAssertEqualObjects([[digester final:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"900150983cd24fb0d6963f7d28e17f72");
}

- (void)testDigestStringEncoding {
    // 指定编码喂入的结果，必须与一次性摘要对应编码字节的结果一致
    NSString *string = @"XZKit 摘要";
    NSData *utf16 = [string dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmSHA256 error:NULL];
    [digester digestString:string encoding:NSUTF16LittleEndianStringEncoding error:NULL];
    XCTAssertEqualObjects([digester final:NULL], [XZDataDigester digest:utf16 algorithm:XZDataDigesterAlgorithmSHA256 error:NULL]);
}

- (void)testRepeatFinalReturnsSameDigest {
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmSHA1 error:NULL];
    [digester digestString:@"abc" error:NULL];
    NSData *first = [digester final:NULL];
    XCTAssertEqualObjects(first, [digester final:NULL], @"重复 -final 应返回同一份摘要");
    XCTAssertEqualObjects(first, [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmSHA1 error:NULL]);
}

#pragma mark - reset 语义（问题 1/3 回归）

- (void)testResetDuringDigestDiscardsFedData {
    // 摘要过程中 reset 必须丢弃已喂入的数据（此前 reset 是空操作，会静默产出错误摘要）
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmMD5 error:NULL];
    [digester digestString:@"123" error:NULL];
    [digester reset:NULL];
    XCTAssertEqualObjects([[digester final:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"d41d8cd98f00b204e9800998ecf8427e", @"中途 reset 后应得到空数据的摘要");
}

- (void)testResetAfterFinalStartsNewDigest {
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmMD5 error:NULL];
    [digester digestString:@"abc" error:NULL];
    XCTAssertEqualObjects([digester final:NULL], [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmMD5 error:NULL]);

    [digester reset:NULL];
    [digester digestString:@"123" error:NULL];
    XCTAssertEqualObjects([[digester final:NULL] xz_hexEncodedString:XZLowercaseHexEncoding],
                          @"202cb962ac59075b964b07152d234b70", @"reset 后应开始新的摘要计算");
}

- (void)testFeedAfterFinalFails {
    // Release（NS_BLOCK_ASSERTIONS）下也必须失败：此前数据会被无声丢弃并污染下一次摘要
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmSHA256 error:NULL];
    [digester digestString:@"abc" error:NULL];
    NSData *digest = [digester final:NULL];

    NSData *extra = [@"more" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    XCTAssertFalse([digester digestData:extra error:&error], @"-final 后 digestData: 应失败");
    AssertDigesterError(error, ENOTSUP);

    error = nil;
    XCTAssertFalse([digester digestString:@"more" error:&error], @"-final 后 digestString: 应失败");
    AssertDigesterError(error, ENOTSUP);

    error = nil;
    XCTAssertFalse([digester digestString:@"more" encoding:NSUTF8StringEncoding error:&error], @"-final 后 digestString:encoding: 应失败");
    AssertDigesterError(error, ENOTSUP);

    error = nil;
    XCTAssertFalse([digester digestBytes:extra.bytes length:extra.length error:&error], @"-final 后 digestBytes:length: 应失败");
    AssertDigesterError(error, ENOTSUP);

    // 陈旧摘要不能被破坏，重复 -final 返回同一份结果
    XCTAssertEqualObjects([digester final:NULL], digest);
    XCTAssertEqualObjects(digest, [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmSHA256 error:NULL]);

    // reset 后恢复正常
    [digester reset:NULL];
    [digester digestString:@"abc" error:NULL];
    XCTAssertEqualObjects([digester final:NULL], [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmSHA256 error:NULL]);
}

#pragma mark - 字符串编码失败（问题 6 回归）

- (void)testUnconvertibleStringEncodingFails {
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmMD5 error:NULL];
    NSError *error = nil;
    XCTAssertFalse([digester digestString:@"中文" encoding:NSASCIIStringEncoding error:&error],
                   @"无法转换编码时应失败而非静默跳过");
    AssertDigesterError(error, EINVAL);

    // 失败后实例仍可用，未被破坏
    [digester reset:NULL];
    [digester digestString:@"abc" error:NULL];
    XCTAssertEqualObjects([digester final:NULL], [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmMD5 error:NULL]);
}

- (void)testNilAndNullArgumentFail {
    // nil Data / NULL bytes 搭配非 0 长度必须被拒绝，不能交给 CommonCrypto
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmMD5 error:NULL];
    NSData *nilData = nil; // 经变量传 nil，避免 nonnull 字面量告警
    NSError *error = nil;
    XCTAssertFalse([digester digestData:nilData error:&error], @"digestData: 应拒绝 nil");
    AssertDigesterError(error, EINVAL);

    error = nil;
    const void *nullBytes = NULL; // 同上，经变量传 NULL
    XCTAssertFalse([digester digestBytes:nullBytes length:1 error:&error], @"digestBytes:length: 应拒绝 NULL + 非 0 长度");
    AssertDigesterError(error, EINVAL);

    // NULL + 0 长度是合法的空数据喂入
    XCTAssertTrue([digester digestBytes:nullBytes length:0 error:NULL]);
    [digester digestString:@"abc" error:NULL];
    XCTAssertEqualObjects([digester final:NULL], [XZDataDigester digest:[self abcData] algorithm:XZDataDigesterAlgorithmMD5 error:NULL]);
}

- (void)testUTF8ConvenienceHandlesNonASCII {
    // UTF-8 便捷方法对含 emoji 的字符串永不失败
    NSString *string = @"摘要 🔑 ✅";
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmSHA256 error:NULL];
    [digester digestString:string error:NULL];
    XCTAssertEqualObjects([digester final:NULL],
                          [XZDataDigester digest:[string dataUsingEncoding:NSUTF8StringEncoding] algorithm:XZDataDigesterAlgorithmSHA256 error:NULL]);
}

#pragma mark - 大数据一致性

- (void)testLargeDataStreamingEqualsOneTime {
    NSString *base = @"0123456789abcdef";
    NSData *chunk = [[base stringByPaddingToLength:64 * 1024 withString:base startingAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *large = [NSMutableData dataWithCapacity:chunk.length * 64];
    for (NSUInteger i = 0; i < 64; i++) {
        [large appendData:chunk];
    }
    XZDataDigester *digester = [XZDataDigester digesterWithAlgorithm:XZDataDigesterAlgorithmSHA512 error:NULL];
    NSUInteger location = 0, step = 100 * 1024;
    while (location < large.length) {
        NSUInteger length = MIN(step, large.length - location);
        [digester digestBytes:(const char *)large.bytes + location length:length error:NULL];
        location += length;
    }
    XCTAssertEqualObjects([digester final:NULL],
                          [XZDataDigester digest:large algorithm:XZDataDigesterAlgorithmSHA512 error:NULL],
                          @"分块流式与一次性摘要对大数据结果不一致");
}

#pragma mark - NSData 类目

- (void)testNSDataCategory {
    NSData *abc = [self abcData];
    XCTAssertEqualObjects(abc.xz_md5,    @"900150983cd24fb0d6963f7d28e17f72");
    XCTAssertEqualObjects(abc.xz_MD5,    @"900150983CD24FB0D6963F7D28E17F72");
    XCTAssertEqualObjects(abc.xz_sha1,   @"a9993e364706816aba3e25717850c26c9cd0d89d");
    XCTAssertEqualObjects(abc.xz_SHA1,   @"A9993E364706816ABA3E25717850C26C9CD0D89D");
    XCTAssertEqualObjects(abc.xz_sha256, @"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    XCTAssertEqualObjects(abc.xz_SHA256, @"BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD");
    XCTAssertEqualObjects(abc.xz_sha512, @"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f");
    XCTAssertEqualObjects(abc.xz_SHA512, abc.xz_sha512.uppercaseString);
}

#pragma mark - NSString 类目

- (void)testNSStringCategory {
    NSString *string = @"abc";
    NSData *abc = [self abcData];
    XCTAssertEqualObjects(string.xz_md5,    abc.xz_md5);
    XCTAssertEqualObjects(string.xz_MD5,    abc.xz_MD5);
    XCTAssertEqualObjects(string.xz_sha1,   abc.xz_sha1);
    XCTAssertEqualObjects(string.xz_SHA1,   abc.xz_SHA1);
    XCTAssertEqualObjects(string.xz_sha256, abc.xz_sha256);
    XCTAssertEqualObjects(string.xz_SHA256, abc.xz_SHA256);
    XCTAssertEqualObjects(string.xz_sha512, abc.xz_sha512);
    XCTAssertEqualObjects(string.xz_SHA512, abc.xz_SHA512);
    // 中文与 emoji 在 UTF-8 下均合法
    XCTAssertNotNil(@"摘要🔑".xz_md5);
}

@end
