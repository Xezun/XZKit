//
//  XZKeychainCertificateItem.h
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZKeychainCertificateType) {
    XZKeychainCertificateType1
};
typedef NS_ENUM(NSUInteger, XZKeychainCertificateEncoding) {
    XZKeychainCertificateEncoding1
};

@interface XZKeychainCertificateItem : XZKeychainItem
/// kSecAttrCertificateType: CFNumberRef CSSM_CERT_TYPE cssmtype.h
@property (nonatomic) XZKeychainCertificateType certificateType;
/// kSecAttrCertificateEncoding
@property (nonatomic) XZKeychainCertificateEncoding certificateEncoding;
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
@end

NS_ASSUME_NONNULL_END
