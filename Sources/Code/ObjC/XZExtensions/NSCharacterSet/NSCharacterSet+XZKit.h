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
/// A-Z a-z 0-9 ; , / ? : @ & = + $ - _ . ! ~ * ' ( ) #")
/// ```
///
/// - SeeAlso: [JavaScript - encodeURI](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI#description)
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

/// 由大小写字母和数字组成的字符集。
///
/// 该字符集包含的字符：
/// ```
/// A-Z a-z 0-9
/// ```
@property (class, readonly) NSCharacterSet *xz_letterAndDigitCharacterSet NS_SWIFT_NAME(letterAndDigit);

@end

NS_ASSUME_NONNULL_END
