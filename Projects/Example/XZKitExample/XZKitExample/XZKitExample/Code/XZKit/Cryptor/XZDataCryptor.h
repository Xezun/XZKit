//
//  XZDataCryptor.h
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <Foundation/Foundation.h>

// 加密或解密
typedef NS_ENUM(NSUInteger, XZDataCryptoOperation) {
    XZDataCryptoOperationEncrypt = 0,
    XZDataCryptoOperationDecrypt
};

@class XZAlgorithm;

/**
 *  对称加解密类。
 */
@interface XZDataCryptor : NSObject

/**
 *  加密数据的快速静态方法。
 *
 *  @param data      要加密的明文。
 *  @param algorithm 所使用的算法。
 *  @param key       密钥。
 *  @param error        初始化向量。
 *
 *  @return 加密得到的密文。
 */
+ (NSData *)encrypt:(NSData *)data algorithm:(XZAlgorithm *)algorithm key:(NSString *)key error:(NSError **)error;

/**
 *  解密数据。
 *
 *  @param data      待解密的密文。
 *  @param algorithm 密文所使用的算法。
 *  @param key       密钥。
 *  @param error        初始化向量
 *
 *  @return 解密得到的明文。
 */
+ (NSData *)decrypt:(NSData *)data algorithm:(XZAlgorithm *)algorithm key:(NSString *)key error:(NSError **)error;



//- (void)cryptInit:(XZDataCryptoOperation)operation;
//- (void)cryptUpdate:(NSData *)data;
//- (NSString *)cryptFinal;

@end

/** 块加密算法 */
typedef NS_OPTIONS(uint32_t, XZAlgorithmOptions) {
    XZAlgorithmOptionPKCS7Padding = 0x0001,
    XZAlgorithmOptionECBMode = 0x0002
};

typedef NS_ENUM(NSUInteger, XZAlgorithmType) {
    XZAlgorithmTypeAES128 = 0,
    XZAlgorithmTypeAES192,
    XZAlgorithmTypeAES256,
    XZAlgorithmTypeDES,
    XZAlgorithmType3DES,
    XZAlgorithmTypeCAST,
    XZAlgorithmTypeRC4,
    XZAlgorithmTypeRC2,
    XZAlgorithmTypeBlowfish
};

// 算法
@interface XZAlgorithm : NSObject

/**
 *  创建一个 XZDataCryptor 所用的算法对象。
 *
 *  @param type    算法类型
 *  @param options 块加密选项，目前 iOS 只支持 CBC 模式（默认）和 ECB 模式，支持的填充方式有 NONE （默认）、PKCS7 两种方式。
 *  @param iv      密钥初始化偏移量，在 CBC 模式下，该字符串长度为 16 字节，不足填充 '\0' ，超过无效；EBC 模式下自动忽略。
 *
 *  @return XZAlgorithm 对象
 */
+ (instancetype)algorithmWithType:(XZAlgorithmType)type options:(XZAlgorithmOptions)options iv:(NSString *)iv;
- (instancetype)initWithType:(XZAlgorithmType)type options:(XZAlgorithmOptions)options iv:(NSString *)iv;

/**
 *  使用默认参数的加密算法实例的快速创建方法。CBC 模式，PKCS7 填充。
 *
 *  @param iv 初始密钥偏移量，可选。
 *
 *  @return XZAlgorithm 对象。
 */
+ (instancetype)AES128:(NSString *)iv;
+ (instancetype)AES192:(NSString *)iv;
+ (instancetype)AES256:(NSString *)iv;

+ (instancetype)DES:(NSString *)iv;
+ (instancetype)TripleDES:(NSString *)iv;


@end




