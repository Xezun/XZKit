//
//  XZKeychainKeyItem.h
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZKeychainItem.h>
#else
#import "XZKeychainItem.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZKeychainKeyClass) {
    XZKeychainKeyClassNone,
    /// CFString kSecAttrKeyClassPublic
    XZKeychainKeyClassPublic,
    /// CFString kSecAttrKeyClassPrivate
    XZKeychainKeyClassPrivate,
    /// CFString kSecAttrKeyClassSymmetric
    XZKeychainKeyClassSymmetric,
};
typedef NS_ENUM(NSUInteger, XZKeychainKeyType) {
    XZKeychainKeyTypeNone,
    /// kSecAttrKeyTypeRSA: CFString
    XZKeychainKeyTypeRSA,
    /// kSecAttrKeyTypeDSA: CFString
    XZKeychainKeyTypeDSA API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeAES: CFString
    XZKeychainKeyTypeAES API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeDES: CFString
    XZKeychainKeyTypeDES API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyType3DES: CFString
    XZKeychainKeyType3DES API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeRC4: CFString
    XZKeychainKeyTypeRC4 API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeRC2: CFString
    XZKeychainKeyTypeRC2 API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeCAST: CFString
    XZKeychainKeyTypeCAST API_AVAILABLE(macos(10.7), ios(NA)),
    /// kSecAttrKeyTypeECDSA: CFString Deprecated
    XZKeychainKeyTypeECDSA API_AVAILABLE(macos(10.7), ios(NA)), // Elliptic curve DSA
    /// kSecAttrKeyTypeEC: CFString Deprecated
    XZKeychainKeyTypeEC, // Elliptic curve
    /// kSecAttrKeyTypeECSECPrimeRandom: CFString Elliptic curve algorithm.
    XZKeychainKeyTypeECSECPrimeRandom,
};

@protocol XZKeychainCertificateItem <NSObject>
/// kSecAttrCertificateType: CFNumberRef CSSM_CERT_TYPE cssmtype.h
@property (nonatomic) UInt32 certificateType;
/// kSecAttrCertificateEncoding
@property (nonatomic) UInt32 certificateEncoding;
/// kSecAttrSubject: CFDataRef the X.500 subject name of a certificate
@property (nonatomic, nullable) NSData *subject;
/// kSecAttrIssuer: CFDataRef the X.500 issuer name of a certificate
@property (nonatomic, nullable) NSData *issuer;
/// kSecAttrSerialNumber: CFDataRef the serial number data of a certificate
@property (nonatomic, nullable) NSData *serialNumber;
/// kSecAttrSubjectKeyID: CFDataRef the subject key ID of a certificate
@property (nonatomic, nullable) NSData *subjectKeyID;
/// kSecAttrPublicKeyHash: CFDataRef the hash of a certificate’s public key
@property (nonatomic, nullable) NSData *publicKeyHash;
@end

@protocol XZKeychainKeyItem <NSObject>
@property (nonatomic) XZKeychainKeyClass keyClass;
/// kSecAttrApplicationLabel: CFDataRef
@property (nonatomic, nullable) NSData *applicationLabel;
/// kSecAttrIsPermanent
@property (nonatomic, setter=setPermanent:) BOOL isPermanent;
/// kSecAttrApplicationTag
@property (nonatomic, nullable) NSData *applicationTag;
/// kSecAttrKeyType
@property (nonatomic) XZKeychainKeyType keyType;
/// kSecAttrKeySizeInBits
@property (nonatomic) size_t keySizeInBits;
/// kSecAttrEffectiveKeySize
@property (nonatomic) size_t effectiveKeySize;
/// kSecAttrCanEncrypt
@property (nonatomic) BOOL canEncrypt;
/// kSecAttrCanDecrypt
@property (nonatomic) BOOL canDecrypt;
/// kSecAttrCanDerive
@property (nonatomic) BOOL canDerive;
/// kSecAttrCanSign
@property (nonatomic) BOOL canSign;
/// kSecAttrCanVerify
@property (nonatomic) BOOL canVerify;
/// kSecAttrCanWrap
@property (nonatomic) BOOL canWrap;
/// kSecAttrCanUnwrap
@property (nonatomic) BOOL canUnwrap;
@end

/// 证书钥匙串，对应 kSecClassCertificate。用于存储 X.509 证书。
///
/// ## 核心属性
/// - **保存必需**：
///   - `data`（kSecValueData）——DER 编码的证书二进制数据，缺失时 SecItemAdd 返回 errSecParam。
///   - `certificateType`（kSecAttrCertificateType）——证书类型（CSSM_CERT_X_509v3 等）。
///   - `certificateEncoding`（kSecAttrCertificateEncoding）——证书编码格式。
/// - **查询主键**：`certificateType` + `certificateEncoding` + `subject` + `issuer` + `serialNumber` + `subjectKeyID` + `publicKeyHash`；实际使用中常以 `subjectKeyID` 或 `serialNumber` + `issuer` 定位。
@interface XZKeychainCertificateItem : XZKeychainItem <XZKeychainCertificateItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

/// 密钥钥匙串，对应 kSecClassKey。用于存储对称密钥、公钥或私钥。
///
/// ## 核心属性
/// - **保存必需**：
///   - `data`（kSecValueData）——密钥的二进制表示，缺失时 SecItemAdd 返回 errSecParam。
///   - `keyClass`（kSecAttrKeyClass）——密钥类别（Public / Private / Symmetric）。
///   - `keyType`（kSecAttrKeyType）——密钥算法（RSA / EC / ECSECPrimeRandom 等）。
///   - `keySizeInBits`（kSecAttrKeySizeInBits）——密钥位长。
/// - **查询主键**：`keyClass` + `applicationLabel` + `isPermanent` + `applicationTag` + `keyType` + `keySizeInBits` + `effectiveKeySize` + `canEncrypt` + `canDecrypt` + `canDerive` + `canSign` + `canVerify` + `canWrap` + `canUnwrap`；实际使用中常以 `applicationTag` + `keyClass` 定位。
/// - **推荐**：一般使用 SecKeyGeneratePair / SecKeyCreateRandomKey 生成密钥对，而非手工 SecItemAdd。
@interface XZKeychainKeyItem : XZKeychainItem <XZKeychainKeyItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

/// 身份钥匙串，对应 kSecClassIdentity。同时包含“私钥”与“证书”，因此兼具 XZKeychainKeyItem 和 XZKeychainCertificateItem 两种属性。
///
/// ## 核心属性
/// - **保存必需**：
///   - `data`（kSecValueData）——PKCS#12 或其他包含私钥+证书的数据。
///   - 证书侧：`certificateType`、`certificateEncoding`。
///   - 密钥侧：`keyClass`（必为 Private）、`keyType`、`keySizeInBits`。
/// - **查询主键**：Certificate + Key 两侧主键属性的并集；实际使用中常以证书的 `subjectKeyID` 或 `serialNumber` + `issuer` 定位。
/// - **推荐**：Identity 一般由系统导入 PKCS#12（SecPKCS12Import）或 SecIdentityCreateFromCertificate 创建，不推荐直接 SecItemAdd。
@interface XZKeychainIdentityItem : XZKeychainItem <XZKeychainCertificateItem, XZKeychainKeyItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
