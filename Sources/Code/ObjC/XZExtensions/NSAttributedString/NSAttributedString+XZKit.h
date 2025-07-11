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
- (NSAttributedString *)xz_attributedStringByAddingFontAttributeForCharatersMatchedGlyphOfFont:(UIFont *)font NS_SWIFT_NAME(addingFontAttributeForCharatersMatchedGlyph(of:));

@end

@interface NSMutableAttributedString (XZKit)

/// 给富文本中的包含字形的字符添加字体。
/// @param font 字体
- (void)xz_addFontAttributeForCharatersMatchedGlyphOfFont:(UIFont *)font NS_SWIFT_NAME(addFontAttributeForCharatersMatchedGlyph(of:));

@end

NS_ASSUME_NONNULL_END
