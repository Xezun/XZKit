//
//  XZDataDigester.m
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "XZDataDigester.h"

NS_ASSUME_NONNULL_BEGIN

NSErrorDomain const XZDataDigesterErrorDomain = @"XZDataDigesterErrorDomain";

typedef NS_ENUM(NSUInteger, XZDataDigesterErrorCode) {
    /// No error
    XZDataDigesterErrorCodeNoError         = noErr,
    /// Invalid argument，或 CommonCrypto 计算接口报告失败（非法上下文/参数）
    XZDataDigesterErrorCodeInvalidArgument = EINVAL,
    /// Cannot allocate memory
    XZDataDigesterErrorCodeMemory          = ENOMEM,
    /// Operation not supported，如 -final 之后未 -reset 就继续喂入数据
    XZDataDigesterErrorCodeNotSupported    = ENOTSUP
};

/// 在 CommonDigest.h 头文件中，消息摘要是通过 init、update、final 三个过程函数以及各算法专属的 context 结构体实现的。
/// - 以下三个函数类型描述这三种通用操作。
/// - 返回类型保持 int，与 CommonCrypto 的真实原型一致。
/// - CommonDigest 头文件显示三个函数返回值始终为 1 ，本类中判断返回 0 表示失败。
typedef int (*XZDataDigesterInit)(void *);
typedef int (*XZDataDigesterUpdate)(void *, const void *, CC_LONG);
typedef int (*XZDataDigesterFinal)(unsigned char *, void *);
/// 一次性摘要函数的返回类型是 unsigned char *（指向摘要结果缓冲区），必须与真实原型完全一致，
/// 否则经由不兼容函数指针类型调用构成未定义行为。
typedef unsigned char *(*XZDataDigesterExecute)(const void *data, CC_LONG len, unsigned char *md);

/// 把某个算法的三段式操作函数与其上下文尺寸、摘要长度统一关联起来的描述符。
typedef struct {
    XZDataDigesterAlgorithm algorithm;      // 本条目代表的算法
    size_t                  contextSize;    // CC_XXX_CTX 的字节大小
    CC_LONG                 digestLength;   // 摘要长度
    XZDataDigesterInit      init;
    XZDataDigesterUpdate    update;
    XZDataDigesterFinal     final;
    XZDataDigesterExecute   execute;
} XZDataDigesterOperation;

static void XZDataDigesterHandleError(XZDataDigesterErrorCode code, NSString *reason, NSError * _Nullable * _Nullable error);

/// 根据算法查找操作描述符；不受支持（含枚举定义之外）的算法返回 NULL。
static const XZDataDigesterOperation * _Nullable XZDataDigesterOperationForAlgorithm(XZDataDigesterAlgorithm algorithm) {
    /// 算法与操作的唯一数据源：新增算法只需扩展本表，流式与一次性两套 API 会自动共享同一份映射与校验逻辑。
    static const XZDataDigesterOperation kOperations[XZDataDigesterAlgorithmUnknown] = {
        // MD2、MD4、MD5 因安全性问题已被 CommonCrypto 标记为废弃，
        // 此处保留它们仅为兼容历史数据的摘要校验，因此抑制废弃告警。
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        {
            XZDataDigesterAlgorithmMD2,
            sizeof(CC_MD2_CTX),
            CC_MD2_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_MD2_Init,
            (XZDataDigesterUpdate)CC_MD2_Update,
            (XZDataDigesterFinal)CC_MD2_Final,
            (XZDataDigesterExecute)CC_MD2
        },
        {
            XZDataDigesterAlgorithmMD4,
            sizeof(CC_MD4_CTX),
            CC_MD4_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_MD4_Init,
            (XZDataDigesterUpdate)CC_MD4_Update,
            (XZDataDigesterFinal)CC_MD4_Final,
            (XZDataDigesterExecute)CC_MD4
        },
        {
            XZDataDigesterAlgorithmMD5,
            sizeof(CC_MD5_CTX),
            CC_MD5_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_MD5_Init,
            (XZDataDigesterUpdate)CC_MD5_Update,
            (XZDataDigesterFinal)CC_MD5_Final,
            (XZDataDigesterExecute)CC_MD5
        },
    #pragma clang diagnostic pop
        {
            XZDataDigesterAlgorithmSHA1,
            sizeof(CC_SHA1_CTX),   CC_SHA1_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_SHA1_Init,
            (XZDataDigesterUpdate)CC_SHA1_Update,
            (XZDataDigesterFinal)CC_SHA1_Final,
            (XZDataDigesterExecute)CC_SHA1
        },
        {
            XZDataDigesterAlgorithmSHA224,
            sizeof(CC_SHA256_CTX),
            CC_SHA224_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_SHA224_Init,
            (XZDataDigesterUpdate)CC_SHA224_Update,
            (XZDataDigesterFinal)CC_SHA224_Final,
            (XZDataDigesterExecute)CC_SHA224
        },
        {
            XZDataDigesterAlgorithmSHA256,
            sizeof(CC_SHA256_CTX),
            CC_SHA256_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_SHA256_Init,
            (XZDataDigesterUpdate)CC_SHA256_Update,
            (XZDataDigesterFinal)CC_SHA256_Final,
            (XZDataDigesterExecute)CC_SHA256
        },
        {
            XZDataDigesterAlgorithmSHA384,
            sizeof(CC_SHA512_CTX),
            CC_SHA384_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_SHA384_Init,
            (XZDataDigesterUpdate)CC_SHA384_Update,
            (XZDataDigesterFinal)CC_SHA384_Final,
            (XZDataDigesterExecute)CC_SHA384
        },
        {
            XZDataDigesterAlgorithmSHA512,
            sizeof(CC_SHA512_CTX),
            CC_SHA512_DIGEST_LENGTH,
            (XZDataDigesterInit)CC_SHA512_Init,
            (XZDataDigesterUpdate)CC_SHA512_Update,
            (XZDataDigesterFinal)CC_SHA512_Final,
            (XZDataDigesterExecute)CC_SHA512
        },
    };
    if (algorithm >= XZDataDigesterAlgorithmUnknown) {
        return NULL;
    }
    NSCAssert(kOperations[algorithm].algorithm == algorithm, @"发生严重错误 XZDataDigesterAlgorithm 枚举顺序被修改");
    return &kOperations[algorithm];
}

/// 这个结构体封装了摘要所需的“上下文”，其设计模仿的是 CG、CF 框架的接口形式，封装了操作和基本属性。
typedef struct {
    const XZDataDigesterOperation *operation; // 与算法关联的操作描述符
    void *context;                            // CC_XXX_CTX 实例
    XZDataDigesterAlgorithm algorithm;        // 算法
    void *buffer;                             // 存放结果
} XZDataDigesterContext;

static XZDataDigesterContext * _Nullable XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm, NSError * _Nullable * _Nullable error);
static BOOL XZDataDigesterContextRelease(XZDataDigesterContext * _Nullable context);

NS_ASSUME_NONNULL_END

@interface XZDataDigester () {
    // 默认 YES；-final 之后为 NO，需要调用 -reset 方法才能继续喂入数据。
    BOOL _isReady;
    // 缓存 -final 的摘要结果，保证重复调用 -final 返回同一份摘要，
    // 且不依赖“CommonCrypto final 后不清零 context”这一实现细节。
    NSData *_digest;
    XZDataDigesterContext *_context;
}

// 指定初始化器在类扩展中声明，避免公共头文件暴露内部 C 结构体类型。
- (instancetype)initWithContext:(XZDataDigesterContext *)context NS_DESIGNATED_INITIALIZER;

@end

@implementation XZDataDigester

+ (NSData *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    const XZDataDigesterOperation *operation = XZDataDigesterOperationForAlgorithm(algorithm);
    if (operation == NULL) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, [NSString stringWithFormat:@"不支持的数据摘要算法: %ld", (long)algorithm], error);
        return nil;
    }
    // 一次性接口直调 CommonCrypto 单函数，入参长度为 32 位的 CC_LONG，无法表达 >4GiB 的数据；
    // 与 XZDataCryptor 一次性接口一致的能力边界策略：显式报错，禁止静默截断产出错误摘要，
    // 超大数据请改用流式实例接口（其内部已分块喂入）。
    if (data.length > UINT32_MAX) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeNotSupported, @"一次性摘要接口不支持超过 4GiB 的数据，请使用流式的 XZDataDigester 实例接口。", error);
        return nil;
    }

    void *buffer = calloc(operation->digestLength, sizeof(unsigned char));
    if (buffer == NULL) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeMemory, @"内存不足，无法分配摘要计算所需的内存。", error);
        return nil;
    }
    operation->execute(data.bytes, (CC_LONG)data.length, buffer);

    return [[NSData alloc] initWithBytesNoCopy:buffer length:operation->digestLength freeWhenDone:YES];
}

+ (NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexEncoding:(XZHexEncoding)hexEncoding error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [[self digest:data algorithm:algorithm error:error] xz_hexEncodedString:hexEncoding];
}

- (void)dealloc {
    XZDataDigesterContextRelease(_context);
}

+ (instancetype)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    XZDataDigesterContext *context = XZDataDigesterContextCreate(algorithm, error);
    if (context == NULL) {
        return nil;
    }
    return [[self alloc] initWithContext:context];
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (instancetype)initWithContext:(XZDataDigesterContext *)context {
    self = [super init];
    if (self) {
        _isReady = YES;
        _context = context;
    }
    return self;
}

- (XZDataDigesterAlgorithm)algorithm {
    return _context->algorithm;
}

- (NSUInteger)length {
    return _context->operation->digestLength;
}

- (BOOL)reset:(NSError * _Nullable __autoreleasing *)error {
    // 既支持 -final 之后重新开始，也支持在摘要过程中丢弃已喂入的数据。
    if (_context->operation->init(_context->context) == 0) {
        _isReady = NO;
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, @"重置数据摘要算法环境失败", error);
        return NO;
    };
    // 丢弃上一次 -final 缓存的结果，避免重置后返回陈旧摘要。
    _digest = nil;
    _isReady = YES;
    return YES;
}

- (BOOL)digestBytes:(const void *)bytes length:(NSUInteger)length error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    // 必须是 Release 下也生效的运行时检查：若仅用 NSAssert，Release 编译会整条移除，
    // 导致 -final 之后新喂入的数据被无声丢弃、返回陈旧摘要。
    if (!_isReady) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeNotSupported, @"当前操作不支持：已有摘要结果，若要重新开始，须先调用 -[XZDataDigester reset] 方法。", error);
        return NO;
    }
    // length 非 0 时 bytes 不可为 NULL，否则会把空指针直接交给 CommonCrypto。
    if (bytes == NULL && length > 0) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, @"参数 bytes 不能为 NULL。", error);
        return NO;
    }
    // CC_LONG 为 32 位类型，直接把 NSUInteger 强转成它，会在单一 byte range 超过 4 GiB 时（如 mmap 读取的
    // 超大文件）发生截断，得到错误且无提示的摘要。故对超限数据分块喂入。
    const XZDataDigesterOperation *operation = _context->operation;
    while (length > 0) {
        CC_LONG const chunk = length > UINT32_MAX ? UINT32_MAX : (CC_LONG)length;
        // CommonCrypto 的 update 返回 0 表示失败，必须检查，否则会输出一份内容未定义的“摘要”。
        if (operation->update(_context->context, bytes, chunk) == 0) {
            _isReady = NO;
            XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, @"添加数据到摘要计算失败。", error);
            return NO;
        }
        bytes = (const char *)bytes + chunk;
        length -= chunk;
    }
    return YES;
}

- (BOOL)digestData:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (data == nil) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, @"参数 data 不能为 nil", error);
        return NO;
    }
    return [self digestBytes:data.bytes length:data.length error:error];
}

- (BOOL)digestString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSData *data = [string dataUsingEncoding:encoding];
    if (data == nil) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, [NSString stringWithFormat:@"字符串无法转换为指定编码(%lu)，不能添加到摘要计算中：%@", (unsigned long)encoding, string], error);
        return NO;
    }
    return [self digestData:data error:error];
}

- (BOOL)digestString:(NSString *)string error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self digestString:string encoding:NSUTF8StringEncoding error:error];
}

- (NSData *)final:(NSError * _Nullable __autoreleasing *)error {
    // 已有摘要结果时直接返回缓存，不重复触发 CommonCrypto 的 final。
    if (_digest) {
        return _digest;
    }
    if (_context->operation->final(_context->buffer, _context->context) == 0) {
        _isReady = NO;
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, @"摘要计算结束失败。", error);
        return nil;
    }
    // 成功路径同样必须落位状态：若遗漏，-final 之后继续喂入的数据会被静默并入下一次摘要，
    // 产出内容错误且无提示的摘要结果。
    _isReady = NO;
    _digest = [NSData dataWithBytes:_context->buffer length:_context->operation->digestLength];
    return _digest;
}

@end


static XZDataDigesterContext * _Nullable XZDataDigesterContextCreate(XZDataDigesterAlgorithm algorithm, NSError * _Nullable * _Nullable error) {
    const XZDataDigesterOperation *operation = XZDataDigesterOperationForAlgorithm(algorithm);
    if (operation == NULL) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, [NSString stringWithFormat:@"不支持的数据摘要算法: %ld", (long)algorithm], error);
        return NULL;
    }
    
    XZDataDigesterContext *context = malloc(sizeof(XZDataDigesterContext));
    if (context == NULL) {
        XZDataDigesterHandleError(XZDataDigesterErrorCodeMemory, @"内存不足，无法分配摘要计算所需的内存。", error);
        return NULL;
    }
    context->operation = operation;
    context->algorithm = algorithm;
    context->context   = calloc(1, operation->contextSize);
    context->buffer    = calloc(1, operation->digestLength);
    if (context->context == NULL || context->buffer == NULL) {
        XZDataDigesterContextRelease(context);
        XZDataDigesterHandleError(XZDataDigesterErrorCodeMemory, @"内存不足，无法分配摘要计算所需的内存。", error);
        return NULL;
    }

    if (operation->init(context->context) == 0) {
        XZDataDigesterContextRelease(context);
        XZDataDigesterHandleError(XZDataDigesterErrorCodeInvalidArgument, [NSString stringWithFormat:@"数据摘要算法(%ld)环境初始化失败。", (long)algorithm], error);
        return NULL;
    }
    
    return context;
}

static BOOL XZDataDigesterContextRelease(XZDataDigesterContext * _Nullable context) {
    if (context == NULL) {
        return NO;
    }
    free(context->buffer);
    free(context->context);  // 释放 CC_XX_CTX
    free(context);
    return YES;
}

static void XZDataDigesterHandleError(XZDataDigesterErrorCode code, NSString *reason, NSError * _Nullable * _Nullable error) {
    if (code == XZDataDigesterErrorCodeNoError) {
        return;
    }
    if (error != NULL) {
        *error = [NSError errorWithDomain:XZDataDigesterErrorDomain code:code userInfo:@{
            NSLocalizedFailureReasonErrorKey: reason
        }];
    }
}
