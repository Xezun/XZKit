//
//  NSAttributedString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (XZKit)

/// 给富文本中包含字形的字符应用字体。
/// @param font 字体
- (NSAttributedString *)xz_attributedStringByAddingAttributesForCharactersDesignedInFont:(UIFont *)font NS_SWIFT_NAME(addingAttributeForCharacters(designedIn:));

@end

@interface NSMutableAttributedString (XZKit)

/// 给富文本中包含字形的字符应用字体。
/// @param font 字体
- (void)xz_addAttributesForCharactersDesignedInFont:(UIFont *)font NS_SWIFT_NAME(addAttributeForCharacters(designedIn:));

@end

NS_ASSUME_NONNULL_END
