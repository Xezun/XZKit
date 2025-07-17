//
//  NSAttributedString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (XZKit)

/// 给富文本中的包含字形的字符添加字体。
/// @param font 字体
/// @param charactersInGlyphs 是否仅处理在字体中包含字型的文本 
- (NSAttributedString *)xz_attributedStringByAddingFontAttribute:(UIFont *)font forCharactersInGlyphs:(BOOL)charactersInGlyphs NS_SWIFT_NAME(addingFontAttribute(_:forCharactersInGlyphs:));

@end

@interface NSMutableAttributedString (XZKit)

/// 给富文本中的包含字形的字符添加字体。
/// @param font 字体
/// @param charactersInGlyphs 是否仅处理在字体中包含字型的文本
- (void)xz_addFontAttribute:(UIFont *)font forCharactersInGlyphs:(BOOL)charactersInGlyphs NS_SWIFT_NAME(addFontAttribute(_:forCharactersInGlyphs:));

@end

NS_ASSUME_NONNULL_END
