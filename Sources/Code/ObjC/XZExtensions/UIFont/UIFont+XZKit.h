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

/// 字体中的字形能否完全匹配字符串中的所有字符。
/// @param aString 待匹配的字符串。
- (BOOL)xz_matchesGlyphsForCharactersInString:(NSString *)aString NS_SWIFT_NAME(matchesGlyphsForCharacters(in:));

@end

NS_ASSUME_NONNULL_END
