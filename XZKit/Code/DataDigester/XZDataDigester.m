//
//  XZDataDigester.m
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "XZDataDigester.h"
#import <CommonCrypto/CommonDigest.h>
#import "XZKit+HexadecimalEncoding.h"

/// 在 CommonDigest.h 头文件中，消息摘要是通过 init、update、final 三个过程函数以及 context 结构体实现的。
/// 以下三个函数类型，分别代表这三种通用的操作，通过 DataDigesterContextCreate() 函数关联实际的操作函数。

/// 初始化 context 的函数。
typedef void (*_XZDataDigesterOperationInit)(void * _Nonnull);
/// 添加要进行摘要的消息。
typedef void (*_XZDataDigesterOperationUpdate)(void * _Nonnull, const void * _Nonnull, CC_LONG);
/// 结束摘要计算，并输出结果。
typedef void (*_XZDataDigesterOperationFinal)(unsigned char * _Nonnull, void * _Nonnull);
/// 这是一个快速计算消息摘要的方法。
typedef void (*_XZDataDigesterOperator)(const void * _Nonnull, CC_LONG, unsigned char * _Nonnull);


/// 这个结构体封装了加密所需的“上下文”，其设计模仿的是 CG、CF 框架的接口形式，封装了操作和基本属性。
struct __XZDataDigesterContext {
    void *context; // 上面三个操作的上下文
    _XZDataDigesterOperationInit init;
    _XZDataDigesterOperationUpdate update;
    _XZDataDigesterOperationFinal final;
    CC_LONG length; // 摘要长度
    XZDataDigesterAlgorithm algorithm; // 算法
    bool isReady; // 如果为 false 需要调用 init 方法。
};
typedef struct __XZDataDigesterContext *_XZDataDigesterContext;

/// 创建消息摘要计算器，_XZDigesterContext 是一个指针。
/// @note 必须调用 DataDigesterContextRelease 释放。
static _XZDataDigesterContext _XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm);
/// 释放摘要器。
static void _XZDataDigesterContextRelease(_XZDataDigesterContext __nonnull context);
/// 使用便利函数直接进行摘要。
static void *_XZDataDigesterExecuteWithBlock(NSData * _Nonnull data, XZDataDigesterAlgorithm algorithm, void *(^ _Nonnull block)(const unsigned char *buffer, CC_LONG length));


@interface XZDataDigester () {
    _XZDataDigesterContext _context;
}

@end

@implementation XZDataDigester

+ (NSData *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm {
    return (__bridge_transfer NSData *)_XZDataDigesterExecuteWithBlock(data, algorithm, ^(const unsigned char *buffer, CC_LONG length) {
        return (__bridge_retained void *)[NSData dataWithBytes:buffer length:length];
    });
}

+ (NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexadecimalEncoding:(XZCharacterCase)characterCase {
    return (__bridge_transfer NSString *)_XZDataDigesterExecuteWithBlock(data, algorithm, ^(const unsigned char *buffer, CC_LONG length) {
        return (__bridge_retained void *)[NSString xz_hexadecimalEncodedStringWithBytes:buffer length:length characterCase:characterCase];
    });
}

- (void)dealloc {
    if (_context != NULL) {
        _XZDataDigesterContextRelease(_context);
        _context = NULL;
    }
}

+ (XZDataDigester *)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm {
    return [[self alloc] initWithAlgorithm:algorithm];
}

- (instancetype)initWithAlgorithm:(XZDataDigesterAlgorithm)algorithm {
    self = [super init];
    if (self) {
        _algorithm = algorithm;
    }
    return self;
}

- (void)digest:(NSData *)data {
    if (_context == NULL) {
        _context = _XZDataDigesterContextCreate(_algorithm);
    } else if (!_context->isReady) {
        _context->init(_context->context);
        _context->isReady = true;
    }
    _context->update(_context->context, data.bytes, (CC_LONG)data.length);
}

- (id)finishByUsingBlock:(id  _Nullable (^)(const unsigned char * _Nonnull, NSUInteger))block {
    if (_context == NULL) {
        return nil;
    }
    unsigned char *buffer = calloc(_context->length, sizeof(unsigned char)); // 开辟存放加密结果的内存
    _context->final(buffer, _context->context);
    id result = block(buffer, (NSUInteger)(_context->length));
    free(buffer);
    _context->isReady = false;
    return result;
}

- (NSData *)data {
    return [self finishByUsingBlock:^id _Nullable(const unsigned char * _Nonnull output, NSUInteger length) {
        return [NSData dataWithBytes:output length:length];
    }];
}

- (NSString *)hexadecimalEncodedString:(XZCharacterCase)characterCase {
    return [self finishByUsingBlock:^id _Nullable(const unsigned char * _Nonnull output, NSUInteger length) {
        return [NSString xz_hexadecimalEncodedStringWithBytes:output length:length characterCase:characterCase];
    }];
}

@end


_XZDataDigesterContext _XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm) {
    _XZDataDigesterContext context = calloc(1, sizeof(struct __XZDataDigesterContext));
    switch (algorithm) {
        case XZDataDigesterAlgorithmMD2:
            context->init    = (_XZDataDigesterOperationInit)CC_MD2_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_MD2_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_MD2_Final;
            context->context = calloc(1, sizeof(CC_MD2_CTX));
            context->length  = CC_MD2_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD4:
            context->init    = (_XZDataDigesterOperationInit)CC_MD4_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_MD4_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_MD4_Final;
            context->context = calloc(1, sizeof(CC_MD4_CTX));
            context->length  = CC_MD4_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD5:
            context->init    = (_XZDataDigesterOperationInit)CC_MD5_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_MD5_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_MD5_Final;
            context->context = calloc(1, sizeof(CC_MD5_CTX));
            context->length  = CC_MD5_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA1:
            context->init    = (_XZDataDigesterOperationInit)CC_SHA1_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_SHA1_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_SHA1_Final;
            context->context = calloc(1, sizeof(CC_SHA1_CTX));
            context->length  = CC_SHA1_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA224:
            context->init    = (_XZDataDigesterOperationInit)CC_SHA224_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_SHA224_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_SHA224_Final;
            context->context = calloc(1, sizeof(CC_SHA256_CTX));
            context->length  = CC_SHA224_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA256:
            context->init    = (_XZDataDigesterOperationInit)CC_SHA256_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_SHA256_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_SHA256_Final;
            context->context = calloc(1, sizeof(CC_SHA256_CTX));
            context->length  = CC_SHA256_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA384:
            context->init    = (_XZDataDigesterOperationInit)CC_SHA384_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_SHA384_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_SHA384_Final;
            context->context = calloc(1, sizeof(CC_SHA512_CTX));
            context->length  = CC_SHA384_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA512:
            context->init    = (_XZDataDigesterOperationInit)CC_SHA512_Init;
            context->update  = (_XZDataDigesterOperationUpdate)CC_SHA512_Update;
            context->final   = (_XZDataDigesterOperationFinal)CC_SHA512_Final;
            context->context = calloc(1, sizeof(CC_SHA512_CTX));
            context->length  = CC_SHA512_DIGEST_LENGTH;
            break;
    }
    context->init(context->context);
    context->isReady = true;
    context->algorithm = algorithm;
    return context;
}

void _XZDataDigesterContextRelease(_XZDataDigesterContext __nonnull context) {
    free(context->context);  // 释放 CC_XX_CTX
    free(context);
}

void *_XZDataDigesterExecuteWithBlock(NSData *data, XZDataDigesterAlgorithm algorithm, void *(^block)(const unsigned char *buffer, CC_LONG length)) {
    _XZDataDigesterOperator operator = NULL;
    CC_LONG length = 0;
    switch (algorithm) {
        case XZDataDigesterAlgorithmMD2:
            operator = (_XZDataDigesterOperator)CC_MD2;
            length  = CC_MD2_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD4:
            operator = (_XZDataDigesterOperator)CC_MD4;
            length  = CC_MD4_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmMD5:
            operator = (_XZDataDigesterOperator)CC_MD5;
            length  = CC_MD5_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA1:
            operator = (_XZDataDigesterOperator)CC_SHA1;
            length  = CC_SHA1_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA224:
            operator = (_XZDataDigesterOperator)CC_SHA224;
            length  = CC_SHA224_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA256:
            operator = (_XZDataDigesterOperator)CC_SHA256;
            length  = CC_SHA256_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA384:
            operator = (_XZDataDigesterOperator)CC_SHA384;
            length  = CC_SHA384_DIGEST_LENGTH;
            break;
        case XZDataDigesterAlgorithmSHA512:
            operator = (_XZDataDigesterOperator)CC_SHA512;
            length  = CC_SHA512_DIGEST_LENGTH;
            break;
    }
    
    unsigned char *buffer = calloc(length, sizeof(unsigned char));
    operator(data.bytes, (CC_LONG)data.length, buffer);          
    void * const result = block(buffer, length);
    free(buffer);
    
    return result;
}

