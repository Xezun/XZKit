//
//  UIFont+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (XZKit)

/// 注册字体。
/// @param fontURL 字体路径
/// @param error 错误
+ (BOOL)xz_registerFontWithURL:(NSURL *)fontURL error:(NSError ** _Nullable)error NS_SWIFT_NAME(registerFont(with:));

/// 字体字符集。
@property (nonatomic, readonly) NSCharacterSet *xz_characterSet NS_SWIFT_NAME(characterSet);

@end

@interface NSString (XZGlyphsEnumeration)

/// 检测字符串中的所有字符，是否能在字体中都找到字形。
/// @param font 字体对象
- (BOOL)xz_isDesignedInFont:(UIFont *)font NS_SWIFT_NAME(isDesigned(in:));

/// 遍历字符串中，在字体中能找到字形的所有子串。
/// @param font 字体对象
/// @param block 遍历字符串所用的块函数，符合条件的子串在字符串中的位置 range 将通过 block 的参数提供
- (void)xz_enumerateSubstringsDesignedInFont:(UIFont *)font usingBlock:(void (^NS_NOESCAPE)(NSRange range))block NS_SWIFT_NAME(enumerateSubstringsDesigned(in:using:));

@end

NS_ASSUME_NONNULL_END
