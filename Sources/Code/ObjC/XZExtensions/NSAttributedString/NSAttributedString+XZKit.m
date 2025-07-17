//
//  NSAttributedString+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import "NSAttributedString+XZKit.h"
#import "UIFont+XZKit.h"

@implementation NSAttributedString (XZKit)

- (NSAttributedString *)xz_attributedStringByAddingFontAttribute:(UIFont *)font forCharactersInGlyphs:(BOOL)charactersInGlyphs {
    NSMutableAttributedString *attributedStringM = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [attributedStringM xz_addFontAttribute:font forCharactersInGlyphs:charactersInGlyphs];
    return attributedStringM;
}

@end


@implementation NSMutableAttributedString (XZKit)

- (void)xz_addFontAttribute:(UIFont *)font forCharactersInGlyphs:(BOOL)charactersInGlyphs {
    if (font == nil) {
        return;
    }
    if (charactersInGlyphs) {
        [font xz_enumerateGlyphsInString:self.string usingBlock:^(NSRange range) {
            [self addAttribute:NSFontAttributeName value:font range:range];
        }];
    } else {
        [self addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    }
}

@end


