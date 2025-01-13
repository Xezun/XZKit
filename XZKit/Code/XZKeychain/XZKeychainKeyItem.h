//
//  XZKeychainKeyItem.h
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZKeychainKeyClass) {
    /// CFString kSecAttrKeyClassPublic
    XZKeychainKeyClassPublic,
    /// CFString kSecAttrKeyClassPrivate
    XZKeychainKeyClassPrivate,
    /// CFString kSecAttrKeyClassSymmetric
    XZKeychainKeyClassSymmetric,
};
typedef NS_ENUM(NSUInteger, XZKeychainKeyType) {
    /// kSecAttrKeyTypeRSA: CFString
    XZKeychainKeyTypeRSA,
    /// kSecAttrKeyTypeDSA: CFString
    XZKeychainKeyTypeDSA,
    /// kSecAttrKeyTypeAES: CFString
    XZKeychainKeyTypeAES,
    /// kSecAttrKeyTypeDES: CFString
    XZKeychainKeyTypeDES,
    /// kSecAttrKeyType3DES: CFString
    XZKeychainKeyType3DES,
    /// kSecAttrKeyTypeRC4: CFString
    XZKeychainKeyTypeRC4,
    /// kSecAttrKeyTypeRC2: CFString
    XZKeychainKeyTypeRC2,
    /// kSecAttrKeyTypeCAST: CFString
    XZKeychainKeyTypeCAST,
    /// kSecAttrKeyTypeECDSA: CFString Deprecated
    XZKeychainKeyTypeECDSA, // Elliptic curve DSA
    /// kSecAttrKeyTypeEC: CFString Deprecated
    XZKeychainKeyTypeEC, // Elliptic curve
    /// kSecAttrKeyTypeECSECPrimeRandom: CFString Elliptic curve algorithm.
    XZKeychainKeyTypeECSECPrimeRandom,
};

@interface XZKeychainKeyItem : XZKeychainItem
/// kSecAttrKeyClass
@property (nonatomic) XZKeychainKeyClass *keyClass;
/// kSecAttrApplicationLabel: CFDataRef
@property (nonatomic) NSData *applicationLabel;
/// kSecAttrIsPermanent
@property (nonatomic) BOOL isPermanent;
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

NS_ASSUME_NONNULL_END
