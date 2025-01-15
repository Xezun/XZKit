//
//  XZKeychainIdentityItem.h
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainItem.h"

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

/// 由于 XZKeychainIdentity 钥匙串同时包含“私钥”和“证书”，
/// 所以它同时具有 XZKeychainKey 和 XZKeychainCertificate 两种钥匙串的属性。
@interface XZKeychainIdentityItem : XZKeychainItem
/// kSecAttrCertificateType: CFNumberRef CSSM_CERT_TYPE cssmtype.h
@property (nonatomic) UInt32 certificateType;
/// kSecAttrCertificateEncoding
@property (nonatomic) UInt32 certificateEncoding;
/// kSecAttrSubject: CFDataRef the X.500 subject name of a certificate
@property (nonatomic) NSData *subject;
/// kSecAttrIssuer: CFDataRef the X.500 issuer name of a certificate
@property (nonatomic) NSData *issuer;
/// kSecAttrSerialNumber: CFDataRef the serial number data of a certificate
@property (nonatomic) NSData *serialNumber;
/// kSecAttrSubjectKeyID: CFDataRef the subject key ID of a certificate
@property (nonatomic) NSData *subjectKeyID;
/// kSecAttrPublicKeyHash: CFDataRef the hash of a certificate’s public key
@property (nonatomic) NSData *publicKeyHash;
// ----
/// kSecAttrKeyClass
@property (nonatomic) XZKeychainKeyClass keyClass;
/// kSecAttrApplicationLabel: CFDataRef
@property (nonatomic) NSData *applicationLabel;
/// kSecAttrIsPermanent
@property (nonatomic, setter=setPermanent:) BOOL isPermanent;
/// kSecAttrApplicationTag
@property (nonatomic) NSData *applicationTag;
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


@interface XZKeychainCertificateItem : XZKeychainIdentityItem
/// kSecAttrKeyClass
@property (nonatomic) XZKeychainKeyClass keyClass NS_UNAVAILABLE;
/// kSecAttrApplicationLabel: CFDataRef
@property (nonatomic) NSData *applicationLabel NS_UNAVAILABLE;
/// kSecAttrIsPermanent
@property (nonatomic, setter=setPermanent:) BOOL isPermanent NS_UNAVAILABLE;
/// kSecAttrApplicationTag
@property (nonatomic) NSData *applicationTag NS_UNAVAILABLE;
/// kSecAttrKeyType
@property (nonatomic) XZKeychainKeyType keyType NS_UNAVAILABLE;
/// kSecAttrKeySizeInBits
@property (nonatomic) size_t keySizeInBits NS_UNAVAILABLE;
/// kSecAttrEffectiveKeySize
@property (nonatomic) size_t effectiveKeySize NS_UNAVAILABLE;
/// kSecAttrCanEncrypt
@property (nonatomic) BOOL canEncrypt NS_UNAVAILABLE;
/// kSecAttrCanDecrypt
@property (nonatomic) BOOL canDecrypt NS_UNAVAILABLE;
/// kSecAttrCanDerive
@property (nonatomic) BOOL canDerive NS_UNAVAILABLE;
/// kSecAttrCanSign
@property (nonatomic) BOOL canSign NS_UNAVAILABLE;
/// kSecAttrCanVerify
@property (nonatomic) BOOL canVerify NS_UNAVAILABLE;
/// kSecAttrCanWrap
@property (nonatomic) BOOL canWrap NS_UNAVAILABLE;
/// kSecAttrCanUnwrap
@property (nonatomic) BOOL canUnwrap NS_UNAVAILABLE;
@end

@interface XZKeychainKeyItem : XZKeychainIdentityItem
/// kSecAttrCertificateType: CFNumberRef CSSM_CERT_TYPE cssmtype.h
@property (nonatomic) UInt32 certificateType NS_UNAVAILABLE;
/// kSecAttrCertificateEncoding
@property (nonatomic) UInt32 certificateEncoding NS_UNAVAILABLE;
/// kSecAttrSubject: CFDataRef the X.500 subject name of a certificate
@property (nonatomic) NSData *subject NS_UNAVAILABLE;
/// kSecAttrIssuer: CFDataRef the X.500 issuer name of a certificate
@property (nonatomic) NSData *issuer NS_UNAVAILABLE;
/// kSecAttrSerialNumber: CFDataRef the serial number data of a certificate
@property (nonatomic) NSData *serialNumber NS_UNAVAILABLE;
/// kSecAttrSubjectKeyID: CFDataRef the subject key ID of a certificate
@property (nonatomic) NSData *subjectKeyID NS_UNAVAILABLE;
/// kSecAttrPublicKeyHash: CFDataRef the hash of a certificate’s public key
@property (nonatomic) NSData *publicKeyHash NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
