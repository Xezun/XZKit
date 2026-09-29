//
//  XZDataCryptorTests.m
//  ExampleTests
//
//  Created by Xezun on 2026/9/28.
//

#import <XCTest/XCTest.h>
@import XZKit;
@import CommonCrypto;

/// XZDataCryptorAlgorithm 的设计目标是：任何输入都产出合法的密钥与初始化向量，
/// 使 XZDataCryptor 不会因密钥/向量问题而构造失败。本文件即围绕这一目标进行验证。
@interface XZDataCryptorTests : XCTestCase
@end

@implementation XZDataCryptorTests

- (void)testAES {
    NSData *key = [NSData xz_dataWithHexEncodedString:@"4f865d7517c459ee4a3bb759578bcdc2"];
    NSData *vector = [NSData xz_dataWithHexEncodedString:@"92d69c89d89c146a1a4b2a8a7f8561c5"];
    NSLog(@"key => %@, vector => %@", key, vector);
    
    NSData *data = [@"AES" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSData *endata = [XZDataCryptor AES:data operation:(XZDataCryptorOperationEncrypt) key:key vector:vector error:&error];
    
    NSString *enstr = endata.xz_hexEncodedString;
    NSLog(@"AES: %@", enstr);
    XCTAssertTrue([enstr isEqualToString:@"81aba785d7e15a5ca1c1f027e2f9ad92"]);
}

#pragma mark - 密钥与向量的规范化

- (void)testKeyAndVectorAreAlwaysCanonical {
    // 任意密钥都规范化为 AES 要求的 16/24/32 字节
    NSDictionary<NSString *, NSNumber *> *cases = @{
        @"": @16,                        // 空密钥 -> 全 \0 的 AES128 密钥
        @"1": @16,                       // 短密钥 -> 补 \0 到 16 字节
        @"123": @16,
        @"123456789012345": @16,         // 15 字节 -> 补到 16
        @"1234567890123456": @16,        // 恰好 16
        @"12345678901234567": @24,       // 17 字节 -> 就近取大的 AES192
        @"0123456789abcdefg": @24,
        @"0123456789abcdef0123456789abcde": @32, // 31 字节 -> AES256
        @"中文密钥": @16,                 // 中文按 UTF-8 字节计算，4 字 12 字节
    };
    for (NSString *key in cases) {
        NSData *datakey = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSData *datavector = [@"iv" dataUsingEncoding:NSUTF8StringEncoding];
        XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:datakey vector:datavector];
        XCTAssertEqual(algorithm.key.length, cases[key].unsignedLongValue, @"key = %@ 规范化后的字节长度", key);
        XCTAssertEqual(algorithm.vector.length, algorithm.blockSize, @"向量长度必须与块大小一致");
        XCTAssertNotNil(algorithm.key, @"key 属性不允许为 nil");
        XCTAssertNotNil(algorithm.vector, @"vector 属性不允许为 nil");
    }
}

- (void)testNilKeyAndVectorAreCanonical {
    XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:nil vector:nil];
    XCTAssertNotNil(algorithm.key);
    XCTAssertNotNil(algorithm.vector);
    XCTAssertEqual(algorithm.key.length, 16);
    XCTAssertEqual(algorithm.vector.length, 16);
    // 全 \0 密钥：UTF-8 字节长度必须是 16，用 strlen 量会在第一个 \0 处截断
    XCTAssertEqualObjects(algorithm.hexEncodedKey, @"00000000000000000000000000000000");
}

- (void)testBase64EncodedKeyAndVector {
    NSData *key = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"fedcba9876543210" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Key = [key base64EncodedStringWithOptions:0];
    NSString *base64Vector = [vector base64EncodedStringWithOptions:0];

    // Base64 工厂与 NSData 工厂必须产出相同的规范化密钥/向量
    XZDataCryptorAlgorithm *fromData = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    XZDataCryptorAlgorithm *fromBase64 = [XZDataCryptorAlgorithm AESAlgorithmWithBase64EncodedKey:base64Key vector:base64Vector];
    XCTAssertEqualObjects(fromData.key, fromBase64.key);
    XCTAssertEqualObjects(fromData.vector, fromBase64.vector);

    // 属性读写往返
    XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:nil vector:nil];
    algorithm.base64EncodedKey = base64Key;
    algorithm.base64EncodedVector = base64Vector;
    XCTAssertEqualObjects(algorithm.key, key, @"base64EncodedKey  setter 应解码并规范化");
    XCTAssertEqualObjects(algorithm.vector, vector, @"base64EncodingVector setter 应解码并规范化");
    XCTAssertEqualObjects(algorithm.base64EncodedKey, base64Key, @"base64EncodedKey getter 应往返一致");

    // 非法 Base64 与 nil 一样降级为全 \0 的合法密钥（延续「任何输入产出合法密钥」的设计）
    XZDataCryptorAlgorithm *invalid = [XZDataCryptorAlgorithm AESAlgorithmWithBase64EncodedKey:@"!!!not base64!!!" vector:nil];
    XCTAssertEqual(invalid.key.length, 16, @"非法 Base64 仍要产出合法长度的密钥");
    XCTAssertEqualObjects(invalid.key, [NSMutableData dataWithLength:16], @"非法 Base64 应补成全 \\0");
}

- (void)testAllAlgorithmsProduceLegalKeyAndVector {
    NSData *key = [@"k" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray<XZDataCryptorAlgorithm *> *algorithms = @[
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
    ];
    for (XZDataCryptorAlgorithm *algorithm in algorithms) {
        XCTAssertGreaterThan(algorithm.key.length, 0, @"%@ 必须有非空密钥", [algorithm description]);
        XCTAssertEqual(algorithm.vector.length, algorithm.blockSize, @"%@ 向量长度必须等于块大小", [algorithm description]);
    }
}

#pragma mark - 构造

- (void)testConstructorsNeverFailForAnyKey {
    NSArray<NSString *> *keys = @[ @"", @"a", @"123", @"中文密钥中文密钥" ];
    for (NSString *key in keys) {
        NSData *datakey = [key dataUsingEncoding:NSUTF8StringEncoding];
        XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:datakey vector:datakey];
        XCTAssertNotNil([XZDataCryptor cryptorWithAlgorithm:algorithm operation:XZDataCryptorOperationEncrypt error:NULL], @"密钥「%@」应能构造加密器", key);
        XCTAssertNotNil([XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:datakey vector:datakey error:NULL], @"AES 便利构造（密钥「%@」）", key);
        XCTAssertNotNil([XZDataCryptor DESCryptor:XZDataCryptorOperationEncrypt key:datakey vector:datakey error:NULL], @"DES 便利构造（密钥「%@」）", key);
    }
    // nil 同样是合法输入
    XCTAssertNotNil([XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:nil vector:nil error:NULL], @"nil 密钥也要能构造加密器");
}

- (void)testModeMatrixConstruction {
    NSData *key = [@"k" dataUsingEncoding:NSUTF8StringEncoding];
    // CommonCrypto 的 kCCModeRC4 只支持 RC4 算法，其他算法使用此模式必须返回 nil 而不是崩溃
    NSArray<XZDataCryptorAlgorithm *> *algorithms = @[
        [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm DESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm tripleDESAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm CASTAlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm RC4AlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm RC2AlgorithmWithKey:key vector:nil],
        [XZDataCryptorAlgorithm BlowfishAlgorithmWithKey:key vector:nil],
    ];
    NSArray<NSNumber *> *modes = @[ @(XZDataCryptorModeECB), @(XZDataCryptorModeCBC), @(XZDataCryptorModeCFB),
                                    @(XZDataCryptorModeCTR), @(XZDataCryptorModeOFB), @(XZDataCryptorModeRC4),
                                    @(XZDataCryptorModeCFB8) ];
    NSArray<NSNumber *> *paddings = @[ @(XZDataCryptorNoPadding), @(XZDataCryptorPKCS7Padding) ];
    for (XZDataCryptorAlgorithm *algorithm in algorithms) {
        for (NSNumber *mode in modes) {
            for (NSNumber *padding in paddings) {
                XZDataCryptor *cryptor = [XZDataCryptor cryptorWithAlgorithm:algorithm
                                                                   operation:XZDataCryptorOperationEncrypt
                                                                        mode:mode.unsignedIntValue
                                                                     padding:padding.unsignedIntValue
                                                                       error:NULL];
                XCTAssertNotNil(cryptor, @"%@ × 模式 %@ × 填充 %@ 构造失败", [algorithm description], mode, padding);
            }
        }
    }
}

#pragma mark - 加解密

- (void)testShortKeyRoundTrip {
    // 旧实现用 strlen 量取密钥长度，会在补齐用的 \0 处截断，短密钥必然报 kCCKeySizeError
    NSArray<NSString *> *keys = @[ @"", @"123", @"中文密钥中文密钥中文密钥" ];
    NSString *plain = @"床前明月光，疑是地上霜。";
    NSData *vectorkey = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    for (NSString *key in keys) {
        NSData *datakey = [key dataUsingEncoding:NSUTF8StringEncoding];
        XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:datakey vector:vectorkey];
        NSError *error = nil;
        NSData *cipher = [XZDataCryptor encrypt:[plain dataUsingEncoding:NSUTF8StringEncoding]
                                      algorithm:algorithm
                                           mode:XZDataCryptorModeCBC
                                        padding:XZDataCryptorPKCS7Padding
                                          error:&error];
        XCTAssertNotNil(cipher, @"密钥「%@」加密失败：%@", key, error);
        NSData *decrypted = [XZDataCryptor decrypt:cipher algorithm:algorithm mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:&error];
        XCTAssertEqualObjects([[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding], plain, @"密钥「%@」解密结果不一致", key);
    }
}

- (void)testChunkedResultEqualsOneShot {
    // 首块可能因未满一块而输出 0 字节，历史上此处存在悬空指针；分块结果必须与一次性加密一致
    NSMutableString *plain = [NSMutableString string];
    for (NSInteger i = 0; i < 200; i++) {
        [plain appendFormat:@"<%zd>", i];
    }
    NSLog(@"plain => %@", plain);
    NSData *data = [plain dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *key = [@"key" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    
    NSData *oneShot = [XZDataCryptor encrypt:data algorithm:algorithm mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    NSLog(@"oneshot => %@", oneShot.xz_hexEncodedString);
    XCTAssertNotNil(oneShot);
    NSLog(@"%@", [[NSString alloc] initWithData:[XZDataCryptor decrypt:oneShot algorithm:algorithm mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:NULL] encoding:NSUTF8StringEncoding]);
    
    XZDataCryptor *cryptor = [XZDataCryptor cryptorWithAlgorithm:algorithm operation:XZDataCryptorOperationEncrypt mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    NSMutableData *chunked = [NSMutableData data];
    for (NSUInteger offset = 0; offset < data.length; offset += 16) {
        NSRange const range = NSMakeRange(offset, MIN((NSUInteger)16, data.length - offset));
        NSLog(@"[%ld, %ld)", range.location, range.location + range.length);
        [chunked appendData:[cryptor cryptBytes:(void *)[data bytes] + range.location length:range.length error:NULL]];
    }
    NSLog(@"final1 => %@", chunked.xz_hexEncodedString);
    [chunked appendData:[cryptor final:NULL]];
    NSLog(@"final2 => %@", chunked.xz_hexEncodedString);
    NSLog(@"%@", [[NSString alloc] initWithData:[XZDataCryptor decrypt:chunked algorithm:algorithm mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:NULL] encoding:NSUTF8StringEncoding]);
    XCTAssertTrue([chunked isEqualToData:oneShot], @"分块加密结果必须与一次性加密一致");
}

- (void)testAlignmentErrorUsesLibraryErrorDomain {
    // NoPadding 下解密非整数块数据必然失败；实测 CommonCrypto 在 -final: 阶段才报 kCCAlignmentError，
    // 因为不足一块的输入会被缓存。失败必须返回 nil 并携带 XZDataCryptorErrorDomain 的错误。
    NSMutableData *cipher = [NSMutableData data];
    for (NSInteger i = 0; i < 31; i++) {
        [cipher appendBytes:"x" length:1];
    }
    
    NSData *key = [@"key" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    
    XZDataCryptor *cryptor = [XZDataCryptor cryptorWithAlgorithm:[XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector]
                                                       operation:XZDataCryptorOperationDecrypt
                                                            mode:XZDataCryptorModeCBC
                                                         padding:XZDataCryptorNoPadding
                                                           error:NULL];
    NSError *error = nil;
    XCTAssertNotNil([cryptor cryptData:cipher error:&error], @"不足一块的输入会被缓存，此时不应报错");
    XCTAssertNil([cryptor final:&error], @"凑不满一块，补齐阶段必须失败");
    XCTAssertEqualObjects(error.domain, XZDataCryptorErrorDomain, @"错误必须使用 XZDataCryptorErrorDomain");
    XCTAssertEqual(error.code, kCCAlignmentError);
}

- (void)testOneShotRejectsUnsupportedModes {
    // CCCrypt 只支持 ECB/CBC/RC4，历史上一次性接口把 CFB/CTR/OFB/CFB8 静默降级成 CBC，
    // 产出的密文与流式接口不一致且对端无法解密，现在必须显式返回 kCCUnimplemented
    NSData *key = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *plain = [@"Guard test data" dataUsingEncoding:NSUTF8StringEncoding];
    XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    NSArray<NSNumber *> *supported = @[ @(XZDataCryptorModeECB), @(XZDataCryptorModeCBC), @(XZDataCryptorModeRC4) ];
    NSArray<NSNumber *> *unsupported = @[ @(XZDataCryptorModeCFB), @(XZDataCryptorModeCTR), @(XZDataCryptorModeOFB), @(XZDataCryptorModeCFB8) ];
    for (NSNumber *mode in supported) {
        NSError *error = nil;
        NSData *cipher = [XZDataCryptor encrypt:plain algorithm:algorithm mode:mode.unsignedIntegerValue padding:XZDataCryptorPKCS7Padding error:&error];
        XCTAssertNotNil(cipher, @"模式 %@ 应受一次性接口支持：%@", mode, error);
        XCTAssertNil(error, @"模式 %@ 加密成功时不应有错误", mode);
    }
    for (NSNumber *mode in unsupported) {
        NSError *error = nil;
        NSData *cipher = [XZDataCryptor encrypt:plain algorithm:algorithm mode:mode.unsignedIntegerValue padding:XZDataCryptorPKCS7Padding error:&error];
        XCTAssertNil(cipher, @"模式 %@ 必须被一次性接口拒绝而不是静默降级", mode);
        XCTAssertEqualObjects(error.domain, XZDataCryptorErrorDomain);
        XCTAssertEqual(error.code, kCCUnimplemented, @"模式 %@ 应返回 kCCUnimplemented", mode);
    }
}

#pragma mark - 重置

- (void)testResetAppliesNewKeyAndVector {
    // CCCryptorReset 不更换密钥，历史上 -resetWithKey:vector: 的新密钥并不生效
    NSData *key = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"fedcba9876543210" dataUsingEncoding:NSUTF8StringEncoding];
    
    XZDataCryptorAlgorithm *oldAlgorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    
    XZDataCryptor *cryptor = [XZDataCryptor cryptorWithAlgorithm:oldAlgorithm operation:XZDataCryptorOperationEncrypt mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    NSString *plain = @"after reset";
    [cryptor resetWithKey:[@"x" dataUsingEncoding:NSUTF8StringEncoding] vector:nil error:NULL];
    
    NSData *cipher = [cryptor cryptData:[plain dataUsingEncoding:NSUTF8StringEncoding] error:NULL];
    NSMutableData *fullCipher = [cipher mutableCopy];
    [fullCipher appendData:[cryptor final:NULL]];
    
    XZDataCryptorAlgorithm *newAlgorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:[@"x" dataUsingEncoding:NSUTF8StringEncoding] vector:nil];
    NSData *decrypted = [XZDataCryptor decrypt:fullCipher algorithm:newAlgorithm mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    XCTAssertEqualObjects([[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding], plain, @"重置后的新密钥必须生效");
    
    NSData *stale = [XZDataCryptor decrypt:fullCipher algorithm:oldAlgorithm mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    XCTAssertNotEqualObjects([[NSString alloc] initWithData:stale encoding:NSUTF8StringEncoding], plain, @"旧密钥不应还能解密");
}

- (void)testResetDoesNotPolluteExternalAlgorithm {
    NSData *key = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector = [@"fedcba9876543210" dataUsingEncoding:NSUTF8StringEncoding];
    
    XZDataCryptorAlgorithm *algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    XZDataCryptor *cryptor = [XZDataCryptor cryptorWithAlgorithm:algorithm operation:XZDataCryptorOperationEncrypt mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    [cryptor resetWithKey:[@"x" dataUsingEncoding:NSUTF8StringEncoding] vector:nil error:NULL];
    XCTAssertEqualObjects(algorithm.key, key, @"外部传入的 algorithm 不应被修改");
    XCTAssertEqualObjects(algorithm.vector, vector);
    XCTAssertEqual(cryptor.algorithm.key.length, 16, @"加密器持有的密钥已规范化");
}

- (void)testResetWithVectorAppliesNewVector {
    // 历史缺陷：_mode 与 kCCModeCBC 直接比较导致 CBC 走不到 CCCryptorReset 快路径、
    // CFB 误入快路径且失败后返回 YES 却残留 error，违反「返回 YES 则无错误」的约定
    NSData *key = [@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector1 = [@"AAAAAAAAAAAAAAAA" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vector2 = [@"BBBBBBBBBBBBBBBB" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray<NSNumber *> *modes = @[ @(XZDataCryptorModeCBC), @(XZDataCryptorModeCFB), @(XZDataCryptorModeCTR), @(XZDataCryptorModeECB) ];
    for (NSNumber *mode in modes) {
        XZDataCryptor *cryptor = [XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:key vector:vector1 mode:mode.unsignedIntegerValue padding:XZDataCryptorPKCS7Padding error:NULL];
        // 先消费掉一块，确保上下文中已有状态被重置
        [cryptor cryptData:[@"0123456789ABCDEF" dataUsingEncoding:NSUTF8StringEncoding] error:NULL];
        NSError *error = nil;
        BOOL ok = [cryptor resetWithVector:vector2 error:&error];
        XCTAssertTrue(ok, @"模式 %@ 重置向量失败", mode);
        XCTAssertNil(error, @"模式 %@ 返回 YES 时不应残留错误", mode);
    }
    // CBC 快路径重置后，新向量必须真实生效：与「新实例用新向量」的密文一致
    // 结构：vec1 完成一整段（crypt+final）→ reset 为 vec2 → vec2 完成另一整段（crypt+final）
    NSData *pre = [@"0123456789ABCDEF" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *rest = [@"TailData12345678" dataUsingEncoding:NSUTF8StringEncoding];
    XZDataCryptor *a = [XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:key vector:vector1 mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    NSMutableData *cipher = [[a cryptData:pre error:NULL] mutableCopy];
    [cipher appendData:[a final:NULL]];
    XCTAssertTrue([a resetWithVector:vector2 error:NULL]);
    [cipher appendData:[a cryptData:rest error:NULL]];
    [cipher appendData:[a final:NULL]];
    
    XZDataCryptor *b1 = [XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:key vector:vector1 mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    XZDataCryptor *b2 = [XZDataCryptor AESCryptor:XZDataCryptorOperationEncrypt key:key vector:vector2 mode:XZDataCryptorModeCBC padding:XZDataCryptorPKCS7Padding error:NULL];
    NSMutableData *expected = [[b1 cryptData:pre error:NULL] mutableCopy];
    [expected appendData:[b1 final:NULL]];
    [expected appendData:[b2 cryptData:rest error:NULL]];
    [expected appendData:[b2 final:NULL]];
    
    XCTAssertEqualObjects(cipher, expected, @"重置后的新向量必须生效");
}

#pragma mark - 值语义

- (void)testIsEqualAndHash {
    XZDataCryptorAlgorithm *a = [XZDataCryptorAlgorithm AESAlgorithmWithKey:[@"123" dataUsingEncoding:NSUTF8StringEncoding] vector:[@"iv" dataUsingEncoding:NSUTF8StringEncoding]];
    XZDataCryptorAlgorithm *b = [XZDataCryptorAlgorithm AESAlgorithmWithKey:[@"123" dataUsingEncoding:NSUTF8StringEncoding] vector:[@"iv" dataUsingEncoding:NSUTF8StringEncoding]];
    XZDataCryptorAlgorithm *c = [XZDataCryptorAlgorithm AESAlgorithmWithKey:[@"456" dataUsingEncoding:NSUTF8StringEncoding] vector:[@"iv" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(a, b);
    XCTAssertEqual(a.hash, b.hash);
    XCTAssertEqualObjects(a, c);
    NSSet *set = [NSSet setWithArray:@[ a, b, c ]];
    XCTAssertEqual(set.count, 1);
}

@end
