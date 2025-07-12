//
//  XZDataDigester.m
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "XZDefer.h"
#import "XZDataDigester.h"

/// 在 CommonDigest.h 头文件中，消息摘要是通过 init、update、final 三个过程函数以及 context 结构体实现的。
/// 以下三个函数类型，分别代表这三种通用的操作，通过 DataDigesterContextCreate() 函数关联实际的操作函数。

/// 初始化 context 的函数。
typedef void (*XZDataDigesterOperationInit)(void * _Nonnull);
/// 添加要进行摘要的消息。
typedef void (*XZDataDigesterOperationUpdate)(void * _Nonnull, const void * _Nonnull, CC_LONG);
/// 结束摘要计算，并输出结果。
typedef void (*XZDataDigesterOperationFinal)(unsigned char * _Nonnull, void * _Nonnull);
/// 这是一个快速计算消息摘要的方法。
typedef void (*XZDataDigesterOperator)(const void * _Nonnull, CC_LONG, unsigned char * _Nonnull);


/// 这个结构体封装了加密所需的“上下文”，其设计模仿的是 CG、CF 框架的接口形式，封装了操作和基本属性。
typedef struct {
    void *context; // 上面三个操作的上下文
    XZDataDigesterOperationInit init;
    XZDataDigesterOperationUpdate update;
    XZDataDigesterOperationFinal final;
    CC_LONG length; // 摘要长度
    XZDataDigesterAlgorithm algorithm; // 算法
    BOOL isReady; // 默认 YES 如果为 NO 需要调用 init 方法。
    void *buffer; // 存放结果
} XZDataDigesterContext;

NS_ASSUME_NONNULL_BEGIN
static XZDataDigesterContext XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm);
static void                  XZDataDigesterContextRelease(XZDataDigesterContext context);
static void *                XZDataDigesterExecuteWithBlock(NSData * data,
                                                            XZDataDigesterAlgorithm algorithm,
                                                            void *(^block)(const unsigned char *buffer, CC_LONG length));
NS_ASSUME_NONNULL_END

@interface XZDataDigester () {
    XZDataDigesterContext _context;
}

@end

@implementation XZDataDigester

+ (NSData *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm {
    return (__bridge_transfer NSData *)XZDataDigesterExecuteWithBlock(data, algorithm, ^(const unsigned char *buffer, CC_LONG length) {
        return (__bridge_retained void *)[NSData dataWithBytes:buffer length:length];
    });
}

+ (NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexEncoding:(XZHexEncoding)hexEncoding {
    return (__bridge_transfer NSString *)XZDataDigesterExecuteWithBlock(data, algorithm, ^(const unsigned char *buffer, CC_LONG length) {
        return (__bridge_retained void *)[[[NSData alloc] initWithBytes:buffer length:length] xz_hexEncodedString:hexEncoding];
    });
}

- (void)dealloc {
    XZDataDigesterContextRelease(_context);
}

+ (XZDataDigester *)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm {
    return [[self alloc] initWithAlgorithm:algorithm];
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (instancetype)initWithAlgorithm:(XZDataDigesterAlgorithm)algorithm {
    self = [super init];
    if (self) {
        _context = XZDataDigesterContextCreate(algorithm);
    }
    return self;
}

- (XZDataDigesterAlgorithm)algorithm {
    return _context.algorithm;
}

- (NSUInteger)length {
    return _context.length;
}

- (void)addBytes:(const void *)bytes length:(NSUInteger)length {
    if (!_context.isReady) {
        _context.init(_context.context);
        _context.isReady = YES;
    }
    _context.update(_context.context, bytes, (CC_LONG)length);
}

- (void)addData:(NSData *)data {
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        [self addBytes:bytes length:byteRange.length];
    }];
}

- (void)addString:(NSString *)string encoding:(NSStringEncoding)encoding {
    NSData *data = [string dataUsingEncoding:encoding];
    if (data == nil) {
        return;
    }
    [self addData:data];
}

- (void)addString:(NSString *)string {
    [self addString:string encoding:NSUTF8StringEncoding];
}

- (NSData *)digest {
    if (_context.isReady) {
        _context.final(_context.buffer, _context.context);
        _context.isReady = NO;
    }
    return [NSData dataWithBytes:_context.buffer length:_context.length];
}

@end


XZDataDigesterContext XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm) {
    XZDataDigesterContext context;
    switch (algorithm) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case XZDataDigesterAlgorithmMD2:
            context.init    = (XZDataDigesterOperationInit)CC_MD2_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_MD2_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_MD2_Final;
            context.context = calloc(1, sizeof(CC_MD2_CTX));
            context.length  = CC_MD2_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD4:
            context.init    = (XZDataDigesterOperationInit)CC_MD4_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_MD4_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_MD4_Final;
            context.context = calloc(1, sizeof(CC_MD4_CTX));
            context.length  = CC_MD4_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD5:
            context.init    = (XZDataDigesterOperationInit)CC_MD5_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_MD5_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_MD5_Final;
            context.context = calloc(1, sizeof(CC_MD5_CTX));
            context.length  = CC_MD5_DIGEST_LENGTH;
            break;
#pragma clang diagnostic pop
        case XZDataDigesterAlgorithmSHA1:
            context.init    = (XZDataDigesterOperationInit)CC_SHA1_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_SHA1_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_SHA1_Final;
            context.context = calloc(1, sizeof(CC_SHA1_CTX));
            context.length  = CC_SHA1_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA224:
            context.init    = (XZDataDigesterOperationInit)CC_SHA224_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_SHA224_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_SHA224_Final;
            context.context = calloc(1, sizeof(CC_SHA256_CTX));
            context.length  = CC_SHA224_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA256:
            context.init    = (XZDataDigesterOperationInit)CC_SHA256_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_SHA256_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_SHA256_Final;
            context.context = calloc(1, sizeof(CC_SHA256_CTX));
            context.length  = CC_SHA256_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA384:
            context.init    = (XZDataDigesterOperationInit)CC_SHA384_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_SHA384_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_SHA384_Final;
            context.context = calloc(1, sizeof(CC_SHA512_CTX));
            context.length  = CC_SHA384_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA512:
#if !DEBUG
        default:
#endif
            context.init    = (XZDataDigesterOperationInit)CC_SHA512_Init;
            context.update  = (XZDataDigesterOperationUpdate)CC_SHA512_Update;
            context.final   = (XZDataDigesterOperationFinal)CC_SHA512_Final;
            context.context = calloc(1, sizeof(CC_SHA512_CTX));
            context.length  = CC_SHA512_DIGEST_LENGTH;
            break;
#if DEBUG
        default: {
            NSString * const reason = @"暂不支持除 XZDataDigesterAlgorithm 枚举定义之外的摘要算法";
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
            break;
        }
#endif
    }
    context.init(context.context);
    context.isReady     = YES;
    context.algorithm   = algorithm;
    context.buffer      = calloc(context.length, sizeof(unsigned char));
    return context;
}

void XZDataDigesterContextRelease(XZDataDigesterContext context) {
    free(context.buffer);
    free(context.context);  // 释放 CC_XX_CTX
}

void *XZDataDigesterExecuteWithBlock(NSData *data, XZDataDigesterAlgorithm algorithm, void *(^block)(const unsigned char *buffer, CC_LONG length)) {
    XZDataDigesterOperator operator = NULL;
    CC_LONG length = 0;
    switch (algorithm) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case XZDataDigesterAlgorithmMD2:
            operator = (XZDataDigesterOperator)CC_MD2;
            length  = CC_MD2_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD4:
            operator = (XZDataDigesterOperator)CC_MD4;
            length  = CC_MD4_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD5:
            operator = (XZDataDigesterOperator)CC_MD5;
            length  = CC_MD5_DIGEST_LENGTH;
            break;
#pragma clang diagnostic pop
        case XZDataDigesterAlgorithmSHA1:
            operator = (XZDataDigesterOperator)CC_SHA1;
            length  = CC_SHA1_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA224:
            operator = (XZDataDigesterOperator)CC_SHA224;
            length  = CC_SHA224_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA256:
            operator = (XZDataDigesterOperator)CC_SHA256;
            length  = CC_SHA256_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA384:
            operator = (XZDataDigesterOperator)CC_SHA384;
            length  = CC_SHA384_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA512:
            operator = (XZDataDigesterOperator)CC_SHA512;
            length  = CC_SHA512_DIGEST_LENGTH;
            break;
    }
    
    void *buffer = calloc(length, sizeof(unsigned char));
    defer(^{
        free(buffer);
    });
    
    operator(data.bytes, (CC_LONG)data.length, buffer);
    
    return block(buffer, length);
}

