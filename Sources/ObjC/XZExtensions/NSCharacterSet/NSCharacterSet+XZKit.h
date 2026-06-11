//
//  NSCharacterSet+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (XZKit)

/// 在 URI 中允许的字符集，即进行 URI 编码时，不会被转义的字符集。
///
/// 该字符集包含以下字符：
///
/// ```
/// A–Z a–z 0–9 - _ . ! ~ * ' ( ) ; / ? : @ & = + $ , #
/// ```
///
/// - SeeAlso: [JavaScript - encodeURI](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI#description)
/// - SeeAlso: [RFC2396](https://datatracker.ietf.org/doc/html/rfc2396)
@property (class, readonly) NSCharacterSet *xz_URIAllowedCharacterSet NS_SWIFT_NAME(URIAllowed);

/// 在 URIComponent 中允许的字符集，即进行 URIComponent 编码时，不会被转义的字符集。
///
/// 该字符集包含以下字符：
///
/// ```
/// A-Z a-z 0-9 - _ . ! ~ * ' ( )
/// ```
///
/// - SeeAlso: [JavaScript - encodeURIComponent](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#description)
@property (class, readonly) NSCharacterSet *xz_URIComponentAllowedCharacterSet NS_SWIFT_NAME(URIComponentAllowed);


/// 在 URL 中允许的字符，即在 URL 中可以见到原身的字符。
///
/// 字符在 URL 中可以见到原身，但是不代表字符在 URL 中使用不需要被编码，比如“?”在 URL 中可以见到，但是如果作为 query 的值，则必须编码。
@property (class, readonly) NSCharacterSet *xz_URLAllowedCharacterSet NS_SWIFT_NAME(URLAllowedCharacterSet);

/// 由大小写字母和数字组成的字符集。
///
/// 该字符集包含的字符：
/// ```
/// A-Z a-z 0-9
/// ```
@property (class, readonly) NSCharacterSet *xz_alphaDigitCharacterSet NS_SWIFT_NAME(alphaDigit);

@end

NS_ASSUME_NONNULL_END
