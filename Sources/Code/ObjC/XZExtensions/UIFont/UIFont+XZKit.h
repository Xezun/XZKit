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

/// 字体中的字形能否完全匹配字符串中的所有字符。
/// @param aString 待匹配的字符串。
- (BOOL)xz_containsGlyphsForCharactersInString:(NSString *)aString NS_SWIFT_NAME(containsGlyphsForCharacters(in:));

/// 遍历字符串所有符合条件的子串：子串所有字符都在字体 font 存在字形。
/// @param aString 字体
/// @param block 符合条件的（最长）子串在字符串中的位置 range 将通过 block 的参数提供
- (void)xz_enumerateGlyphsForSubstringsInString:(NSString *)aString usingBlock:(void (^)(NSRange range))block NS_SWIFT_NAME(enumerateMatchesGlyphsInString(of:using:));

@end

NS_ASSUME_NONNULL_END
