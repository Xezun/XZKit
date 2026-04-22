//
//  NSAttributedString+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/10/5.
//

#import "NSAttributedString+XZKit.h"
#import "UIFont+XZKit.h"

@implementation NSAttributedString (XZKit)

- (NSAttributedString *)xz_attributedStringByAddingAttributesForCharactersDesignedInFont:(UIFont *)font {
    NSMutableAttributedString *attributedStringM = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [attributedStringM xz_addAttributesForCharactersDesignedInFont:font];
    return attributedStringM;
}

@end


@implementation NSMutableAttributedString (XZKit)

- (void)xz_addAttributesForCharactersDesignedInFont:(UIFont *)font {
    if (font == nil) {
        return;
    }
    
    [self.string xz_enumerateSubstringsDesignedInFont:font usingBlock:^(NSRange range) {
        [self addAttribute:NSFontAttributeName value:font range:range];
    }];
}

@end


