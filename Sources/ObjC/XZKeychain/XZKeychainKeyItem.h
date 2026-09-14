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

@interface XZKeychainCertificateItem : XZKeychainItem <XZKeychainCertificateItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

@interface XZKeychainKeyItem : XZKeychainItem <XZKeychainKeyItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

/// 由于 XZKeychainIdentity 钥匙串同时包含“私钥”和“证书”，
/// 所以它同时具有 XZKeychainKey 和 XZKeychainCertificate 两种钥匙串的属性。
@interface XZKeychainIdentityItem : XZKeychainItem <XZKeychainCertificateItem, XZKeychainKeyItem>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
